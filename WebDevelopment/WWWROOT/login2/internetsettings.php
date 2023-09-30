<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/wappush.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

session_start();
session_name("BITJOEPARIS");
$MobilePhone 			= $_SESSION['mobilephone'];

### Referer
$SettingsNeeded			= $_REQUEST["needed"];
$SettingsNeededStatus	= checkInput($SettingsNeeded, "M", 2, 4 );	# functions.inc.php	- input validieren


if ( $SettingsNeededStatus == 1 ) {

	if ( $SettingsNeeded == 'ja' ){
		
		###
		# USer benötigt die Settings
		###

		### Later: SMS mit konfigurationseinstellungen
		LoginPageScreen4aUserwahl( $MobilePhone );
		exit(0);

	} elseif ( $SettingsNeeded == 'nein' ){
		
		###
		# User braucht die Settings nicht
		###


		# Hole vollständige Handynummer
		$TABLE1				= BJPARIS_TABLE;
		$SqlQuery 			= "SELECT `web_mobilephone_full` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND `hc_abuse` = '0' LIMIT 1;";
		$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$web_mobilephone_full 	= $sql_results["web_mobilephone_full"];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
		
		# leite auf /hilfe weiter
		header("HTTP/1.1 301 Moved Permanently");
		header("Location: /hilfe/"); 
		
		# Sende Wappush
		SendWapPushSimple( $web_mobilephone_full );

		exit(0);	
	
	}; # if ( $SettingsNeeded == 'ja' ){

} else {

	echo "error";

	# leite auf /hilfe weiter
	header("HTTP/1.1 301 Moved Permanently");
	header("Location: /hilfe/"); 
	exit(0);

}; # if ( $SettingsNeededStatus == 1 ) {


exit(0);

?>