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

check_accessed_times( SECURITY_ACCESS_PATH, MAXSIGNUPREQUESTPERDAY);	# security.inc.php


$refURL 		= deleteSqlChars($_REQUEST["refURL"]);		# security.inc.php - böse zeichen entfernen
$refURL			= htmlspecialchars(urldecode($refURL));

if ( strlen($refURL) <= 0 ) {
	$refURL = htmlspecialchars(urldecode($_SERVER["HTTP_REFERER"]));
};

$refPP 			= deleteSqlChars($_REQUEST["refPP"]);
$grpPP 			= deleteSqlChars($_REQUEST["grpPP"]);

# referer checken auf gültigkeit
$refPP_isValid		= checkRefererPP( $refPP );			# functions.inc.php
$grpPP_isValid		= checkRefererPP( $grpPP );	

$PreMobilePhone		= deleteSqlChars($_REQUEST["prenumber"]);
$MobilePhone 		= deleteSqlChars($_REQUEST["mobilephone"]);	# sonderzeichen und sql commands entfernen

# auf korrekte zeichen prüfen, sprich auf integers und entsprechenden länge
$MobilePhoneStatus	= checkInput($MobilePhone, "I", 7, 12 );	# functions.inc.php	- input validieren
$PreMobilePhoneStatus	= checkInput($PreMobilePhone, "I", 3, 5 );

$isSuccess 		= 0;

# ungültige referer gehen auf das firmenkonto
if ( $refPP_isValid != 1 ){	
	$refPP = 0;
}; # if ( $refPP_isValid == 1 ){

if ( $grpPP_isValid != 1 ){	
	$grpPP = 0;
}; # if ( $grpPP_isValid != 1 ){



if ( $MobilePhoneStatus == 1 && $PreMobilePhoneStatus == 1 ) {
	
	$MobilePhoneFull		= $PreMobilePhone . $MobilePhone; 	# Vorwahl und Mobilfunknummer: zb 0160 7979247
	$MobilePhoneCountryVorwahl	= classifyVorwahlByPhoneNumber( $MobilePhoneFull );	# functions.inc.php
	$tmp				= $MobilePhoneFull;
	$tmp_substr			= substr($tmp, 1, strlen($tmp)); 		# entferne die führende Null
	$MobilePhoneBeauty 		= $MobilePhoneCountryVorwahl . $tmp_substr;	# Ländervorwahl plus Rufnummer
	$Country			= classifyCountryByPhoneNumber( $MobilePhoneFull );

	if ( strlen($MobilePhoneCountryVorwahl) > 1 ) {
		$isSuccess = 1;
	}; # if ( strlen($MobilePhoneCountryVorwahl) > 1 ) {

} else {

	$phone_error = formatErrorMessage("Mobilfunknummer $MobilePhoneFull ist ung&uuml;ltig!");
	IndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, $phone_error );
	LogAccessIndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, $phone_error );
	exit(0);

}; # if ( $MobilePhoneStatus == 1 && $PreMobilePhoneStatus == 1 ) {




/*
	START: SQL COMMANDOS Ausfüllen mit werten füllen, standart user
*/
$UserPIN		= generatePassword();				# functions.inc.php	- PIN für user generieren
$web_up_MD5		= md5($MobilePhoneFull.$UserPIN);
$overall_searches	= STANDART_VOLUME_OVERALL;
$successfull_searches 	= STANDART_VOLUME_SUCCESS;
$TABLE1			= BJPARIS_TABLE;
$REMOTE			= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
$SqlQueryBJTABLE	= "";
$SqlQueryBJTABLE	= "INSERT INTO `$TABLE1` ( `web_mobilephone`,`web_mobilephone_full`,`web_ref_PP`,`web_grp_PP`,`web_ref_UID`,`web_ref_URL`, `web_lead_istracked`,`web_signup_date`,`web_signup_remote`,`web_servicetype`, `web_password`,`web_up_MD5`, `web_country`,`web_testaccount`,`hc_contingent_volume_success`,`hc_contingent_volume_overall`, `hc_userType`,`hc_abuse`) VALUES ( '$MobilePhoneFull','$MobilePhoneBeauty', '$refPP', '$grpPP', '0', '$refURL', '0', NOW(), '$REMOTE', '1', '$UserPIN', '$web_up_MD5' , '$Country' , '0', '$successfull_searches', '$overall_searches', '1','0' );";

$TABLE3			= BILL_TABLE;
$SqlQueryBILL_TABLE	= "";
$SqlQueryBILL_TABLE	= "INSERT INTO `$TABLE3` ( `bill_mobilephone`) VALUES ( '$MobilePhoneFull' );";
/*
	END: SQL COMMANDOS Ausfüllen mit werten füllen, standart user
*/


/*
	Checke, ob Mobilfunnummer schon in unserer Datenbank besteht
*/
$SqlQuery 		= "SELECT `web_mobilephone` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhoneFull' LIMIT 1;";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$PHONE = $sql_results["web_mobilephone"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	if ( strcmp($PHONE, $MobilePhoneFull) == 0 ){

		$phone_error = formatErrorMessage("Mobilfunknummer $MobilePhoneFull ist bereits in unserer Datenbank vorhanden!");
		IndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, $phone_error );
		LogAccessIndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, $phone_error );
		exit(0);

	}; # if ( strcmp($PHONE, $MobilePhoneBeauty) == 0 ){

}; # if ( $MySqlArrayCheck ) {



if ( $isSuccess == 1 ){

	# Handynummer gültig - Handynummer eingabe Input validiert - korrektes Land

	session_start();
	session_name("BITJOEPARIS");
	$SessionId			= session_id();
	$_SESSION['mobilephone'] 	= $MobilePhoneFull;
	$_SESSION['mobilephonefull'] 	= $MobilePhoneBeauty;

	# es gab keine Fehler bei der Eingabe darum stelle die Daten in die SQL Datenbank ein
	$MySqlArray1 	= doSQLQuery($SqlQueryBJTABLE);
	$MySqlArray2 	= doSQLQuery($SqlQueryBILL_TABLE);

#	echo "BJ $SqlQueryBJTABLE<br>";
#	echo "BI $SqlQueryBILL_TABLE<br>";
#	echo "CO $SqlQueryCOUPON_TABLE<br>";

}; # if ( $isSuccess == 1 ){


ScreenStep2( $MobilePhoneFull ); 
exit(0);


?>