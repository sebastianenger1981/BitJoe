<?php

# http://www.bitjoe.de/service_micropayment_api/apihandler.php

#test: http://www.bitjoe.de/service_micropayment_api/apihandler.php?amount=995&title=Bitjoe_Volumen_Tarif_30_Suchanfragen&auth=712da28a3bd0f9e7fca3e7bc0c10afef&country=DE&currency=EUR&free=volumelow_call2pay_01607979247_1211193243&function=billing
# http://www.bitjoe.de/service_micropayment_api/apihandler.php?amount=995&title=Bitjoe_Volumen_Tarif_30_Suchanfragen&auth=712da28a3bd0f9e7fca3e7bc0c10afef&country=DE&currency=EUR&free=flat6_ebank_01607979247_1211193243&function=billing
# http://www.bitjoe.de/service_micropayment_api/apihandler.php?amount=995&title=Bitjoe_Volumen_Tarif_30_Suchanfragen&auth=712da28a3bd0f9e7fca3e7bc0c10afef&country=DE&currency=EUR&free=anmeldunghandy_call2pay_01607979247_1234530249&function=billing


require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/wappush.inc.php");

# http://www.bitjoe.de/service_micropayment_api/apihandler2.php?amount=995&title=Bitjoe_Volumen_Tarif_30_Suchanfragen&auth=712da28a3bd0f9e7fca3e7bc0c10afef&country=DE&currency=EUR&free=anmeldunghandy_call2pay_01607979247_1234530249&function=billing

# parameter entgegennehmen
$BillAmount	= deleteSqlChars($_GET['amount']);
$title		= $_GET['title'];
$auth		= $_GET['auth'];		# ist beliebige von micropayment generierte 32 stellige id
$country	= $_GET['country'];
$currency	= $_GET['currency'];
$free		= deleteSqlChars($_GET['free']);	# die werte aus diesem parameter werden ans sql übergeben und müssen desshalb gesichert worden sein
$function	= $_GET['function'];
$isSuccess	= 0;					# wird später im programm verändert, muss jedoch standartmässig auf 0 gesetzt werden
$error		= "";

if ( strlen($free) <= 0 ) {
	$free		= deleteSqlChars($_GET['freeparam']);	# die werte aus diesem parameter werden ans sql übergeben und müssen desshalb gesichert worden sein
}; # if ( strlen($free) <= 0 ) {


######## START: Security Check #########
# Sicherheitscheck: wenn der Parameter $auth von micropayment nicht mit unserem gespeicherten auth key übereinstimmt, gib etwas aus und beende das programm
if ( strlen($auth) != 32 ) {

	header( "HTTP/1.1 301 Moved Permanently" ); 
	header ("Location: http://www.bitjoe.de/"); 
	exit(0);

}; # if ( strcmp($auth, MOBILANTHIDDENKEY ) != 0 ) {
######## END: Security Check #########


# $free Parameter aufsplitten 
list( $MobileTarif, $PaymentType, $MobilePhone, $Unixtimestamp) = explode('_', $free );	# 'flat24_call2pay_' . $phonenumber . '_' . $date;
$PaymentTime	= date("Y-m-d h:i:s", $Unixtimestamp);


