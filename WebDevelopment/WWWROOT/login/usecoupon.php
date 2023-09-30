<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");


session_start();
session_name("BITJOEPARIS");
$MobilePhone 		= $_SESSION['mobilephone'];
$MobilePhoneStatus	= checkInput($MobilePhone, "M", 4, 17 );


if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {

# echo "'$MobilePhone' -'$MobilePhoneStatus' nicht angemeldet -> leite weiter auf /login/";
	header("HTTP/1.1 307 Temporary Redirect"); 
	header ("Location: /login/"); 
	exit(0);

}; # if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {


$couponcode 		= strtolower(deleteSqlChars($_REQUEST["couponcode"]));
$couponcodeStatus	= checkInput($couponcode, "M", 10, 10 );
$error 			= formatErrorMessage("Gutschrift erfolgreich!");
################


if ( $couponcodeStatus == 1 && strlen($couponcode) == 10 ){


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
			$error 	= formatErrorMessage("Du darfst einen Gutschein nicht mehrmals einl&ouml;sen!");	
			UseCouponPage($MobilePhone,$error);
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

		$error 	= formatErrorMessage("Du darfst nur " .MAXCOUPONSTOUSEADAY. " Gutscheine am Tag einl&ouml;sen!");	
		UseCouponPage($MobilePhone,$error);
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

				$error 	= formatErrorMessage("Du hast versucht einen weiteren Aktionsgutschein einl&ouml;sen. Insgesamt darfst du jedoch nur 1 Aktionsgutschein einl&ouml;sen!");	
				UseCouponPage($MobilePhone,$error);
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
			$gift_aktionsgutschein 	= $sql_results["gift_aktionsgutschein"];
			$gift_code		= strtolower($sql_results["gift_code"]);
			# $ = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	} else { # if ($MySqlArrayCheck) {
		$error 	= formatErrorMessage("Fehler beim eintragen deines Gutscheins");	
	};


	# Code schon aufgebraucht 
	if ( strcmp($couponcode , $gift_code) != 0 ) {
		$error 	= formatErrorMessage("Der Gutschein ist nicht g&uuml;ltig!");	
		UseCouponPage($MobilePhone,$error);
		exit(0);
	}; # if ( strcasecmp($couponcode , $gift_code) != 0 ) {
	



	### SQL DAten aus der bjparis TAble holen
	$TABLE1			= BJPARIS_TABLE;
	$SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil`,`web_servicetype` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND `hc_abuse` = '0' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	if ( $MySqlArrayCheck ) {
	
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$hc_contingent_volume_success 	= $sql_results["hc_contingent_volume_success"];
			$hc_contingent_volume_overall 	= $sql_results["hc_contingent_volume_overall"];
			$web_flatrate_validUntil 	= $sql_results["web_flatrate_validUntil"];
			$web_servicetype		= $sql_results["web_servicetype"];	# 1=volumen | 2=flat
			if ( $web_servicetype != 1 || $web_servicetype != 2 ) {
				$web_servicetype = 1;
			};
			# = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	} else {
		$error 	= formatErrorMessage("Fehler beim eintragen deines Gutscheins");	
	}; # if ( $MySqlArrayCheck ) {


	##### Daten vorbereiten für bjparis Table

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
	} else {	# im fehlerfall auf standart setzen
		$web_servicetype_new 	= 1;
		$user_flat_validUntil 	= $web_flatrate_validUntil;
		$user_success_search 	= $hc_contingent_volume_success;
		$user_overall_search 	= $hc_contingent_volume_overall;
	}; # if ( $web_servicetype == 1 && $gift_type == 1 ) {
	

	### SQL Update für bjparis vorbereiten und durchführen
	$TABLE1			= BJPARIS_TABLE;
	$SqlUpdateBJPARIS 	= "UPDATE `$TABLE1` SET `web_servicetype` = \"$web_servicetype_new\", `hc_contingent_volume_success` = \"$user_success_search\", `hc_contingent_volume_overall` = \"$user_overall_search\", `web_flatrate_validUntil` = \"$user_flat_validUntil\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);

	if ( !$MySqlExec ) {
		$error 	= formatErrorMessage("Fehler beim eintragen deines Gutscheins!");	
	};

	### echo "<br>DEBUG: $user_flat_validUntil = $web_flatrate_validUntil + $gift_flat_validUntil<br>";



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




	### SQL Update für used table vorbereiten und durchführen
	$TABLE4			= USED_TABLE;
	$SqlQueryUSED_TABLE	= "INSERT INTO `$TABLE4` ( `used_mobilephone`, `used_code`, `used_isaktionsgutschein`, `used_date`) VALUES ( '$MobilePhone', '$gift_code', '$gift_aktionsgutschein', '$CurrentAsciiDate' );";
	$MySqlExec 		= doSQLQuery($SqlQueryUSED_TABLE);
	
	if ( !$MySqlExec ) {
		$error 	= formatErrorMessage("Fehler beim eintragen deines Gutscheins!Update der Used Table!");	
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
		$error 	= formatErrorMessage("Fehler beim eintragen deines Gutscheins testmessage");	
	}; # if ( $MySqlArrayCheck ) {


	$bill_coupon_count 		+= 1;
	$bill_coupon_searches_bygift 	+= $gift_overall_search;
	
	$TABLE3			= BILL_TABLE;
	$SqlUpdateBILL 		= "UPDATE `$TABLE3` SET `bill_coupon_count` = \"$bill_coupon_count\", `bill_coupon_searches_bygift` = \"$bill_coupon_searches_bygift\"  WHERE CONVERT( `$TABLE3`.`bill_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateBILL);

	# Page wieder ausgeben und Loggin
	UseCouponPage($MobilePhone, $error);
	LogUseCouponWeb($MobilePhone, $gift_code, $couponcode, $hc_contingent_volume_success, $hc_contingent_volume_overall, $web_flatrate_validUntil, $web_servicetype, $web_servicetype_new, $gift_how_often_valid, $gift_code_validUntil, $gift_success_search, $gift_overall_search, $gift_flat_validUntil, $bill_coupon_count, $bill_coupon_searches_bygift, $user_flat_validUntil, $user_success_search, $user_overall_search );
	
	exit(0);

} else {

	UseCouponPage($MobilePhone,"");
	exit(0);

}; # if ( $couponcodeStatus == 1 && strlen($couponcode) == 10 ){


exit(0);

?>