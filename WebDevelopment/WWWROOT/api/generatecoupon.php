<?php

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	Swiss Delicious GmbH CH
##### LastModified	03.09.2009
##### Function:		Generiere Coupon Codes anhand einer vorhandenen Config Datei
########################################

#### http://www.bitjoe.com/api/generatecoupon.php?action=newvoucherv1&sec=3dbb572191ecf01c90885030aea252e5

# set default timezone
date_default_timezone_set('Europe/Berlin');

# sql spezifische anweisungen
define('MYSQL_HOST', 'localhost'); 
define('MYSQL_USER', 'root'); 
define('MYSQL_PASS', 'rouTer99'); 
define('MYSQL_DATABASE', 'bitjoe'); 


# globale parameter definieren
$config_file				= "/srv/server/wwwroot/api/generatecoupon.cfg";
# achtung: wenn der variablenname "comment" hier geändert wird, muss er auch unten bei ReadConfigFile geändert werden
$comment					= "#";	
$CurrentServerIP			= "77.247.178.21";
$CurrentLogFile				= "/var/tmp/bitjoe_account_create_logging.txt";
$IsValidFlag				= 0;

# config file einlesen
$ConfigFile					= ReadConfigFile( $config_file );
$ConfigFileAccountNumbers	= $ConfigFile['CONFIG_COUNT_ACCOUNTS_IN_CONFIG'];
$ConfigAuthenticationKey	= $ConfigFile['CONFIG_SEC_KEY_AUTHENTICATION'];



# request parameter annehmen
$AccountParam				= deleteSpecialChars( $_REQUEST["action"] );
$AuthenticationKeyWebRequest= deleteSpecialChars( $_REQUEST["sec"] );

#######
### sicherheitscheck: Start
######

if ( $AuthenticationKeyWebRequest != $ConfigAuthenticationKey ){
	echo "ERROR: You dont have permission to access this file!\n";
	exit(0);
};

if ( strlen($AccountParam) <= 0 ) {
	echo "ERROR: you didnt give me an action parameter!\n";
	exit(0);
};

#######
### sicherheitscheck: End
######


# die parameter ,die die anzahl der suchen und anzahl der gültigen tage vorhalten hier initialisieren
$SearchesNewAccount			= 0;
$DaysValidNewAccount		= 0;


for ( $i = 1; $i<=$ConfigFileAccountNumbers; $i++ ){

	if ( $ConfigFile['CONFIG_VOUCHER_PARAM_'.$i] == $AccountParam ) {
		#	echo "i use: [$i]" . $ConfigFile['CONFIG_NEW_USER_REQUEST_PARAM_'.$i] . "<br>";
		
		$SearchesNewAccount		= $ConfigFile['CONFIG_VOUCHER_SEARCHES_COUNT_'.$i];
		$DaysValidNewAccount	= $ConfigFile['CONFIG_VOUCHER_CODE_VALID_UNTIL_DATE_'.$i];
		$CodeHowOftenValid		= $ConfigFile['CONFIG_VOUCHER_CODE_HOW_OFTEN_VALID_'.$i];
		$IsValidFlag			= 1;

	}; # if ( $ConfigFile['CONFIG_NEW_USER_REQUEST_PARAM_'.$i] == $AccountParam ) {

}; # for ( $i = 1; $i<=$ConfigFileAccountNumbers; $i++ ){


# teste hier ob mittels web request eine gültige anfrage rein kam - wenn nicht - breche ab!
if ( $IsValidFlag == 0 ) {
	echo "ERROR: Your request is using an outdated protocol - we could not process your request ! - Please inform Sebastian Enger 'thecerial@gmail.com' !\n";
	exit(0);
};


# aktuelles datum festlegen
$CurrentDate		= date("Y-m-d");

# hier username und password initialisieren
$VoucherCode		= generatePassword( 10 );
$DataValidUntil		= GetValidUntilDate( $CurrentDate, $DaysValidNewAccount );


$BJParisDBUPdate	= "INSERT INTO `coupon_new` ( `voucher_code`,`voucher_searches`,`voucher_code_how_often_valid`, `voucher_code_valid_until_date`, `created` ) VALUES ( '$VoucherCode','$SearchesNewAccount','$CodeHowOftenValid','$DataValidUntil', NOW() );";
$MySqlArrayCheck 	= doSQLQuery($BJParisDBUPdate);


if ( !$MySqlArrayCheck ) {
	echo "ERROR: Could not install new Userdata into SQL Table of SQL Server $CurrentServerIP - I quit now! Please inform Sebastian Enger 'thecerial@gmail.com' !\n";
	exit(0);
}; # if ( $MySqlArrayCheck ) {


# hier die daten ausgeben!
echo "vouchercode=$VoucherCode\n";

# hier alles mitloggen
$NOW		= date("Y-m-d : H:i:s", time());
$log_handle = fopen($CurrentLogFile	,"a+");
flock($log_handle, LOCK_EX);
fputs($log_handle,"VOUCHERCODE#$NOW#$VoucherCode#$DataValidUntil#$AccountParam#$SearchesNewAccount\n");
fclose($log_handle);

exit(0);



###################
######## Functionen
###################

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