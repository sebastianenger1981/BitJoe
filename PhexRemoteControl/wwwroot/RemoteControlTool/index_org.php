<?php

require_once("sms.inc.php");

####
#### Voreinstellungen
####

# Version
$Version					= "PhexRemoteControl - 9.1.2007 - Version 0.2.a + gzip";

# PhexRemoteControl Server
$PhexRemoteControlServer	= array("87.106.63.182","85.214.39.76","81.169.141.129");
$PhexRemoteControlPort		= 9977;

# Sicherheitsspezifische Voreinstellungen
$SecurityToken				= "%6ASdgdfAERGHA7845338w4eFW44325fwer";


####
#### Parameter annehmen
####

$ParameterAction		= deleteSpecialChars(stripcslashes(trim($_REQUEST["a"])));
$ParameterActionServer	= deleteSpecialChars(stripcslashes(trim($_REQUEST["ip"])));


if ( isset($ParameterAction) && strlen($ParameterAction) >= 1 && strlen($ParameterAction) <= 11 && isset($ParameterActionServer) && strlen($ParameterActionServer) >= 8 && strlen($ParameterActionServer) <= 16 ) {
	
	writeStatusFieldHtmlPage($ParameterActionServer, $ParameterAction);
	exit(0);

} elseif ( isset($ParameterActionServer) && strlen($ParameterActionServer) == 3 ){

	if (strcasecmp($ParameterActionServer, "all") == 0) {

		writeStatusFieldHtmlPageAllServers($ParameterAction);
		exit(0);

	}; # if (strcasecmp($ParameterActionServer, "all") == 0) {

} else {

	writeStartHtmlPage();
	echo "</body></html>";
	exit(0);

}; # if ( isset($ParameterAction) && strlen($ParameterAction) >= 1 && strlen($ParameterAction) =< 11 ) {

exit(0);


function writeStatusFieldHtmlPageAllServers( $ParameterAction ){

	global $PhexRemoteControlServer;
	global $PhexRemoteControlPort;
	global $SecurityToken;

	writeStartHtmlPage();
	echo "Information für alle Server";

	foreach ( $PhexRemoteControlServer as $Server ) { 
	
		$fp	= fsockopen($Server, $PhexRemoteControlPort, $errno, $errstr, 3);

		if (!$fp) {
			
			echo "$Server -> $errstr ($errno) - SERVER DOWN!<br />\n";
			SendSMS( "WARNING Server $Server - IS DOWN" );

		} else { # if (!$fp) {
		
			$RequestString	= gzencode("$ParameterAction##$SecurityToken\r\n", 9);
			fwrite($fp, $RequestString . "\r\n");
			stream_set_timeout($fp, 3);

			$ReturnString = "";
			while (!feof($fp)) {
				$ReturnString .= fgets($fp, 128);
			}; # while (!feof($fp)) {

			$info = stream_get_meta_data($fp);
			if ($info['timed_out']) {
				echo '[$Server] Read/Write Connection timed out!';
			}; # if ($info['timed_out']) {

			fclose($fp);
			
			$ReturnString = trim($ReturnString);

			if (strcasecmp("load", $ParameterAction) == 0) {

				list( $CurrentLoad, $OldLoad, $VeryOldLoad) = explode(" ", $ReturnString );
				$ResultString								= "<br>Aktueller Load &nbsp;&nbsp;: $CurrentLoad<br>Load vor 5min &nbsp;&nbsp;: $OldLoad <br> Load vor 20min : $VeryOldLoad";

			} elseif (strcasecmp("restart", $ParameterAction) == 0) {

				list( $Status ) = explode("#", $ReturnString );
				$ResultString	= "<br>$Status";

			} elseif (strcasecmp("memory", $ParameterAction) == 0) {
		
				list( $AllMem, $VirtMem, $UsedMem)	= explode(" ", $ReturnString );
				$ResultString						= "<br>Server Gesamtspeicher &nbsp;&nbsp;&nbsp;: $AllMem <br> Phex Virtueller Speicher &nbsp;&nbsp;: $VirtMem <br> Phex physikaler Speicher &nbsp;: $UsedMem";

			} elseif (strcasecmp("uptime", $ParameterAction) == 0) {
		
				list( $CurrentDate, $UptimeSince, $UptimeFinal )	= explode(" ", $ReturnString );
				$ResultString										= "<br>Serverzeit &nbsp;&nbsp;&nbsp;&nbsp;: $CurrentDate <br> Phex Online &nbsp;&nbsp;: $UptimeSince <br> Phex Uptime &nbsp;: seit $UptimeFinal";

			} elseif (strcasecmp("status", $ParameterAction) == 0) {
				
				list( $Status ) = explode("#", $ReturnString );
				$ResultString	= "<br>$Status";

			}; # if (strcasecmp("load", $ParameterAction) == 0) {

			echo <<<END
				
				<b id="msg"><h2>$Server - $ParameterAction</b></h2>
				$ResultString
				<hr>
				
END;

		}; # if (!$fp) {
			
	}; # foreach ( $PhexRemoteControlServer as $Server ) { 

	echo "</body></html>";
	return 1;

}; # function writeStatusFieldHtmlPageAllServers( $ParameterAction ){


