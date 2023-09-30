<?php

require_once("/srv/server/wwwroot/lib/sms.inc.php");
require_once("/srv/server/wwwroot/lib/wappush.inc.php");


define('MYSQL_HOST', 'localhost'); 
define('MYSQL_USER', 'root'); 
define('MYSQL_PASS', 'rouTer99'); 
define('MYSQL_DATABASE', 'bitjoe'); 


$SqlQuery 			= "SELECT `web_mobilephone`,`web_password`,`web_mobilephone_full` FROM `bjparis`;";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		
		$PHONE	= $sql_results["web_mobilephone"];
		$PASS	= $sql_results["web_password"];
		$PHONEFULL	= $sql_results["web_mobilephone_full"];
		
		# echo "$PHONE und $PASS und $PHONEFULL<br>";
		echo "Sending to $PHONE - $PASS - $PHONEFULL<br>\n";

	#	$Cutted = substr($PHONEFULL, 2,strlen($PHONEFULL));
	#	$PHONEFULL = "+".$Cutted;
	#	echo "Normal $PHONEFULL | Cutted $Cutted<br>\n";

		$Status = SendWapPush( $PHONE, $PASS, $PHONEFULL );
		echo "Status=$Status\n";
		sleep(10);
		exit;

	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

}; # if ( $MySqlArrayCheck ) {



# verbinde dich zum zoozle mysql server 
function connectToServer(){
	
	$DBH = @mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS) AND ("Keine Verbindung zur Datenbank. Fehlermeldung");
	echo mysql_errno() . ": " . mysql_error(). "\n";	
	mysql_select_db(MYSQL_DATABASE, $DBH) OR die ("Konnte Datenbank nicht benutzen, Fehlermeldung");
	

	return $DBH;

}; # function connectToServer(){


function doSQLQuery( $sql_query ) { 

	$db_handle	= connectToServer();
	$results	= mysql_query($sql_query , $db_handle );
	mysql_close($db_handle);
	return $results;

}; # function doSQLQuery( $sql_query ) { 



exit(0);


?>