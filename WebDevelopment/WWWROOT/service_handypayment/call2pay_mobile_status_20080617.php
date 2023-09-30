<?php


require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/http.inc.php");
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

		$project	= 'btjovf';
		$freeparam	= 'volumelow_call2pay_' . $PHONE . '_' . time();

	} elseif ( $TARIF == 2 ){

		$project	= 'btjovo';
		$freeparam	= 'volumebig_call2pay_' . $PHONE . '_' .time();

	} else {	# im fehlerfall
		
		$project	= 'btjovf';
		$freeparam	= 'volumelow_call2pay_' . $PHONE . '_' . time();

	}; # if ( $TARIF == 1 ){

	# generiere micropayment session id - functions.inc.php
	$SessionID			= generateUniqueID();	

	# Micropayment API Url zusammensetzen
	$MicroPaymentURI	= "http://webservices.micropayment.de/public/c2p/v2/?accesskey=712da28a3bd0f9e7fca3e7bc0c10afef&action=STATUS&project=$project&projectcampaign=bjc2p&account=12917&webmastercampain=bjc2p&handle=$HANDLE&sessionid=$SessionID&ip=$IP&country=$LANG&language=$LANG&currency=EUR&freeparam=$freeparam";

	# Request an micropayment api uri senden
	$r					= new HTTPRequest($MicroPaymentURI);
	$ResultString		= $r->DownloadToString();

	
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
	
	echo trim($status);

	# Logging vorbereiten
	$tmp				= $ResultString;
	$tmp				= str_replace("\n", ", ", $tmp);

	LogHandyPaymentAPI( $IP, $UP_MD5, $MicroPaymentURI, $tmp, $handle );

	exit(0);

}; # if ( $IP_Status == 1 && $UP_MD5_Status == 1 && $TARIF_Status == 1 && $API_Status == 1 ){


exit(0);


?>