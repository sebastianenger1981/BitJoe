#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	13.07.2006
##### Function:		
##### Todo:			DEFAULT in encrypt und decrypt löschen!!
########################################

package PhexProxy::CryptoLibrary;

use PhexProxy::CheckSum;
use PhexProxy::Time;
#use Crypt::Rijndael;
#use PhexProxy::SQL;
use PhexProxy::IO;
use IO::Socket;
#use Crypt::CBC;
use strict;
no strict "subs";
# use Data::Dumper;


my $VERSION				= '0.30.0';
use constant CRYPT		=> "/usr/bin/java /srv/server/phexproxy/decrypt/Crypt";
use constant DECRYPT	=> "/usr/bin/java /srv/server/phexproxy/decrypt/Decrypt";

my %CryptoHashRef		= ( 
	# public => privatekey
	'0123456789abcdef0123456789abcdef'	=> '!123456789abcdef0123456789abcdef',
	'399e8c5b89f81fd31a9341f1e6c539d7'	=> '380971de720bf96f51d372441d4cacf3'
);


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}



sub GetPrivateCryptoKeyFromDatabase(){

	my $self		= shift;
	my $PublicKey	= shift;

#	print "\n\n\n PublicKey=$PublicKey \n\n\n";
#	print Dumper %CryptoHashRef;
#	print $CryptoHashRef{$PublicKey};
#	print "\n";

	if ( exists($CryptoHashRef{$PublicKey}) ) {
		return $CryptoHashRef{$PublicKey};
	} else {
		return -1;
	}; # if ( exists($CryptoHashRef{$PublicKey}) ) {


#	my $sth;
#	my $sth2;
#	my $DBHandle;
#	my $ResultHashRef;
#	
#	eval {
#
#		$DBHandle = PhexProxy::SQL->SQLConnect();
#	#	$sth = $DBHandle->prepare( qq { SELECT * FROM `Crypto` WHERE `PUBLICKEY` = "$PublicKey" AND `VALIDUNTIL` >= CURDATE() LIMIT 1; } );
#	###	$sth = $DBHandle->prepare( qq { SELECT `PRIVATEKEY` FROM `licence` WHERE `PUBLICKEY` = "$PublicKey" AND `VALIDUNTIL` >= CURDATE() LIMIT 1; } );
#		$sth = $DBHandle->prepare( qq { SELECT `PRIVATEKEY` FROM `licence` WHERE `PUBLICKEY` = "$PublicKey" LIMIT 1; } );
#		$sth->execute;
#		$ResultHashRef = $sth->fetchrow_hashref;
#		$sth->finish;

###		# update den hits counter, der den zugriff auf den jeweiligen cryptoschlüssel zählt
###		my $NEWHITS = $ResultHashRef->{'HITS'} + 1;
###		$sth2	= $DBHandle->prepare( qq { UPDATE `Licence` SET `HITS` = "$NEWHITS" WHERE `PUBLICKEY` = "$PublicKey" AND `VALIDUNTIL` >= CURDATE() LIMIT 1; } );
###		$sth2->execute;
###		$sth2->finish;

#	};
#
#	if ( length($ResultHashRef->{'PRIVATEKEY'}) == 32 && ref($ResultHashRef) eq 'HASH' ){
#		
#		return $ResultHashRef->{'PRIVATEKEY'};
#
#	} else {
#
#		return -1;	# error
#
#	};

	return -1;	# always return error for default

}; # sub GetPrivateCryptoKeyFromDatabase(){}


sub Encrypt(){

	my $self			= shift;
	my $key				= shift;
	my $PlainText		= shift;
	my $returnString	= "";

	my $IO				= PhexProxy::IO->new();
	my $socket			= IO::Socket::INET->new( PeerAddr => "127.0.0.1",
												 PeerPort => 2222,
												 Proto    => "tcp",
												 Type     => SOCK_STREAM)
    or die "Couldn't connect to encrypt Server : $@\n";

	$IO->writeSocket($socket, "$key:$PlainText");
	$IO->writeSocket($socket, "\r\n");
	my $returnString = $IO->readSocket($socket);
	
	close($socket);
	$IO = "";

	return $returnString;

#	if ( length($PlainText) != 0 && ref($PlainText) eq 'SCALAR' ) {
#	#	my $cipher	= $self->CreateCryptoObject( $key );
#	#	return $cipher->encrypt( ${$PlainText} );
#		return `CRYPT $key ${$PlainText}`;
#	} elsif ( length($PlainText) != 0 && ref($PlainText) eq '' ) {
#	#	my $cipher	= $self->CreateCryptoObject( $key );
#	#	return $cipher->encrypt( $PlainText );
#		return `CRYPT $key $PlainText`;
#	} else { 
#		return -1;	
#	}; # if ( length($PlainText) != 0 ) {}

}; # sub Encrypt(){}


