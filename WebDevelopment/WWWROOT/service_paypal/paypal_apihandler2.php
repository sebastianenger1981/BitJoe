<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");


# es wird auf EUR als währung geprüft !!

// read the post from PayPal system and add 'cmd'
$req = 'cmd=_notify-validate';

foreach ($_POST as $key => $value) {
	
	$value = urlencode(stripslashes($value));
	$req .= "&$key=$value";

}; # foreach ($_POST as $key => $value) {

// post back to PayPal system to validate
$header .= "POST /cgi-bin/webscr HTTP/1.1\r\n";
$header .= "Content-Type: application/x-www-form-urlencoded\r\n";
$header .= "Content-Length: " . strlen($req) . "\r\n\r\n";
$fp		= fsockopen ('www.paypal.com', 80, $errno, $errstr, 30);


// assign posted variables to local variables
$item_name			= $_POST['item_name'];
$item_number		= deleteSqlChars($_POST['item_number']);
$payment_status		= $_POST['payment_status'];
$payment_amount		= $_POST['mc_gross'];
$payment_currency	= $_POST['mc_currency'];
$txn_id				= $_POST['txn_id'];
$receiver_email		= $_POST['receiver_email'];
$payer_email		= $_POST['payer_email'];

list( $MobileTarif, $PaymentType, $MobilePhone, $Unixtimestamp) = explode('_', $item_number );	# 'flat24_call2pay_' . $phonenumber . '_' . $date;
$PaymentTime		= date("Y-m-d h:i:s", $Unixtimestamp);


