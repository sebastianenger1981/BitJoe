<?php

###################
#### SQL SERVER
###################

require_once("/srv/server/wwwroot/lib/config.inc.php");


# verbinde dich zum zoozle mysql server 
function connectToServer(){
	
	$DBH = @mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS) OR die ("Keine Verbindung zur Datenbank. Fehlermeldung");
	# echo mysql_errno() . ": " . mysql_error(). "\n";	
	mysql_select_db(MYSQL_DATABASE, $DBH) OR die ("Konnte Datenbank nicht benutzen, Fehlermeldung");
	

	return $DBH;

}; # function connectToServer(){


function doSQLQuery( $sql_query ) { 

	$db_handle	= connectToServer();
	$results	= mysql_query($sql_query , $db_handle );
	mysql_close($db_handle);
	return $results;

}; # function doSQLQuery( $sql_query ) { 


?>