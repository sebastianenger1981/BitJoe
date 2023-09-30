<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");
require_once("/srv/server/wwwroot/lib/wappush.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");


header("HTTP/1.1 307 Temporary Redirect"); 
header ("Location: /"); 
exit(0);



session_start();
session_name("BITJOEPARIS");
$MobilePhone 			= $_SESSION['mobilephone'];
$MobilePhoneStatus		= checkInput($MobilePhone, "I", 4, 17 );



if ( $MobilePhoneStatus != 1 || !isset($MobilePhone) ) {

	# echo "'$MobilePhone' -'$MobilePhoneStatus' nicht angemeldet -> leite weiter auf /login/";
	header("HTTP/1.1 307 Temporary Redirect"); 
	header ("Location: /login/"); 
	exit(0);

}; # if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {


$MobilePhoneCountry	= classifyVorwahlByPhoneNumber($MobilePhone);
$MobilePhoneTo		= substr($MobilePhone , 1, strlen($MobilePhone ) );
$MobilePhoneTo		= $MobilePhoneCountry . $MobilePhoneTo;
$error				= "";


if ( $MobilePhoneStatus == 1 ){

	$TABLE1					= BJPARIS_TABLE;
	$SqlQueryAlreadyUsed	= "SELECT `web_resend_wappush` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' LIMIT 1;";
	$MySqlArrayCheck_1 		= doSQLQuery($SqlQueryAlreadyUsed);	
	$sql_results_1 			= mysql_fetch_array($MySqlArrayCheck_1);
	$WappushResendLeft	 	= $sql_results_1["web_resend_wappush"];

	### echo "du kannst dir die software noch $WappushResendLeft zusenden lassen";

	if ( $WappushResendLeft > 0 ) {	# user darf wappush nochmal anfordern

		$StatusCode 		= SendWapPushSimple( $MobilePhoneTo );	# wappush.inc.php
		if ( $StatusCode == 'OK' ) {
			$error 	= formatErrorMessage("Wir haben Dir an Deine Handynummer $MobilePhone die BitJoe.de Software nochmals zugesendet!");
			$WappushResendLeft--;
		} else {
			$error 	= formatErrorMessage("Es trat ein Serverfehler auf. Bitte melde Dich bei <a href=\"mailto:tec@swissrefresh.ch?subject=Software%20zusenden%20an%20$MobilePhone\">tec@swissrefresh.ch</a> mit Deiner Handynummer $MobilePhone um die Software nochmal zu erhalten!");
		};

		$SqlUpdateBJPARIS 	= "UPDATE `$TABLE1` SET `web_resend_wappush` = \"$WappushResendLeft\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
		$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);

	} else {	# user darf wappush NICHT nochmal anfordern

		$error 	= formatErrorMessage("Du darfst die BitJoe Software nur einmal pro Monat neu anfordern. Bitte melde Dich bei <a href=\"mailto:tec@swissrefresh.ch?subject=Software%20zusenden%20an%20$MobilePhone\">tec@swissrefresh.ch</a> mit Deiner Handynummer $MobilePhone um die Software nochmal zu erhalten!");

	};

	/*
	if ( !$MySqlExec ) {
		$error 	= formatErrorMessage("Fehler beim eintragen deines Gutscheins!");	
	};
	*/


	ResendSoftwarePage($MobilePhone, $error);
	LogResendSoftware( $MobilePhone, $StatusCode, $error );		# logging.inc.php
	exit(0);

} else {

	$error 	= formatErrorMessage("Handynummer $MobilePhone nicht im System bekannt!");
	ResendSoftwarePage($MobilePhone, $error);
	LogResendSoftware( $MobilePhone, "bybasti=handyinvalid", $error );		# logging.inc.php
	exit(0);

};


exit(0);

?>