if (!$fp) {
// HTTP ERROR

} else {

	fputs ($fp, $header . $req);

	while (!feof($fp)) {
		$res = fgets ($fp, 1024);
		if (strcmp ($res, "VERIFIED") == 0) {

		// check the payment_status is Completed
		// check that txn_id has not been previously processed
		// check that receiver_email is your Primary PayPal email
		// check that payment_amount/payment_currency are correct
		// process payment
		
			
			if ( strcasecmp($res, "completed") == 0 && strcasecmp($payment_currency, "EUR") == 0 && strcasecmp($receiver_email, "support@bitjoe.at") == 0 ) {
			} else {
				# logging
				exit(0);
			};

			# Bereite SQL Vor: Hole wichtige Daten zu einer Handynummer
			$TABLE1			= BJPARIS_TABLE;
			$SqlQuery 		= "SELECT `hc_contingent_volume_success`,`hc_contingent_volume_overall`,`web_flatrate_validUntil` FROM `$TABLE1` WHERE `web_mobilephone` = '$MobilePhone' LIMIT 1;";
			$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

			if ( $MySqlArrayCheck ) {
			
				while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
					$hc_contingent_volume_success 	= $sql_results["hc_contingent_volume_success"];
					$hc_contingent_volume_overall 	= $sql_results["hc_contingent_volume_overall"];
					$web_flatrate_validUntil 	= $sql_results["web_flatrate_validUntil"];
					# = $sql_results[""];
				}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {
			
			}; # if ( $MySqlArrayCheck ) {


			if ( strcmp($MobileTarif, "volumelow") == 0 ){

				$hc_userType			= 2;				# 2=paying user
				$web_servicetype		= 1;				# 1=searches | 2=flat
				$hc_contingent_volume_success	+= BUY_VOLUMENLOW_SUCCESS; 	# wieviele erfolgreiche suchanfragen sollen hinzugefügt werden
				$hc_contingent_volume_overall	+= BUY_VOLUMENLOW_OVERALL;	# wieviele insgesamt suchanfragen sollen hinzugefügt werden
				$web_flatrate_validUntil	= $web_flatrate_validUntil;

			} elseif ( strcmp($MobileTarif, "volumebig") == 0 ){
				
				$hc_userType			= 2;
				$web_servicetype		= 1;
				$hc_contingent_volume_success	+= BUY_VOLUMENBIG_SUCCESS; 
				$hc_contingent_volume_overall	+= BUY_VOLUMENBIG_OVERALL;
				$web_flatrate_validUntil	= $web_flatrate_validUntil;

			} elseif ( strcmp($MobileTarif, "volumehandy") == 0 ){
				
				$hc_userType			= 2;
				$web_servicetype		= 1;
				$hc_contingent_volume_success	+= BUY_VOLUMENHANDY_SUCCESS; 
				$hc_contingent_volume_overall	+= BUY_VOLUMENHANDY_OVERALL;
				$web_flatrate_validUntil	= $web_flatrate_validUntil;

			} elseif ( strcmp($MobileTarif, "flathandy") == 0 ){	# 5 tages flatrate vom handy aus bezahlen

				$hc_userType			= 2;
				$web_servicetype		= 2;	# 2=flat
				$hc_contingent_volume_success	+= 0; 
				$hc_contingent_volume_overall	+= 0;
				$web_flatrate_validUntil	= GetFlatrateValidUntilDateInDays($web_flatrate_validUntil, BUY_FLATHANDY_DAYS); # functions.inc.php

			} elseif ( strcmp($MobileTarif, "flat3") == 0 ){

				$hc_userType			= 2;
				$web_servicetype		= 2;	# 2=flat
				$hc_contingent_volume_success	+= 0; 
				$hc_contingent_volume_overall	+= 0;
				$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 1); # functions.inc.php

			} elseif ( strcmp($MobileTarif, "flat6") == 0 ){

				$hc_userType			= 2;
				$web_servicetype		= 2;	# 2=flat
				$hc_contingent_volume_success	+= 0; 
				$hc_contingent_volume_overall	+= 0;
				$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 6); # functions.inc.php

			} elseif ( strcmp($MobileTarif, "flat12") == 0 ){

				$hc_userType			= 2;
				$web_servicetype		= 2;	# 2=flat
				$hc_contingent_volume_success	+= 0; 
				$hc_contingent_volume_overall	+= 0;
				$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 12); # functions.inc.php

			} elseif ( strcmp($MobileTarif, "flat24") == 0 ){

				$hc_userType			= 2;
				$web_servicetype		= 2;	# 2=flat
				$hc_contingent_volume_success	+= 0; 
				$hc_contingent_volume_overall	+= 0;
				$web_flatrate_validUntil	= GetFlatrateValidUntilDate($web_flatrate_validUntil, 18); # functions.inc.php

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

	#	} elseif (strcmp ($payment_status, "INVALID") == 0) {
	#		// log for manual investigation
	#
		} # if (strcmp ($res, "VERIFIED") == 0) {

	}; # while (!feof($fp)) {

	fclose ($fp);

}; # if (!$fp) {











# Request Loggen
$date			= date("Y-m-d h:i:s A");
$remote_ip		= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
$query_string	= $_SERVER['QUERY_STRING'];
$postvar		= $_POST;

$handle 		= fopen(LOGPAYPALPAYMENTAPI, "a");
fwrite($handle, "[$date] # $remote_ip # [$MobileTarif,$PaymentType,$MobilePhone,$Unixtimestamp] # $BillAmount # $title # $country # $currency # $auth # $free # $function # $error # $query_string \n");
fclose($handle);



/*
	<form method="post" action="https://www.paypal.com/cgi-bin/webscr" target="_blank">
	<input type="image" src="/images/button_anmeldung_paypal.jpg" width="65" height="31" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal">
	<input type="hidden" name="cmd" value="_xclick">
	<input type="hidden" name="return" value="http://www.bitjoe.de/login/">
	<input type="hidden" name="business" value="support@bitjoe.at">
	<input type="hidden" name="item_name" value="$paypal24[1]">
	<input type="hidden" name="item_number" value="$paypal24[0]">
	<input type="hidden" name="amount" value="$paypal24[2]">
	<input type="hidden" name="currency_code" value="EUR">
	<input type="hidden" name="bn"  value="ButtonFactory.PayPal.001">
</form>

bigfis_1211212033_pre@gmail.com
211212179
*/

?>