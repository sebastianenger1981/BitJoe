<?php


require_once("/srv/server/wwwroot/lib/sql.inc.php");
### require_once("/srv/server/wwwroot/lib/http.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");

# http://www.bitjoe.de/service_handypayment/call2pay_mobile.php?ip=127.0.0.1&up_md5=68035c85bcfd0de0970c142d4ed8d866&tarif=1&bj_auth=e62526bcf84865dac863350c121e8f88
# http://www.bitjoe.de/service_handypayment/call2pay_mobile.php?ip=127.0.0.1&up_md5=68035c85bcfd0de0970c142d4ed8d866&tarif=2&bj_auth=e62526bcf84865dac863350c121e8f88



$IP 			= deleteSqlChars($_REQUEST["ip"]);
$UP_MD5			= deleteSqlChars($_REQUEST["up_md5"]);
$TARIF			= deleteSqlChars($_REQUEST["tarif"]);
$HANDLE			= $_REQUEST["handle"];
$PerlApiAuthKey = deleteSqlChars($_REQUEST["bj_auth"]);

$IP_Status		= check_ip_address($IP);
$UP_MD5_Status	= checkInput($UP_MD5, "M", 32, 32 );
$TARIF_Status	= checkInput($TARIF, "I", 1, 1 );
$API_Status		= checkInput($PerlApiAuthKey, "M", 32, 32 );



### Sicherheitscheck
# echo "'$PerlApiAuthKey' und ORG: '".BITJOEPERLAPIACCESSKEY."'<br>";
# echo "[$IP] $IP_Status && $UP_MD5_Status && $TARIF_Status && $API_Status";

