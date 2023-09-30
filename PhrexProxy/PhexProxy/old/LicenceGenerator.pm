#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		Lizenzen generieren
##### Todo:			
########################################

package PhexProxy::LicenceGenerator;
  
use PhexProxy::CryptoLibrary;
use PhexProxy::CheckSum;
use PhexProxy::Phex;
use PhexProxy::Debug;
use PhexProxy::Time;
use PhexProxy::SQL;
use strict;

# todo: hier alle sql werte anpassen und die sql für den private/public key mit einbauen

my $VERSION				= '0.21.0';
my $LICENCESTOREPATH	= '/server/phexproxy/LICENCE';	mkdir $LICENCESTOREPATH;  # later Config

# diese werte müssen ensprechend geändert werden
my $ClientCurrentMin	= "1.0";
my $ClientCurrentMax	= "1.1";


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub GenerateALLLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();		
	my $PRIVATEKEY		= $self->GenerateLicence();	
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "1", "1", "1", "1", "1", "1", "$MySQLDateTime", "0");
END_OF_SQL

	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateALLLicenceForToday(){}


sub GenerateKombiJavaMP3LicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();	
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();	
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "1", "0", "0", "1", "0", "$MySQLDateTime", "0");
END_OF_SQL

	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateKombiJavaMP3LicenceForToday(){}


sub GenerateKombiKlingelDocuLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();	
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "0", "1", "0", "0", "1", "$MySQLDateTime", "0");
END_OF_SQL

	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateKombiKlingelDocuLicenceForToday(){}

sub GenerateKombiBilderVideoLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();	
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "1", "0", "0", "1", "0", "0", "$MySQLDateTime", "0");
END_OF_SQL

	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateKombiBilderVideoLicenceForToday(){}


sub GenerateDocuLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "0", "0", "0", "0", "1", "$MySQLDateTime", "0");
END_OF_SQL

	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateDocuLicenceForToday(){}


sub GenerateJavaLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();		
	my $PRIVATEKEY		= $self->GenerateLicence();
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "0", "0", "0", "1", "0", "$MySQLDateTime", "0");
END_OF_SQL
	
	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateJavaLicenceForToday(){}


sub GenerateVideoLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "0", "0", "1", "0", "0", "$MySQLDateTime", "0");
END_OF_SQL
	
	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateVideoLicenceForToday(){}


sub GenerateKlingelLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "0", "1", "0", "0", "0", "$MySQLDateTime", "0");
END_OF_SQL

	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateKlingelLicenceForToday(){}


sub GenerateMP3LicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "0", "1", "0", "0", "0", "0", "$MySQLDateTime", "0");
END_OF_SQL
	
	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateMP3LicenceForToday(){}


sub GenerateBildLicenceForToday(){

	my $self			= shift;
	my $Licence			= $self->GenerateLicence();		
	my $PUBLICKEY		= $self->GenerateLicence();
	my $PRIVATEKEY		= $self->GenerateLicence();
	my $ValidUntil		= PhexProxy::Time->GetValid8DayDateForLicence();
	my $MySQLDateTime	= PhexProxy::Time->MySQLDateTime();

	my $LICENCE=<<END_OF_SQL;
INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` ) VALUES ( "", "$Licence", "$ClientCurrentMin", "$ClientCurrentMax", "$ValidUntil", "1", "0", "0", "0", "0", "0", "$MySQLDateTime", "0");
END_OF_SQL
	
	my $CRYPTO=<<END_OF_PUBLICKKEY;
INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` ) VALUES ( "", "$PUBLICKEY", "$PRIVATEKEY", "$ValidUntil", "$MySQLDateTime", "0");	
END_OF_PUBLICKKEY

	return ($LICENCE, $CRYPTO);

}; # sub GenerateBildLicenceForToday(){}


