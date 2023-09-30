<?php

require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/http.inc.php");
require_once("/srv/server/wwwroot/lib/sms.inc.php");
require_once("/srv/server/wwwroot/lib/sql.inc.php");

# mobile-marketing-gmbh
$username = "KU-T6VI";	// hier bitte Ihre Kunden-ID eintragen
$password = "FMBS1ZXA";	// hier bitte das in den Einstellungen definierte Password


### SendWapPush( "017696136425", "812c" );
### SendWapPush( "015154822782", "XXXX" );
### SendWapPush( "01607979247", "d9ce" );
### SendWapPush( "01737153272", "da47" );

 
###SendWapPushSimple( "00491607979247", "0f6f" );



function SendWapPushSimple( $MobilePhoneBeauty ){ # handynummer mit landesvorwahl

	# bis der error mit mobile-marketing behoben ist
	$HiddenGateWayKey	= MOBILANTHIDDENKEY;
	$HalifaxWapURI		= urlencode("http://www.bitjoe.de/download/BitJoe.jad");
	$DisplayText		= urlencode("BitJoe Software"); # urlencode("PIN $Pin BitJoe - Installationshilfe unter www.bitjoe.de/hilfe");
	$QueryUri			= "http://gateway2.mobilant.net/index.php?key=$HiddenGateWayKey&receiver=$MobilePhoneBeauty&name=$DisplayText&url=$HalifaxWapURI&service=wap";
	
	$HttpObj			= new HTTPRequest($QueryUri);
	$StatusCode			= $HttpObj->DownloadToString();

	return 1;

	# Wichtig: Wappush Beschreibung und Wappush Link dürfen nicht mehr als 120 Zeichen lang sein

	#### START: http://gateway.mobile-marketing-system.de

	$tmp		= $MobilePhoneBeauty;
	$tmp		= substr($tmp, 0, 4); 

	if ( $tmp == '0049' ){
		# low cost sms plus nach deutschland
		$result = send_wap_push("$MobilePhoneBeauty", "BitJoe Software", "http://www.bitjoe.de/software/BitJoe.jad", "route2");
	} else{
		# direkt plus nach ausland
		$result = send_wap_push("$MobilePhoneBeauty", "BitJoe Software", "http://www.bitjoe.de/software/BitJoe.jad", "route1");
	}; # if ( $tmp == '0049' ){

	list($Status,) = explode(" ", $result);	# OK MSG: 3
	
	### echo "Status='$Status'\n";

	if ( $Status != 'OK' ){		# fehler ist passiert
		
		$WapPushFile= "/srv/server/logs/wappushs_errors.txt";
		$DateTime	= date("Y-m-d h.i.s");
		$fh			= fopen($WapPushFile, 'a');
		flock($fh, LOCK_EX);
		$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$result#mobile-marketing-system\n";
		fwrite($fh,$string );
		fclose($fh);
	
	} elseif ( $Status == 'OK' ){

		$TABLE1				= BJPARIS_TABLE;
		$SqlUpdateBJPARIS 	= "UPDATE `$TABLE1` SET `web_got_wappush` = \"1\"  WHERE CONVERT( `$TABLE1`.`web_mobilephone_full` USING utf8 ) = \"$MobilePhoneBeauty\" LIMIT 1;";
		$MySqlExec 			= doSQLQuery($SqlUpdateBJPARIS);
	
	}; # if ( $Status != 'OK' ){

	$WapPushFile= "/srv/server/logs/wappushs_simple_wantedtosend.txt";
	$DateTime	= date("Y-m-d h.i.s");
	$fh			= fopen($WapPushFile, 'a');
	flock($fh, LOCK_EX);
	$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$Status#mobile-marketing-system\n";
	fwrite($fh,$string );
	fclose($fh);

	return $Status;

	#### END: http://gateway.mobile-marketing-system.de

}; # function SendWapPushSimple( $MobilePhoneBeauty ){




