#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		LicenceTransfer
##### Todo:			
########################################


# my $scpe = Net::SCP::Expect->new(host=>'85.214.59.105', user=>'root', password=>'PQdfqZHr');
# $scpe->auto_yes(1);
# $scpe->scp('/server/mutella/MutellaProxy_V0.1.9.pl','root@85.214.59.105:/root/');

package PhexProxy::LicenceTransfer;

use PhexProxy::CryptoLibrary;
use PhexProxy::CheckSum;
use PhexProxy::Mail;
use PhexProxy::Time;
use PhexProxy::SQL;
use PhexProxy::IO;
use Net::SCP::Expect;		#  perl -MCPAN -e 'install "Net::SCP::Expect"' 
use strict;

my $VERSION					= '0.20.1';

mkdir '/server/phexproxy/LICENCE';
mkdir '/server/phexproxy/LICENCE/ENCRYPTED';
mkdir '/server/phexproxy/LICENCE/DECRYPTED';

my $LICENCEPATH				= '/server/phexproxy/LICENCE';				# todo: config auslesen
my $CRYPTOLICENCEPATH		= '/server/phexproxy/LICENCE/ENCRYPTED';	# todo: config auslesen
my $DECRYPTEDLICENCEPATH	= '/server/phexproxy/LICENCE/DECRYPTED';
my $CRYPTOKEY				= '12341234123412341234123412342341';	# todo: config auslesen

# Definiere einen Config Hash - hier stehen alle Username,Passwords u. Hostnames drinne, zu denen die verschlüsselten Daten übertragen werden sollen
my %ConfigHash =(
	"1"	=> my $CfG1 = { 
			"HOST"	=> "85.214.59.105",
			"USER"	=> "root",
			"PASS"	=> "PQdfqZHr",
			"PATH"	=> "/server/mutella/"
			},
#	"2"	=> my $CfG2 = { 
#			"HOST"	=> "HOSTIP",
#			"USER"	=> "USERNAME",
#			"PASS"	=> "PASSWORD",
#			"PATH"	=> "/root/.mutella"	 # wo soll es gespeichert werden
#			}, 
);


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


###########################################
################# Verschlüsselung #########
###########################################

#### [Lizenzserver T=0 ] ####

sub EncryptLicenceForTransfer(){

	my $self		= shift;
	
	my $CurTime		= PhexProxy::Time->SimpleMySQLDateTime();
	my $FileCrypto	= "$LICENCEPATH/$CurTime-CryptoSQL.txt";
	my $FileLicence	= "$LICENCEPATH/$CurTime-LicenceSQL.txt";

	my $FileCryptoEncrypted	 = "$CRYPTOLICENCEPATH/$CurTime-CryptoSQL.txt.encrypted";
	my $FileLicenceEncrypted = "$CRYPTOLICENCEPATH/$CurTime-LicenceSQL.txt.encrypted";

	my $FileContent;
	my $ErrorCount = 0;

	my $MailConfigHashRef = {
		'TO1'		=> 'thecerial@gmail.com',
	#	'TO2'		=> 'torsten.morgenroth@gmail.com',
		'SUBJECT'	=> 'MD5 - Werte verschlüsselten Lizenzdaten vom ' . PhexProxy::Time->MySQLDateTime(),
		'BODY'		=> '',
	};

	my $ContentScalarRef1		= PhexProxy::IO->ReadFileIntoScalar( $FileCrypto );
	my $Crypted					= PhexProxy::CryptoLibrary->Encrypt( $CRYPTOKEY, $ContentScalarRef1 );
	my $MD5ofCryptedContent1	= PhexProxy::CheckSum->MD5ToHEX($Crypted);
	
	PhexProxy::IO->WriteFile( $FileCryptoEncrypted, \$Crypted );

	my $ContentScalarRef2		= PhexProxy::IO->ReadFileIntoScalar( $FileLicence ); 
	my $Crypted					= PhexProxy::CryptoLibrary->Encrypt( $CRYPTOKEY, $ContentScalarRef2 );
	my $MD5ofCryptedContent2	= PhexProxy::CheckSum->MD5ToHEX($Crypted);
	
	PhexProxy::IO->WriteFile( $FileLicenceEncrypted, \$Crypted );
					
	$MailConfigHashRef->{'BODY'} = "MD5 Werte der CryptoDaten $FileCryptoEncrypted: $MD5ofCryptedContent1\n";

	PhexProxy::Mail->SendMail( $MailConfigHashRef );

	$MailConfigHashRef->{'BODY'} = "MD5 Werte der CryptoDaten $FileLicenceEncrypted: $MD5ofCryptedContent2\n";

	PhexProxy::Mail->SendMail( $MailConfigHashRef );
	
	return 1;


}; # sub EncryptLicenceForTransfer(){}


