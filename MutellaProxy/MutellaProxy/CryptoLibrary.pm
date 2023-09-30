#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	13.07.2006
##### Function:		
##### Todo:			DEFAULT in encrypt und decrypt löschen!!
########################################

package MutellaProxy::CryptoLibrary;

use MutellaProxy::CheckSum;
use MutellaProxy::Time;
use MutellaProxy::SQL;
use Crypt::Rijndael;
use Crypt::CBC;
use strict;

my $VERSION			= '0.22.1';

sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub GetPrivateCryptoKeyFromDatabase(){

	my $self		= shift;
	my $PublicKey	= shift;

	RESTART:

	$@ ='';
	undef $@;

	my $sth;
	my $sth2;
	my $DBHandle;
	my $ResultHashRef;
	
	eval {

		$DBHandle = MutellaProxy::SQL->SQLConnect();

		$sth = $DBHandle->prepare( qq { SELECT * FROM `Crypto` WHERE `PUBLICKEY` = "$PublicKey" AND `VALIDUNTIL` >= CURDATE() LIMIT 1; } );
		$sth->execute;
		$ResultHashRef = $sth->fetchrow_hashref;
		$sth->finish;

		# update den hits counter, der den zugriff auf den jeweiligen cryptoschlüssel zählt
		my $NEWHITS = $ResultHashRef->{'HITS'} + 1;
		$sth2	= $DBHandle->prepare( qq { UPDATE `Crypto` SET `HITS` = "$NEWHITS" WHERE `PUBLICKEY` = "$PublicKey" AND `VALIDUNTIL` >= CURDATE() LIMIT 1; } );
		$sth2->execute;
		$sth2->finish;

	};

	if ( $@ ) {
		print "ERROR: $@ - Restarting $self->InstallLicenceToDataBase( ) \n";
		select(undef, undef, undef, 0.1 );
		goto RESTART;
	};

	

	if ( length($ResultHashRef->{'PRIVATEKEY'}) == 32 ){
		return $ResultHashRef->{'PRIVATEKEY'};
	} else {
		return -1;	# error
	};

	return -1;	# always return error for default

}; # sub GetPrivateCryptoKeyFromDatabase(){}


sub Encrypt(){

	my $self		= shift;
	my $key			= shift;
	my $PlainText	= shift;

	if ( length($PlainText) != 0 && ref($PlainText) eq 'SCALAR' ) {
		my $cipher	= $self->CreateCryptoObject( $key );
		return $cipher->encrypt( ${$PlainText} );
	} elsif ( length($PlainText) != 0 && ref($PlainText) eq '' ) {
		my $cipher	= $self->CreateCryptoObject( $key );
		return $cipher->encrypt( $PlainText );
	} else { 
		return -1;	
	}; # if ( length($PlainText) != 0 ) {}

}; # sub Encrypt(){}


sub Decrypt(){
	
	my $self			= shift;
	my $key				= shift;
	my $EncryptedText	= shift;

	if ( length($EncryptedText) != 0 && ref($EncryptedText) eq 'SCALAR' ) {
		my $cipher		= $self->CreateCryptoObject( $key );
		return $cipher->decrypt( ${$EncryptedText} );
	} elsif ( length($EncryptedText) != 0 && ref($EncryptedText) eq '' ) {
		my $cipher		= $self->CreateCryptoObject( $key );
		return $cipher->decrypt( $EncryptedText );
	} else {
		return -1;	
	};

}; # sub Decrypt(){}


sub CreateCryptoObject(){

	my $self	= shift;
	my $key		= shift;

	my $cipher = Crypt::CBC->new(
				-key			=> $key,
				-cipher			=> 'Crypt::Rijndael',
				-salt			=> '1',
				-padding		=> 'standard',
               	-keysize        => '32',
				-blocksize		=> '16',
                -header			=> 'salt');

	return $cipher;

}; # sub CreateCryptoObject(){}


##############################
########### RANDOM ###########
##############################


sub SimpleRandom(){

	my $self = shift;

	srand();
	return int(rand(900000000))+1;

}; # sub SimpleRandom(){}


sub URandom(){
	
	srand();

	my $self		= shift;
	my $KeyLengh	= shift || int(rand(8096))+1;

	return MutellaProxy::IO->readRandomBytes( $KeyLengh );

}; # sub URandom(){}


sub SimpleURandom(){

	srand();

	my $self	= shift;
	my $length	= shift || int(rand(8096))+1;
	my $rand	= $self->SimpleRandom();

	return pack("C*",map {rand($rand)} 1..$length);
	
}; # sub SimpleURandom(){}


sub GenerateTemporaryKey(){

	my $self	= shift;
	my @array	= ( 'A', 'B', 'C', 'D', 'E', 'F' ,'G','H','I' ,'J' ,'K' ,'0' ,'1' ,'2' ,'3' ,'4' ,'5' ,'6' ,'7' ,'8' ,'9' ,'!','#' ,'*' ,'Ü' ,'Ö' ,'Ä','a' ,'b' ,'c' ,'d' ,'e' ,'f' );
	
	return $self->ShuffleArrayAdvanced( \@array );
		
}; # sub GenerateTemporaryKey(){}


sub ShuffleArrayAdvanced(){
	
	srand();

	my $self	= shift;
	my $array	= shift;
	
	my $i; my $one_line;

	for ($i = @{$array}; --$i;){
		my $j = int(rand($i+1));
		next if $i == $j;
		@{$array}[$i,$j] = @{$array}[$j,$i];
	};

	foreach my $content ( @{$array} ) {
		$one_line = $one_line . $content;
	};

	return $one_line;

}; # sub ShuffleArrayAdvanced(){}


sub ShuffleArray(){
	
	srand();

	my $self	= shift;
	my $array	= shift;
	
	my $i;

	for ($i = @{$array}; --$i;){
		my $j = int(rand($i+1));
		next if $i == $j;
		@{$array}[$i,$j] = @{$array}[$j,$i];
	};

	return $array;

}; # sub ShuffleArray(){}


return 1;