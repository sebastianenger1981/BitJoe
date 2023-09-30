<?php


require_once("/srv/server/wwwroot/lib/sms.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
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

session_start();
session_name("BITJOEPARIS");
$MobilePhone 		= $_SESSION['mobilephone'];
$MobilePhoneStatus	= checkInput($MobilePhone, "M", 4, 17 );
$MobilePhoneOfSender	= $MobilePhone;

if ( $MobilePhoneStatus != 1 || !isset($MobilePhone) ) {

	# echo "'$MobilePhone' -'$MobilePhoneStatus' nicht angemeldet -> leite weiter auf /login/";
	header("HTTP/1.1 307 Temporary Redirect"); 
	header ("Location: /login/"); 
	exit(0);

}; # if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {


$MobilePhonePre 	= deleteSqlChars($_REQUEST["prenumber"]);
$MobilePhoneAft 	= deleteSqlChars($_REQUEST["mobilephone"]);	
$MobilePhoneStatusPre	= checkInput($MobilePhonePre, "I", 3, 5 );
$MobilePhoneStatusAft	= checkInput($MobilePhoneAft, "I", 4, 12 );
$MobilePhoneTo		= $MobilePhonePre . $MobilePhoneAft;

$MobilePhoneCountry	= classifyVorwahlByPhoneNumber($MobilePhoneTo);
$MobilePhoneTo		= substr($MobilePhoneTo, 1, strlen($MobilePhoneTo) );
$MobilePhoneTo		= $MobilePhoneCountry . $MobilePhoneTo;
$error			= "";


if ( $MobilePhoneStatusPre == 1 && $MobilePhoneStatusAft == 1 && strlen($MobilePhoneCountry) == 4 ){

	check_accessed_times( SECURITY_ACCESS_PATH, MAXTELLAFRIENDREQUESTPERDAY);	# security.inc.php

	$StatusCode 		= SendTellAFriendMessage( $MobilePhoneTo, $MobilePhoneOfSender );	# sms.inc.php
	if ( $StatusCode == 100 ) {
		$error 	= formatErrorMessage("Benachrichtigung verschickt!");
	};

	TellAFriendPage($MobilePhoneOfSender, $error);
	LogTellAFriend( $MobilePhoneOfSender, $MobilePhoneTo, $StatusCode );		# logging.inc.php
	exit(0);

## } elseif ( $MobilePhoneStatus != 1 ) {
##
##	$error = formatErrorMessage("Mobilfunknummer $MobilePhone ist ung&uuml;ltig!");
##	TellAFriendPage($error);
##	exit(0);

} else {

	TellAFriendPage($MobilePhoneOfSender);
	exit(0);

};

exit(0);

?>