sub DecryptLicence(){

	my $self		= shift;

	my $CurTime		= PhexProxy::Time->SimpleMySQLDateTime();
	my $FileCryptoEncrypted		= "$CRYPTOLICENCEPATH/$CurTime-CryptoSQL.txt.encrypted";
	my $FileLicenceEncrypted	= "$CRYPTOLICENCEPATH/$CurTime-LicenceSQL.txt.encrypted";

	my $FileCryptoDecrypted		= "$DECRYPTEDLICENCEPATH/$CurTime-CryptoSQL.txt";
	my $FileLicenceDecrypted	= "$DECRYPTEDLICENCEPATH/$CurTime-LicenceSQL.txt"; 
	
	my $FileContent;

	my $ContentScalarRef	= PhexProxy::IO->ReadFileIntoScalar( $FileCryptoEncrypted ); 
	my $PlainText			= PhexProxy::CryptoLibrary->Decrypt( $CRYPTOKEY, $ContentScalarRef );
	
	PhexProxy::IO->WriteFile( $FileCryptoDecrypted, \$PlainText );	

	my $ContentScalarRef	= PhexProxy::IO->ReadFileIntoScalar( $FileLicenceEncrypted ); 
	my $PlainText			= PhexProxy::CryptoLibrary->Decrypt( $CRYPTOKEY, $ContentScalarRef );
	
	PhexProxy::IO->WriteFile( $FileLicenceDecrypted, \$PlainText );	

	return 1;

}; # sub DecryptLicence(){}


###########################################
################# Transfer ################
###########################################

#### [Lizenzserver T=0 ] ####

sub TransferEncryptedContent(){
	
	my $self		= shift;
	my $StatusFlag;

	RESTARTSUBROUTINE:
	$StatusFlag = $self->EncryptLicenceForTransfer();
	
	if ( $StatusFlag == -1 ) {	# Error
		select(undef, undef, undef, 0.3 );
		goto RESTARTSUBROUTINE;
	};

	my $CurTime				 = PhexProxy::Time->SimpleMySQLDateTime();
	my $FileCryptoEncrypted	 = "$CRYPTOLICENCEPATH/$CurTime-CryptoSQL.txt.encrypted";
	my $FileLicenceEncrypted = "$CRYPTOLICENCEPATH/$CurTime-LicenceSQL.txt.encrypted";

	# von A nach B kopieren
	while ( my ($key, $value) = each(%ConfigHash) ) {

		my $RemoteUserName	= $value->{ 'USER' };
		my $RemotePassword	= $value->{ 'PASS' };
		my $RemoteHostname	= $value->{ 'HOST' };
		my $RemoteStorePath	= $value->{ 'PATH' };

		# print "SCP: $RemoteUserName $RemotePassword $RemoteHostname $RemoteStorePath\n";

		my $SCP = Net::SCP::Expect->new(
			host => "$RemoteHostname",
			user => "$RemoteUserName",
			password => "$RemotePassword" );

		$SCP->auto_yes(1);
		$SCP->scp("$FileCryptoEncrypted","$RemoteUserName\@$RemoteHostname:$RemoteStorePath");
		$SCP->scp("$FileLicenceEncrypted","$RemoteUserName\@$RemoteHostname:$RemoteStorePath");
		undef $SCP;

	}; # while (my ($key, $value) = each(%ConfigHash) ) {}

  return 1;

}; # sub TransferEncryptedContent(){}


