<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/sms.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/class.phpmailer.inc.php");
require_once("/srv/server/wwwroot/lib/wappush.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");


session_start();
session_name("BITJOEPARIS");

$UserName	= $_SESSION['username'];
$UserPIN	= $_SESSION['userpassword'];
$IsUserType	= $_SESSION['IsUserType'];



######## START: Security Check #########
if ( strlen($UserName) < 4 || strlen($UserPIN) < 4 ) {

	header( "HTTP/1.1 301 Moved Permanently" ); 
	header ("http://www.bitjoe.de/anmeldung-pro-user/"); 
	exit(0);

}; # if ( strcmp($auth, MOBILANTHIDDENKEY ) != 0 ) {
######## END: Security Check #########



$sms_checkbox			= $_REQUEST["sms"];
$email_checkbox			= $_REQUEST["email"];


$PreMobilePhone			= deleteSqlChars($_REQUEST["prenumber"]);
$MobilePhone 			= deleteSqlChars($_REQUEST["mobilephone"]);	# sonderzeichen und sql commands entfernen

$PreMobilePhoneStatus	= checkInput($PreMobilePhone, "I", 3, 5 );
$MobilePhoneStatus		= checkInput($MobilePhone, "I", 7, 12 );	# functions.inc.php	- input validieren

$MobilePhoneFull		= $PreMobilePhone . $MobilePhone; 	# Vorwahl und Mobilfunknummer: zb 0160 7979247

$emailadresse			= deleteSqlChars($_REQUEST["emailadresse"]);
$isSuccessSMS			= 0;
$isSuccessEmail			= 0;
$phone_error			= "";

# sms parameter verarbeiten
if ( $sms_checkbox == 1 ) { 
	
	if ( $MobilePhoneStatus == 1 && $PreMobilePhoneStatus == 1 ) {
			
		$MobilePhoneCountryVorwahl	= classifyVorwahlByPhoneNumber( $MobilePhoneFull );	# functions.inc.php
		$tmp						= $MobilePhoneFull;
		$tmp_substr					= substr($tmp, 1, strlen($tmp)); 		# entferne die führende Null
		$MobilePhoneBeauty 			= $MobilePhoneCountryVorwahl . $tmp_substr;	# Ländervorwahl plus Rufnummer
		$Country					= classifyCountryByPhoneNumber( $MobilePhoneFull );

		if ( strlen($MobilePhoneCountryVorwahl) > 1 ) {
			
			$isSuccessSMS = 1;

		}; # if ( strlen($MobilePhoneCountryVorwahl) > 1 ) {

	} else {

		$phone_error = formatErrorMessage("Mobilfunknummer $MobilePhoneFull ist ung&uuml;ltig!");
		
	}; # if ( $MobilePhoneStatus == 1 && $PreMobilePhoneStatus == 1 ) {

}; # if ( $sms_checkbox == 1 ) { 


# email parameter verarbeiten
if ( $email_checkbox == 1 ) {

	$email_valid = checkEmailAddress( $emailadresse );

	if ( $email_valid == 1 ){

		$isSuccessEmail = 1;

	} else {

		$phone_error .= formatErrorMessage("<br>eMail $emailadresse ist ung&uuml;ltig!");

	}; # if ( $email_valid == 1 ){

}; # if ( $email_checkbox == 1 ) {


# fehlermeldung wenn weder sms noch email ausgewählt wurden
if ( $sms_checkbox != 1 && $email_checkbox != 1 ) {

	if ( $IsUserType == 2 ) {
		$phone_error .= formatErrorMessage("<br>Bitte w&auml;hlen Sie aus, ob Sie die BitJoe Zugangssoftware per eMail oder per SMS zugesendet bekommen wollen.");
	} else {
		$phone_error .= formatErrorMessage("<br>Bitte w&auml;hlen Sie aus, ob Sie die BitJoe Zugangssoftware per eMail zugesendet bekommen wollen.");
	}; # if ( $IsUserType == 2 ) {

}; # if ( $sms_checkbox != 1 && $email_checkbox != 1 ) {


# es trat ein fehler auf -> drum error message ausgeben
if ( strlen($phone_error) > 0 ){

	BezahlPageStep3( $MobilePhone, $emailadresse, $phone_error );
	exit(0);

}; # if ( strlen($phone_error) > 0 ){



if ( $isSuccessEmail == 1 ){

	$mail			= new PHPMailer();
	$mail->From     = "anmeldung@bitjoe.de";
	$mail->FromName = "BitJoe Pro-Anmeldung";
	$mail->Subject	= "BitJoe Pro-Anmeldung Zugangssoftware";
	$mail->Body		= "Hallo, anbei finden Sie die BitJoe Zugangssoftware.Ihre Zugangsdaten lauten: Benutzername $UserName und Ihr Passwort $UserPIN. Wir wünschen Ihnen viel Spass mit der BitJoe Software. Tipp: Sie können Ihren Freunden die BitJoe Software weiterleiten, damit diese ebenfalls BitJoe benutzen können. Ihr BitJoe Support Team"; 
	$mail->IsHTML(false);
	$mail->AddAddress("$emailadresse");
	$mail->AddAttachment("/srv/server/wwwroot/download/BitJoe.jar", "BitJoe.jar");
	$mail->AddAttachment("/srv/server/wwwroot/download/BitJoe.jad", "BitJoe.jad");
	$mail->AddAttachment("/srv/server/wwwroot/download/BitJoe.zip", "BitJoe.zip");

	if( !$mail->Send() ){
	#  echo 'Failed to send mail';
	} else {
	 # echo 'Mail sent';
	};

}; # if ( $isSuccessEmail == 1 ){


if ( $isSuccessSMS == 1 && $IsUserType == 2 ){

	SendAnmeldungsDaten( $UserName, $MobilePhoneBeauty, $UserPIN );
	SendWapPushSimple( $MobilePhoneBeauty );

}; # if ( $isSuccessEmail == 1 ){


if ( $isSuccessSMS == 1 || $isSuccessEmail == 1 ) {

	// Zum Schluß, löschen der Session.
	session_destroy();

}; # if ( $isSuccessSMS == 1 || $isSuccessEmail == 1 ) {


echo <<<END
<script language ="JavaScript">
<!--
window.location.replace('http://www.bitjoe.de/login/');
// -->
</script>
END;

exit(0);


?>