function writeStatusFieldHtmlPage( $ParameterActionServer, $ParameterAction){

	global $PhexRemoteControlServer;
	global $PhexRemoteControlPort;
	global $SecurityToken;
	
	$comma_separated_servers	= implode(", ", $PhexRemoteControlServer);

	$fp	= fsockopen($ParameterActionServer, $PhexRemoteControlPort, $errno, $errstr, 3);

	if (!$fp) {
		
		echo "$ParameterActionServer -> $errstr ($errno) - SERVER DOWN!<br />\n";
		SendSMS( "WARNING Server $ParameterActionServer - IS DOWN" );

	} else {
	
		$RequestString	= gzencode("$ParameterAction##$SecurityToken\r\n", 9);
		fwrite($fp, $RequestString . "\r\n");
		stream_set_timeout($fp, 3);

		$ReturnString = "";
		while (!feof($fp)) {
			$ReturnString .= fgets($fp, 128);
		}; # while (!feof($fp)) {

		$info = stream_get_meta_data($fp);
		if ($info['timed_out']) {
			echo '[$ParameterActionServer] Read/Write Connection timed out!';
		}; # if ($info['timed_out']) {

		fclose($fp);
		
		$ReturnString = trim($ReturnString);

		if (strcasecmp("load", $ParameterAction) == 0) {

			list( $CurrentLoad, $OldLoad, $VeryOldLoad) = explode(" ", $ReturnString );
			$ResultString								= "<br>Aktueller Load &nbsp;&nbsp;: $CurrentLoad<br>Load vor 5min &nbsp;&nbsp;: $OldLoad <br> Load vor 20min : $VeryOldLoad";

		} elseif (strcasecmp("restart", $ParameterAction) == 0) {

			list( $Status ) = explode("#", $ReturnString );
			$ResultString	= "<br>$Status";

		} elseif (strcasecmp("memory", $ParameterAction) == 0) {
	
			list( $AllMem, $VirtMem, $UsedMem)	= explode(" ", $ReturnString );
			$ResultString						= "<br>Server Gesamtspeicher &nbsp;&nbsp;&nbsp;: $AllMem <br> Phex Virtueller Speicher &nbsp;&nbsp;: $VirtMem <br> Phex physikaler Speicher &nbsp;: $UsedMem";

		} elseif (strcasecmp("uptime", $ParameterAction) == 0) {
	
			list( $CurrentDate, $UptimeSince, $UptimeFinal )	= explode(" ", $ReturnString );
			$ResultString										= "<br>Serverzeit &nbsp;&nbsp;&nbsp;&nbsp;: $CurrentDate <br> Phex Online &nbsp;&nbsp;: $UptimeSince <br> Phex Uptime &nbsp;: seit $UptimeFinal";

		} elseif (strcasecmp("status", $ParameterAction) == 0) {
			
			list( $Status ) = explode("#", $ReturnString );
			$ResultString	= "<br>$Status";

		}; # if (strcasecmp("load", $ParameterAction) == 0) {

		$HtmlHeaders = writeHtmlHeaders();

		echo <<<END
			$HtmlHeaders
			
			Ein Befehl für alle Server ausführen
			<form method="get" action="index.php" target="_self">	
				<select name="a" style="width: 40mm">
					<option value="load">Load abfragen</option>
					<option value="uptime">Phex Uptime</option>
					<option value="memory">Memory abfragen</option>
					<option value="restart">Phex restarten</option>
					<option value="status">Phex Status</option>
				</select>
				<input type="text" name="ip" value="all" maxlength="16" size="16" READONLY>
				<input type="submit" value="exec()" > 
			</form>
			<hr noshade color="red" />
END;

		foreach ( $PhexRemoteControlServer as $Server ) { 
			
			if (strcasecmp($Server, $ParameterActionServer) == 0) {
			
				echo <<<END
			
					<form method="get" action="index.php" target="_self">	
						<select name="a" style="width: 40mm">
							<option value="load">Load abfragen</option>
							<option value="uptime">Phex Uptime</option>
							<option value="memory">Memory abfragen</option>
							<option value="restart">Phex restarten</option>
							<option value="status">Phex Status</option>
						</select>
						<input type="text" name="ip" value="$Server" maxlength="16" size="16" READONLY>
						<input type="submit" value="exec()" > 
					</form>
					<br>
					<b id="msg"><h2>$Server - $ParameterAction</b></h2>
					$ResultString
					<hr>
END;
			
			} else { # if (strcasecmp($Server, $ParameterActionServer) == 0) {

				echo <<<END
				
					<form method="get" action="index.php" target="_self">	
						<select name="a" style="width: 40mm">
							<option value="load">Load abfragen</option>
							<option value="uptime">Phex Uptime</option>
							<option value="memory">Memory abfragen</option>
							<option value="restart">Phex restarten</option>
							<option value="status">Phex Status</option>
						</select>
						<input type="text" name="ip" value="$Server" maxlength="16" size="16" READONLY>
						<input type="submit" value="exec()" > 
					</form>
					<hr>
END;
			}; # if (strcasecmp($Server, $ParameterActionServer) == 0) {

		}; # foreach ( $PhexRemoteControlServer as $Server ) { 

	}; # if (!$fp) {

	echo "</body></html>";
	return 1;

}; # function writeStatusFieldHtmlPage($ParameterActionServer, $ParameterAction){