sub AddLicenceToSQL(){

	my $self = shift;
	
	my ($LICENCE1, $CRYPTO1)	= $self->GenerateBildLicenceForToday();
	my ($LICENCE2, $CRYPTO2)	= $self->GenerateMP3LicenceForToday();
	my ($LICENCE3, $CRYPTO3)	= $self->GenerateKlingelLicenceForToday();
	my ($LICENCE4, $CRYPTO4)	= $self->GenerateVideoLicenceForToday();
	my ($LICENCE5, $CRYPTO5)	= $self->GenerateJavaLicenceForToday();
	my ($LICENCE6, $CRYPTO6)	= $self->GenerateDocuLicenceForToday();
	my ($LICENCE7, $CRYPTO7)	= $self->GenerateKombiKlingelDocuLicenceForToday();
	my ($LICENCE8, $CRYPTO8)	= $self->GenerateKombiJavaMP3LicenceForToday();
	my ($LICENCE9, $CRYPTO9)	= $self->GenerateALLLicenceForToday();
	my ($LICENCE10, $CRYPTO10)	= $self->GenerateKombiBilderVideoLicenceForToday();

	$self->SaveLicenceSQLToFile( \$LICENCE1 );	   # übergebe eine scalarreferenz!
	$self->SaveLicenceSQLToFile( \$LICENCE2 );
	$self->SaveLicenceSQLToFile( \$LICENCE3 );
	$self->SaveLicenceSQLToFile( \$LICENCE4 );
	$self->SaveLicenceSQLToFile( \$LICENCE5 );
	$self->SaveLicenceSQLToFile( \$LICENCE6 );
	$self->SaveLicenceSQLToFile( \$LICENCE7 );
	$self->SaveLicenceSQLToFile( \$LICENCE8 );
	$self->SaveLicenceSQLToFile( \$LICENCE9 );
	$self->SaveLicenceSQLToFile( \$LICENCE10 );

	$self->SaveCryptoSQLToFile( \$CRYPTO1 );
	$self->SaveCryptoSQLToFile( \$CRYPTO2 );
	$self->SaveCryptoSQLToFile( \$CRYPTO3 );
	$self->SaveCryptoSQLToFile( \$CRYPTO4 );
	$self->SaveCryptoSQLToFile( \$CRYPTO5 );
	$self->SaveCryptoSQLToFile( \$CRYPTO6 );
	$self->SaveCryptoSQLToFile( \$CRYPTO7 );
	$self->SaveCryptoSQLToFile( \$CRYPTO8 );
	$self->SaveCryptoSQLToFile( \$CRYPTO9 );
	$self->SaveCryptoSQLToFile( \$CRYPTO10 );

	RESTARTFUNCTION:

	my $DBHandle;

	$@ ='';
	undef $@;

	eval {

		$DBHandle = PhexProxy::SQL->SQLConnect();

		# hole die lizenzinformationen aus der datenbank
		my $sth1	= $DBHandle->prepare( qq {$LICENCE1} );
		my $sth2	= $DBHandle->prepare( qq {$LICENCE2} );
		my $sth3	= $DBHandle->prepare( qq {$LICENCE3} );
		my $sth4	= $DBHandle->prepare( qq {$LICENCE4} );
		my $sth5	= $DBHandle->prepare( qq {$LICENCE5} );
		my $sth6	= $DBHandle->prepare( qq {$LICENCE6} );
		my $sth7	= $DBHandle->prepare( qq {$LICENCE7} );
		my $sth8	= $DBHandle->prepare( qq {$LICENCE8} );
		my $sth9	= $DBHandle->prepare( qq {$LICENCE9} );
		my $sth10	= $DBHandle->prepare( qq {$LICENCE10} );

		my $sth11	= $DBHandle->prepare( qq {$CRYPTO1} );
		my $sth22	= $DBHandle->prepare( qq {$CRYPTO2} );
		my $sth33	= $DBHandle->prepare( qq {$CRYPTO3} );
		my $sth44	= $DBHandle->prepare( qq {$CRYPTO4} );
		my $sth55	= $DBHandle->prepare( qq {$CRYPTO5} );
		my $sth66	= $DBHandle->prepare( qq {$CRYPTO6} );
		my $sth77	= $DBHandle->prepare( qq {$CRYPTO7} );
		my $sth88	= $DBHandle->prepare( qq {$CRYPTO8} );
		my $sth99	= $DBHandle->prepare( qq {$CRYPTO9} );
		my $sth100	= $DBHandle->prepare( qq {$CRYPTO10} );
		
		$sth1->execute;
		$sth2->execute;
		$sth3->execute;
		$sth4->execute;
		$sth5->execute;
		$sth6->execute;
		$sth7->execute;
		$sth8->execute;
		$sth9->execute;
		$sth10->execute;

		$sth11->execute;
		$sth22->execute;
		$sth33->execute;
		$sth44->execute;
		$sth55->execute;
		$sth66->execute;
		$sth77->execute;
		$sth88->execute;
		$sth99->execute;
		$sth100->execute;

		$sth1->finish;
		$sth2->finish;
		$sth3->finish;
		$sth4->finish;
		$sth5->finish;
		$sth6->finish;
		$sth7->finish;
		$sth8->finish;
		$sth9->finish;
		$sth10->finish;

		$sth11->finish;
		$sth22->finish;
		$sth33->finish;
		$sth44->finish;
		$sth55->finish;
		$sth66->finish;
		$sth77->finish;
		$sth88->finish;
		$sth99->finish;
		$sth100->finish;

	}; # eval{}

	if ( $@ ) {
		print "ERROR: $@ - Restarting $self->CheckLicence( ArrayRef ) \n";
		select(undef, undef, undef, 0.1 );
		goto RESTARTFUNCTION;
	};
	
	
	return 1;

}; # sub AddLicenceToSQL(){}