if ( strcmp($function, "billing") == 0 ) {

	# Bereite SQL Vor: Hole wichtige Daten zu einer Handynummer
	$TABLE1			= BJPARIS_TABLE;
	$SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil`,`web_password`,`web_mobilephone_full` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	if ( $MySqlArrayCheck ) {
	
		while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
			
			$hc_contingent_volume_success 	= $sql_results["hc_contingent_volume_success"];
			$hc_contingent_volume_overall 	= $sql_results["hc_contingent_volume_overall"];
			$web_flatrate_validUntil 		= $sql_results["web_flatrate_validUntil"];
			$web_password					= $sql_results["web_password"];
			$web_mobilephone_full			= $sql_results["web_mobilephone_full"];
			# = $sql_results[""];
		}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
	}; # if ( $MySqlArrayCheck ) {



	if ( strcmp($MobileTarif, "anmeldunghandy") == 0 ){	# BUY_FLATHANDY_DAYS_STARTPAGE_ANMELDUNG == 14 tages flatrate vom handy aus bezahlen

		$hc_userType					= 2;
		$web_servicetype				= 2;	# 2=flat
		$hc_contingent_volume_success	+= 10; 
		$hc_contingent_volume_overall	+= 30;
		# $web_flatrate_validUntil		= GetFlatrateValidUntilDateInDays($web_flatrate_validUntil, BUY_FLATHANDY_DAYS_STARTPAGE_ANMELDUNG); # functions.inc.php

		# SMS Wappush versenden
		SendWapPushSMS( $web_mobilephone_full, $MobilePhone, $web_password );


	}; # if ( strcmp($PHONE, $MobilePhoneBeauty) == 0 ){




	# Update Query vorbereiten und ausführen
	$SqlUpdateBJPARIS 	= "UPDATE `bitjoe`.`$TABLE1` SET `hc_userType` = \"$hc_userType\", `web_servicetype` = \"$web_servicetype\", `hc_contingent_volume_success` = \"$hc_contingent_volume_success\", `hc_contingent_volume_overall` = \"$hc_contingent_volume_overall\", `web_flatrate_validUntil` = \"$web_flatrate_validUntil\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);
	
	if ( $MySqlExec ) {	# sql update der bjparis tabelle erfolgreich
		$error 		.= "Mobilfunknummer $MobilePhone wurde auf Tarif $MobileTarif gestellt: Volumen Success $hc_contingent_volume_success | Volumen Overall $hc_contingent_volume_overall | Flat Valid Until $web_flatrate_validUntil ";
		$isSuccess 	= 1;
	} else {
		$isSuccess = 0;
		$error 		= "SQL Fehler UPDATE $TABLE1 : $SqlUpdateBJPARIS # ";
	}; # if ( $MySqlExec ) {


	# hier jetzt die tabelle payment aktualisieren
	if ( $isSuccess == 1 ) { # tabelle payment aktualsisiern
	
		$TABLE2		= BILL_TABLE;
		$SqlQuery 	= "SELECT `bill_payed_incount`,`bill_payed_amount` FROM `$TABLE2` WHERE `bill_mobilephone` = '$MobilePhone' LIMIT 1;";
		$MySqlGet 	= doSQLQuery($SqlQuery);

		if ( $MySqlGet ) {	# sql get von payment tabelle erfolgreich
		
			while( $sql_results = mysql_fetch_array($MySqlGet)) {
				$bill_payed_incount 	= $sql_results["bill_payed_incount"];
				$bill_payed_amount 	= $sql_results["bill_payed_amount"];
				# = $sql_results[""];
			}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
	
		} else {
			$error 		.= "SQL Fehler UPDATE $TABLE2 : $MySqlGet # ";
		}; # if ( $MySqlArrayCheck ) {


		$bill_last_pay_amount	= $BillAmount;
		$bill_last_pay_isbooked	= 1;
		$bill_payed_incount	+= 1; 
		$bill_payed_amount	+= $BillAmount;
		
		$SqlUpdateBJPAYMENT 	= "UPDATE `bitjoe`.`$TABLE2` SET `bill_last_pay` = NOW(), `bill_last_pay_amount` = \"$bill_last_pay_amount\" , `bill_last_pay_isbooked` = \"$bill_last_pay_isbooked\", `bill_payed_incount` = \"$bill_payed_incount\", `bill_payed_amount` = \"$bill_payed_amount\" WHERE CONVERT( `$TABLE2`.`bill_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
		$MySqlExec 		= doSQLQuery($SqlUpdateBJPAYMENT);
		
		if ( $MySqlExec ) {	
			$error .= "Payment tabelle erfolgreich angepasst";
		} else {
			$error .= "SQL Fehler UPDATE $TABLE2 : $SqlUpdateBJPAYMENT";
		}; # if ( $MySqlExec ) {

	}; # if ( $isSuccess == 1 ) { # tabelle payment aktualsisiern

} elseif ( strcmp($function, "storno") == 0 ) {

	# bei storno den user als hc_abuse = 1 einstellen, denn er hat nicht bezahlt!

	$TABLE1			= BJPARIS_TABLE;
	$SqlUpdateBJPARIS 	= "UPDATE `bitjoe`.`$TABLE1` SET `hc_abuse` = \"1\" WHERE CONVERT( `$TABLE1`.`web_mobilephone` USING utf8 ) = \"$MobilePhone\" LIMIT 1;";
	$MySqlExec 		= doSQLQuery($SqlUpdateBJPARIS);

}; # if ( strcmp($function, "billing") == 0 ) {



