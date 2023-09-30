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

# use PhexProxy::CryptoLibrary;
use Digest::MD5 qw( md5_hex );
use PhexProxy::Time;
use PhexProxy::SQL;
use Fcntl ':flock';
use strict;

# use Data::Dumper;

my $VERSION							= '1.1.a';
my $ERRORLOG						= "/server/logs/bjparisBackend_error.log";
my $BitJoeTable						= "bjparis_new";

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
	
	# 20090903
	my $SQLQuery	= "SELECT `username`,`searchcount`,`web_up_MD5`,`password`,`account_valid_until`,`searchcontingent`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5` FROM `bjparis_new` WHERE `web_up_MD5` = '$UP_MD5' LIMIT 1;";


	### hole die lizenzinformationen aus der datenbank
	eval {
	
		$DBHandle = PhexProxy::SQL->SQLConnect();
		$sth = $DBHandle->prepare( qq { $SQLQuery } );
		$sth->execute;
		$ResultHashRef = $sth->fetchrow_hashref;
		$sth->finish;
	
	}; # eval {


	### Werte entgegennehmen
	my $username				= $ResultHashRef->{'username'};
	my $searchcount				= $ResultHashRef->{'searchcount'};
	my $password				= $ResultHashRef->{'password'};
	my $account_valid_until		= $ResultHashRef->{'account_valid_until'};			
	my $searchcontingent		= $ResultHashRef->{'searchcontingent'};

	my $hc_sec1_MD5				= $ResultHashRef->{'hc_sec1_MD5'};
	my $hc_sec2_MD5				= $ResultHashRef->{'hc_sec2_MD5'};
	my $hc_sec3_MD5				= $ResultHashRef->{'hc_sec3_MD5'};
	my $hc_sec4_MD5				= $ResultHashRef->{'hc_sec4_MD5'};
	my $hc_sec5_MD5				= $ResultHashRef->{'hc_sec5_MD5'};

	# $ResultHashRef->{'hc_contingent_volume_overall_previous_entry'} = $hc_contingent_volume_overall;	

	if ( ref($ResultHashRef) eq 'HASH' && keys(%{$ResultHashRef}) == 11 ) {		### Hier ist der erste Security Check erfolgreich gewesen - 12 muss der anzahl der SELECT Werte von $SQLQuery entsprechen


		# penalty / sperren: wenn ( searchcount / 2 ) > searchcontingent dann penalty!!!!!
		if ( ($searchcount / 2) > $searchcontingent ) {	# der user hat schon doppelt so viel gesucht wie er volumen hatte -> blocken
			
			# setzte das search contingent vom user auf null zurück!
			$searchcontingent = 0;
		
			# ... und aktualisiere die sql tabellen!
			my $SqlUpdateBJPARIS_ZERO 	= "UPDATE `$BitJoeTable` SET `searchcontingent` = \"0\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$UP_MD5' LIMIT 1;";
			$DBHandle = PhexProxy::SQL->SQLConnect();
			$sth = $DBHandle->prepare( qq { $SqlUpdateBJPARIS_ZERO } );
			$sth->execute;
			$sth->finish;

		}; # if ( ($searchcount / 2) > $searchcontingent ) {


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
			$SqlUpdateBJPARIS 	= "UPDATE `$BitJoeTable` SET `hc_sec1_MD5` = \"$SEC_MD5\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$UP_MD5' LIMIT 1;";

		} elsif ( length($hc_sec2_MD5) == 0 && $hc_sec2_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {
			
			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `$BitJoeTable` SET `hc_sec2_MD5` = \"$SEC_MD5\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$UP_MD5' LIMIT 1;";

		} elsif ( length($hc_sec3_MD5) == 0 && $hc_sec3_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {

			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `$BitJoeTable` SET `hc_sec3_MD5` = \"$SEC_MD5\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$UP_MD5' LIMIT 1;";

		} elsif ( length($hc_sec4_MD5) == 0 && $hc_sec4_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {
			
			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `$BitJoeTable` SET `hc_sec4_MD5` = \"$SEC_MD5\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$UP_MD5' LIMIT 1;";

		} elsif ( length($hc_sec5_MD5) == 0 && $hc_sec5_MD5 ne $SEC_MD5 && length($SEC_MD5) == 32 ) {
			
			$update = 1;
			$SqlUpdateBJPARIS 	= "UPDATE `$BitJoeTable` SET `hc_sec5_MD5` = \"$SEC_MD5\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$UP_MD5' LIMIT 1;";

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
		$CurrentDate			=~ s/-//g;
		$account_valid_until	=~ s/-//g;


		if ( $searchcontingent > 0 && $CurrentDate <= $account_valid_until ) {		
			
			# volumen user hat noch success suchen und darf suchen
		### print "CheckLicence() - Successfull Licence Check for Volume! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (1,$ResultHashRef);

		} elsif ( $CurrentDate > $account_valid_until ) {	

			# bitjoe.de volumen user hat kein success mehr frei und darf nicht mehr suchen
			###	print "CheckLicence() - Failed Licence Check for bitjoe.de Volume User - No more success volume left! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
			return (0,$ResultHashRef);

		} elsif ( $searchcontingent <= 0 ) {	

			# bitjoe.de volumen user hat kein success mehr frei und darf nicht mehr suchen
			###	print "CheckLicence() - Failed Licence Check for bitjoe.de Volume User - No more success volume left! - UP:'$UP_MD5' SEC:'$SEC_MD5' \n";
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



sub UpdateSearchContingent(){

	### verrringere den searchcontingent um 1
	my $self					= shift;
	my $ResultHashRef			= shift;

	my $web_up_MD5				= $ResultHashRef->{'web_up_MD5'};
	my $searchcount				= $ResultHashRef->{'searchcount'};
	my $searchcontingent		= $ResultHashRef->{'searchcontingent'};
	my $SqlBJParisUpdateTable	= "";
	$searchcount++;
	
	#############
	############# verringere searchcontingent um 1	
	#############
	
	if ( $searchcontingent <= 0 ) {
			
		$SqlBJParisUpdateTable = "UPDATE `$BitJoeTable` SET `searchcontingent` = \"0\", `searchcount` = \"$searchcount\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' LIMIT 1;";
		
	} else {	# > 0

		$searchcontingent--;
		$SqlBJParisUpdateTable = "UPDATE `$BitJoeTable` SET `searchcontingent` = \"$searchcontingent\", `searchcount` = \"$searchcount\" WHERE CONVERT( `$BitJoeTable`.`web_up_MD5` USING utf8 ) = '$web_up_MD5' LIMIT 1;";

	}; # if ( $hc_contingent_volume_overall <= 0 ) {

	my $DBHandle = PhexProxy::SQL->SQLConnect();
	my $sth = $DBHandle->prepare( qq { $SqlBJParisUpdateTable } );
	$sth->execute;
	$sth->finish;

	return 1;

}; # sub UpdateSearchContingent(){



return 1;
