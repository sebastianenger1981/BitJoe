<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

### Referer
$MobilePhone		= deleteSqlChars($_REQUEST["mobilephone"]);
$MobileTarif		= deleteSqlChars($_REQUEST["tarifaccess"]);
$BillAmount		= deleteSqlChars($_REQUEST["amount"]);
$BillAmount		= str_replace(",", ".", $BillAmount);	# komma durch punkt ersetzen

$MobilePhoneStatus	= checkInput($MobilePhone, "I", 7, 18 );	# functions.inc.php	- input validieren
$MobileTarifStatus	= checkInput($MobileTarif, "M", 5, 8 );


if ( $MobilePhoneStatus == 1 && $MobileTarifStatus == 1 && isset($BillAmount) ) {

	$TABLE1			= BJPARIS_TABLE;
	$SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);
	
	
	if ( $MySqlArrayCheck ) {
	
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$hc_contingent_volume_success 	= $sql_results["hc_contingent_volume_success"];
			$hc_contingent_volume_overall 	= $sql_results["hc_contingent_volume_overall"];
			$web_flatrate_validUntil 	= $sql_results["web_flatrate_validUntil"];
			# = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	}; # if ( $MySqlArrayCheck ) {
	
	if ( strcmp($MobileTarif, "volume10") == 0 ){

		$hc_userType			= 2;	# 2=paying user
		$web_servicetype		= 1;	# 1=searches | 2=flat
		$hc_contingent_volume_success	+= 10; 	# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
		$hc_contingent_volume_overall	+= 25;	# wieviele insgesamt suchanfragen sollen hinzugefügt werden
		$web_flatrate_validUntil	= "0000-00-00";

	} elseif ( strcmp($MobileTarif, "volume30") == 0 ){
		
		$hc_userType			= 2;
		$web_servicetype		= 1;
		$hc_contingent_volume_success	+= 30; 
		$hc_contingent_volume_overall	+= 85;
		$web_flatrate_validUntil	= "0000-00-00";

	} elseif ( strcmp($MobileTarif, "flat3") == 0 ){

		$hc_userType			= 2;
		$web_servicetype		= 2;	# 2=flat
		$hc_contingent_volume_success	+= 0; 
		$hc_contingent_volume_overall	+= 0;
		$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 3); # functions.inc.php

	} elseif ( strcmp($MobileTarif, "flat6") == 0 ){

		$hc_userType			= 2;
		$web_servicetype		= 2;	# 2=flat
		$hc_contingent_volume_success	+= 0; 
		$hc_contingent_volume_overall	+= 0;
		$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 6); # functions.inc.php

	} elseif ( strcmp($MobileTarif, "flat12") == 0 ){

		$hc_userType			= 2;
		$web_servicetype		= 2;	# 2=flat
		$hc_contingent_volume_success	+= 0; 
		$hc_contingent_volume_overall	+= 0;
		$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 12); # functions.inc.php

	} elseif ( strcmp($MobileTarif, "flat24") == 0 ){

		$hc_userType			= 2;
		$web_servicetype		= 2;	# 2=flat
		$hc_contingent_volume_success	+= 0; 
		$hc_contingent_volume_overall	+= 0;
		$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 24); # functions.inc.php

	}; # if ( strcmp($PHONE, $MobilePhoneBeauty) == 0 ){



	/*
		Update Query vorbereiten und ausführen
	*/

	$SqlUpdateBJPARIS ="UPDATE `bitjoe`.`$TABLE1` SET `hc_userType` = \"$hc_userType\", `web_servicetype` = \"$web_servicetype\", `hc_contingent_volume_success` = \"$hc_contingent_volume_success\", `hc_contingent_volume_overall` = \"$hc_contingent_volume_overall\", `web_flatrate_validUntil` = \"$web_flatrate_validUntil\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	
	$MySqlExec = doSQLQuery($SqlUpdateBJPARIS);
	
	if ( $MySqlExec ) {	# sql update der bjparis tabelle erfolgreich

		$error = formatErrorMessage("Mobilfunknummer $MobilePhone wurde auf Tarif $MobileTarif gestellt: Volumen Success $hc_contingent_volume_success | Volumen Overall $hc_contingent_volume_overall | Flat Valid Until $web_flatrate_validUntil");
		
		$isSuccess = 1;

	} else {
		
		$isSuccess = 0;
		$phone_error = formatErrorMessage("SQL Fehler: $SqlUpdateBJPARIS");
		
	}; # if ( $MySqlExec ) {

	# hier jetzt die tabelle payment aktualisieren
	if ( $isSuccess == 1 ) { # tabelle payment aktualsisiern
	
		$TABLE2		= BILL_TABLE;
		$SqlQuery 	= "SELECT `bill_payed_incount`,`bill_payed_amount` FROM `$TABLE2` WHERE `bill_mobilephone` = '$MobilePhone' LIMIT 1;";
		$MySqlGet 	= doSQLQuery($SqlQuery);

		if ( $MySqlGet ) {	# sql get von payment tabelle erfolgreich
		
			while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
				$bill_payed_incount 	= $sql_results["bill_payed_incount"];
				$bill_payed_amount 	= $sql_results["bill_payed_amount"];
				# = $sql_results[""];
			}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
		} else {
			echo "SQL ERROR: $SqlQuery<br>";
		}; # if ( $MySqlArrayCheck ) {


		$bill_last_pay_amount	= $BillAmount;
		$bill_last_pay_isbooked	= 1;
		$bill_payed_incount	+= 1; 
		$bill_payed_amount	+= $BillAmount;
		
		$SqlUpdateBJPAYMENT ="UPDATE `bitjoe`.`$TABLE2` SET `bill_last_pay` = NOW(), `bill_last_pay_amount` = \"$bill_last_pay_amount\" , `bill_last_pay_isbooked` = \"$bill_last_pay_isbooked\", `bill_payed_incount` = \"$bill_payed_incount\", `bill_payed_amount` = \"$bill_payed_amount\" WHERE CONVERT( `$TABLE2`.`bill_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
		
		$MySqlExec = doSQLQuery($SqlUpdateBJPAYMENT);
		
		if ( $MySqlExec ) {	
	
			$error2 = formatErrorMessage("Payment tabelle erfolgreich angepasst");
		
		} else {
	
			$error2 = formatErrorMessage("SQL Fehler: $SqlUpdateBJPAYMENT");
			
		}; # if ( $MySqlExec ) {

	}; # if ( $isSuccess == 1 ) { # tabelle payment aktualsisiern

	BJAdminPage($error, $error2);
	exit(0);


} else {	# keine request parameter darum normal die admin seite ausgeben

	BJAdminPage("","");
	exit(0);
	
}; # if ( $MobilePhoneStatus == 1 && $MobileTarifStatus == 1) {


exit(0);

?>