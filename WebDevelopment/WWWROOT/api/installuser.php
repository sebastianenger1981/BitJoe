<?php

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	Swiss Delicious GmbH CH
##### LastModified	02.10.2009
##### Function:		Installiere oder Update einen User mittels remote web request
########################################

#### http://77.247.178.21/api/installuser.php?user=info@bitjoe.com&password=secretkIy&flattype=(1|2|3)
# real: http://77.247.178.21/api/installuser.php?user=ee7f0c7728&password=be56646858&flattype=1&sec=342f75dc8975061ed9498fd227ae0bd3

# set default timezone
date_default_timezone_set('Europe/Berlin');

# sql spezifische anweisungen
define('MYSQL_HOST', 'localhost'); 
define('MYSQL_USER', 'root'); 
define('MYSQL_PASS', 'rouTer99'); 
define('MYSQL_DATABASE', 'bitjoe'); 


# globale parameter definieren
$comment					= "#";	
$CurrentServerIP			= "77.247.178.21";
$CurrentLogFile				= "/var/tmp/bitjoe_installuser_logging.txt";

# request parameter annehmen
$Username					= $_REQUEST["user"];
$Password					= $_REQUEST["password"];
$Flattype					= $_REQUEST["flattype"]; # 1=7day flat / 2=14 day flat / 3= 30 day flat
$AuthenticationKeyWebRequest= $_REQUEST["sec"];

# config file einlesen
$config_file				= "/srv/server/wwwroot/api/generatenewuser.cfg";	# Achtung,wenn der Security Key hier geändert wird, dann muss dies auch yottacash mitgeteilt werden
$ConfigFile					= ReadConfigFile( $config_file );

# config parameter verarbeiten
$SearchesNewAccount			= $ConfigFile['CONFIG_NEW_ACCOUNT_MAX_SEARCHES_'.$Flattype];
$DaysValidNewAccount		= $ConfigFile['CONFIG_NEW_ACCOUNT_VALID_DAYS_'.$Flattype];
$ConfigFileAccountNumbers	= $ConfigFile['CONFIG_COUNT_ACCOUNTS_IN_CONFIG'];
$ConfigAuthenticationKey	= $ConfigFile['CONFIG_SEC_KEY_AUTHENTICATION'];	# auth key


if ( $AuthenticationKeyWebRequest != $ConfigAuthenticationKey ){
	echo "ERROR: You dont have permission to access this file!\n";
	exit(0);
};


for ( $i = 1; $i<=$ConfigFileAccountNumbers; $i++ ){

	if ( $ConfigFile['CONFIG_NEW_USER_REQUEST_PARAM_'.$i] == $Flattype ) {
			
		$SearchesNewAccount		= $ConfigFile['CONFIG_NEW_ACCOUNT_MAX_SEARCHES_'.$i];
		$DaysValidNewAccount	= $ConfigFile['CONFIG_NEW_ACCOUNT_VALID_DAYS_'.$i];

	}; # if ( $ConfigFile['CONFIG_NEW_USER_REQUEST_PARAM_'.$i] == $AccountParam ) {

}; # for ( $i = 1; $i<=$ConfigFileAccountNumbers; $i++ ){


# bj paris first check sql vorbereiten
# BUG: $BJParis_FirstCheck	= "SELECT count(*) AS COUNT FROM `bjparis_new` WHERE `username` = \"$Username\" AND `password` = \"$Password\" LIMIT 1;";
$BJParis_FirstCheck	= "SELECT count(*) AS COUNT FROM `bjparis_new` WHERE `username` = \"$Username\" LIMIT 1;";
$MySqlArrayCheck 	= doSQLQuery($BJParis_FirstCheck);

if ( !$MySqlArrayCheck ) {
	echo "ERROR";
	exit(0);
}; # if ( $MySqlArrayCheck ) {


# sql daten abholen
$sql_results = mysql_fetch_array($MySqlArrayCheck);

# firstcheck durchführen: ist der user schon im system(=1) oder noch nocht (=0)
$FirstCheck = $sql_results["COUNT"];


if ( $FirstCheck == 0 ) {	# user noch nicht im system vorhanden: Fall A

	# aktuelles datum festlegen
	$CurrentDate			= date("Y-m-d");
	$DataValidUntil			= GetValidUntilDate( $CurrentDate, $DaysValidNewAccount );

	$web_up_MD5				= md5(strtolower($Username.$Password));
	$BJParis_InstallUser	= "INSERT INTO `bjparis_new` ( `username`, `password`, `searchcontingent`, `account_valid_until`, `web_up_MD5` ) VALUES ('$Username','$Password','$SearchesNewAccount','$DataValidUntil', '$web_up_MD5');";
	$MySqlArrayInstall		= doSQLQuery($BJParis_InstallUser);

	if ( !$MySqlArrayInstall ) {
		echo "ERROR";
		exit(0);
	}; # if ( $MySqlArrayCheck ) {

	echo "ACTIVATED";

} elseif ( $FirstCheck == 1 ) {	# user schon im system vorhanden, passwort aktualisieren: Fall B

	$BJParis_Update			= "UPDATE `bjparis_new` SET password='$Password' WHERE username='$Username' LIMIT 1;";
	$MySqlArrayUpdate		= doSQLQuery($BJParis_Update);

	if ( !$MySqlArrayUpdate ) {
		echo "ERROR";
		exit(0);
	}; # if ( $MySqlArrayCheck ) {

	echo "UPDATED";

} else {	# ein error ist aufgetreten

	echo "ERROR";

}; # if ( $FirstCheck == 0 ) {	


# hier alles mitloggen
$NOW		= date("Y-m-d : H:i:s", time());
$log_handle = fopen($CurrentLogFile	,"a+");
flock($log_handle, LOCK_EX);
fputs($log_handle,"INSTALLUSER#$NOW#$Username#$Password#$Flattype#$SearchesNewAccount#$DaysValidNewAccount#$FirstCheck\n");
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
	$del_badchar = preg_replace("/,/", "", $del_badchar);
	$del_badchar = preg_replace("/ß/", "ss", $del_badchar);
	$del_badchar = preg_replace("/\|/", "", $del_badchar);
	$del_badchar = preg_replace("/€/", "", $del_badchar);
	$del_badchar = preg_replace("/´/", "", $del_badchar);
	$del_badchar = preg_replace("/~/", "", $del_badchar);
	$del_badchar = preg_replace("/µ/", "", $del_badchar);
	$del_badchar = preg_replace("/\&+\#+(\d)+\;/", " ", $del_badchar);	# entferne html entities

	$code_entities_match	= array(' ','--','&quot;','!','#','$','%','^','&','*','(',')','_','{','}','|',':','"','<','>','?','[',']','\\',';',"'",',','/','*','~','`','=');
	$code_entities_replace	= array(' ',' ','','','','','','','','','','','','','','','','','','','','');
	$del_badchar			= str_replace($code_entities_match, $code_entities_replace, $del_badchar);
	
	return trim($del_badchar);

}; # function deleteSpecialChars($del_badchar) {

/*
echo "'$Username' und '$Password' \n";
echo "account valid days: '$DaysValidNewAccount' - so its valid until:'$DataValidUntil' <br>";
*/

?>