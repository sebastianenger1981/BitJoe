<?php

#require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/payment.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/sql.inc.php");
#require_once("/srv/server/wwwroot/lib/security.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

### Referer
$zahlmethode		= $_REQUEST["zahlmethode"];
$mobilephone		= str_replace(" ","", $_REQUEST["mobile"]);
$mobilephone_full	= classifyVorwahlByPhoneNumber($mobilephone);
$tmp				= $mobilephone;
$tmp_substr			= substr($tmp, 1, strlen($tmp)); 		# entferne die führende Null
$MobilePhoneBeauty 	= $mobilephone_full . $tmp_substr;	# Ländervorwahl plus Rufnummer


# START: SQL COMMANDOS Ausfüllen mit werten füllen, standart user
$UserPIN				= generatePasswordForHandyAnmeldung();				
$web_up_MD5				= md5($mobilephone.$UserPIN);
$overall_searches		= BITJOEHANDY_STANDART_VOLUME_OVERALL;
$successfull_searches 	= BITJOEHANDY_STANDART_VOLUME_SUCCESS;
$TABLE1					= BJPARIS_TABLE;
$REMOTE					= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
$SqlQueryBJTABLE		= "";

# Achtung: BitJoeHandy anmeldungen dürfen sich das update nicht kostenlos nochmals zusenden lassen, sie müssen für ein update bezahlen
$SqlQueryBJTABLE		= "INSERT INTO `$TABLE1` ( `web_mobilephone`,`web_mobilephone_full`,`web_ref_PP`,`web_grp_PP`,`web_ref_UID`,`web_ref_URL`, `web_lead_istracked`,`web_signup_date`,`web_signup_remote`,`web_servicetype`, `web_password`,`web_up_MD5`, `web_country`,`web_testaccount`,`hc_contingent_volume_success`,`hc_contingent_volume_overall`, `hc_userType`,`hc_abuse`,`web_resend_wappush`) VALUES ( '$mobilephone','$MobilePhoneBeauty', '$refPP', '$grpPP', '0', 'Anmeldung_Startseiten_User', '0', NOW(), '$REMOTE', '1', '$UserPIN', '$web_up_MD5' , 'DE' , '0', '$successfull_searches', '$overall_searches', '3', '0', '0' );";

$TABLE3					= BILL_TABLE;
$SqlQueryBILL_TABLE		= "";
$SqlQueryBILL_TABLE		= "INSERT INTO `$TABLE3` ( `bill_mobilephone`) VALUES ( '$mobilephone' );";

# stelle die Daten in die SQL Datenbank ein
$MySqlArray1 	= doSQLQuery($SqlQueryBJTABLE);
$MySqlArray2 	= doSQLQuery($SqlQueryBILL_TABLE);

if ( $zahlmethode == 'ebank' ){
	$PaymentURI	= eBankStartseite($mobilephone);
} elseif ( $zahlmethode == 'phone' ){
	$PaymentURI = Call2PayStartseite($mobilephone);
} elseif ( $zahlmethode == 'paypal' ){
	
};

$PaymentURI = Call2PayStartseite($mobilephone);
header( "Location: $PaymentURI" ) ;
exit(0);

?>