sub Decrypt(){
	
	my $self			= shift;
	my $key				= shift;
	my $EncryptedText	= shift;
	my $returnString	= "";

	my $IO				= PhexProxy::IO->new();
	my $socket			= IO::Socket::INET->new( PeerAddr => "127.0.0.1",
												 PeerPort => 1111,
												 Proto    => "tcp",
												 Type     => SOCK_STREAM)
    or die "Couldn't connect to decrypt Server : $@\n";

	$IO->writeSocket($socket, "$key:$EncryptedText");
	$IO->writeSocket($socket, "\r\n");
	my $returnString = $IO->readSocket($socket);
	
	close($socket);
	$IO = "";

	return $returnString;

	# ... do something with the socket
#	print $socket "#123456789abcdef0123456789abcdef:cb49a5ce4b966a3824b110e8ace2b0e7eaab0d71b977d087cc22ebe856fcc7997f7d969e25dc93b5223262c6f82f3fb6c43274860d33fc464cdeb2321c5bb05a42d46de4ecaf3d6afd7261b39cf89c99";
	#print $socket "\r\n";

	#while ( <$socket>) {
	#	$returnString .= $_;
	#	print "$_\n";
	#};


#	if ( length($EncryptedText) != 0 && ref($EncryptedText) eq 'SCALAR' ) {
#	#	my $cipher		= $self->CreateCryptoObject( $key );
#	#	return $cipher->decrypt( ${$EncryptedText} );
#		return `DECRYPT $key ${$EncryptedText}`;
#	} elsif ( length($EncryptedText) != 0 && ref($EncryptedText) eq '' ) {
#	#	my $cipher		= $self->CreateCryptoObject( $key );
#	#	return $cipher->decrypt( $EncryptedText );
#		return `DECRYPT $key $EncryptedText`;
#	} else {
#		return -1;	
#	};

}; # sub Decrypt(){}


sub CreateCryptoObject(){

#	my $self	= shift;
#	my $key		= shift;
#
#	my $cipher = Crypt::CBC->new(
#				-key			=> $key,
##				-cipher			=> 'Crypt::Rijndael',
#				-salt			=> '1',
#				-padding		=> 'standard',
#              	-keysize        => '32',
#				-blocksize		=> '16',
#               -header			=> 'salt');
#
#	return $cipher;

}; # sub CreateCryptoObject(){}


##############################
########### RANDOM ###########
##############################


sub SimpleRandom(){

	my $self = shift;

	srand();
	return rand(90000);

}; # sub SimpleRandom(){}


sub URandom(){
	
	srand();

	my $self		= shift;
	my $KeyLengh	= shift || int(rand(98096))+8096;

	return PhexProxy::IO->readRandomBytes( $KeyLengh );

}; # sub URandom(){}


sub SimpleURandom(){

	srand();

	my $self	= shift;
	my $length	= shift || int(rand(98096))+8096;
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


sub UniqueID(){

	# returns unique 32 Bit id

	my $self	= shift;
	my $length	= 512;

	my @source	= ('A'..'Z', 'a'..'z', '0'..'9');
	my $tmp		= "";
	my $id		= "";


	for(my $i=0; $i<$length; ){

		my $j = chr(int(rand(127)));

		if( $j =~ /[a-zA-Z0-9]/ ){
			
			$tmp .=$j;
			$i++;

		}; # if( $j =~ /[a-zA-Z0-9]/ ){

	}; # for(my $i=0; $i<$length; ){

	for (1..$length) {
		$id .= $source[rand @source];
	};
	
	return PhexProxy::CheckSum->md5_hex( $tmp . time() . $$ . rand(8096) . $id . $self->URandom(1024) );

}; # sub UniqueID(){

return 1;