sub GenerateLicence(){

	my $self					= shift;
	
	# Wichtige Datenstrukturen definieren und zurücksetzen
	my $Licence					= '';
	my $CheckSumHash;
	my %CheckSumHash			= ();
	my @CheckSumArray			= ();
	my @CheckSumArrayAdvanced	= ();

	# Randomizer initialisieren
	srand();

	my $TempCheckSum	= PhexProxy::CryptoLibrary->GenerateTemporaryKey();
	my $SimpleURandom	= PhexProxy::CryptoLibrary->SimpleURandom( 10000 );
	my $URandom			= PhexProxy::CryptoLibrary->URandom( 10000 );
	my $SimpleRandom	= PhexProxy::CryptoLibrary->SimpleRandom();
	my $TimeStamp		= PhexProxy::Time->GetCurrentTimeStamp();
	my $CurrentTime		= PhexProxy::Time->MySQLDateTime();
	
	my $TempCheckSumMD5	= PhexProxy::CheckSum->MD5ToHEX( \$TempCheckSum ); 
	my $SimpleRandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$SimpleRandom ); 
	my $URandomMD5		= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $CurrentTimeMD5	= PhexProxy::CheckSum->MD5ToHEX( \$CurrentTime ); 
	my $TimeStampMD5	= PhexProxy::CheckSum->MD5ToHEX( \$TimeStamp ); 
	my $SimpleURandomMD5= PhexProxy::CheckSum->MD5ToHEX( \$SimpleURandom ); 
	
	my $TempCheckSumMD4	= PhexProxy::CheckSum->MD4ToHEX( \$TempCheckSum ); 
	my $SimpleRandomMD4	= PhexProxy::CheckSum->MD4ToHEX( \$SimpleRandom ); 
	my $URandomMD4		= PhexProxy::CheckSum->MD4ToHEX( \$URandom ); 
	my $CurrentTimeMD4	= PhexProxy::CheckSum->MD4ToHEX( \$CurrentTime ); 
	my $TimeStampMD4	= PhexProxy::CheckSum->MD4ToHEX( \$TimeStamp ); 
	my $SimpleURandomMD4= PhexProxy::CheckSum->MD4ToHEX( \$SimpleURandom );

	my $TempCheckSumSHA	= PhexProxy::CheckSum->SHA1ToHEX( \$TempCheckSum ); 
	my $SimpleRandomSHA	= PhexProxy::CheckSum->SHA1ToHEX( \$SimpleRandom ); 
	my $URandomSHA		= PhexProxy::CheckSum->SHA1ToHEX( \$URandom ); 
	my $CurrentTimeSHA	= PhexProxy::CheckSum->SHA1ToHEX( \$CurrentTime ); 
	my $TimeStampSHA	= PhexProxy::CheckSum->SHA1ToHEX( \$TimeStamp ); 
	my $SimpleURandomSHA= PhexProxy::CheckSum->SHA1ToHEX( \$SimpleURandom );

	@CheckSumArray = (
		$TempCheckSumMD5,
		$SimpleRandomMD5,
		$URandomMD5,
		$CurrentTimeMD5,
		$TimeStampMD5,
		$SimpleURandomMD5,
		$TempCheckSumMD4,
		$SimpleRandomMD4,
		$URandomMD4,
		$CurrentTimeMD4,
		$TimeStampMD4,
		$SimpleURandomMD4,
		$TempCheckSumSHA,
		$SimpleRandomSHA,
		$URandomSHA,
		$CurrentTimeSHA,
		$TimeStampSHA,
		$SimpleURandomSHA,
	); # my @CheckSumArray = ()

	my $Shuffled1 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );
	my $Shuffled2 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );
	my $Shuffled3 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );
	my $Shuffled4 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );
	my $Shuffled5 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );
	my $Shuffled6 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );

	my $md5_1 = PhexProxy::CheckSum->MD5ToHEX( \$Shuffled1 );
	my $md4_1 = PhexProxy::CheckSum->MD4ToHEX( \$Shuffled1 );
	my $sha_1 = PhexProxy::CheckSum->SHA1ToHEX( \$Shuffled1 );

	my $md5_2 = PhexProxy::CheckSum->MD5ToHEX( \$Shuffled2 );
	my $md4_2 = PhexProxy::CheckSum->MD4ToHEX( \$Shuffled2 );
	my $sha_2 = PhexProxy::CheckSum->SHA1ToHEX( \$Shuffled2 );

	my $md5_3 = PhexProxy::CheckSum->MD5ToHEX( \$Shuffled3 );
	my $md4_3 = PhexProxy::CheckSum->MD4ToHEX( \$Shuffled3 );
	my $sha_3 = PhexProxy::CheckSum->SHA1ToHEX( \$Shuffled3 );

	my $md5_4 = PhexProxy::CheckSum->MD5ToHEX( \$Shuffled4 );
	my $md4_4 = PhexProxy::CheckSum->MD4ToHEX( \$Shuffled4 );
	my $sha_4 = PhexProxy::CheckSum->SHA1ToHEX( \$Shuffled4 );

	my $md5_5 = PhexProxy::CheckSum->MD5ToHEX( \$Shuffled5 );
	my $md4_5 = PhexProxy::CheckSum->MD4ToHEX( \$Shuffled5 );
	my $sha_5 = PhexProxy::CheckSum->SHA1ToHEX( \$Shuffled5 );

	my $md5_6 = PhexProxy::CheckSum->MD5ToHEX( \$Shuffled6 );
	my $md4_6 = PhexProxy::CheckSum->MD4ToHEX( \$Shuffled6 );
	my $sha_6 = PhexProxy::CheckSum->SHA1ToHEX( \$Shuffled6 );

	%CheckSumHash =	(
		"1"		=> $TempCheckSum,
		"2"		=> $SimpleURandom,
		"3"		=> $SimpleRandom,
		"4"		=> $TimeStamp,
		"5"		=> $URandom,
		"6"		=> $CurrentTime,
		"7"		=> $TempCheckSumMD5,
		"8"		=> $SimpleRandomMD5,
		"9"		=> $URandomMD5,
		"10"	=> $CurrentTimeMD5,
		"11"	=> $TimeStampMD5,
		"12"	=> $SimpleURandomMD5,
		"13"	=> $TempCheckSumMD4,
		"14"	=> $SimpleRandomMD4,
		"15"	=> $URandomMD4,
		"16"	=> $CurrentTimeMD4,
		"17"	=> $TimeStampMD4,
		"18"	=> $SimpleURandomMD4,
		"19"	=> $TempCheckSumSHA,
		"20"	=> $SimpleRandomSHA,
		"21"	=> $URandomSHA,
		"22"	=> $CurrentTimeSHA,
		"23"	=> $TimeStampSHA,
		"24"	=> $SimpleURandomSHA,
		"25"	=> $Shuffled1,
		"26"	=> $Shuffled2,
		"27"	=> $Shuffled3,
		"28"	=> $Shuffled4,
		"29"	=> $Shuffled5,
		"30"	=> $Shuffled6,
		"31"	=> $md5_1,
		"32"	=> $md4_1,
		"33"	=> $sha_1,
		"34"	=> $md5_2,
		"35"	=> $md4_2,
		"36"	=> $sha_2,
		"37"	=> $md5_3,
		"38"	=> $md4_3,
		"39"	=> $sha_3,
		"40"	=> $md5_4,
		"41"	=> $md4_4,
		"42"	=> $sha_4,
		"43"	=> $md5_5,
		"44"	=> $md4_5,
		"45"	=> $sha_5,
		"46"	=> $md5_6,
		"47"	=> $md4_6,
		"48"	=> $sha_6,
		"49"	=> PhexProxy::CryptoLibrary->URandom( 10000 ),
		"50"	=> PhexProxy::CryptoLibrary->SimpleRandom(),
		"51"	=> PhexProxy::CryptoLibrary->SimpleURandom( 99812 ),
	); # my %CheckSumHash =	()

	my $HashKeys = keys(%CheckSumHash);
	my $rand1	= int(rand($HashKeys))+1;
	my $rand2	= int(rand($HashKeys))+1;
	my $rand3	= int(rand($HashKeys))+1;
	my $rand4	= int(rand($HashKeys))+1;
	my $rand5	= int(rand($HashKeys))+1;
	my $rand6	= int(rand($HashKeys))+1;
	my $rand7	= int(rand($HashKeys))+1;
	my $rand8	= int(rand($HashKeys))+1;
	my $rand9	= int(rand($HashKeys))+1;

	my $c1 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand1} );
	my $c2 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand2} );
	my $c3 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand3} );
	my $c4 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand4} );
	my $c5 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand5} );
	my $c6 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand6} );
	my $c7 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand7} );
	my $c8 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand8} );
	my $c9 = PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand9} );

	@CheckSumArrayAdvanced = (
		$TempCheckSum,
		$SimpleURandom,
		$SimpleRandom,
		$TimeStamp,
		$URandom,
		$CurrentTime,
		$TempCheckSumMD5,
		$SimpleRandomMD5,
		$URandomMD5,
		$CurrentTimeMD5,
		$TimeStampMD5,
		$SimpleURandomMD5,
		$TempCheckSumMD4,
		$SimpleRandomMD4,
		$URandomMD4,
		$CurrentTimeMD4,
		$TimeStampMD4,
		$SimpleURandomMD4,
		$TempCheckSumSHA,
		$SimpleRandomSHA,
		$URandomSHA,
		$CurrentTimeSHA,
		$TimeStampSHA,
		$SimpleURandomSHA,
		$Shuffled1,
		$Shuffled2,
		$Shuffled3,
		$Shuffled4,
		$Shuffled5,
		$Shuffled6,
		$md5_1,
		$md4_1,
		$sha_1,
		$md5_2,
		$md4_2,
		$sha_2,
		$md5_3,
		$md4_3,
		$sha_3,
		$md5_4,
		$md4_4,
		$sha_4,
		$md5_5,
		$md4_5,
		$sha_5,
		$md5_6,
		$md4_6,
		$sha_6,
	); # my @CheckSumArrayAdvanced =	()

	my $BubbleScalar1 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $BubbleScalar2 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $BubbleScalar3 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );

	my $BubbleScalar4 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $BubbleScalar5 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $BubbleScalar6 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );

	my $BubbleScalar7 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $BubbleScalar8 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $BubbleScalar9 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );

	my $FF1 = PhexProxy::CheckSum->MD5ToHEX( $c1 . $BubbleScalar2 . $c5 );
	my $FF2 = PhexProxy::CheckSum->MD4ToHEX( $BubbleScalar5 . $c4 . $c6 );
	my $FF3 = PhexProxy::CheckSum->SHA1ToHEX( $c7 . $c2 . $BubbleScalar4 );

	my $FF4 = PhexProxy::CheckSum->MD5ToHEX( $c9 . $BubbleScalar8 . $BubbleScalar7 );
	my $FF5 = PhexProxy::CheckSum->MD4ToHEX( $BubbleScalar1 . $c8 . $BubbleScalar9 );
	my $FF6 = PhexProxy::CheckSum->SHA1ToHEX( $BubbleScalar3 . $BubbleScalar6 . $c3 );

	my $rand111 = int(rand($HashKeys))+1;
	my $rand222 = int(rand($HashKeys))+1;
	my $rand333 = int(rand($HashKeys))+1;
	my $rand444 = int(rand($HashKeys))+1;

	# Encrypt($key,$plaintext);
	my $CipherText = PhexProxy::CryptoLibrary->Encrypt( PhexProxy::CheckSum->MD5ToHEX( $CheckSumHash{$rand111} ) , PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced ) );
	
	my $t1 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArrayAdvanced );
	my $t2 = PhexProxy::CryptoLibrary->ShuffleArrayAdvanced( \@CheckSumArray );

	# Eigentliche Lizenz generieren
	$Licence = PhexProxy::CheckSum->MD5ToHEX( $CipherText . $FF1 . $Shuffled3 . $FF2 . $FF3 . $URandom . $SimpleURandom . $FF4 . $FF5 . $FF6 . $t1 . $t2 . %CheckSumHash->{$rand222} . %CheckSumHash->{$rand333} . %CheckSumHash->{$rand444} ); 

	return $Licence; 

}; # sub GenerateLicence(){}


