<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
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
$MobilePhone 			= $_SESSION['mobilephone'];
$MobilePhoneStatus		= checkInput($MobilePhone, "I", 9, 15 );
$error					= '';



if ( $MobilePhoneStatus != 1 || !isset($MobilePhone) ) {

	# echo "'$MobilePhone' -'$MobilePhoneStatus' nicht angemeldet -> leite weiter auf /login/";
	header("HTTP/1.1 307 Temporary Redirect"); 
	header("Location: /login/"); 
	exit(0);

}; # if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {



if ( $MobilePhoneStatus == 1 ) {

	$action		= $_REQUEST["action"];
	$captcha	= $_REQUEST["captcha"];


	if ( ( strlen($_SESSION['captcha']) != 6 || strlen($captcha) != 6 ) && strlen($action) > 17 ) {
		
		###
		#	Captcha Zeichenlänge falsch
		###

		# das hier wird standarmässig aufgerufen, wenn man die seite direkt aufruft
		$error = formatErrorMessage("Fehlermeldung 1: Die Zeichen aus dem Bild stimmen nicht &uuml;berein. Alle Buchstaben werden gross geschrieben.");
		ScreenStep2( $MobilePhone , $error); 
		exit(0);		

	} elseif ( $action == 'correctmobilephone' && $captcha == $_SESSION['captcha'] ){
	
		###
		#	Captcha korrekt eingegeben, Mobilfunknummer wurde korrekt eingegeben
		###

		# hole sql daten aus datenbank
		$TABLE1				= BJPARIS_TABLE;
		$SqlQuery 			= "SELECT `web_mobilephone_full`,`web_password` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' AND `hc_abuse` = '0' LIMIT 1;";
		$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			$web_mobilephone_full 	= $sql_results["web_mobilephone_full"];
			$web_password 			= $sql_results["web_password"];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

		# header redirekt auf /login2/
		header("HTTP/1.1 301 Moved Permanently");
		header("Location: /login2/"); 
		
		# sende user eine sms mit seinen login daten
		SendAnmeldungsDatenLogin2( $MobilePhone, $web_mobilephone_full, $web_password );

		exit(0);		

	} elseif ( $action == 'correctmobilephone' && $captcha != $_SESSION['captcha'] ){

		###
		#	Captcha falsch eingegeben, Mobilfunknummer wurde korrekt eingegeben
		###

		$error = "Fehlermeldung 2: Die Zeichen aus dem Bild stimmen nicht &uuml;berein. Alle Buchstaben werden gross geschrieben.";
		ScreenStep2( $MobilePhone , $error); 
		exit(0);		

	} elseif ( $action == 'changemobilephone' && $captcha == $_SESSION['captcha'] ) {
		
		###
		#	Captcha korrekt eingegeben, Mobilfunknummer soll geändert werden
		###

		$NewMobilePhone				= $_REQUEST["mobilephone"];  
		$NewMobilePhoneStatus		= checkInput($NewMobilePhone, "I", 9, 15 );
		$NewMobilePhone				= deleteSqlChars($NewMobilePhone);
		
		$MobilePhoneCountryVorwahl	= classifyVorwahlByPhoneNumber( $NewMobilePhone );	# functions.inc.php
		$tmp						= $NewMobilePhone;
		$tmp_substr					= substr($tmp, 1, strlen($tmp)); 		# entferne die führende Null
		$MobilePhoneBeauty 			= $MobilePhoneCountryVorwahl . $tmp_substr;	# Ländervorwahl plus Rufnummer

		#### echo "normalnew=$NewMobilePhone | beauty=$MobilePhoneBeauty<br>"; exit(0);


		if ( $NewMobilePhoneStatus == 1 ) {
	
			# Neue Nummer ist Gültig
			
			$TABLE1			= BJPARIS_TABLE;
			$SqlUpdateBJPARIS 	= "UPDATE `$TABLE1` SET `web_mobilephone` = \"$NewMobilePhone\", `web_mobilephone_full` = \"$MobilePhoneBeauty\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
			$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);

			$TABLE2			= BILL_TABLE;
			$SqlUpdateBJBILL 	= "UPDATE `$TABLE2` SET `bill_mobilephone` = \"$NewMobilePhone\" WHERE CONVERT( `$TABLE2`.`bill_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
			$MySqlExec2		= doSQLQuery($SqlUpdateBJBILL);

			if ( !$MySqlExec ) {	# korrekt=if ( !$MySqlExec ) {
				
				$error = "BitJoe Systemfehler beim &auml;ndern Deiner Handynummer!Deine neue Nummer wurde nicht gespeichert.";	
				ScreenStep2( $MobilePhone , $error); 
				exit(0);	

			} else {

				$TABLE1			= BJPARIS_TABLE;
				$SqlQuery 		= "SELECT `web_password` FROM `$TABLE1` WHERE `web_mobilephone` = '$NewMobilePhone' AND`hc_abuse` = '0' LIMIT 1;";
				$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

				while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
					$SericePassword 	= $sql_results["web_password"];
				}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {


				$_SESSION['mobilephone'] = $NewMobilePhone;

				# header redirekt auf /login2/
				header("HTTP/1.1 301 Moved Permanently");
				header("Location: /login2/index.php?changed=$NewMobilePhone");

				# sende user eine sms mit seinen login daten
				SendAnmeldungsDatenLogin2( $NewMobilePhone, $MobilePhoneBeauty, $SericePassword );

				exit(0);	

			}; # if ( !$MySqlExec ) {


		} else {

			$error = "Mobilfunknummer $NewMobilePhone ist ung&uuml;ltig!";
			ScreenStep2( $MobilePhone , $error); 
			exit(0);		

		}; # if ( $NewMobilePhoneStatus == 1 ) {


	} elseif ( $action == 'changemobilephone' && $captcha != $_SESSION['captcha'] ) {
		
		###
		#	Captcha falsch eingegeben, Mobilfunknummer soll geändert werden
		###

		$error = "Fehlermeldung 3: Die Zeichen aus dem Bild stimmen nicht &uuml;berein. Alle Buchstaben werden gross geschrieben.";
		ScreenStep2( $MobilePhone , $error); 
		exit(0);		

	} else {

		$error = "No correct action parameter";
		ScreenStep2( $MobilePhone , $error); 
		exit(0);

	}; # if ( ( strlen($_SESSION['captcha']) != 6 || strlen($captcha) != 6 ) && strlen($action) < 18 ) {


} else {	# Login wurde blank ohne parameter aufgerufen

	$error = "Fehlermeldung 3: Die Zeichen aus dem Bild stimmen nicht &uuml;berein. Alle Buchstaben werden gross geschrieben.";
	ScreenStep2( $MobilePhone , $error); 
	exit(0);

}; # if ( $MobilePhoneStatus == 1 && $MobilePinStatus == 1) {



exit(0);


?>