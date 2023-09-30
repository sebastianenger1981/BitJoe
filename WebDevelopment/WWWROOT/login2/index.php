<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/ip2country.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

### Referer
$MobilePhone		= deleteSqlChars($_REQUEST["mobilephone"]);
$MobilePin			= deleteSqlChars($_REQUEST["pin"]);

$MobilePhoneStatus	= checkInput($MobilePhone, "I", 7, 18 );	# functions.inc.php	- input validieren
$MobilePinStatus	= checkInput($MobilePin, "M", 4, 4 );
$addional			= '';

$ChangedMobilePhone	= $_REQUEST["changed"];

if ( strlen($ChangedMobilePhone) > 7 ) {
	$addional		= "Wir haben Deine neue Handynummer $ChangedMobilePhone f&uuml;r BitJoe.de gespeichert.<br>";	# <br> hier wichtig
};


if ( $MobilePhoneStatus == 1 && $MobilePinStatus == 1 ) {

	# alles korrekt hier jetzt user einloggen

	$TABLE1			= BJPARIS_TABLE;
	$SqlQuery 		= "SELECT `web_password` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND `web_password` = '$MobilePin' AND`hc_abuse` = '0' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$SericePassword 	= $sql_results["web_password"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	if ( strcmp($MobilePin, $SericePassword) == 0 ){	# eingegebene pin korrekt

		session_start();
		session_name("BITJOEPARIS");
		$_SESSION['mobilephone'] = $MobilePhone;
		
		LoginPageScreen4( $MobilePhone );
		exit(0);

	} else {	# eingegebene pin falsche
		
		$error = formatErrorMessage("Login oder Passwort sind falsch!");
		LoginPageScreen3( $land, $error, $MobilePhone, $MobilePin, $addional );
		exit(0);

	}; # if ( strcmp($MobilePin, $SericePassword) == 0 ){


} elseif ( (strlen($MobilePhone) > 2 || strlen($MobilePin) > 2 ) && ( $MobilePhoneStatus != 1 || $MobilePinStatus != 1 ) ) { 

	$error = formatErrorMessage("Es ist ein Fehler bei der Eingabe der Handynummer oder des Passwortes aufgetreten!");
	LoginPageScreen3( $land, $error, $MobilePhone, $MobilePin, $addional );
	exit(0);


} else {	# Login wurde blank ohne parameter aufgerufen

	# normale login template ausgeben
	$referer	= htmlspecialchars(urldecode($_SERVER["HTTP_REFERER"]));
	$RemoteIP	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$iplook 	= new ip2country($RemoteIP);	# ip2country.inc.php
	$error		= "";

	if ( $iplook->LookUp() ){
		$land = $iplook->Prefix1;
	} else {
		$land = "NA";
	};

	if ( strstr($referer, "micropayment") ){
		$error = formatErrorMessage("Wir haben deinen Account akualisiert. Du kannst BitJoe sofort benutzen!");
	};

	LoginPageScreen3( $land, $error, $MobilePhone, $MobilePin, $addional );
	exit(0);
	
}; # if ( $MobilePhoneStatus == 1 && $MobilePinStatus == 1) {


exit(0);

?>