#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		LicenceManagement
##### Todo:			
########################################


# INSERT INTO `licence` ( `PUBLICKEY`, `PRIVATEKEY`) VALUES ( '0123456789abcdef0123456789abcdef','!123456789abcdef0123456789abcdef' );

package PhexProxy::LicenceManagement;

###use PhexProxy::Messages;
use PhexProxy::CryptoLibrary;
use Digest::MD5 qw( md5_hex );
use PhexProxy::Time;
use PhexProxy::SQL;
use Fcntl ':flock';
use strict;

# use Data::Dumper;

####
# neue Gratis User bekommen userType=3 damit die anderen noch weiter suchen können, dann bei jedem lizenzcheck auf userType=1 testen=(bekommen komplette ergebnisse) oder UserType=2=(paying user) oder usertype=3 = ( gratis user handyanmeldung ) testen
####

my $VERSION							= '1.1.a';
###my $MESSAGES						= PhexProxy::Messages->new();
my $ERRORLOG						= "/server/logs/bjparisBackend_error.log";
my $IsSuccessSearchKB				= 5 * 1024;	# für $hc_userType != 3 user
my $IsSuccessSearchHandyAnmeldungKB	= 3 * 1024;	# für $hc_userType == 3 user
my $successfull_searches			= 3;	# 3 erfolgreiche suchen	- weil der user effektiv nur 3 mal suchen incl downloaden darf
my $overall_searches				= 21;	# 21 maximale suchen sind eigentlich nur 20 suchen, aber da ein bug auftritt wenn man nur noch 1=overall hat, wurde der wert hier erhöht


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()




