<?php

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	Swiss Delicious GmbH CH
##### LastModified	04.09.2009
##### Function:		Installiere Coupon Codes anhand eines HTTP Requests mit hilfe eines distributedparis proxy http requests
########################################

#### http://bitjoe.com/api/installvoucher.php?vouchercode=38b055218b&accesscode=35a75e3c5f958834650db467357f2633&web_up_md5=1461a6d4b95fe2dd1a76375f79e4bdcf

# sql spezifische anweisungen
define('MYSQL_HOST', 'localhost'); 
define('MYSQL_USER', 'root'); 
define('MYSQL_PASS', 'rouTer99'); 
define('MYSQL_DATABASE', 'bitjoe'); 

# set default timezone
date_default_timezone_set('Europe/Berlin');

# achtung: wenn der variablenname "comment" hier geändert wird, muss er auch unten bei ReadConfigFile geändert werden
$comment					= "#";	
$CurrentServerIP			= "77.247.178.21";
$CurrentLogFile				= "/var/tmp/bitjoe_voucher_code_logging.txt";
$ConfigAuthenticationKey	= "35a75e3c5f958834650db467357f2633";					# der geheime access key ohne den nix läuft
$ConfigVoucherCodeLength	= 10;													# wie lang ist ein voucher code immer so 
$ConfigMaxCodeUsePerDay		= 1;													# wieviele voucher codes darf der user pro tag maximal einlösen?

# request parameter annehmen
$VoucherCodeRequest	= deleteSpecialChars( strtolower($_REQUEST["vouchercode"]) );	# der einzulösende voucher code
$AccessCode			= deleteSpecialChars( $_REQUEST["accesscode"] );				# der zugriffscode
#$Security_MD5_Value	= deleteSpecialChars( $_REQUEST["sec_md5"] );					# der sec_md5 wert
$Web_UP_MD5_Value	= deleteSpecialChars( $_REQUEST["web_up_md5"] );				# der web_up_md5 wert
$sprache			= deleteSpecialChars( $_REQUEST["lang"] );						# in welcher sprache sollen error und success meldungen ausgegeben werden? - noch nicht eingebaut!



#######
### sicherheitscheck: Start
######
if ( $AccessCode != $ConfigAuthenticationKey ){
	echo "ERROR: You dont have permission to access this file!\n";
	exit(0);
};
if ( strlen($VoucherCodeRequest) <= 0 ) {
	echo "-Voucher Code Install Error- you didnt give me an voucher code!\n";
	exit(0);
};
# if ( strlen($Security_MD5_Value) != 32 || strlen($Web_UP_MD5_Value) != 32 ) {
if ( strlen($Web_UP_MD5_Value) != 32 ) {
	echo "-Voucher Code Install Error- You are using and outdated protocoll handler! - I quit now! Please inform Sebastian Enger 'thecerial@gmail.com' !\n";
	exit(0);
};

#######
### sicherheitscheck: End
######
/*
1.) schau nach ob der couponcode existiert und zeitlich gültig ist: SELECT * FROM `coupon_new` WHERE `voucher_code` = "$VoucherCode" AND `voucher_code_how_often_valid` > 0 AND DateDiff(`voucher_code_valid_until_date`, DATE()) > 0 LIMIT 1;
																	SELECT * FROM `coupon_new` WHERE `voucher_code` = "$VoucherCode" AND `voucher_code_how_often_valid` > 0 AND `voucher_code_valid_until_date` > DATE() LIMIT 1;
2.) schaue in usedcoupons nach, ob der user diesen code schonmal eingeben hat

3.) schaue nach, wie oft der user heute schon einen code eingelöst hat

4.) wenn bis jetzt alles erfolgreich: schreibe dem user den gutschein gut

5.) aktualisiere alle tabellen: bjparis_new und coupon_new und usedcoupons

6.) gib eine erfolgsmeldung aus

7.)Logging
*/

###
# 1.) schau nach ob der couponcode existiert und zeitlich gültig ist: 
###
$CurrentDate			= date("Y-m-d");
#$GetVoucherCodeSql		= "SELECT * FROM `coupon_new` WHERE `voucher_code` = \"$VoucherCodeRequest\" AND `voucher_code_how_often_valid` > 0 AND `voucher_code_valid_until_date` >= '$CurrentDate' LIMIT 1;";
$GetVoucherCodeSql		= "SELECT * FROM `coupon_new` WHERE `voucher_code` = \"$VoucherCodeRequest\" AND `voucher_code_how_often_valid` > 0 LIMIT 1;";
$MySqlArrayCheck 		= doSQLQuery( $GetVoucherCodeSql );	
$sql_results			= mysql_fetch_array($MySqlArrayCheck);

