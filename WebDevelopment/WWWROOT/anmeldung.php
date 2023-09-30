<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");

#<meta http-equiv="refresh" content="300;url=anmeldung.php">

echo <<<END

<html><head></head><body>

	<script language="javascript" type="text/javascript">
		<!-- // JavaScript-Bereich für ältere Browser auskommentieren

		window.setTimeout ('redirect_to ("/anmeldung.php")', 300000);

		function redirect_to (destination) {
		  window.location.href = destination;
		};
		// -->
	</script>

END;


$date				= date("Y-m-d");

$german				= date("d.m.Y H.i.s");
echo "Heute[DE]: $german - $date <br><br><br>";




$SqlQuery 			= "SELECT count(*) AS COUNT FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

list($y,$m,$d)		= explode("-",$date);
$d					-= 1;
$SqlQuery1 			= "SELECT count(*) AS COUNT1 FROM `bjparis` WHERE DATE(`web_signup_date`) = '$y-$m-$d';";
$MySqlArrayCheck1 	= doSQLQuery($SqlQuery1);



if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count = $sql_results["COUNT"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck1)) {
		$count1 = $sql_results["COUNT1"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {


	echo "[$count] <b>heute</b> anmeldungen ### [$count1] <b>gestern</b> anmeldungen <br><br>";

}; # if ( $MySqlArrayCheck ) {

/*
$SqlQuery 			= "SELECT count(*) AS COUNT11 FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date' AND `web_got_wappush` = \"1\";";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count11 = $sql_results["COUNT11"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count11] erfolgreich software mittels wappush versendet <b>heute</b><br><br>";

}; # if ( $MySqlArrayCheck ) {
*/


/*
$SqlQuery 			= "SELECT count(*) AS COUNT1 FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date' AND CHAR_LENGTH(`hc_sec1_MD5`) > 0 AND `hc_userType` != '3';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count1 = $sql_results["COUNT1"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count1] Benutzungen der Software -durch www.bitjoe.de Anmeldung User- <b>heute</b><br><br>";

}; # if ( $MySqlArrayCheck ) {
*/


$SqlQuery 			= "SELECT count(*) AS COUNT111 FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date' AND CHAR_LENGTH(`hc_sec1_MD5`) > 0 AND `hc_userType` = '3';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count1 = $sql_results["COUNT111"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count1] Benutzungen der Software -durch HandyAnmeldung User- <b>heute</b><br><br>";

}; # if ( $MySqlArrayCheck ) {


/*
$SqlQuery 			= "SELECT count(*) AS COUNT2 FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date' AND ( `hc_contingent_volume_success` != '4' OR `hc_contingent_volume_overall` != '12' ) AND `hc_userType` != '3';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count2 = $sql_results["COUNT2"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count2] SUCHEN -durch www.bitjoe.de Anmeldung User- <b>heute</b><br><br>";

}; # if ( $MySqlArrayCheck ) {
*/


$SqlQuery 			= "SELECT count(*) AS COUNT222 FROM `bjparis` WHERE DATE(`web_signup_date`) = '$date' AND ( `hc_contingent_volume_success` != '3' OR `hc_contingent_volume_overall` != '21' ) AND `hc_userType` = '3';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count2 = $sql_results["COUNT222"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count2] SUCHEN -durch HandyAnmeldung User- <b>heute</b><br><br>";

}; # if ( $MySqlArrayCheck ) {


$SqlQuery 			= "SELECT count(*) AS COUNT7 FROM `bjparis` WHERE ( DATE(`web_signup_date`) = '$date' AND `hc_userType` = '2' );";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count4 = $sql_results["COUNT7"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count4] User die schonmal gezahlt haben oder ein Gutschein eingelöst haben <b>heute</b><br><br>";

}; # if ( $MySqlArrayCheck ) {



echo "<br><br><br>";

$SqlQuery 			= "SELECT count(*) AS COUNT5 FROM `bjparis`;";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count5 = $sql_results["COUNT5"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	$count5 = $count5 - 3;
	echo "[$count5] Anmeldungen <b>insgesamt</b><br><br>";

}; # if ( $MySqlArrayCheck ) {


$SqlQuery 			= "SELECT count(*) AS COUNT3 FROM `bjparis` WHERE CHAR_LENGTH(`hc_sec1_MD5`) > 0 ;";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count3 = $sql_results["COUNT3"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	$count3 = $count3 - 3;
	echo "[$count3] Benutzungen der Software <b>insgesamt</b><br><br>";

}; # if ( $MySqlArrayCheck ) {


$SqlQuery 			= "SELECT count(*) AS COUNT4 FROM `bjparis` WHERE ( `hc_contingent_volume_success` != '4' OR `hc_contingent_volume_overall` != '12' ) OR ( `hc_contingent_volume_success` != '3' OR `hc_contingent_volume_overall` != '21' ) ;";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count4 = $sql_results["COUNT4"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	#$count4 = $count4 - 3;
	echo "[$count4] SUCHEN <b>insgesamt(Website und HandyAnmeldung User)</b><br><br>";

}; # if ( $MySqlArrayCheck ) {



$SqlQuery 			= "SELECT count(*) AS COUNT6 FROM `bjparis` WHERE ( `hc_userType` = '2' );";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count4 = $sql_results["COUNT6"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count4] User die schonmal gezahlt haben <b>insgesamt</b> - laut normaler Tabelle <br><br>";

}; # if ( $MySqlArrayCheck ) {



$SqlQuery 			= "SELECT count(*) AS COUNT689 FROM `payment` WHERE `bill_last_pay` != '0000-00-00 00:00:00';";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count4 = $sql_results["COUNT689"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {

	echo "[$count4] User die schonmal gezahlt haben <b>insgesamt</b> - laut payment tabelle<br><br>";

}; # if ( $MySqlArrayCheck ) {



$SqlQuery 			= "SELECT count(*) AS COUNT1234 FROM `payment` WHERE ( `bill_last_pay` != '0000-00-00 00:00:00' ) AND DATE(`bill_last_pay`) = CURDATE();";
$MySqlArrayCheck 	= doSQLQuery($SqlQuery);


if ( $MySqlArrayCheck ) {

	while( $sql_results = mysql_fetch_array($MySqlArrayCheck)) {
		$count4 = $sql_results["COUNT1234"];
	}; # while( $sql_results = mysql_fetch_array($MySqlArray)) {


	$betrag = $count4 * 1.18;
	echo "[$count4] Bezahlvorgänge heute <b>insgesamt</b> | ~ $betrag EUR verdient - laut payment tabelle<br><br>";

}; # if ( $MySqlArrayCheck ) {


echo "<br><br>Version 0.5.b -20081007</body></html>";



exit(0);


?>