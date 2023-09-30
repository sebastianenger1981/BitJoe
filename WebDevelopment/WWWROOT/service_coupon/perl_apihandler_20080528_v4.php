<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");

/*
Beispiel URI Request um eine Coupon vom Handy aus zu aktualisieren:
Actung: bj_SEC_MD5 muss angepasst werden
http://www.bitjoe.de/bcah_65b2a9aaa90e7fb5836d7553025a2a9b_F2FshG78532_gF42HjkaS3g67wfsa432/perl_apihandler_20080504_v1.php?bj_couponcode=a90f200104&bj_accesss=Perl+Web+Test+V1&bj_SEC_MD5=11111111111111111111111111111111&bj_UP_MD5=68035c85bcfd0de0970c142d4ed8d866&bj_auth=e62526bcf84865dac863350c121e8f88
*/

### Sicherheitscheck
$PerlApiAuthKey 	= deleteSqlChars($_REQUEST["bj_auth"]);

###echo "'$PerlApiAuthKey' und ORG: '".BITJOEPERLAPIACCESSKEY."'<br>";

if ( $PerlApiAuthKey != BITJOEPERLAPIACCESSKEY ) {
	echo "";	# bei der finalen version gar nichts ausgeben
	exit(0);
}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {


# weitere Parameter entgegen nehmen
$couponcode 		= strtolower(deleteSqlChars($_REQUEST["bj_couponcode"]));	# coupon code 
$bjAccessProgramm	= shortenString($_REQUEST["bj_access"], 130 );			# beschneide string auf 30 zeichen
$bj_SEC_MD5		= deleteSqlChars($_REQUEST["bj_SEC_MD5"]);			# hc_sec1_MD5
$bj_UP_MD5		= deleteSqlChars($_REQUEST["bj_UP_MD5"]);			# hc_up_MD5
$MobilePhone 		= GetMobilePhone( $bj_UP_MD5 );						# mobile phone

# Status Werte berechnen
$MobilePhoneStatus	= checkInput($MobilePhone, "I", 4, 17 );
$CouponCodeStatus	= checkInput($couponcode, "M", 10, 10 );
$bj_SEC_MD5Status	= checkInput($bj_SEC_MD5, "M", 32, 32 );
$bj_UP_MD5Status	= checkInput($bj_UP_MD5, "M", 32, 32 );


# Status Werte auf Gültigkeit prüfen
if ( $MobilePhoneStatus == 1 && $CouponCodeStatus == 1 && $bj_SEC_MD5Status == 1 && $bj_UP_MD5Status == 1 && strlen($couponcode) == 10 ) {
	
	### Checken, dass der user nur einmal den gleichen code einlösen darf
	$SqlQueryGetUsedCoupons	= "SELECT `used_code`,`used_isaktionsgutschein` FROM `usedcoupons` WHERE `used_mobilephone` = '$MobilePhone' ORDER BY `used_date` DESC;";	# LIMIT 300;
	$MySqlArrayCheck 	= doSQLQuery($SqlQueryGetUsedCoupons);	
	$UsedCouponsArray	= array();
	$UsedCouponsAktionArray	= array();

	if ($MySqlArrayCheck) {
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {

			$usedcoupon 		= $sql_results["used_code"];
			$usedcoupon_aktion 	= $sql_results["used_isaktionsgutschein"];

			array_push($UsedCouponsArray, $usedcoupon);
			array_push($UsedCouponsAktionArray, $usedcoupon_aktion);

		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	}; # if ($MySqlArrayCheck) {

	foreach ( $UsedCouponsArray as $USEDCOUPON ){

		# Der User versucht hier einen Coupon einzulösen, den er bereits eingelöst hat -> Fehlermeldung ausgeben
		if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {
			echo "Du darfst einen Gutschein nicht mehrmals einloesen!";	
			exit(0);
		}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {

	}; # foreach ( $UsedCouponsArray as $USEDCOUPON ){




	### Checken, wie oft ein User heute schon ein Coupon eingelöst hat
	$CurrentAsciiDate	= date("Y-m-d");	# dieser wert wird später auch für die USED_TABLE gebraucht
	$SqlQueryAlreadyUsed	= "SELECT count(*) AS `ALREADYUSEDCOUPONSFORTODAY` FROM `usedcoupons` WHERE `used_mobilephone` = '$MobilePhone' AND `used_date` = '$CurrentAsciiDate' LIMIT 1;";
	$MySqlArrayCheck_1 	= doSQLQuery($SqlQueryAlreadyUsed);	
	$sql_results_1 		= mysql_fetch_array($MySqlArrayCheck_1);
	$AlreadyUsedGiftsToday 	= $sql_results_1["ALREADYUSEDCOUPONSFORTODAY"];


	# Gib eine Fehlermeldung aus, wenn der user heute schon mehr als MAXCOUPONSTOUSEADAY eingelöst hat
	if ( $AlreadyUsedGiftsToday >= MAXCOUPONSTOUSEADAY ){

		echo "Du darfst nur " .MAXCOUPONSTOUSEADAY. " Gutscheine am Tag einloesen!";	
		exit(0);

	}; # if ( $AlreadyUsedGiftsToday >= MAXCOUPONSTOUSEADAY ){


	
	### Checken ob der user einen Aktionsgutschein einlösen will, wenn er schon einen Aktionsgutschein eingelöst hat -> error
	$TABLE2			= COUPON_TABLE;
	$SqlQueryCOUPON_TABLE	= "SELECT `gift_aktionsgutschein` FROM `$TABLE2` WHERE `gift_code` = '$couponcode' AND `gift_isValid` = '1' AND `gift_how_often_valid` > '0' AND '$CurrentDate' <= `gift_code_validUntil` LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQueryCOUPON_TABLE);	

	$sql_results_2 		= mysql_fetch_array($MySqlArrayCheck);
	$gift_aktionsgutschein 	= $sql_results_2["gift_aktionsgutschein"];

	if ( $gift_aktionsgutschein == 1 ) {

		# Will der user einen Aktionsgutschein einlösen
	
		foreach ( $UsedCouponsAktionArray as $USEDCOUPONAKTION ){
	
			# Der User versucht hier einen Aktionsgutschein einzulösen, obwohl er schon einen Aktionsgutschein eingeloest hat -> Fehlermeldung ausgeben
			if ( $USEDCOUPONAKTION == 1 ) {

				echo "Du hast versucht einen weiteren Aktionsgutschein einzuloesen. Insgesamt darfst du jedoch nur 1 Aktionsgutschein einloesen!";	
				exit(0);

			}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {
	
		}; # foreach ( $UsedCouponsArray as $USEDCOUPON ){

	}; # if ( $gift_aktionsgutschein == 1 ) {
	


	### SQL Daten aus COUPON TABLE holen
	$CurrentDate		= date("Y-m-d h:i:s");
	#$CurrentDateCreation 	= strtotime($CurrentDate); 

	$TABLE2			= COUPON_TABLE;
	$SqlQueryCOUPON_TABLE	= "SELECT * FROM `$TABLE2` WHERE `gift_code` = '$couponcode' AND `gift_isValid` = '1' AND `gift_how_often_valid` > '0' AND '$CurrentDate' <= `gift_code_validUntil` LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQueryCOUPON_TABLE);	

	if ($MySqlArrayCheck) {
	
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$gift_code_validUntil 	= $sql_results["gift_code_validUntil"];
			$gift_flat_validUntil 	= $sql_results["gift_flat_validUntil"];
			$gift_how_often_valid 	= $sql_results["gift_how_often_valid"];
			$gift_success_search 	= $sql_results["gift_success_search"];
			$gift_overall_search 	= $sql_results["gift_overall_search"];
			$gift_type 		= $sql_results["gift_type"];	# 1=volumen | 2=flat
			$gift_isValid 		= $sql_results["gift_isValid"];
			$gift_code		= strtolower($sql_results["gift_code"]);
			# $ = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	} else { # if ($MySqlArrayCheck) {
		echo "Fehler beim eintragen deines Gutscheins!";
		exit(0);	
	};


	# Code schon aufgebraucht 
	# if ( strcmp($couponcode , $gift_code) != 0 ) {
	 if ( $couponcode != $gift_code ) {
		echo "Der Gutschein ist nicht gueltig!";	
		exit(0);
	}; # if ( strcasecmp($couponcode , $gift_code) != 0 ) {
	



	### SQL DAten aus der bjparis TAble holen
	$TABLE1			= BJPARIS_TABLE;
	# $SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil`,`web_servicetype`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND `hc_up_MD5` = '$bj_UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";
	
	
	# $SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil`,`web_servicetype`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND ( `hc_up_MD5` = '$bj_UP_MD5' AND `web_up_MD5` = '$bj_UP_MD5' ) AND `hc_abuse` = '0' LIMIT 1;";
	
	$SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil`,`web_servicetype`,`hc_sec1_MD5`,`hc_sec2_MD5`,`hc_sec3_MD5`,`hc_sec4_MD5`,`hc_sec5_MD5` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND `web_up_MD5` = '$bj_UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";

	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);
	$SecArray		= array();

	if ( $MySqlArrayCheck ) {
	
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$hc_contingent_volume_success 	= $sql_results["hc_contingent_volume_success"];
			$hc_contingent_volume_overall 	= $sql_results["hc_contingent_volume_overall"];
			$web_flatrate_validUntil 	= $sql_results["web_flatrate_validUntil"];
			$web_servicetype		= $sql_results["web_servicetype"];	# 1=volumen | 2=flat
			$hc_sec1_MD5			= $sql_results["hc_sec1_MD5"];
			$hc_sec2_MD5			= $sql_results["hc_sec2_MD5"];
			$hc_sec3_MD5			= $sql_results["hc_sec3_MD5"];
			$hc_sec4_MD5			= $sql_results["hc_sec4_MD5"];
			$hc_sec5_MD5			= $sql_results["hc_sec5_MD5"];

			## echo "DEBUG service type: '$web_servicetype'<br>";

		#	if ( $web_servicetype != 1 || $web_servicetype != 2 ) {
		#		$web_servicetype = 1;
		#	};

			# = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
		array_push($SecArray, $hc_sec1_MD5);
		array_push($SecArray, $hc_sec2_MD5);
		array_push($SecArray, $hc_sec3_MD5);
		array_push($SecArray, $hc_sec4_MD5);
		array_push($SecArray, $hc_sec5_MD5);

	} else {
		echo "Fehler beim eintragen deines Gutscheins! SQL DAten aus der bjparis TAble holen";
		exit(0);
	}; # if ( $MySqlArrayCheck ) {

	
	# echo "DEGUGGING :'$web_servicetype' <br>";

	##### Checke UP und SEC MD5 Werte
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
	


	### BJ PARIS 'hc_sec_MD5' Check - Version 1
	$isValid_1	= 0;	# Algorithmus Stufe 1 - Status Check

	# echo "AFT: isValid_1=$isValid_1 isValid_2=$isValid_2<br>";

	foreach ( $SecArray as $secMD5 ){

		# vergleiche $bj_SEC_MD5 aus dem WebParameter bj_SEC_MD5 mit den daten aus hc_secXYZ_MD5 aus der tabelle
		if ( strlen($secMD5) == 32 && strcmp($secMD5, $bj_SEC_MD5) == 0 && strlen($bj_SEC_MD5) == 32 ) {

			$isValid_1 = 1;	# setzte das Algorithmus Stufe 1 Status Flag auf Valid

		}; # if ( strlen($secMD5)

	}; # foreach ( $SecArray as $secMD5 ){


	# echo "PRE: isValid_1=$isValid_1 isValid_2=$isValid_2<br>";

	### BJ PARIS 'hc_sec_MD5' Check - Version 2
	# hier wurde der 'hc_sec_MD5' Check - Version 1 nicht erfolgreich passiert
	$isValid_2	= 0;	# Algorithmus Stufe 2 - Status Check
	
	if ( $isValid_1 != 1 ) {	# Algorithmus Stufe 1 war nicht erfolgreich, gehe zu Algorithmus Stufe 2
		
		$hc_sec_MD5_Counter = 1;	# zählt, wo wir gerade bei
		foreach ( $SecArray as $secMD5 ){

			if ( $isValid_2 != 1 ) {	# solange nichts installiert wurde
				if ( strcmp($secMD5, $bj_SEC_MD5) != 0 && strlen($secMD5) == 0 && strlen($bj_SEC_MD5) == 32 ) {
					
					# da die hc_secXYZ_MD5 spalte nicht gesetzt ist, aktualisiere diese mit dem Wert $bj_SEC_MD5, den wir als Parameter vom Web bekommen haben
					# dies machen wir, damit ein flatrate/volumen user seine zugangsdaten nicht unbegrenzt weitergeben darf
					$spalte			= "hc_sec".$hc_sec_MD5_Counter."_MD5";
					$TABLE1			= BJPARIS_TABLE;
					$SqlUpdateBJPARIS_SEC 	= "UPDATE `$TABLE1` SET `$spalte` = \"$bj_SEC_MD5\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
					$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS_SEC);
					
					if ( !$MySqlExec ) {
						echo "Fehler beim eintragen deines Gutscheins! Algorithmus Stufe 2";
						exit(0);
					};
					$isValid_2 = 1;		# setzte das Algorithmus Stufe 2 Status Flag auf Valid
					
				}; # if ( strlen($secMD5)
			}; # if ( $isValid_2 != 1 ) {

			$hc_sec_MD5_Counter++;

		}; # foreach ( $SecArray as $secMD5 ){
	}; # if ( $IsValid_1 != 1 ) {


	# echo "AFT: isValid_1=$isValid_1 isValid_2=$isValid_2<br>";

	
	### Algorithmus: Auswertung , nur wenn Stufe 1 oder Stufe 2 den korrekten Wert 1 haben ist der Coupon Request gültig
	if ( $isValid_1 == 1 ) {
	} elseif ( $isValid_2 == 1 ) {
	} else {
		# Beenden, wenn 
		echo "Deine Zugangsdaten wurden von zuvielen Handys genutzt!";
		exit(0);
	};


	##### Daten vorbereiten für bjparis Table

	### echo "DEGUG: $web_servicetype | $gift_type<br>";

	# 1=volumen | 2=flat
	if ( $web_servicetype == 1 && $gift_type == 1 ) { # user=volumentarif und coupon=volumentarif
		# user bleibt volumen und bekommt volumengutschrift
		$web_servicetype_new 	= 1;
		$user_flat_validUntil 	= $web_flatrate_validUntil;
		$user_success_search 	= $hc_contingent_volume_success + $gift_success_search;
		$user_overall_search 	= $hc_contingent_volume_overall + $gift_overall_search;
	#	echo "1 $user_flat_validUntil<br>";
	} elseif ( $web_servicetype == 1 && $gift_type == 2 ) { # user=volumentarif und coupon=flat
		# user wird flat und behält sein volumen
		$web_servicetype_new 	= 2;
		$user_flat_validUntil 	= $gift_flat_validUntil;
		$user_success_search 	= $hc_contingent_volume_success;
		$user_overall_search 	= $hc_contingent_volume_overall;
	#	echo "2 $user_flat_validUntil<br>";
	} elseif ( $web_servicetype == 2 && $gift_type == 1 ) { # user=flat und coupon=volumen
		# user bleibt flat und bekommt volumen gutschrift
		$web_servicetype_new 	= 2;
		$user_flat_validUntil 	= $web_flatrate_validUntil;
		$user_success_search 	= $hc_contingent_volume_success + $gift_success_search;
		$user_overall_search 	= $hc_contingent_volume_overall + $gift_overall_search;
	#	echo "3 $user_flat_validUntil<br>";
	} elseif ( $web_servicetype == 2 && $gift_type == 2 ) { # user=flat und coupon=flat
		# user bleibt flat und bekommt flat gutschrift
		$web_servicetype_new 	= 2;
		$user_flat_validUntil 	= AddionOfTwoDates( $web_flatrate_validUntil, $gift_flat_validUntil ); # Hinweis: zuerst Datum, und dann der Datumsbetrag Datum2 um den Datum1 es erweitert werden soll
		$user_success_search 	= $hc_contingent_volume_success;
		$user_overall_search 	= $hc_contingent_volume_overall;
	#	echo "4 $user_flat_validUntil<br>";
	} else { 	# im fehlerfall auf standart setzen
		$web_servicetype_new 	= 1;
		$user_flat_validUntil 	= $web_flatrate_validUntil;
		$user_success_search 	= $hc_contingent_volume_success;
		$user_overall_search 	= $hc_contingent_volume_overall;
	#	echo "5 error handler<br>";
	}; # if ( $web_servicetype == 1 && $gift_type == 1 ) {


	### SQL Update für bjparis vorbereiten und durchführen
	
	$TABLE1			= BJPARIS_TABLE;
	$SqlUpdateBJPARIS 	= "UPDATE `$TABLE1` SET `web_servicetype` = \"$web_servicetype_new\", `hc_contingent_volume_success` = \"$user_success_search\", `hc_contingent_volume_overall` = \"$user_overall_search\", `web_flatrate_validUntil` = \"$user_flat_validUntil\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);

	if ( !$MySqlExec ) {
		echo "Fehler beim eintragen deines Gutscheins! SQL Update für bjparis vorbereiten und durchführen";
		exit(0);
	};

	

	### SQL Update für coupon table vorbereiten und durchführen
	$gift_how_often_valid--;	# anweisen, das der coupon code einmal benutzt wurde und desshalb eins abgezogen wird
	
	# wenn alle coupon codes aufgebraucht wurden, ist dieser coupon code ungültig
	if ( $gift_how_often_valid <= 0 ) {
		$gift_how_often_valid 	= 0;
		$gift_isValid 		= 0;
	};

	$TABLE2			= COUPON_TABLE;
	$SqlUpdateCOUPON 	= "UPDATE `$TABLE2` SET `gift_how_often_valid` = \"$gift_how_often_valid\", `gift_isValid` = \"$gift_isValid\" WHERE `gift_code` = '$couponcode' LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateCOUPON);
	
	if ( !$MySqlExec ) {
		echo "Fehler beim eintragen deines Gutscheins! SQL Update für coupon table vorbereiten und durchführen";
		exit(0);
	};



	### SQL Update für used table vorbereiten und durchführen
	$TABLE4			= USED_TABLE;
	$SqlQueryUSED_TABLE	= "INSERT INTO `$TABLE4` ( `used_mobilephone`, `used_code`, `used_isaktionsgutschein`, `used_date`) VALUES ( '$MobilePhone', '$gift_code', '$gift_aktionsgutschein', '$CurrentAsciiDate' );";
	$MySqlExec 		= doSQLQuery($SqlQueryUSED_TABLE);
	
	if ( !$MySqlExec ) {
		echo "Fehler beim eintragen deines Gutscheins! SQL Update für used table vorbereiten und durchführen";
		exit(0);
	};


	### SQL Update für bill table vorbereiten und durchführen
	$TABLE3			= BILL_TABLE;
	$SqlQuery 		= "SELECT `bill_coupon_count`,`bill_coupon_searches_bygift` FROM `$TABLE3` WHERE `bill_mobilephone` = '$MobilePhone' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	if ( $MySqlArrayCheck ) {
	
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$bill_coupon_count 		= $sql_results["bill_coupon_count"];
			$bill_coupon_searches_bygift 	= $sql_results["bill_coupon_searches_bygift"];
			# = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	} else {
		echo "Fehler beim eintragen deines Gutscheins! SQL Update für bill table vorbereiten und durchführen";
		exit(0);
	}; # if ( $MySqlArrayCheck ) {


	$bill_coupon_count 		+= 1;
	$bill_coupon_searches_bygift 	+= $gift_overall_search;
	
	$TABLE3			= BILL_TABLE;
	$SqlUpdateBILL 		= "UPDATE `$TABLE3` SET `bill_coupon_count` = \"$bill_coupon_count\", `bill_coupon_searches_bygift` = \"$bill_coupon_searches_bygift\"  WHERE CONVERT( `$TABLE3`.`bill_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateBILL);

	LogUseCouponAPI($MobilePhone, $gift_code, $couponcode, $hc_contingent_volume_success, $hc_contingent_volume_overall, $web_flatrate_validUntil, $web_servicetype, $web_servicetype_new, $gift_how_often_valid, $gift_code_validUntil, $gift_success_search, $gift_overall_search, $gift_flat_validUntil, $bill_coupon_count, $bill_coupon_searches_bygift, $user_flat_validUntil, $user_success_search, $user_overall_search, $bjAccessProgramm, $bj_SEC_MD5, $bj_UP_MD5 );
	
	echo "Wir haben dir den Gutschein gutgeschrieben!";
	exit(0);

} else {
	echo "Dieser Gutschein ist ungueltig!";
	exit(0);

}; # if ( $MobilePhoneStatus == 1 && $CouponCodeStatus == 1 && $bj_SEC_MD5Status == 1 && $bj_UP_MD5Status == 1 && strlen($couponcode) == 10 ) {


function GetMobilePhone( $UP_MD5 ){

	# hole mobilfunknummer zu gegebenen up_md5 wert
	$TABLE1				= BJPARIS_TABLE;
	$SqlQuery 			= "SELECT `web_mobilephone` FROM `$TABLE1` WHERE `web_up_MD5` = '$UP_MD5' AND `hc_abuse` = '0' LIMIT 1;";
	
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);
	$sql_results		= mysql_fetch_array($MySqlArrayCheck);
	return $sql_results["web_mobilephone"];

}; # function GetMobilePhone( $UP_MD5 ){




exit(0);


/*

	WENN BEIM TESTEN HIER IN DIESEM PROGRAMM KEIN FEHLER MEHR AUFTRITT, DANN DIESE DATEI UMPROGRAMMIEREN
	UND DANN DIESE DATEI ALS URL FÜR DAS UPDATEN DES GUTSCHEINSYSTEMS VON PERL PROXY AUS
	grund: perl programm ruft einfach diese url dann auf und der gutschein wird dem user gutgeschrieben
	later: neuer query parameter: | unter service/bj_add_coupon.php neu anlegen

	dann auch noch die übergebene handynummer auf das entsprechende land prüfen und die status meldung in deutsch, englisch
	etc zurückgeben

	bj_mobilephone 	= $phone
	$bj_auth 	= $MD5	
	$bj_accesss	= perl proxy $0
	$bj_SEC_MD5	= $param
	$bj_UP_MD5	= $param
	dann siegel bilden: 

*/


?>