sub CheckLicence(){
	
	my $self		= shift;
	my $UP_MD5		= shift;
	my $SEC_MD5		= shift;
	my $HandyIP		= shift;


	my $sth;
	my $update				= 0;
	my $DBHandle;
	my $ResultHashRef		= {};
	my $SqlUpdateBJPARIS;
	my $CurrentDateTime		= PhexProxy::Time->MySQLDateTime();



	### Wenn die wichtige Lizenzwerte nicht genau 32 stellen haben, dann ist der Handy Request ung�ltig und wir k�nnen gleich zur�ckkehren
	if ( length($UP_MD5) != 32 ) {
		return (-1, $ResultHashRef);
	} elsif ( length($SEC_MD5) != 32 ) {
		return (-1, $ResultHashRef);
	}; # if ( length($UP_MD5) != 32 ) {
	


#	#######
#	### Die standart gratis user bekommen ergebnisse, die dann allerdings später beschnitten werden
#	######
#	# cc917b8dfffc08995b6cd2699caf0fd6 standart UP_MD5 für Gratis user | c0d410d040ed471a80696f06409f801d standart SEC_MD5
#	if ( $self->CheckFreeStandartUser($UP_MD5, $SEC_MD5) == 1 ) {	
#		
#	###	print "CheckLicence() - Successfull Licence Check for Standart Gratis User! - UP:'cc917b8dfffc08995b6cd2699caf0fd6' SEC:'c0d410d040ed471a80696f06409f801d' \n";
#		
#		# wichtigen userType=3 setzen
#		$ResultHashRef->{'hc_userType'} = 3;
#		
#		return (1,$ResultHashRef);
#
#	}; # if ( $UP_MD5 eq 
#
#

	### Sql Query vorbereiten
	# my $SQLQuery	= "SELECT `hc_contingent_volume_success`,`web_mobilephone`,`web_flatrate_validUntil`,`web_servicetype` FROM `bjparis` WHERE ( `hc_contingent_volume_success` > '0' OR '$CurrentDate' <= `web_flatrate_validUntil` ) AND `web_up_MD5` = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";
	# my $SQLQuery	= "SELECT `hc_contingent_volume_success`,`web_mobilephone`,`web_flatrate_validUntil`,`web_servicetype` FROM `bjparis` WHERE ( '$CurrentDate' <= `web_flatrate_validUntil` or `hc_contingent_volume_success` > '0' ) AND ( `hc_sec1_MD5` = '$SEC_MD5' OR `hc_sec2_MD5` = '$SEC_MD5' OR `hc_sec3_MD5` = '$SEC_MD5' OR `hc_sec4_MD5` = '$SEC_MD5' OR `hc_sec5_MD5` = '$SEC_MD5' ) AND `web_up_MD5` = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";
	
	# 20080506
	# my $SQLQuery	= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_mobilephone`,`web_flatrate_validUntil`,`web_servicetype`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5`,`web_testaccount` FROM `bjparis` WHERE ( '$CurrentDate' <= `web_flatrate_validUntil` or `hc_contingent_volume_success` > '0' ) AND ( `web_up_MD5` = '$UP_MD5' OR `hc_up_MD5` = '$UP_MD5' ) AND `hc_abuse` = '0' LIMIT 1;";

	# 20080507
	# my $SQLQuery	= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_mobilephone`,`web_flatrate_validUntil`,`web_servicetype`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5`,`web_testaccount` FROM `bjparis` WHERE  ( `web_up_MD5` = '$UP_MD5' OR `hc_up_MD5` = '$UP_MD5' ) AND `hc_abuse` = '0' LIMIT 1;";

	# 20080521
	my $SQLQuery	= "SELECT `hc_userType`,`web_up_MD5`,`hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_mobilephone`,`web_flatrate_validUntil`,`web_servicetype`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5`,`web_testaccount` FROM `bjparis` WHERE `web_up_MD5` = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";




	### hole die lizenzinformationen aus der datenbank
	eval {
	
		$DBHandle = PhexProxy::SQL->SQLConnect();
		$sth = $DBHandle->prepare( qq { $SQLQuery } );
		$sth->execute;
		$ResultHashRef = $sth->fetchrow_hashref;
		$sth->finish;
	
	}; # eval {


	#	print "Keys: " . keys(%{$ResultHashRef});
	#	print "\n";


	### Werte entgegennehmen
	my $web_flatrate_validUntil			= $ResultHashRef->{'web_flatrate_validUntil'};
	my $hc_contingent_volume_success	= $ResultHashRef->{'hc_contingent_volume_success'};
	my $hc_contingent_volume_overall	= $ResultHashRef->{'hc_contingent_volume_overall'};			
	my $web_mobilephone					= $ResultHashRef->{'web_mobilephone'};
	my $web_servicetype					= $ResultHashRef->{'web_servicetype'};

	my $hc_sec1_MD5						= $ResultHashRef->{'hc_sec1_MD5'};
	my $hc_sec2_MD5						= $ResultHashRef->{'hc_sec2_MD5'};
	my $hc_sec3_MD5						= $ResultHashRef->{'hc_sec3_MD5'};
	my $hc_sec4_MD5						= $ResultHashRef->{'hc_sec4_MD5'};
	my $hc_sec5_MD5						= $ResultHashRef->{'hc_sec5_MD5'};
	my $web_testaccount					= $ResultHashRef->{'web_testaccount'};
	my $hc_userType						= $ResultHashRef->{'hc_userType'};
	# $ResultHashRef->{'hc_contingent_volume_overall_previous_entry'} = $hc_contingent_volume_overall;	


	if ( $web_testaccount == 1 ) {
		
	###	print "CheckLicence() - Successfull Licence Check for Testaccount! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
		return (1,$ResultHashRef);

	}; # if ( $web_testaccount == 1 ) {

	if ( ref($ResultHashRef) eq 'HASH' && keys(%{$ResultHashRef}) == 13 ) {		### Hier ist der erste Security Check erfolgreich gewesen - 12 muss der anzahl der SELECT Werte von $SQLQuery entsprechen
	
		### Algorithmus:
		#	1a. wenn hc_sec1 == $SEC_MD5 -> valid oder
		#	1b. wenn hc_sec2 == $SEC_MD5 -> valid oder
		#	1c. wenn hc_sec3 == $SEC_MD5 -> valid oder
		#	1d. wenn hc_sec4 == $SEC_MD5 -> valid oder
		#	1e. wenn hc_sec5 == $SEC_MD5 -> valid oder
		#
		#	2a. wenn hc_sec1 != $SEC_MD5 && length hc1 == 0 -> installiere $SEC_MD5 als hc_sec1 -> danach valid oder
		#	2b. wenn hc_sec2 != $SEC_MD5 && length hc2 == 0 -> installiere $SEC_MD5 als hc_sec2 -> danach valid oder
		#	2c. wenn hc_sec3 != $SEC_MD5 && length hc3 == 0 -> installiere $SEC_MD5 als hc_sec3 -> danach valid oder
		#	2d. wenn hc_sec4 != $SEC_MD5 && length hc4 == 0 -> installiere $SEC_MD5 als hc_sec4 -> danach valid oder
		#	2e. wenn hc_sec5 != $SEC_MD5 && length hc5 == 0 -> installiere $SEC_MD5 als hc_sec5 -> danach valid oder
		#
		#	3. Else -> Invalid
				
		
		if ( length($hc_sec1_MD5) == 32 && $hc_sec1_MD5 eq $SEC_MD5 && length($SEC_MD5) == 32 ) {
			# valid
		} elsif ( length($hc_sec2_MD5) == 32 && $hc_sec2_MD5 eq $SEC_MD5 && length($SEC_MD5) == 32 ) {
			# valid
		} elsif ( length($hc_sec3_MD5) == 32 && $hc_sec3_MD5 eq $SEC_MD5 && length($SEC_MD5) == 32 ) {
			# valid
		} elsif ( length($hc_sec4_MD5) == 32 && $hc_sec4_MD5 eq $SEC_MD5 && length($SEC_MD5) == 32 ) {
			# valid
		} elsif ( length($hc_sec5_MD5) == 32 && $hc_sec5_MD5 eq $SEC_MD5 && length($SEC_MD5) == 32 ) {
			# valid

		} elsif ( length($hc_sec1_MD5) == 0 && $hc_sec1_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {

			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `bjparis` SET `hc_sec1_MD5` = \"$SEC_MD5\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";

		} elsif ( length($hc_sec2_MD5) == 0 && $hc_sec2_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {
			
			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `bjparis` SET `hc_sec2_MD5` = \"$SEC_MD5\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";

		} elsif ( length($hc_sec3_MD5) == 0 && $hc_sec3_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {

			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `bjparis` SET `hc_sec3_MD5` = \"$SEC_MD5\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";

		} elsif ( length($hc_sec4_MD5) == 0 && $hc_sec4_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {
			
			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `bjparis` SET `hc_sec4_MD5` = \"$SEC_MD5\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";

		} elsif ( length($hc_sec5_MD5) == 0 && $hc_sec5_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {
			
			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `bjparis` SET `hc_sec5_MD5` = \"$SEC_MD5\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";

		} elsif ( ( $hc_sec1_MD5 ne $SEC_MD5 && $hc_sec2_MD5 ne $SEC_MD5 && $hc_sec3_MD5 ne $SEC_MD5 && $hc_sec4_MD5 ne $SEC_MD5 && $hc_sec5_MD5 ne $SEC_MD5 ) && length($SEC_MD5) == 32 ) {

				print "CheckLicence() - Failed Security SEC_MD5 Licence Check - To much HC MD5 Values! \n";
			
				open(ERROR,"+>>$ERRORLOG");
					flock(ERROR, LOCK_EX);
					print ERROR "[$CurrentDateTime] [$HandyIP,$SEC_MD5,$UP_MD5] [Too much different SEC_MD5]\n";
				close ERROR;

				return (-1,$ResultHashRef);

		} else {
				
			# print Dumper $ResultHashRef;
		###	print "CheckLicence() - Failed Security SEC_MD5 Licence Check! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
	
			open(ERROR,"+>>$ERRORLOG");
				flock(ERROR, LOCK_EX);
				print ERROR "[$CurrentDateTime] [$HandyIP,$SEC_MD5,$UP_MD5] [Failed Licence Check]\n";
			close ERROR;
			
			return (-1,$ResultHashRef);	# former: return (0,$ResultHashRef);

		}; # ### Algorithmus: Ende



		if ( $update == 1 ) {

			$DBHandle = PhexProxy::SQL->SQLConnect();
			$sth = $DBHandle->prepare( qq { $SqlUpdateBJPARIS } );
			$sth->execute;
			$sth->finish;

		}; # if ( $update == 1 ) {


		### Aktuelles Datum holen
		my $CurrentDate		= PhexProxy::Time->SimpleMySQLDateTime();

		# Zeichen '-' aus den Datumsangaben löschen, diese Daten brauchen wir dann später zum vergleich
		$CurrentDate				=~ s/-//g;
		$web_flatrate_validUntil	=~ s/-//g;


		if ( $web_servicetype == 1 && $hc_contingent_volume_success > 0 ) {		
			
			# volumen user hat noch success suchen und darf suchen
		### print "CheckLicence() - Successfull Licence Check for Volume! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (1,$ResultHashRef);

		} elsif ( $web_servicetype == 1 && $hc_contingent_volume_success <= 0 && $hc_userType != 3 ) {	

			# bitjoe.de volumen user hat kein success mehr frei und darf nicht mehr suchen
		###	print "CheckLicence() - Failed Licence Check for bitjoe.de Volume User - No more success volume left! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (0,$ResultHashRef);

		} elsif ( $web_servicetype == 1 && $hc_contingent_volume_success <= 0 && $hc_contingent_volume_overall > 0 && $hc_userType == 3 ) {	

			# handyanmeldung user hat kein success mehr frei aber hat noch overall frei und darf desshalb noch ergebnisse bekommen - allerdings nur noch fakes
		###	print "CheckLicence() - Handyanmeldung User Volume - No more success volume left! - gets only Fakes - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (1,$ResultHashRef);

		} elsif ( $web_servicetype == 1 && $hc_contingent_volume_success <= 0 && $hc_contingent_volume_overall <= 0 && $hc_userType == 3 ) {

			# handyanmeldung user hat kein success mehr frei und kein overall frei und darf desshalb nicht mehr suchen
		###	print "CheckLicence() - Handyanmeldung User Volume - No more success and overall volume left! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (0,$ResultHashRef);

		} elsif ( $web_servicetype == 2 && $CurrentDate <= $web_flatrate_validUntil ) {
			
			# flatrate user dürfen noch suchen, weil flat noch gültig ist
		###	print "CheckLicence() - Successfull Licence Check for Flatrate! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (1,$ResultHashRef);
		
		} elsif ( $web_servicetype == 2 && $CurrentDate > $web_flatrate_validUntil ) {

			# flatrate nicht mehr gültig
		###	print "CheckLicence() - Failed Licence Check for Flatrate - Flatrate Date invalid! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (0,$ResultHashRef);

		} else {
			
			# wenn alle stricke reißen gibts nen error und der user darf NICHTS mehr
		###	print "CheckLicence() - Failed Licence Check! -Entry unknown- UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			my $CurrentDateTime		= PhexProxy::Time->MySQLDateTime();

			open(ERROR,"+>>$ERRORLOG");
				flock(ERROR, LOCK_EX);
				print ERROR "[$CurrentDateTime] [$HandyIP,$SEC_MD5,$UP_MD5] [Too much different SEC_MD5]\n";
			close ERROR;

			### korrekt: return (-1, $ResultHashRef);
			return (-1, $ResultHashRef);

		}; # if ( $web_servicetype == 1 || $web_servicetype == 2) {


	}; # if ( ( ref($ResultHashRef) eq 'HASH' ) && keys(%{$ResultHashRef}) == 4 ) {
	
		
	### Hier kommt man nur hin, wenn ein ungültiger Eintrag bei Handnr+Pin eingegeben wurde
###	print "LAST CheckLicence() - Failed Licence Check! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
	my $CurrentDateTime		= PhexProxy::Time->MySQLDateTime();

	open(ERROR,"+>>$ERRORLOG");
		flock(ERROR, LOCK_EX);
		print ERROR "[$CurrentDateTime] [$HandyIP,$SEC_MD5,$UP_MD5] [Failed Licence Check-Entry unknown-]\n";
	close ERROR;

	### DEFALUT UND RICHTIG: return (-1,$ResultHashRef);
	return (-1,$ResultHashRef);	

};  # sub CheckLicence(){}



sub CreateNewUser(){

	### Erstelle neuen gratis User für direkte handyanmeldung 

	my $self			= shift;
	my $REMOTE			= shift;
	my $version			= shift;
	
	my $ResultHashRef	= {};
	my $CRYPTO			= PhexProxy::CryptoLibrary->new();

	my $passwd_full		= $CRYPTO->UniqueID();
	my $from_pass		= int(rand(26));							# 32 - passwort länge
	my $password		= lc(substr($passwd_full, $from_pass, 6));	# password 6 stellen lang


	my $user_full		= $CRYPTO->UniqueID();
	my $from_user		= int(rand(25));
	my $username		= lc(substr($user_full, $from_user, 7));	# username 7 stellen lang
	
	# DEBUG
	# $username			= 'T' . $username;


	my $stringRaw		= $username . $password;
	my $web_up_MD5		= md5_hex($stringRaw);


	# bjparis tabellen werte für neuen user erstellen, handyanmeldung gratis user hat userType=3
	my $SqlQueryBJTABLE	= "INSERT INTO `bjparis` ( `web_mobilephone`,`web_mobilephone_full`,`web_ref_PP`,`web_grp_PP`,`web_ref_UID`,`web_ref_URL`, `web_lead_istracked`,`web_signup_date`,`web_signup_remote`,`web_servicetype`, `web_password`,`web_up_MD5`, `web_country`,`web_testaccount`,`hc_contingent_volume_success`,`hc_contingent_volume_overall`, `hc_userType`,`hc_abuse`) VALUES ( '$username','$username', '0', '0', '0', 'HandySignup_$version', '0', NOW(), '$REMOTE', '1', '$password', '$web_up_MD5' , 'NA' , '0', '$successfull_searches', '$overall_searches', '3','0' );";	


	# payment tabelle vorbereiten
	my $SqlQueryBILL_TABLE	= "INSERT INTO `payment` ( `bill_mobilephone`) VALUES ( '$username' );";


	my $DBHandle = PhexProxy::SQL->SQLConnect();
	my $sth = $DBHandle->prepare( qq { $SqlQueryBJTABLE } );
	$sth->execute;
	$sth->finish;

	my $DBHandle = PhexProxy::SQL->SQLConnect();
	my $sth = $DBHandle->prepare( qq { $SqlQueryBILL_TABLE } );
	$sth->execute;
	$sth->finish;

###	print "CreateNewUser() - Erstelle User: '$username' - Passwort: '$password' - stringRaw: '$stringRaw' -web_up_MD5: '$web_up_MD5' \n";

	$ResultHashRef->{'hc_contingent_volume_success'}	= $successfull_searches;
	$ResultHashRef->{'hc_contingent_volume_overall'}	= $overall_searches;			
	$ResultHashRef->{'web_servicetype'}					= 1;
	$ResultHashRef->{'web_testaccount'}					= 0;
	$ResultHashRef->{'hc_userType'}						= 3;	# 1=free user website anmeldung| 2=paying user | 3 = direkte handyanmeldung free user
	$ResultHashRef->{'web_up_MD5'}						= $web_up_MD5;

	# benutzername ## passwort ## web_UP_MD5
	return ("$username##$password##$web_up_MD5", $ResultHashRef);

}; # sub CreateNewUser(){




sub UpdateBJParisDBOverall(){

	### verrringere den overall um 1

	my $self								= shift;
	my $ResultHashRef						= shift;

	my $hc_contingent_volume_success		= $ResultHashRef->{'hc_contingent_volume_success'};
	my $hc_contingent_volume_overall		= $ResultHashRef->{'hc_contingent_volume_overall'};			
	my $web_servicetype						= $ResultHashRef->{'web_servicetype'};
	my $web_testaccount						= $ResultHashRef->{'web_testaccount'};
	my $web_up_MD5							= $ResultHashRef->{'web_up_MD5'};
	my $hc_userType						= $ResultHashRef->{'hc_userType'};
	# my $sendstringlength					= $ResultHashRef->{'SendStringLength'};
	my $SqlBJParisUpdateTable				= "";
	#	$ResultHashRef->{'SuccessVolumeFlag'} = "";	


	# Testaccount wird nichts an den Volumen abgezogen
	if ( $web_testaccount == 1 ) {
		
		###	print "UpdateBJParisDBOverall() - Testaccount \n";
		return 1;

	}; # if ( $web_testaccount == 1 ) {

	
	if ( $web_servicetype == 1 ) {	# Volumen
			
		#############
		############# verringere hc_contingent_volume_overall um 1	
		#############
		
		if ( $hc_contingent_volume_overall <= 0 ) {
				
			$SqlBJParisUpdateTable = "UPDATE `bjparis` SET `hc_contingent_volume_overall` = \"0\", `web_firstuse` = \"0\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' AND `hc_abuse` = '0' LIMIT 1;";
		###	print "UpdateBJParisDBOverall() [UserType=$hc_userType] - Volumen Overall = 0 # New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";

		} else {	# > 0

			$hc_contingent_volume_overall--;
			$SqlBJParisUpdateTable = "UPDATE `bjparis` SET `hc_contingent_volume_overall` = \"$hc_contingent_volume_overall\", `web_firstuse` = \"0\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' AND `hc_abuse` = '0' LIMIT 1;";
		###	print "UpdateBJParisDBOverall() [UserType=$hc_userType] - Volumen Overall abziehen # New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";

		}; # if ( $hc_contingent_volume_overall <= 0 ) {

		my $DBHandle = PhexProxy::SQL->SQLConnect();
		my $sth = $DBHandle->prepare( qq { $SqlBJParisUpdateTable } );
		$sth->execute;
		$sth->finish;

		return 1;

	} elsif ( $web_servicetype == 2 ) {	# Flatrate

	###	print "UpdateBJParisDBOverall() - Flatrate \n";
		return 1;

	} else {
		
		# es gibt nur $web_servicetype = 1 oder $web_servicetype = 2
		return -1;

	}; # if ( $web_servicetype == 1 ) {


	return -1;

}; # sub UpdateBJParisDBOverall(){


sub UpdateBJParisDBSuccess(){

	### verringere success um 1, wenn mehr als 5KB resultdaten und hc_userType != 3 -unkomprimiert- übertragen wurden
	### verringere success um 1, wenn mehr als 3KB resultdaten und hc_userType == 3 -unkomprimiert- übertragen wurden

	my $self							= shift;
	my $ResultHashRef					= shift;
	

	my $hc_contingent_volume_overall	= $ResultHashRef->{'hc_contingent_volume_overall'};		
	my $hc_contingent_volume_success	= $ResultHashRef->{'hc_contingent_volume_success'};
	my $web_servicetype					= $ResultHashRef->{'web_servicetype'};
	my $web_testaccount					= $ResultHashRef->{'web_testaccount'};
	my $web_up_MD5						= $ResultHashRef->{'web_up_MD5'};
	my $sendstringlength				= $ResultHashRef->{'SendStringLength'};
	my $hc_userType						= $ResultHashRef->{'hc_userType'};
	my $SqlBJParisUpdateTable			= "";




	# Testaccount wird nichts an den Volumen abgezogen
	if ( $web_testaccount == 1 ) {
		
	###	print "UpdateBJParisDBSuccess() - Testaccount \n";
		return 1;

	}; # if ( $web_testaccount == 1 ) {



	my $TrafficVolumeParameter;

	if ( $hc_userType == 3 ) {
		$TrafficVolumeParameter = $IsSuccessSearchHandyAnmeldungKB;
	} else {
		$TrafficVolumeParameter = $IsSuccessSearchKB;
	}; # if ( $hc_userType == 3 ) {


	if ( $web_servicetype == 1 ) {	# Volumen
			
		# wenn HandyAnmeldungGratis user mehr als 3 KB daten bekommen hat ODER normaler volumen user mehr als 
		if ( $sendstringlength > $TrafficVolumeParameter ) {
				
			# wenn overall == 0 dann verringere success um 1 egal ob über 5 kb oder nicht

			#############	
			############# verringere hc_contingent_volume_success um 1
			#############
		
			if ( $hc_contingent_volume_success <= 0 ) {
			
				$SqlBJParisUpdateTable = "UPDATE `bjparis` SET `hc_contingent_volume_success` = \"0\", `web_firstuse` = \"0\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' AND `hc_abuse` = '0' LIMIT 1;";
			###	print "UpdateBJParisDBSuccess() [UserType=$hc_userType] - Volumen Success = 0 # New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";

			} else {

				$hc_contingent_volume_success--;
				$SqlBJParisUpdateTable = "UPDATE `bjparis` SET `hc_contingent_volume_success` = \"$hc_contingent_volume_success\", `web_firstuse` = \"0\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' AND `hc_abuse` = '0' LIMIT 1;";
			###	print "UpdateBJParisDBSuccess() [UserType=$hc_userType] - Volumen Success Abziehen # New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";

			}; # if ( $hc_contingent_volume_success <= 0 ) {

			###	print "UpdateBJParisDBSuccess() - Volumen Success Normal New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";
	
			my $DBHandle = PhexProxy::SQL->SQLConnect();
			my $sth = $DBHandle->prepare( qq { $SqlBJParisUpdateTable } );
			$sth->execute;
			$sth->finish;
		
		}; # if ( ( ($sendstringlength > $IsSuccessSearchHandyAnmeldungKB) && $hc_userType == 3) || ( ($sendstringlength > $IsSuccessSearchKB) && $hc_userType != 3) ) {

		
		if ( $hc_contingent_volume_overall <= 0 ) {
			
			### Wenn Overall Volumen kleiner gleich 0 ist, dann wird dem user ein Successfull Search abgezogen

			if ( $hc_contingent_volume_success <= 0 ) {
			
				$SqlBJParisUpdateTable = "UPDATE `bjparis` SET `hc_contingent_volume_success` = \"0\", `web_firstuse` = \"0\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' AND `hc_abuse` = '0' LIMIT 1;";
			###	print "UpdateBJParisDBSuccess() [UserType=$hc_userType] - Volumen Success = 0 und Overall = 0 # New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";
			
			} else {

				$hc_contingent_volume_success--;
				$SqlBJParisUpdateTable = "UPDATE `bjparis` SET `hc_contingent_volume_success` = \"$hc_contingent_volume_success\", `web_firstuse` = \"0\" WHERE CONVERT( `bjparis`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' AND `hc_abuse` = '0' LIMIT 1;";
			###	print "UpdateBJParisDBSuccess() [UserType=$hc_userType] - Volumen Success Abziehen und Overall > 0 # New o=$hc_contingent_volume_overall | s=$hc_contingent_volume_success \n";

			}; # if ( $hc_contingent_volume_success <= 0 ) {
				
			my $DBHandle = PhexProxy::SQL->SQLConnect();
			my $sth = $DBHandle->prepare( qq { $SqlBJParisUpdateTable } );
			$sth->execute;
			$sth->finish;

		}; # if ( $hc_contingent_volume_overall <= 0 ) {

		
		return 1;

	} elsif ( $web_servicetype == 2 ) {	# Flatrate
		
		###	print "UpdateBJParisDBSuccess() - Flatrate \n";
		return 1;

	} else {
		
		# es gibt nur $web_servicetype = 1 oder $web_servicetype = 2
		return -1;
		
	} # if ( $web_servicetype == 1 ) {

	return -1;

}; # sub UpdateBJParisDBSuccess(){





sub CheckFreeStandartUser(){
	
	my $self		= shift;
	my $UP_MD5		= shift;
	my $SEC_MD5		= shift;

	### Wenn die wichtige Lizenzwerte nicht genau 32 stellen haben, dann ist der Handy Request ung�ltig und wir k�nnen gleich zur�ckkehren
	if ( length($UP_MD5) != 32 ) {
		return -1;
	} elsif ( length($SEC_MD5) != 32 ) {
		return -1;
	}; # if ( length($UP_MD5) != 32 ) {
	
	# cc917b8dfffc08995b6cd2699caf0fd6 standart UP_MD5 für Gratis user | c0d410d040ed471a80696f06409f801d standart SEC_MD5
	if ( $UP_MD5 eq 'cc917b8dfffc08995b6cd2699caf0fd6' && $SEC_MD5 eq 'c0d410d040ed471a80696f06409f801d' ) {	
		return 1;
	} else {
		return 0;	
	}; # if ( $UP_MD5 eq 

	return 0; # never reached

}; # sub CheckFreeStandartUser(){



return 1;