###########################################
################# Checking ################
###########################################

#### [[Proxyserver T=? ] ####

sub CheckIfEncryptedFileExists(){

	my $self		= shift;
	my $FilePath	= shift || $CRYPTOLICENCEPATH;

	my $CurTime				 = PhexProxy::Time->SimpleMySQLDateTime();
	my $FileCryptoEncrypted	 = "$FilePath/$CurTime-CryptoSQL.txt.encrypted";
	my $FileLicenceEncrypted = "$FilePath/$CurTime-LicenceSQL.txt.encrypted";

	my $StatusFlag = 0;

	if ( -e $FileCryptoEncrypted ) {
		$StatusFlag++;
	} elsif ( !-e $FileCryptoEncrypted ) {
		print "$0 -> PhexProxy::LicenceTransfer->CheckIfEncryptedFileExists(): File '$FileCryptoEncrypted' does not exist -> Exit now!\n";
		return -1;
	};

	if ( -e $FileLicenceEncrypted ) {
		$StatusFlag++;
	} elsif ( !-e $FileLicenceEncrypted ) {
		print "$0 -> PhexProxy::LicenceTransfer->CheckIfEncryptedFileExists(): File '$FileCryptoEncrypted' does not exist -> Exit now!\n";
		return -1;
	};

	return $StatusFlag;

	# if return == -1 then send mail

}; # sub CheckIfEncryptedFileExists(){}


sub SendCheckSumOfFiles(){

	my $self		= shift;
	my $FilePath	= shift || $CRYPTOLICENCEPATH;

	my $CurTime				 = PhexProxy::Time->SimpleMySQLDateTime();
	my $FileCryptoEncrypted	 = "$FilePath/$CurTime-CryptoSQL.txt.encrypted";
	my $FileLicenceEncrypted = "$FilePath/$CurTime-LicenceSQL.txt.encrypted";
	
	my $FileContent;
	
	my $MailConfigHashRef = {
		'TO1'		=> 'thecerial@gmail.com',
		#'TO2'		=> 'torsten.morgenroth@gmail.com',
		'SUBJECT'	=> 'MD5 - Werte verschlüsselten Lizenzdaten vom ' . PhexProxy::Time->MySQLDateTime(),
		'BODY'		=> '',
	};

	my $ContentScalarRef	= PhexProxy::IO->ReadFileIntoScalar( $FileCryptoEncrypted ); 
	my $CheckSum			= PhexProxy::CheckSum->MD5ToHEX( $ContentScalarRef );

	$MailConfigHashRef->{'BODY'} = "MD5 Werte der CryptoDaten $FileCryptoEncrypted: $CheckSum\n";
	PhexProxy::Mail->SendMail( $MailConfigHashRef );

	my $ContentScalarRef	= PhexProxy::IO->ReadFileIntoScalar( $FileLicenceEncrypted ); 
	my $CheckSum			= PhexProxy::CheckSum->MD5ToHEX( $ContentScalarRef );

	$MailConfigHashRef->{'BODY'} = "MD5 Werte der CryptoDaten $FileLicenceEncrypted: $CheckSum\n";
	PhexProxy::Mail->SendMail( $MailConfigHashRef );

	return 1;

}; # sub SendCheckSumOfFiles(){}


###########################################
############### SQL-Installation  #########
###########################################