if ( !$MySqlArrayCheck ) {
	echo "-Voucher Code Install Error- Could not read voucher code from SQL Table of SQL Server $CurrentServerIP - I quit now! Please inform Sebastian Enger 'thecerial@gmail.com' !\n";
	exit(0);
}; # if ( $MySqlArrayCheck ) {

$voucher_code 					= strtolower($sql_results["voucher_code"]);
$voucher_searches 				= $sql_results["voucher_searches"];
$voucher_code_how_often_valid 	= $sql_results["voucher_code_how_often_valid"];
$voucher_code_valid_until_date	= $sql_results["voucher_code_valid_until_date"];

if ( $VoucherCodeRequest != $voucher_code || strlen($VoucherCodeRequest) != $ConfigVoucherCodeLength ) {
#	echo strlen($VoucherCodeRequest) . " config=$ConfigVoucherCodeLength<br>";
#	echo "'$VoucherCodeRequest' != '$voucher_code' <br>";
	echo "-Voucher Code Install Error- Your Voucher Code isn't valid! Please buy an new voucher code from your dealer! \n";
	exit(0);
};

###
# 2.) schaue in usedcoupons nach, ob der user diesen code schonmal eingeben hat
###
$MobilePhone 			= GetMobilePhone( $Web_UP_MD5_Value );	
$UsedCouponsSql			= "SELECT `used_code` FROM `usedcoupons` WHERE `used_code` = '$VoucherCodeRequest' AND `used_mobilephone` = '$MobilePhone' ORDER BY `used_date` DESC LIMIT 1;";
$MySqlArrayCheck2 		= doSQLQuery( $UsedCouponsSql );	
$sql_results			= mysql_fetch_array($MySqlArrayCheck2);
$usedcoupon				= $sql_results["used_code"];

if ( $usedcoupon == $VoucherCodeRequest ) {
	echo "-Voucher Code Install Error- You are not allowed to install a voucher code more than one time!\n";
	exit(0);
};

###
# 3.) schaue nach, wie oft der user heute schon einen code eingelöst hat
### 
$CurrentAsciiDate		= date("Y-m-d");	# dieser wert wird später auch für die USED_TABLE gebraucht
$SqlQueryAlreadyUsed	= "SELECT count(*) AS `ALREADYUSEDCOUPONSFORTODAY` FROM `usedcoupons` WHERE `used_mobilephone` = '$MobilePhone' AND `used_date` = '$CurrentAsciiDate' LIMIT 1;";
$MySqlArrayCheck_1		= doSQLQuery($SqlQueryAlreadyUsed);	
$sql_results_1 			= mysql_fetch_array($MySqlArrayCheck_1);
$AlreadyUsedGiftsToday 	= $sql_results_1["ALREADYUSEDCOUPONSFORTODAY"];

# Gib eine Fehlermeldung aus, wenn der user heute schon mehr als MAXCOUPONSTOUSEADAY eingelöst hat
if ( $AlreadyUsedGiftsToday >= $ConfigMaxCodeUsePerDay ){
	echo "-Voucher Code Install Error- You are only allowed to install $ConfigMaxCodeUsePerDay voucher codes per day!\n";
	exit(0);
}; # if ( $AlreadyUsedGiftsToday >= MAXCOUPONSTOUSEADAY ){

###
# 4.) wenn bis jetzt alles erfolgreich: schreibe dem user den gutschein gut: zuerst bjparis_new, dann coupon anpassen anpassen
###

# hole die aktuellen suchkontingent werte
$VorhandenesSuchcontingent	= GetSearchContingent( $Web_UP_MD5_Value );
$AccountValidUntil			= GetAccountValidUntil( $Web_UP_MD5_Value );

# berechne wie lange der account nun nach gutschreiben des codes noch gültig ist
$AccountValidUntilAfterCode = AddionOfTwoDates( $AccountValidUntil, $voucher_code_valid_until_date );

# schreibe dem user die voucher_searches gut
$neuessuchcontingent		= $VorhandenesSuchcontingent + $voucher_searches;

# ziehe eins vom coupon anzahl ab
$voucher_code_how_often_valid--;
  	
