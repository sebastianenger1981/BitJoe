<?php


require_once("/srv/server/wwwroot/lib/sql.inc.php");


$date				= date("Y-m-d");

$german				= date("d.m.Y H.i.s");
echo "Heute[DE]: $german - $date <br><br><br>";


$SqlQuery 			= "SELECT `web_mobilephone` FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

$count = 0;
if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$phone = $sql_results["web_mobilephone"];
		$count++;
		echo "[$count] $phone<br><br>";
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

}; # if ( $MySqlArrayCheck ) {



exit(0);


?>