if ( $PerlApiAuthKey != BITJOEPERLAPIACCESSKEY ) {
	echo "";	# bei der finalen version gar nichts ausgeben
	exit(0);
}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {




if ( $IP_Status == 1 && $UP_MD5_Status == 1 && $TARIF_Status == 1 && $API_Status == 1 ){

	# Handynummer, Sprache holen 
	$TABLE1				= BJPARIS_TABLE;
	$SqlQuery 			= "SELECT `web_mobilephone`,`web_country` FROM `$TABLE1` WHERE `web_up_MD5` = '$UP_MD5' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	if ( $MySqlArrayCheck ) {

		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$PHONE	= $sql_results["web_mobilephone"];
			$LANG	= $sql_results["web_country"];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	}; # if ( $MySqlArrayCheck ) {

	### echo "'$PHONE' UND $LANG<br>";



	if ( $TARIF == 1 ){		

		$project	= 'hndypy';
		$freeparam	= 'handypaymentTarif1_call2pay_' . $PHONE . '_' . time();

	} elseif ( $TARIF == 2 ){
		
		$project	= 'btjofl5';
		$freeparam	= 'handypaymentTarif1_call2pay_' . $PHONE . '_' . time();

	} else {	# im fehlerfall
		
		$project	= 'hndypy';
		$freeparam	= 'handypaymentTarif1_call2pay_' . $PHONE . '_' . time();

	}; # if ( $TARIF == 1 ){




	# generiere micropayment session id - functions.inc.php
	$SessionID			= generateUniqueID();	

	# Micropayment API Url zusammensetzen
	$MicroPaymentURI	= "http://webservices.micropayment.de/public/c2p/v2/?accesskey=712da28a3bd0f9e7fca3e7bc0c10afef&action=STATUS&project=$project&projectcampaign=bjc2p&account=12917&webmastercampain=bjc2p&handle=$HANDLE&sessionid=$SessionID&ip=$IP&country=$LANG&language=$LANG&currency=EUR&freeparam=$freeparam";



###	# Request an micropayment api uri senden
###	$r					= new HTTPRequest($MicroPaymentURI);
###	$ResultString		= $r->DownloadToString();

	ini_set('default_socket_timeout',3);
	
	$fp = fopen($MicroPaymentURI, "r");
	while(!feof($fp)) {
		 $ResultString .= fread($fp,4096);
	};
	fclose($fp);
	

	# api content auswerten
	# expire=2008-05-18T11%3A38%3A13%2B02%3A00 number=0900+5104+666+273 numberinfo=4%2C95+EUR%2FAnruf+aus+dt.+Festnetz%2C+ggf.+abweichend+aus+Mobilnetz. duration=45
	$ContentArray		= explode("\n", $ResultString);
	$status				= "";

	foreach ( $ContentArray as $string ) {
		
		# echo "STRING=$string<br>";
		list($text,$value) = explode("=", $string);
		
		if ( strtolower($text) == "status" ) {
			$status	= $value;
		}; # if ( strtolower($text) == "status" ) {

	}; #foreach ( $ContentArray as $string ) {
	

	$status = trim($status);


	# Bezahlvorgang komplett
	if ( $status == 'COMPLETE' || strcasecmp( $status , "COMPLETE" ) == 0 ){



		# Bereite SQL Vor: Hole wichtige Daten zu einer Handynummer
		$TABLE1			= BJPARIS_TABLE;
		$SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil`,`web_mobilephone` FROM `$TABLE1` WHERE `web_up_MD5` = '$UP_MD5' LIMIT 1;";
		$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

		if ( $MySqlArrayCheck ) {
		
			while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
				
				$hc_contingent_volume_success 	= $sql_results["hc_contingent_volume_success"];
				$hc_contingent_volume_overall 	= $sql_results["hc_contingent_volume_overall"];
				$web_flatrate_validUntil 		= $sql_results["web_flatrate_validUntil"];
				$web_mobilephone				= $sql_results["web_mobilephone"];
				$DataBase_hcUserType			= $sql_results["hc_userType"];

				# = $sql_results[""];
			}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
		
		}; # if ( $MySqlArrayCheck ) {



		if ( $TARIF == 1 ){

			$BillAmount						= '2.99';
			$TarifLog						= 'handypaymentTarif1';
			$hc_userType					= 2;				# 2=paying user
			$web_servicetype				= 1;				# 1=searches | 2=flat
			
			if ( $DataBase_hcUserType == 2 ) {
				
				# wenn ein user schon bezahlt hat, bekommt er zu seinem vorhandenen guthaben etwas zusätzlich gutgeschrieben
				$hc_contingent_volume_success	+= BUY_HANDYTARIF_1_SUCCESS; 	# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
				$hc_contingent_volume_overall	+= BUY_HANDYTARIF_1_OVERALL;	# wieviele insgesamt suchanfragen sollen hinzugefügt werden
			
			} else {
			
				# user, die bis jetzt noch nicht gezahlt haben, bekommen nur das kaufvolumen gutgeschrieben
				$hc_contingent_volume_success	= 0; 							# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
				$hc_contingent_volume_overall	= 0;
				$hc_contingent_volume_success	= BUY_HANDYTARIF_1_SUCCESS; 	# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
				$hc_contingent_volume_overall	= BUY_HANDYTARIF_1_OVERALL;
			
			}; # if ( $DataBase_hcUserType == 2 ) {

			$web_flatrate_validUntil		= $web_flatrate_validUntil;

		} elseif ( $TARIF == 2 ){
			
			$BillAmount						= '4.99';
			$TarifLog						= 'handypaymentTarif2';
			$hc_userType					= 2;				# 2=paying user
			$web_servicetype				= 2;				# 1=searches | 2=flat
			
			$hc_contingent_volume_success	+= 0; 							# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
			$hc_contingent_volume_overall	+= 0;
			$web_flatrate_validUntil		= GetFlatrateValidUntilDate($web_flatrate_validUntil, 0.5); # functions.inc.php 14 tage statt 1 monat

		}; # if ( $TARIF == 1 ){	



		# Update Query vorbereiten und ausführen
		$SqlUpdateBJPARIS 	= "UPDATE `bitjoe`.`$TABLE1` SET `hc_userType` = \"$hc_userType\", `web_servicetype` = \"$web_servicetype\", `hc_contingent_volume_success` = \"$hc_contingent_volume_success\", `hc_contingent_volume_overall` = \"$hc_contingent_volume_overall\", `web_flatrate_validUntil` = \"$web_flatrate_validUntil\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$web_mobilephone\" LIMIT 1;";
		$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);
		
		if ( $MySqlExec ) {	# sql update der bjparis tabelle erfolgreich
			$error 		.= "Mobilfunknummer $web_mobilephone wurde auf Tarif $TarifLog [$TARIF] gestellt: Volumen Success $hc_contingent_volume_success | Volumen Overall $hc_contingent_volume_overall | Flat Valid Until $web_flatrate_validUntil ";
			$isSuccess 	= 1;
		} else {
			$isSuccess = 0;
			$error 		= "SQL Fehler UPDATE $TABLE1 : $SqlUpdateBJPARIS # ";
		}; # if ( $MySqlExec ) {



		# hier jetzt die tabelle payment aktualisieren
		if ( $isSuccess == 1 ) { # tabelle payment aktualsisiern
		
			$TABLE2		= BILL_TABLE;
			$SqlQuery 	= "SELECT `bill_payed_incount`,`bill_payed_amount` FROM `$TABLE2` WHERE `bill_mobilephone` = '$web_mobilephone' LIMIT 1;";
			$MySqlGet 	= doSQLQuery($SqlQuery);

			if ( $MySqlGet ) {	# sql get von payment tabelle erfolgreich
			
				while( $sql_results = mysql_fetch_array($MySqlGet)) {
					$bill_payed_incount 	= $sql_results["bill_payed_incount"];
					$bill_payed_amount 	= $sql_results["bill_payed_amount"];
					# = $sql_results[""];
				}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
		
			} else {
				$error 		.= "SQL Fehler UPDATE $TABLE2 : $MySqlGet # ";
			}; # if ( $MySqlArrayCheck ) {


			$bill_last_pay_amount	= $BillAmount;
			$bill_last_pay_isbooked	= 1;
			$bill_payed_incount	+= 1; 
			$bill_payed_amount	+= $BillAmount;
			
			$SqlUpdateBJPAYMENT 	= "UPDATE `bitjoe`.`$TABLE2` SET `bill_last_pay` = NOW(), `bill_last_pay_amount` = \"$bill_last_pay_amount\" , `bill_last_pay_isbooked` = \"$bill_last_pay_isbooked\", `bill_payed_incount` = \"$bill_payed_incount\", `bill_payed_amount` = \"$bill_payed_amount\" WHERE CONVERT( `$TABLE2`.`bill_mobilephone` USING utf8 ) = \"$web_mobilephone\" LIMIT 1;";
			$MySqlExec 		= doSQLQuery($SqlUpdateBJPAYMENT);
			
			if ( $MySqlExec ) {	
				$error .= "Payment tabelle erfolgreich angepasst";
			} else {
				$error .= "SQL Fehler UPDATE $TABLE2 : $SqlUpdateBJPAYMENT";
			}; # if ( $MySqlExec ) {

		}; # if ( $isSuccess == 1 ) { # tabelle payment aktualsisiern



	}; # if ( $status == 'COMPLETE' || strcasecmp( $status , "COMPLETE" ) == 0 ){





	# rückgabe statuswert
	echo $status;




	# Logging vorbereiten
	$tmp				= $ResultString;
	$tmp				= str_replace("\n", ", ", $tmp);
	$tmp				= $tmp . " - tarif: $freeparam ";

	LogHandyPaymentAPI( $IP, $UP_MD5, $MicroPaymentURI, $tmp, $handle );

	exit(0);

}; # if ( $IP_Status == 1 && $UP_MD5_Status == 1 && $TARIF_Status == 1 && $API_Status == 1 ){


exit(0);


/*

	if ( $TARIF == 1 ){

			$BillAmount						= '4.95';
			$TarifLog						= 'volumelow';
			$hc_userType					= 2;				# 2=paying user
			$web_servicetype				= 1;				# 1=searches | 2=flat
			$hc_contingent_volume_success	+= BUY_VOLUMENLOW_SUCCESS; 	# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
			$hc_contingent_volume_overall	+= BUY_VOLUMENLOW_OVERALL;	# wieviele insgesamt suchanfragen sollen hinzugefügt werden
			$web_flatrate_validUntil		= $web_flatrate_validUntil;

		} elseif ( $TARIF == 2 ){
			
			$BillAmount						= '9.95';
			$TarifLog						= 'volumebig';
			$hc_userType					= 2;
			$web_servicetype				= 1;
			$hc_contingent_volume_success	+= BUY_VOLUMENBIG_SUCCESS; 
			$hc_contingent_volume_overall	+= BUY_VOLUMENBIG_OVERALL;
			$web_flatrate_validUntil		= $web_flatrate_validUntil;

		} elseif ( $TARIF == 3 ){
			
			$BillAmount						= '2.99';
			$TarifLog						= 'volumehandy';
			$hc_userType					= 2;
			$web_servicetype				= 1;
			$hc_contingent_volume_success	+= BUY_VOLUMENHANDY_SUCCESS; 
			$hc_contingent_volume_overall	+= BUY_VOLUMENHANDY_OVERALL;
			$web_flatrate_validUntil		= $web_flatrate_validUntil;

		} elseif ( $TARIF == 4 ){
			
			$BillAmount						= '2.95';
			$TarifLog						= 'flathandy';
			$hc_userType					= 2;
			$web_servicetype				= 2;
			$hc_contingent_volume_success	+= 0; 
			$hc_contingent_volume_overall	+= 0;
			$web_flatrate_validUntil		= GetFlatrateValidUntilDateInDays($web_flatrate_validUntil, BUY_FLATHANDY_DAYS);

		}; # if ( $TARIF == 1 ){	

*/


?>