if ( $voucher_code_how_often_valid < 0 ) {
	$voucher_code_how_often_valid = 0;
};

$SqlUpdateBJPARIS_NEW 			= "UPDATE `bjparis_new` SET `searchcontingent` = \"$neuessuchcontingent\",`searchcount` = \"0\",`account_valid_until` = \"$AccountValidUntilAfterCode\" WHERE CONVERT( `bjparis_new`.`web_up_MD5` USING utf8 ) = \"$Web_UP_MD5_Value\" LIMIT 1;";	# bjparis_new anpassen!
$SqlUpdateBJPARIS_COUPON		= "UPDATE `coupon_new` SET `voucher_code_how_often_valid` = \"$voucher_code_how_often_valid\" WHERE CONVERT( `coupon_new`.`voucher_code` USING utf8 ) = \"$VoucherCodeRequest\" LIMIT 1;";	# coupon_new anpassen!
$SqlUpdateBJPARIS_USEDCOUPON	= "INSERT INTO `usedcoupons` ( `used_mobilephone`,`used_code`,`used_isaktionsgutschein`, `used_date`) VALUES ( '$MobilePhone','$VoucherCodeRequest','0', '$CurrentAsciiDate' );";


###
# 5.) aktualisiere alle tabellen: bjparis_new und coupon_new und usedcoupons
###
#echo "new valid until date='$AccountValidUntilAfterCode' -$AccountValidUntil, $voucher_code_valid_until_date<br>";

$MySqlArrayCheck_1		= doSQLQuery( $SqlUpdateBJPARIS_NEW );	
$MySqlArrayCheck_2		= doSQLQuery( $SqlUpdateBJPARIS_COUPON );	
$MySqlArrayCheck_3		= doSQLQuery( $SqlUpdateBJPARIS_USEDCOUPON );	


###
# 6.) gib eine erfolgsmeldung aus
###

echo "Success: We installed the voucher code into your account! Have fun with bitjoe!\n";

###
# 7.)Logging
###

# hier alles mitloggen
$NOW		= date("Y-m-d : H:i:s", time());
$log_handle = fopen($CurrentLogFile	,"a+");
flock($log_handle, LOCK_EX);
fputs($log_handle,"VOUCHER#$NOW#$MobilePhone#$voucher_code#$voucher_searches#$web_up_MD5#$voucher_code_valid_until_date\n");
fclose($log_handle);

exit(0);










###################
######## Functionen
###################


# Datum1, Datum2: hole die Tage vom entfernter gelegten Datum und addiere diese Tage zu dem am näher gelegenen 
# Hinweis: zuerst Datum, und dann der Datumsbetrag Datum2 um den Datum1 es erweitert werden soll
function AddionOfTwoDates($date1,$date2){

	# set default timezone
	date_default_timezone_set('Europe/Berlin');

	$date1_unixtimestamp = strtotime($date1);
	$date2_unixtimestamp = strtotime($date2);
	
	if ( strcmp($date2,"0000-00-00" ) == 0 ) {
		$date2_unixtimestamp = strtotime( date("Y-m-d") );
	};
	if ( strcmp($date1,"0000-00-00" ) == 0 ) {
		$date1_unixtimestamp = strtotime( date("Y-m-d") );
	};

	if ( $date2_unixtimestamp > $date1_unixtimestamp ) {
		$diff = $date2_unixtimestamp - $date1_unixtimestamp;
		if ( strcmp($date1,"0000-00-00" ) == 0 ) {
			$date2_unixtimestamp += 0;
		} else {
			$date2_unixtimestamp += $diff;
		};
		return date("Y-m-d", $date2_unixtimestamp);
	}  elseif ( $date2_unixtimestamp == $date1_unixtimestamp ) {
		return date("Y-m-d", $date1_unixtimestamp);	# beide datumsangaben gleichgross also egal welches zurückgegeben wird
	} elseif ( $date1_unixtimestamp > $date2_unixtimestamp ) {
		return date("Y-m-d", $date1_unixtimestamp);
	};

}; # function AddionOfTwoDates($date1,$date2){


# hole das gültig bis datum anhand der web_up_MD5 wertes
function GetAccountValidUntil( $UP_MD5 ){

	$SqlQuery 			= "SELECT `account_valid_until` FROM `bjparis_new` WHERE `web_up_MD5` = '$UP_MD5' LIMIT 1;";
	
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);
	$sql_results		= mysql_fetch_array($MySqlArrayCheck);
	return $sql_results["account_valid_until"];

}; # function GetAccountValidUntil( $UP_MD5 ){


