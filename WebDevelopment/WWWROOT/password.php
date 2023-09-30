<?php


require_once("/srv/server/wwwroot/lib/sms.inc.php");
require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");


$MobilePhone 		= deleteSqlChars($_REQUEST["mobilephone"]);
$MobilePhoneStatus	= checkInput($MobilePhone, "I", 7, 15 );	# functions.inc.php	- input validieren


if ( $MobilePhoneStatus == 1 ) {
	
	### check_accessed_times( SECURITY_ACCESS_PATH, MAXSIGNUPREQUESTPERDAY);	# security.inc.php

	$TABLE1			= BJPARIS_TABLE;
	$SQL			= "SELECT `web_password`,`web_mobilephone_full`,`web_country` from `$TABLE1` WHERE `web_mobilephone` = \"$MobilePhone\" AND `hc_abuse` = '0' LIMIT 1;";
	
	$MySqlArray 		= doSQLQuery($SQL);
	
	if ( $MySqlArray ) {
	
		while( $sql_results = mysql_fetch_array($MySqlArray)) {
			$Password 		= $sql_results["web_password"];
			$land			= $sql_results["web_country"];
			$MobilePhoneFull	= $sql_results["web_mobilephone_full"];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	}; # if ( $MySqlArray ) {

	if ( strlen($land) > 1 && strlen($Password) == 4 && strlen($MobilePhoneFull) > 7 ) {

		$error = formatErrorMessage("We sent your Pin by SMS to you!");
		
		if ( strstr($land, "DE") || strstr($land, "CH") || strstr($land, "AT") ){
			$SmsMessage 	= "Deine Bitjoe.de Pin ist $Password . Viel Spass mit Bitjoe.de - empfehl Bitjoe.de deinen Freunden.";
			$error 		= formatErrorMessage("Wir haben dir deinen Pin per SMS zugeschickt!");
		} elseif ( strstr($land, "GB") ){
			$SmsMessage = "Your Bitjoe.de Pin is $Password . Enjoy the Bitjoe.de Software and tell your friends.";
		} else {
			$SmsMessage = "Bitjoe.de Pin $Password . Enjoy the Bitjoe.de Software and tell your friends.";
		}; # strstr $land
		
		SendPasswordReminder( $MobilePhoneFull, $SmsMessage );
		PasswordPage( $error );
		exit(0);

	}; # if ( strlen($land) > 1 && strlen($Password) == 4 && strlen($MobilePhoneFull) > 7 ) {

} else { # if ( $MobilePhoneStatus == 1 ) {

	PasswordPage();
	exit(0);

}; # END: if ( $MobilePhoneStatus == 1 ) {


# Never reached
PasswordPage( );
exit(0);


?>