function SendWapPush( $HandyNummer, $Pin, $MobilePhoneBeauty ){ # norale login handynummer, pin, handynummer mit landesvorwahl

	# Wichtig: Wappush Beschreibung und Wappush Link dürfen nicht mehr als 120 Zeichen lang sein

/*
	$Cutted				= substr($MobilePhoneBeauty, 2,strlen($MobilePhoneBeauty));
	$MobilePhoneBeauty	= "+".$Cutted;
*/

	# SMS anmeldedaten versenden
	SendAnmeldungsDaten( $HandyNummer, $MobilePhoneBeauty, $Pin);
	
	# 30 Sekunden schlafen, damit der user sms bekommen und daten lesen kann
	sleep(5);

	#### START: http://gateway.mobile-marketing-system.de

	#$Country	= classifyCountryByPhoneNumber( $HandyNummer );
	#$IsO2status	= classifyO2Number( $HandyNummer );

	$tmp		= $MobilePhoneBeauty;
	$tmp		= substr($tmp, 0, 4); 

	if ( $tmp == '0049' ){
		# low cost sms plus nach deutschland
		$result = send_wap_push("$MobilePhoneBeauty", "BitJoe Software", "http://www.bitjoe.de/software/BitJoe.jad", "route2");
	} else{
		# direkt plus nach ausland
		$result = send_wap_push("$MobilePhoneBeauty", "BitJoe Software", "http://www.bitjoe.de/software/BitJoe.jad", "route1");
	}; # if ( $tmp == '0049' ){


	list($Status,) = explode(" ", $result);	# OK MSG: 3
	
	if ( $Status != 'OK' ){	# fehler ist passiert
		
		$WapPushFile= "/srv/server/logs/wappushs_errors.txt";
		$DateTime	= date("Y-m-d h.i.s");
		$fh			= fopen($WapPushFile, 'a');
		flock($fh, LOCK_EX);
		$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$result#mobile-marketing-system\n";
		fwrite($fh,$string );
		fclose($fh);

	} elseif ( $Status == 'OK' ){
	
		$TABLE1				= BJPARIS_TABLE;
		$SqlUpdateBJPARIS 	= "UPDATE `$TABLE1` SET `web_got_wappush` = \"1\"  WHERE CONVERT( `$TABLE1`.`web_mobilephone_full` USING utf8 ) = \"$MobilePhoneBeauty\" LIMIT 1;";
		$MySqlExec 			= doSQLQuery($SqlUpdateBJPARIS);
		
	}; # if ( $Status != 'OK' ){


	$WapPushFile= "/srv/server/logs/wappushs_whole_wantedtosend.txt";
	$DateTime	= date("Y-m-d h.i.s");
	$fh			= fopen($WapPushFile, 'a');
	flock($fh, LOCK_EX);
	$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$Status#mobile-marketing-system\n";
	fwrite($fh,$string );
	fclose($fh);


	return $Status;

	#### END: http://gateway.mobile-marketing-system.de

}; # function SendWapPush( $HandyNummer ){


function send_wap_push($empfaenger, $text, $url, $versandroute = ""){
	
	global $username;
	global $password;
	
	$sms_query = sprintf("http://gateway.mobile-marketing-system.de/send_wap_push.php?username=%s&password=%s&text=%s&recipient=%s&url=%s&route=%s&dlr=1",
		urlencode($username),
		urlencode($password),
		urlencode($text),
		urlencode($empfaenger),
		urlencode($url),
		urlencode($versandroute)
	);

	ini_set('default_socket_timeout',3);
/*
	$WapPushFile= "out.txt";
		$DateTime	= date("Y-m-d h.i.s");
		$fh			= fopen($WapPushFile, 'a');
		flock($fh, LOCK_EX);
		$string		= "$sms_query\n";
		fwrite($fh,$string );
		fclose($fh);
*/

	if(function_exists("curl_init"))
	{
		$ch = curl_init($sms_query);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		$result = curl_exec($ch);
		curl_close($ch);
	}
	else
	{
		$fp = fopen($sms_query, "r");
		while(!feof($fp)) 
		{
			 $result .= fread($fp,4096);
		}
		
		fclose($fp);
	}

	return $result;

}; # function send_wap_push($empfaenger, $text, $url, $versandroute = ""){