sub InstallLicenceToDataBase(){

	my $self	= shift;
	my $CurTime	= PhexProxy::Time->SimpleMySQLDateTime();
	my $DBHandle;

	my $FileCryptoDecrypted		= "$DECRYPTEDLICENCEPATH/$CurTime-CryptoSQL.txt";
	my $FileLicenceDecrypted	= "$DECRYPTEDLICENCEPATH/$CurTime-LicenceSQL.txt"; 
	

	$@ ='';
	undef $@;

	eval {
		$DBHandle = PhexProxy::SQL->SQLConnect();
	};

	if ( $@ ) {
		print "ERROR: $@ - Restarting $self->InstallLicenceToDataBase( ) \n";
		select(undef, undef, undef, 0.1 );
		$self->InstallLicenceToDataBase();
	};


	my $ContentArrayRef1 = PhexProxy::IO->ReadFileIntoArray( $FileCryptoDecrypted );
	my $ContentArrayRef2 = PhexProxy::IO->ReadFileIntoArray( $FileLicenceDecrypted );

	foreach my $entry ( @{$ContentArrayRef1} ) {
	
		next if ( $entry !~ /INSERT/i ); # hier ändern, wenn ein anderer sql befehl um einfügen der daten verwendet wird
		$entry =~ s/^[\s]//;
		$entry =~ s/$[\s]//;
		chomp($entry);

		
		$@ ='';
		undef $@;

		my $sth;
		eval {
			$sth = $DBHandle->prepare( qq {$entry} );
			$sth->execute;
			$sth->finish;
		};

		if ( $@ ) {
			print "ERROR: $@ - Restarting $self->InstallLicenceToDataBase( ) \n";
			select(undef, undef, undef, 0.1 );
			$self->InstallLicenceToDataBase();
		};


	}; # foreach my $entry ( ) {}

	foreach my $entry ( @{$ContentArrayRef2} ) {
	
		next if ( $entry !~ /INSERT/i ); # hier ändern, wenn ein anderer sql befehl um einfügen der daten verwendet wird
		$entry =~ s/^[\s]//;
		$entry =~ s/$[\s]//;
		chomp($entry);
		

		$@ ='';
		undef $@;

		my $sth;
		eval {
			$sth = $DBHandle->prepare( qq {$entry} );
			$sth->execute;
			$sth->finish;
		};

		if ( $@ ) {
			print "ERROR: $@ - Restarting $self->InstallLicenceToDataBase( ) \n";
			select(undef, undef, undef, 0.1 );
			$self->InstallLicenceToDataBase();
		};


	}; # foreach my $entry ( ) {}

	return 1;

}; # sub InstallLicenceToDataBase(){}


###########################################
############### SQL-Überprüfung ###########
###########################################


sub TestInstalledLicence(){

	# Wichtig:! Routine optimiert auf genau 9 verschiedene Lizenzen (0-8)

	my $self		= shift;
	my $DBHandle 	= PhexProxy::SQL->SQLConnect();
	my $ValidUntil	= PhexProxy::Time->GetValid8DayDateForLicence();


	$@ ='';
	undef $@;

	my $sth;
	my $sth2;
	my $ResultHashRef;
	my $ResultHashRef2;

	eval {
		
		$sth = $DBHandle->prepare( qq { SELECT * FROM `Licence` WHERE `VALIDUNTIL` = "$ValidUntil" } );
		$sth->execute;
		$ResultHashRef = $sth->fetchrow_hashref;
		$sth->finish;

		$sth2 = $DBHandle->prepare( qq { SELECT * FROM `Crypto` WHERE `VALIDUNTIL` = "$ValidUntil" } );
		$sth2->execute;
		$ResultHashRef2 = $sth2->fetchrow_hashref;
		$sth2->finish;
	};

	if ( $@ ) {
		print "ERROR: $@ - Restarting $self->InstallLicenceToDataBase( ) \n";
		select(undef, undef, undef, 0.1 );
		$self->TestInstalledLicence();
	};

	

	if ( keys(%{$ResultHashRef}) == 8 && keys(%{$ResultHashRef2}) == 8 ) {
		my $MailConfigHashRef = {
			'TO1'		=> 'thecerial@gmail.com',
			'SUBJECT'	=> 'Lizenzdaten korrekt installiert ' . PhexProxy::Time->MySQLDateTime(),
			'BODY'		=> '',
		};
		PhexProxy::Mail->SendMail( $MailConfigHashRef );
		return 1;
	} else {
		my $MailConfigHashRef = {
			'TO1'		=> 'thecerial@gmail.com',
			'SUBJECT'	=> 'Lizenzdaten nicht richtig installiert ' . PhexProxy::Time->MySQLDateTime(),
			'BODY'		=> '',
		};
		PhexProxy::Mail->SendMail( $MailConfigHashRef );
		return 0;
	};
   
}; # sub TestInstalledLicence(){}

return 1;