sub SaveLicenceSQLToFile(){
   
   my $self					= shift;
   my $LicenceSQLScalarRef	= shift;
   
   my $CurTime		=  PhexProxy::Time->SimpleMySQLDateTime();
   my $StorePath	= "$LICENCESTOREPATH/$CurTime-LicenceSQL.txt"; 

	open(STORE,"+>>$StorePath") or sub { warn "PhexProxy::LicenceGenerator->SaveLicenceSQLToFile(): IO ERROR: $!\n"; return -1; };
	flock (STORE, 2);
		print STORE ${$LicenceSQLScalarRef};
	close STORE;

	return 1;
	  
};	# sub SaveLicenceSQLToFile(){}


sub SaveCryptoSQLToFile(){
   
   my $self					= shift;
   my $CryptoSQLScalarRef	= shift;
   
   my $CurTime		=  PhexProxy::Time->SimpleMySQLDateTime();
   my $StorePath	= "$LICENCESTOREPATH/$CurTime-CryptoSQL.txt"; 

	open(STORE,"+>>$StorePath") or sub { warn "PhexProxy::LicenceGenerator->SaveCryptoSQLToFile(): IO ERROR: $!\n"; return -1; };
	flock (STORE, 2);
		print STORE ${$CryptoSQLScalarRef};
	close STORE;

	return 1;
	  
};	# sub SaveCryptoSQLToFile(){}


return 1;

# Kombi1: Video, Bilder, Klingeltöne
# Kombi2: Java, MP3, Dokumente
# Kombi3: alles
# Bild
# MP3
# Klingeltöne
# Video
# Java
# Dokumente

# FORMATBILD   	 FORMATMP3   	 FORMATRING   	 FORMATVIDEO   	 FORMATJAVA   	 FORMATDOC   	 

# INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` )
# VALUES ( '', 'TESTLICENCE', '1.0', '1.1', '2006-06-30', '1', '1', '1', '1', '1', '1', '', '0')