function writeStartHtmlPage(){
	
	global $PhexRemoteControlServer;
	$comma_separated_servers	= implode(", ", $PhexRemoteControlServer);
	$HtmlHeaders				= writeHtmlHeaders();

	echo <<<END
		$HtmlHeaders
		
		Ein Befehl für alle Server ausführen
		<form method="get" action="index.php" target="_self">	
			<select name="a" style="width: 40mm">
				<option value="load">Load abfragen</option>
				<option value="uptime">Phex Uptime</option>
				<option value="memory">Memory abfragen</option>
				<option value="restart">Phex restarten</option>
				<option value="status">Phex Status</option>
			</select>
			<input type="text" name="ip" value="all" maxlength="16" size="16" READONLY>
			<input type="submit" value="exec()" > 
		</form>
		<hr noshade color="red" />
		Ein Befehl pro Server ausführen
END;

	foreach ( $PhexRemoteControlServer as $Server ) { 

		echo <<<END
		
			<form method="get" action="index.php" target="_self">	
				<select name="a" style="width: 40mm">
					<option value="load">Load abfragen</option>
					<option value="uptime">Phex Uptime</option>
					<option value="memory">Memory abfragen</option>
					<option value="restart">Phex restarten</option>
					<option value="status">Phex Status</option>
				</select>
				<input type="text" name="ip" value="$Server" maxlength="16" size="16" READONLY>
				<input type="submit" value="exec()" > 
			</form>
			<hr />
END;

	}; # foreach ( $PhexRemoteControlServer as $Server ) { 

	return 1;

}; # function writeStartHtmlPage(){


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
				##### Function:		Hauptdatei für PhexRemoteControl
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

				<title>PhexRemoteControl</title>

			</head>
		<body>
		<h3><a href="alive.php" title="Teste alle Server auf Erreichbarkeit - Tests dauern ca 20 sec" target="_self">Service Alive Test</a> - <a href="index.php" title="Zurück zur Startseite ohne Parameter" target="_self">PhexRemoteControl</a> for $comma_separated_servers</h3>
END;

	return $ReturnString;

}; # function writeHtmlHeaders(){

