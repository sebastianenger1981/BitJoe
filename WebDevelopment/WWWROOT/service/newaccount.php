<?php

# testurl: http://www.bitjoe.de/service/newaccount.php?ip=79.12.3.12&lang=DE&bj_auth=e62526bcf84865dac863350c121e8f88&mobilephone=0160797924
require_once("/srv/server/wwwroot/lib/sql.inc.php");
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

echo "SQL DISABLED - ENABLE IN LIVE VERSION";

$IP 				= deleteSqlChars($_REQUEST["ip"]);
$LANG 				= deleteSqlChars($_REQUEST["lang"]);
$PerlApiAuthKey		= deleteSqlChars($_REQUEST["bj_auth"]);	# security.inc.php - böse zeichen entfernen
$MobilePhone 		= deleteSqlChars($_REQUEST["mobilephone"]);	# sonderzeichen und sql commands entfernen

# auf korrekte zeichen prüfen, sprich auf integers und entsprechenden länge
$MobilePhoneStatus	= checkInput($MobilePhone, "I", 7, 12 );	# functions.inc.php	- input validieren
$PerlApiKeyStatus	= checkInput($PerlApiAuthKey, "M", 32, 32 );

if ( ( $PerlApiAuthKey != BITJOEPERLAPIACCESSKEY ) || ( $PerlApiKeyStatus != 1 ) ) {
	echo "";	# bei der finalen version gar nichts ausgeben
	LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "False PERLAPIKEY" );
	exit(0);
}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {



if ( $MobilePhoneStatus == 1 && $PerlApiKeyStatus == 1 ) {
	
	$MobilePhoneCountryVorwahl		= classifyVorwahlByPhoneNumber( $MobilePhone );	# functions.inc.php
	
	if ( strlen($MobilePhoneCountryVorwahl) == 4 ){
	
		$tmp						= $MobilePhone;
		$tmp_substr					= substr($tmp, 1, strlen($tmp)); 		# entferne die führende Null
		$MobilePhoneBeauty 			= $MobilePhoneCountryVorwahl . $tmp_substr;	# Ländervorwahl plus Rufnummer
		$Country					= classifyCountryByPhoneNumber( $MobilePhone );
		$isSuccess = 1;

	} else {

		$MobilePhoneBeauty 			= $MobilePhone;
		$Country					= "NA";

	}; # if ( strlen($MobilePhoneCountryVorwahl) == 4 ){



	#	START: SQL COMMANDOS Ausfüllen mit werten füllen, standart user
	$UserPIN				= generatePassword();				# functions.inc.php	- PIN für user generieren
	$web_up_MD5				= md5($MobilePhone.$UserPIN);
	$overall_searches		= BITJOEHANDY_STANDART_VOLUME_OVERALL;
	$successfull_searches 	= BITJOEHANDY_STANDART_VOLUME_SUCCESS;
	$TABLE1					= BJPARIS_TABLE;
	$REMOTE					= $IP;
	$SqlQueryBJTABLE		= "";

	# Achtung: BitJoeHandy anmeldungen dürfen sich das update nicht kostenlos nochmals zusenden lassen, sie müssen für ein update bezahlen
	$SqlQueryBJTABLE		= "INSERT INTO `$TABLE1` ( `web_mobilephone`,`web_mobilephone_full`,`web_ref_PP`,`web_grp_PP`,`web_ref_UID`,`web_ref_URL`, `web_lead_istracked`,`web_signup_date`,`web_signup_remote`,`web_servicetype`, `web_password`,`web_up_MD5`, `web_country`,`web_testaccount`,`hc_contingent_volume_success`,`hc_contingent_volume_overall`, `hc_userType`,`hc_abuse`,`web_resend_wappush`) VALUES ( '$MobilePhone','$MobilePhoneBeauty', '$refPP', '$grpPP', '0', '$refURL', '0', NOW(), '$REMOTE', '1', '$UserPIN', '$web_up_MD5' , '$Country' , '0', '$successfull_searches', '$overall_searches', '1','0', '0' );";

	$TABLE3					= BILL_TABLE;
	$SqlQueryBILL_TABLE		= "";
	$SqlQueryBILL_TABLE		= "INSERT INTO `$TABLE3` ( `bill_mobilephone`) VALUES ( '$MobilePhone' );";
	#	END: SQL COMMANDOS Ausfüllen mit werten füllen, standart user




	#	Checke, ob Mobilfunnummer schon in unserer Datenbank besteht
	$SqlQuery 			= "SELECT `web_mobilephone` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	if ( $MySqlArrayCheck ) {

		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$PHONE = $sql_results["web_mobilephone"];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

		if ( strcmp($PHONE, $MobilePhone) == 0 ){

			$msg_de = "Mobilfunknummer $MobilePhone ist bereits in der www.bitjoe.de Datenbank vorhanden! Wir haben keinen neuen Account erstellt.";
			$msg_en = "The mobile phone number $MobilePhone already exists in the www.bitjoe.de database. We didn't create a new account.";
			
			if ( $LANG == 'de' || $LANG == 'DE' ){
				echo "2##$msg_de##----";
				LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "2##$msg_de##----" );
			} else{
				echo "2##$msg_en##----";
				LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "2##$msg_en##----" );
			}; # if ( $LANG == 'de' || $LANG == 'DE' ){

			exit(0);

		}; # if ( strcmp($PHONE, $MobilePhoneBeauty) == 0 ){

	}; # if ( $MySqlArrayCheck ) {




	# wir wollen, eigentlich alle accounterstellungen durchgehen lassen, darum kein success check
###	if ( $isSuccess == 1 ){

		# Handynummer gültig - Handynummer eingabe Input validiert - korrektes Land

		session_start();
		session_name("BITJOEPARIS");
		$SessionId						= session_id();
		$_SESSION['mobilephone'] 		= $MobilePhone;
		$_SESSION['mobilephonefull'] 	= $MobilePhoneBeauty;

		# es gab keine Fehler bei der Eingabe darum stelle die Daten in die SQL Datenbank ein
	###	$MySqlArray1 					= doSQLQuery($SqlQueryBJTABLE);
	###	$MySqlArray2 					= doSQLQuery($SqlQueryBILL_TABLE);

	#	echo "BJ $SqlQueryBJTABLE<br>";
	#	echo "BI $SqlQueryBILL_TABLE<br>";

		$msg_de = "Wir haben fuer die Handynummer $MobilePhone einen neuen www.bitjoe.de Account erstellt!";
		$msg_en = "We created a new www.bitjoe.de account for your mobile phone number $MobilePhone";
		
		if ( $LANG == 'de' || $LANG == 'DE' ){
			echo "1##$msg_de##$UserPIN";
			LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "1##$msg_de##$UserPIN" );
		} else{
			echo "1##$msg_en##$UserPIN";
			LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "1##$msg_en##$UserPIN" );
		}; # if ( $LANG == 'de' || $LANG == 'DE' ){
	
		exit(0);

###	}; # if ( $isSuccess == 1 ){



} else {

	$msg_de = "Mobilfunknummer $MobilePhone ist ungueltig!";
	$msg_en = "mobile phone number $MobilePhone is not valid";
	
	if ( $LANG == 'de' || $LANG == 'DE' ){
		echo "0##$msg_de##----";
		LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "0##$msg_de##----" );
	} else{
		echo "0##$msg_en##----";
		LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, "0##$msg_en##----" );
	}; # if ( $LANG == 'de' || $LANG == 'DE' ){

	exit(0);

}; # if ( $MobilePhoneStatus == 1 && $PreMobilePhoneStatus == 1 ) {



exit(0);


?>