/*
function SendWapPush( $HandyNummer, $Pin, $MobilePhoneBeauty ){ # norale login handynummer, pin, handynummer mit landesvorwahl

	# SMS anmeldedaten versenden
	SendAnmeldungsDaten( $HandyNummer, $MobilePhoneBeauty, $Pin);
	
	# 30 Sekunden schlafen, damit der user sms bekommen und daten lesen kann
	sleep(20);

	#### START: http://gateway.mobile-marketing-system.de

	$Country	= classifyCountryByPhoneNumber( $HandyNummer );
	$IsO2status	= classifyO2Number( $HandyNummer );

	# österreichische, schweizer und deutsche O2 Kunden bekommen den Wappush über mobile-marketing-system zugeschickt
	if ( $IsO2status == "1" OR $Country == 'AT' OR $Country == 'CH' ){

		# $result = send_wap_push("$HandyNummer", "BitJoe Installation - Installationshilfe unter www.bitjoe.de/hilfe - Dein PIN lautet: $Pin", "http://www.bitjoe.de/software/BitJoe.jad", "route1");
		$result = send_wap_push("$MobilePhoneBeauty", "BitJoe Software", "http://www.bitjoe.de/software/BitJoe.jad", "route1");
		list($Status,) = explode(" ", $result);	# OK MSG: 3
		
		if ( $Status != 'OK' ){
			
			$WapPushFile= "/srv/server/logs/wappushs_errors.txt";
			$DateTime	= date("Y-m-d h.i.s");
			$fh			= fopen($WapPushFile, 'a');
			flock($fh, LOCK_EX);
			$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$StatusCode\n";
			fwrite($fh,$string );
			fclose($fh);
		
		}; # if ( $Status != 'OK' ){

		return 1;

	}; # if ( $Country == 'AT' || $Country == 'CH' ){

	#### END: http://gateway.mobile-marketing-system.de



	$HiddenGateWayKey	= MOBILANTHIDDENKEY;
	$HalifaxWapURI		= urlencode("http://www.bitjoe.de/software/BitJoe.jad");
	$DisplayText		= urlencode("BitJoe Installation - Installationshilfe unter www.bitjoe.de/hilfe - Dein PIN lautet: $Pin"); # urlencode("PIN $Pin BitJoe - Installationshilfe unter www.bitjoe.de/hilfe");
	# OLD: $QueryUri			= "http://gateway.mobilant.net/?key=$HiddenGateWayKey&handynr=$HandyNummer&display=$DisplayText&url=$HalifaxWapURI&service=wap";
	$QueryUri			= "http://gateway2.mobilant.net/index.php?key=$HiddenGateWayKey&receiver=$MobilePhoneBeauty&name=$DisplayText&url=$HalifaxWapURI&service=wap";
	
	$HttpObj			= new HTTPRequest($QueryUri);
	$StatusCode			= $HttpObj->DownloadToString();
	
#	$request			= fopen($QueryUri,"r");
#	$StatusCode			= trim(fread($request,10)); 
#	fclose($request);
	list(,$StatusCode) = explode(":", $StatusCode);

	# wenn wappush nicht korrekt versendet wird, speichere die datei und versende den wappush später nocheinmal
	if ( $StatusCode != 100 ){

		$WapPushFile= "/srv/server/logs/wappushs_errors.txt";
		$DateTime	= date("Y-m-d h.i.s");
		$fh			= fopen($WapPushFile, 'a');
		flock($fh, LOCK_EX);
		$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$StatusCode\n";
		fwrite($fh,$string );
		fclose($fh);
		
	#	echo "Es gab ein Problem beim Versenden der BitJoe SMS Handysoftware. Wir senden Ihnen die Software später nochmal zu.";
	}; # if ( $StatusCode != 100 ){

	return 1;

}; # function SendWapPush( $HandyNummer ){
*/
?>

