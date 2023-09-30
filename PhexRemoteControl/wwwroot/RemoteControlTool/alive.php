<?php

require_once("sms.inc.php");

# PhexRemoteControl Server
$SecurityToken				= "%6ASdgdfAERGHA7845338w4eFW44325fwer";
$PhexRemoteControlServer	= array("87.106.63.182","85.214.39.76","81.169.141.129","85.214.77.110");
$PhexRemoteControlPort		= 9977;
$PhexProxyPort				= 3383;

$Version					= "PhexRemoteControl Service Alive Test - 9.1.2007 - Version 0.1.b";

# Html Header Ausgeben
echo writeHtmlHeaders();

foreach ( $PhexRemoteControlServer as $Server ) { 

	# 1. Ping Test
	$count				= 3;
	$ergebnis			= shell_exec("ping -q -c $count $Server");
	list(,$tmp)			= explode("received, ", $ergebnis);
	list($ProcentLoss,)	= explode("% packet loss, ", $tmp);

    echo "[$Server] <b id=\"red\">$ProcentLoss Lost</b> Ping Packets<br>"; 
	if ( $ProcentLoss == 100 ){ # 100% packet loss
		SendSMS( "Server $Server failed PING Test" );
	}; # if ( $ProcentLoss == 100 ){ 


	# 2. PhexServerThread Port Alive Test
	$fp	= fsockopen($Server, $PhexProxyPort, $errno, $errstr, 3);

	if (!$fp) {
		 echo "[$Server] PhexServerThread Port Alive Test - <b id=\"red\">Failed</b> <br>"; 
		 SendSMS( "Server \n $Server \n failed ServerThread Port Test" );
	} else {
		 echo "[$Server] PhexServerThread Port Alive Test - <b id=\"blue\">Success</b> <br>"; 
	}; # if (!$fp) {
	$fp = "";


	# 3. PhexRemoteControlPort Alive Test
	$fp	= fsockopen($Server, $PhexRemoteControlPort, $errno, $errstr, 3);

	if (!$fp) {
		 echo "[$Server] PhexRemoteControlPort Alive Test - <b id=\"red\">Failed</b> <br>"; 
		  SendSMS( "Server \n $Server \n failed RemoteControl Port Test" );
	} else {
		 echo "[$Server] PhexRemoteControlPort Alive Test - <b id=\"blue\">Success</b> <br>"; 
	}; # if (!$fp) {
	$fp = "";


	# 4. PhexRunning Test
	$fp				= fsockopen($Server, $PhexRemoteControlPort, $errno, $errstr, 3);
	# $RequestString	= gzencode("status##$SecurityToken\r\n", 9); #echo "'status##$SecurityToken\r\n'";
	$RequestString	= "status##$SecurityToken\r\n";
	fwrite($fp, $RequestString . "\r\n");
	stream_set_timeout($fp, 6);

	$ReturnString = "";
	while (!feof($fp)) {
		$ReturnString .= fgets($fp, 128);
	}; # while (!feof($fp)) {

	$info = stream_get_meta_data($fp);
	if ($info['timed_out']) {
		echo "[$Server] Read/Write Connection timed out during PhexRunning Test! <br>"; 
		 SendSMS( "Server \n $Server \n Connection Timeout during Running Test" );
	}; # if ($info['timed_out']) {

	fclose($fp);
		
	$ReturnString = trim($ReturnString);
	if ( $ReturnString == "Phex $Server running" ) {
		echo "[$Server] PhexRunning Test - <b id=\"blue\">Success</b> <br>"; 
	} else {
		echo "[$Server] PhexRunning Test - <b id=\"red\">Failed</b> <br>"; 
		SendSMS( "Server \n $Server \n failed Running Test" );
	}; # if (strcasecmp($ReturnString, "running") == 0) {

	echo '<hr noshade color="red" />';

}; # foreach ( $PhexRemoteControlServer as $Server ) {

echo "</body></html>";
exit(0);


function writeHtmlHeaders(){

	global $Version;
	global $PhexRemoteControlServer;
	$comma_separated_servers	= implode(", ", $PhexRemoteControlServer);

	$ReturnString=<<<END
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
			<html>
			<!--
				All rights of the producer and of the owner of this work are reserved.
				UNAUTHORISED copying, hiring, lending, public performance and 
				broadcasting of this material is prohibited.

				Alle Urheber- und Leistungsschutzrechte vorbehalten. Kein Verleih! 
				Keine unerlaubte Vervielfaeltigung, Vermietung, Auffuehrung, Sendung!

				#########################################
				##### Author:		Sebastian Enger / B.Sc
				##### CopyRight:	BitJoe GmbH
				##### LastModified	$Version
				##### Function:		Hauptdatei für PhexRemoteControl - Server Alive Tests
				########################################

				(C)opyright 2008
				Sebastian Enger
				www.bitjoe.de
			-->

			<head>
				<meta http-equiv="Content-Language" content="de" />
				<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
				<meta name="robots" content= "NOINDEX,NOFOLLOW" />

				<link href="styles.css" rel="stylesheet" type="text/css" />
				<link href="favicon.ico" rel="SHORTCUT ICON" />

				<title>PhexRemoteControl - Service Alive Tests</title>

			</head>
		<body>
		<h3><a href="alive.php" title="Teste alle Server auf Erreichbarkeit - Tests dauern ca 20 sec" target="_self">Service Alive Tests</a> - <a href="index.php" title="Zurück zur Startseite ohne Parameter" target="_self">PhexRemoteControl</a> for $comma_separated_servers</h3>
END;

	return $ReturnString;

}; # function writeHtmlHeaders(){


?>