# hole die anzahl der verbleibenden suche anhand der web_up_MD5 wertes
function GetSearchContingent( $UP_MD5 ){

	$SqlQuery 			= "SELECT `searchcontingent` FROM `bjparis_new` WHERE `web_up_MD5` = '$UP_MD5' LIMIT 1;";
	
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);
	$sql_results		= mysql_fetch_array($MySqlArrayCheck);
	return $sql_results["searchcontingent"];

}; # function GetSearchContingent( $UP_MD5 ){


# hole username zu gegebenen up_md5 wert
function GetMobilePhone( $UP_MD5 ){

	$SqlQuery 			= "SELECT `username` FROM `bjparis_new` WHERE `web_up_MD5` = '$UP_MD5' LIMIT 1;";
	
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);
	$sql_results		= mysql_fetch_array($MySqlArrayCheck);
	return $sql_results["username"];

}; # function GetMobilePhone( $UP_MD5 ){


# verbinde dich zum zoozle mysql server 
function connectToServer(){
	
	$DBH = @mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS) OR die ("ERROR: Cannot establish connection to MYSQL Server on Host '$CurrentServerIP' - i guess that the mysql service is down! Please inform Sebastian Enger 'thecerial@gmail.com'!\n");
	# echo mysql_errno() . ": " . mysql_error(). "\n";	
	mysql_select_db(MYSQL_DATABASE, $DBH) OR die ("ERROR: Cannot establish connection to MYSQL Server DATABASE on Host '$CurrentServerIP' - i guess that the mysql service is down! Please inform Sebastian Enger 'thecerial@gmail.com'!\n");
	
	return $DBH;

}; # function connectToServer(){


function doSQLQuery( $sql_query ) { 

	$db_handle	= connectToServer();
	$results	= mysql_query($sql_query , $db_handle );
	mysql_close($db_handle);
	return $results;

}; # function doSQLQuery( $sql_query ) { 


function GetValidUntilDate( $date, $plus ){	# eg 2007-04-12, days

	# set default timezone
	date_default_timezone_set('Europe/Berlin');

	if ( strcmp($date,"0000-00-00" ) == 0 ) {
		$date = date("Y-m-d");
	};

	$dateSec 	= strtotime($date);
	$dateNewSec	= $dateSec + ( 1 * $plus * 24 * 60 * 60 );	# plus x days in unixtime
	$date		= date("Y-m-d", $dateNewSec);
	return $date;

}; # function GetValidUntilDate( $date, $plus ){



function generatePasswordSlave($length=10,$level=3){

   list($usec, $sec) = explode(' ', microtime());
   srand((float) $sec + ((float) $usec * 100000));

   $validchars[1] = "0123456789abcdfghjkmnpqrstvwxyz";
   $validchars[2] = "0123456789abcdfghjkmnpqrstvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
   $validchars[3] = "0123456789_!@#$%&*()-=+/abcdfghjkmnpqrstvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_!@#$%&*()-=+/";

   $password  = "";
   $counter   = 0;

   while ($counter < $length) {
     $actChar = substr($validchars[$level], rand(0, strlen($validchars[$level])-1), 1);

     // All character must be different
     if (!strstr($password, $actChar)) {
        $password .= $actChar;
        $counter++;
     }
   }

   return $password;

} # function generatePasswordSlave($length=10,$level=3){


function GenerateRandomText(){

	$CAPTCHA_LENGTH = 5120;

	// Unser Zeichenalphabet
	$ALPHABET = array(	'A', 'B', 'C', 'D', 'E', 'F', 'G',
						'H', 'Q', 'J', 'K', 'L', 'M', 'N',
						'P', 'R', 'S', 'T', 'U', 'V', 'Y', '@' ,'!', '?',
						'W', '0', '1', '2', '3', '4', '5', '6', '7','8', '9');

	$captcha = '';

	for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {

		$captcha .= $ALPHABET[rand(0, count($ALPHABET) - 1)]; // ein zufälliges Zeichen aus dem definierten Alphabet ermitteln
		
	}; # for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {

	return $captcha;

}; # function GenerateRandomText(){