function deleteSpecialChars($del_badchar) {

	if ( strlen($del_badchar) > 17 ) {
		# lösche alles nach dem 10sten zeichen bei überlangen eingaben
		$del_badchar = substr($del_badchar, 0, 17);		
	};

	$del_badchar = html_entity_decode($del_badchar);
	$del_badchar = str_replace("\"", "", $del_badchar);
	$del_badchar = str_replace("`", "", $del_badchar);
	$del_badchar = str_replace("'", "", $del_badchar);
	$del_badchar = str_replace("?", "", $del_badchar);
	$del_badchar = str_replace("%", "", $del_badchar);
	$del_badchar = str_replace("$", "", $del_badchar);
	$del_badchar = str_replace("§", "", $del_badchar);
	$del_badchar = str_replace("!", "", $del_badchar);
	$del_badchar = str_replace("&", "", $del_badchar);
	$del_badchar = str_replace("{", "", $del_badchar);
	$del_badchar = str_replace("}", "", $del_badchar);
	$del_badchar = str_replace("(", "", $del_badchar);
	$del_badchar = str_replace(")", "", $del_badchar);
	$del_badchar = str_replace("[", "", $del_badchar);
	$del_badchar = str_replace("]", "", $del_badchar);
	$del_badchar = str_replace("=", "", $del_badchar);
	$del_badchar = str_replace("\\", "", $del_badchar);
	$del_badchar = str_replace("\/", "", $del_badchar);
	$del_badchar = str_replace("#", "", $del_badchar);
	$del_badchar = str_replace(",", "", $del_badchar);
	$del_badchar = str_replace(";", "", $del_badchar);
	$del_badchar = str_replace("|", "", $del_badchar);
	$del_badchar = str_replace("<", "", $del_badchar);
	$del_badchar = str_replace(">", "", $del_badchar);
	$del_badchar = str_replace("/", "", $del_badchar);
	$del_badchar = str_replace("°", "", $del_badchar);
	$del_badchar = str_replace("^", "", $del_badchar);
	$del_badchar = str_replace("*", "", $del_badchar);
	$del_badchar = str_replace(",", "", $del_badchar);
	$del_badchar = str_replace("ß", "ss", $del_badchar);
	$del_badchar = str_replace("|", "", $del_badchar);
	$del_badchar = str_replace("=&szlig;=", "ss", $del_badchar);
	$del_badchar = preg_replace("/\&+\#+(\d)+\;/", " ", $del_badchar);	# entferne html entities

	
	/* Lösche gefährliche SQL-Commandos und versuche so SQL-Injection zu verhindern */
	
	$del_badchar = str_ireplace("drop", "", $del_badchar);
	$del_badchar = str_ireplace("insert", "", $del_badchar);
	$del_badchar = str_ireplace("alter", "", $del_badchar);
	$del_badchar = str_ireplace("distinct", "", $del_badchar);
	$del_badchar = str_ireplace("flush", "", $del_badchar);
	$del_badchar = str_ireplace("union select", "", $del_badchar);
	$del_badchar = str_ireplace("select", "", $del_badchar);
	$del_badchar = str_ireplace("empty", "", $del_badchar);
	$del_badchar = str_ireplace("truncate", "", $del_badchar);
	$del_badchar = str_ireplace("update", "", $del_badchar);
	$del_badchar = str_ireplace("show tables", "", $del_badchar);
	$del_badchar = str_ireplace("exec", "", $del_badchar);
	$del_badchar = str_ireplace("system", "", $del_badchar);
	$del_badchar = str_ireplace("cmd", "", $del_badchar);	
	
	$del_badchar = preg_replace("/drop/i", "", $del_badchar);
	$del_badchar = preg_replace("/insert/i", "", $del_badchar);
	$del_badchar = preg_replace("/alter/i", "", $del_badchar);
	$del_badchar = preg_replace("/distinct/i", "", $del_badchar);
	$del_badchar = preg_replace("/flush/i", "", $del_badchar);
	$del_badchar = preg_replace("/union select/i", "", $del_badchar);
	$del_badchar = preg_replace("/select/i", "", $del_badchar);
	$del_badchar = preg_replace("/empty/i", "", $del_badchar);
	$del_badchar = preg_replace("/truncate/i", "", $del_badchar);
	$del_badchar = preg_replace("/update/i", "", $del_badchar);
	$del_badchar = preg_replace("/show tables/i", "", $del_badchar);
	$del_badchar = preg_replace("/exec/i", "", $del_badchar);
	$del_badchar = preg_replace("/system/i", "", $del_badchar);
	$del_badchar = preg_replace("/cmd/i", "", $del_badchar);
		 
	return $del_badchar;
	
}; # function deleteSpecialChars($del_badchar) {

?>