# MicroPayment Api Handling
echo "status=ok\n";
echo "url=http://www.bitjoe.de/login/\n";
echo "target=_self\n";
echo "forward=1\n";

# Request Loggen
$date			= date("Y-m-d h:i:s A");
$remote_ip		= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
$query_string	= $_SERVER['QUERY_STRING'];
$handle 		= fopen(LOGAPIHANDLERDACCESS, "a");
fwrite($handle, "[$date] # $remote_ip # [$MobileTarif,$PaymentType,$MobilePhone,$Unixtimestamp] # $BillAmount # $title # $country # $currency # $auth # $free # $function # $error # $query_string \n");
fclose($handle);

exit(0);


/*
==============================================================================================
Beispielaufruf der Payment-URL:

http://billing.micropayment.de/call2pay/event/?project=testprojekt&amount=250&currency=EUR&title=memberid2342&theme=d2&freeparam=das_ist_frei

==============================================================================================
.htaccess: erweiterte Contentsicherung durch alleinige Freigabe unserer IP:

Order deny,allow
Deny from all
Allow from service.micropayment.de
Allow from proxy.micropayment.de
Allow from access.micropayment.de

==============================================================================================
*/










function SendWapPushSMS( $MobilePhoneBeauty, $HandyNummer, $Pin ){

	
	# bis der error mit mobile-marketing behoben ist
	$HiddenGateWayKey	= MOBILANTHIDDENKEY;
	$HalifaxWapURI		= urlencode("http://www.bitjoe.de/download/BitJoe.jad");
	$DisplayText		= urlencode("BitJoe Software");
	$MessageURI			= "http://gateway2.mobilant.net/index.php?key=$HiddenGateWayKey&receiver=$MobilePhoneBeauty&name=$DisplayText&url=$HalifaxWapURI&service=wap";

	ini_set('default_socket_timeout',30);
	$request	= fopen($MessageURI,"r");
	$status		= trim(fread($request,10)); 
	fclose($request);

	$SmsMessage	= "BitJoe Zugangsdaten: Username: $HandyNummer, PIN: $Pin . Viel Spass mit BitJoe!";
	$SmsMessage	= urlencode($SmsMessage);
	$tmp		= $MobilePhoneBeauty;
	$tmp		= substr($tmp, 0, 4); 

	if ( $tmp == '0049' ){
		# low cost sms plus nach deutschland
		$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($MobilePhoneBeauty) . "&message=" . $SmsMessage . "&originator=BitJoe.de" . "&type=low";
	} else{
		# direkt plus nach ausland
		$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($MobilePhoneBeauty) . "&message=" . $SmsMessage . "&originator=BitJoe.de";# . "&type=low";
	}; # if ( $tmp == '0049'


	ini_set('default_socket_timeout',3);
	$request	= fopen($MessageURI,"r");
	$status		= trim(fread($request,10)); 
	fclose($request);

	return 1;

}; # function SendWapPushSMS( $MobilePhoneBeauty, $HandyNummer, $Pin ){







?>