# Generate PINs
function generatePassword( $length ){

	$passwd = md5(uniqid(rand(), true) . time() . microtime() . GenerateRandomText() . generatePasswordSlave(10,3) );
	$from	= rand($length,32)-$length;
	$pin	= strtolower(substr($passwd, $from, $length)); 

	if ( strlen($pin) == $length ){
		return $pin;
	} else {
		return rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9);
	};

}; # function generatePasswordForHandyAnmeldung(){



function ReadConfigFile( $config_file ){

	$fp = fopen($config_file, "r");
	
	$config_values = array();
	$comment_ignore = $GLOBALS["comment"];
	
	while (!feof($fp)) {
		$line = trim(fgets($fp));
	#	echo "line '$line' \n";
		if ( strlen($line) > 0 && !ereg("^$comment_ignore", $line)) {
			$pieces = explode("=", $line);
		#	echo "piece '$pieces[0]' \n";
			$option = trim($pieces[0]);	# org
			$value = trim($pieces[1]);	# org
		#	$option = trim($pieces[1]);	# mod
		#	$value = trim($pieces[0]);	# mod
			$config_values[$option] = $value;
		}
	}

	fclose($fp);

	return $config_values;

}; # function ReadConfigFile(){


function deleteSpecialChars($del_badchar) {

	if ( strlen($del_badchar) > 255 ) {
		# lösche alles nach dem 200sten zeichen bei überlangen eingaben
		$del_badchar = substr($del_badchar, 0, 255);		
	};

	$del_badchar = preg_replace("/\"/", "", $del_badchar);
	$del_badchar = preg_replace("/`/", "", $del_badchar);
	$del_badchar = preg_replace("/'/", "", $del_badchar);
	$del_badchar = preg_replace("/\?/", "", $del_badchar);
	$del_badchar = preg_replace("/%/", "", $del_badchar);
	$del_badchar = preg_replace("/$/", "", $del_badchar);
	$del_badchar = preg_replace("/§/", "", $del_badchar);
	$del_badchar = preg_replace("/!/", "", $del_badchar);
	$del_badchar = preg_replace("/\&/", "+", $del_badchar);
	$del_badchar = preg_replace("/\{/", "", $del_badchar);
	$del_badchar = preg_replace("/\}/", "", $del_badchar);
	$del_badchar = preg_replace("/\[/", "", $del_badchar);
	$del_badchar = preg_replace("/\]/", "", $del_badchar);
	$del_badchar = preg_replace("/=/", "", $del_badchar);
	$del_badchar = preg_replace("/#/", "", $del_badchar);
	$del_badchar = preg_replace("/,/", "", $del_badchar);
	$del_badchar = preg_replace("/;/", "", $del_badchar);
	$del_badchar = preg_replace("/\|/", "", $del_badchar);
	$del_badchar = preg_replace("/</", "", $del_badchar);
	$del_badchar = preg_replace("/>/", "", $del_badchar);
	$del_badchar = preg_replace("/\//", "", $del_badchar);
	$del_badchar = preg_replace("/°/", "", $del_badchar);
	$del_badchar = preg_replace("/^/", "", $del_badchar);
	$del_badchar = preg_replace("/\./", "", $del_badchar);
	$del_badchar = preg_replace("/,/", "", $del_badchar);
	$del_badchar = preg_replace("/ß/", "ss", $del_badchar);
	$del_badchar = preg_replace("/\|/", "", $del_badchar);
	$del_badchar = preg_replace("/€/", "", $del_badchar);
	$del_badchar = preg_replace("/´/", "", $del_badchar);
	$del_badchar = preg_replace("/~/", "", $del_badchar);
	$del_badchar = preg_replace("/µ/", "", $del_badchar);
	$del_badchar = preg_replace("/\&+\#+(\d)+\;/", " ", $del_badchar);	# entferne html entities

	$code_entities_match	= array(' ','--','&quot;','!','@','#','$','%','^','&','*','(',')','_','{','}','|',':','"','<','>','?','[',']','\\',';',"'",',','.','/','*','~','`','=');
	$code_entities_replace	= array(' ',' ','','','','','','','','','','','','','','','','','','','','','','');
	$del_badchar			= str_replace($code_entities_match, $code_entities_replace, $del_badchar);
	
	return trim($del_badchar);

}; # function deleteSpecialChars($del_badchar) {

/*
echo "'$Username' und '$Password' \n";
echo "account valid days: '$DaysValidNewAccount' - so its valid until:'$DataValidUntil' <br>";
*/

?>