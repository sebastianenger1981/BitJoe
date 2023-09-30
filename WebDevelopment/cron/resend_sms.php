<?php

require_once("/srv/server/wwwroot/lib/sms.inc.php");

define('MYSQL_HOST', 'localhost'); 
define('MYSQL_USER', 'root'); 
define('MYSQL_PASS', 'rouTer99'); 
define('MYSQL_DATABASE', 'bitjoe'); 


$SqlQuery 			= "SELECT `web_mobilephone`,`web_password` FROM `bjparis`;";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		
		$PHONE	= $sql_results["web_mobilephone"];
		$PASS	= $sql_results["web_password"];
		# echo "$PHONE und $PASS<br>";
		echo "Sending to $PHONE - $PASS <br>\n";
		SendAnmeldungsDaten( $PHONE, $PASS );
		sleep(10);

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