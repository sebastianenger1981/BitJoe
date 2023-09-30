<?php

require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

### Referer
$servicetype			= deleteSqlChars($_REQUEST["servicetype"]);
$gift_code_validUntil		= deleteSqlChars($_REQUEST["gift_code_validUntil"]);
$gift_flat_validUntil		= deleteSqlChars($_REQUEST["gift_flat_validUntil"]);
$gift_how_often_valid		= deleteSqlChars($_REQUEST["gift_how_often_valid"]);
$gift_success_search		= deleteSqlChars($_REQUEST["gift_success_search"]);
$gift_overall_search		= deleteSqlChars($_REQUEST["gift_overall_search"]);
$gift_count			= deleteSqlChars($_REQUEST["gift_count"]);		# wieviele codes sollen erstellt werden
$gift_aktionsgutschein		= deleteSqlChars($_REQUEST["aktionsgutschein"]);
$servicetype_status		= checkInput($servicetype, "I", 1, 1 );

echo $gift_code_validUntil;

# ohne parameter aufgerufen -> standarttemplate ausgeben
if ( !isset($servicetype) || $servicetype_status != 1 ) {	
	StartPage();
	exit(0);
};

$gift_code_validUntil_status 	= checkAsciiDate( $gift_code_validUntil );
$gift_flat_validUntil_status 	= checkAsciiDate( $gift_flat_validUntil );
$gift_how_often_valid_status	= checkInput($gift_how_often_valid, "I", 1, 7 );
$gift_success_search_status 	= checkInput($gift_success_search, "I", 1, 7 );
$gift_overall_search_status 	= checkInput($gift_overall_search, "I", 1, 7 );
$gift_count_status 		= checkInput($gift_count, "I", 1, 5 );
$gift_aktionsgutschein_status	= checkInput($gift_aktionsgutschein, "I", 1, 1 );

$status				= "";
$status				= $servicetype_status.$gift_code_validUntil_status.$gift_flat_validUntil_status.$gift_how_often_valid_status.$gift_success_search_status.$gift_overall_search_status.$gift_count_status.$gift_aktionsgutschein_status;


if ( $status == "11111111" ) {

	if ( $servicetype == 1 ){	# 1= volumen
		$gift_flat_validUntil = "0000-00-00 00:00:00";
	} elseif ( $servicetype == 2 ){	# 2= flat
		$gift_success_search = 0;
		$gift_overall_search = 0;
	} else {
		$gift_success_search 	= 3;
		$gift_overall_search 	= 6;
		$gift_flat_validUntil 	= "0000-00-00 00:00:00";
	};

	for ( $i=1;$i<=$gift_count; $i++ ){
	
		$createtime		= date("d.m.Y h:i:s");	
		$couponcode 		= "";
		$couponcode 		= generateCouponCode();
		$gift_isValid		= 1;

		$TABLE2			= COUPON_TABLE;
		$SqlQueryCOUPON_TABLE	= "";
		
		$SqlQueryCOUPON_TABLE	= "INSERT INTO `$TABLE2` ( `gift_code`, `gift_success_search`,`gift_overall_search`,`gift_flat_validUntil`,`gift_type`,`gift_how_often_valid`,`gift_code_validUntil`,`gift_aktionsgutschein`,`gift_isValid` ) VALUES ( '$couponcode', '$gift_success_search','$gift_overall_search','$gift_flat_validUntil','$servicetype' ,'$gift_how_often_valid','$gift_code_validUntil', '$gift_aktionsgutschein', '$gift_isValid');";

		$MySqlArrayCheck 	= doSQLQuery($SqlQueryCOUPON_TABLE);

		if ( $MySqlArrayCheck ) {
			echo "[$i/$gift_count] $createtime - Coupon erfolgreich erstellt - Gutscheincode <b>$couponcode</b><br>";
		} else {
			$error = formatErrorMessage("[$i/$gift_count] $createtime - Coupon konnte nicht erstell werden!<br>");
			echo $error;
			echo "SQL QUERY '$SqlQueryCOUPON_TABLE'<br>";
		};

	}; # for ( $i=1;$i<=$gift_count; $i++ ){

} else {

	echo "Status '$status' not '111111111' <br>";

}; # if ( $satus == '11111111' ) {



function StartPage(){

	$code_from = date("Y-m-d");

	echo <<<END

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<!--
	All rights of the producer and of the owner of this work are reserved.
	UNAUTHORISED copying, hiring, lending, public performance and 
	broadcasting of this material is prohibited.

	Alle Urheber- und Leistungsschutzrechte vorbehalten. Kein Verleih! 
	Keine unerlaubte Vervielfaeltigung, Vermietung, Auffuehrung, Sendung!

	(C)opyright 2007, 2008, 2009, 2010, 2011, 2012, 2013
	Sebastian Enger, Torsten Morgenroth
	www.bitjoe.de
-->

<head>
	<meta http-equiv="Content-Language" content="de" />
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "" />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "" />
	<meta name="author" content= "Torsten Morgenroth, Sebastian Enger" />
	<meta name="publisher" content= "BitJoe Communications GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "1 days" />
	<meta name="keywords" lang="de" content="T" />
	<meta name="keywords" lang="en-us" content="" />
	<meta name="keywords" lang="en" content="" />

	<meta name="keywords" lang="fr" content="" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Coupon</title>

</head>
<body style="margin:0px">
<div align="center">
<p>
Coupon Generator - Hinweis: wenn als Option Volumen ausgew&auml;hlt wurden, werden die Eintragungen f&uuml;r Flatrate nicht mit ber&uuml;cksichtigt - ASCII DATE in der Form $code_from eingeben werden - Achtung rein Reload der Seite erstellt einen neuen Gutscheincode!
<br><br><br>
	<center>
	<form method="POST" action="/coupon/coupon_generator.php">
		<b>Type Flatrate </b> <input type="radio" name="servicetype" value="2" size="1"><br>
		<b>Type Volumen </b> <input type="radio" name="servicetype" value="1" size="1"><br>
		
		<b>Code g&uuml;ltig bis: </b> <input type="text" name="gift_code_validUntil" value="$code_from" size="10"><br>
	
		<b>Code wie oft verwendbar : </b> <input type="text" name="gift_how_often_valid" value="1" size="10"><br>
	
		<b>Flatrate g&uuml;ltig bis: </b> <input type="text" name="gift_flat_validUntil" value="$code_from" size="10"><br>
	
		<b>Anzahl erfolgreicher Suchen: </b> <input type="text" name="gift_success_search" value="0" size="10"><br>
		<b>Anzahl maximaler Suchen: </b> <input type="text" name="gift_overall_search" value="0" size="10"><br>
		
		<b>Anzahl der zu generierenden Codes: </b> <input type="text" name="gift_count" value="1" size="10"><br>

		<b>Aktionsgutschein (1=ja,0=nein): </b> <input type="text" name="aktionsgutschein" value="0" size="10"><br>

		<input type="submit" value="Senden">
	</form>
	</center>
</div>
</body>
</html>

END;
return 1;


}; # function StartPage(){


exit(0);

?>