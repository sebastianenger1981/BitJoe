<?php

require_once("/srv/server/wwwroot/lib/http.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");


$success_resend	= file ("/srv/server/logs/wappushs_resend.txt");
$file_handle	= fopen("/srv/server/logs/wappushs_errors.txt", "r");
$today			= date("Y-m-d");

while (!feof($file_handle)) {
	
	$line = fgets($file_handle);
	list($date,$number,$pin,$status) = explode("#", $line);  
	list($date,) = explode(" ", $date);
#	echo "$date und $today<br>";
	
	if ( $date == $today ) {
	
		$isGood = 1;
		foreach ( $success_resend as $ele ) {

			$ele = trim($ele);
			### echo "'$ele' und '$number'\n";
			if ( $ele == $number ) {
				$isGood = 0;
			}; # if ( $ele == $number ) {

		}; # foreach ( $ele as $success_resend )
		
		if ( $isGood == 1 ) {
			
			echo "[$isGood] Sending Wappush to: $number | $pin <br>\n";

			$StatusCode = SendWapPush($number,$pin);
			
			if ( $StatusCode == 100 ){
				
				$myFile = "/srv/server/logs/wappushs_resend.txt";
				$fh = fopen($myFile, 'a') or die("can't open file");
				$stringData = "$number\n";
				fwrite($fh, $stringData);
				fclose($fh);

			}; # if ( $StatusCode == 100 ){
			
			echo "[$StatusCode] After Sending Wappush to: $number | $pin <br> \n";
			sleep(10);

		}; # if ( $isGood == 1 ) {

	}; # if ( $date == $today ) {

}; # while (!feof($file_handle)) {
fclose($file_handle);


exit(0);












function SendWapPush( $HandyNummer, $Pin ){

	$HiddenGateWayKey	= MOBILANTHIDDENKEY;
	$HalifaxWapURI		= urlencode("www.bitjoe.de/software/BitJoe.jad");
	$DisplayText		= urlencode("Bitjoe.de PIN $Pin");
	# OLD: $QueryUri			= "http://gateway.mobilant.net/?key=$HiddenGateWayKey&handynr=$HandyNummer&display=$DisplayText&url=$HalifaxWapURI&service=wap";
	$QueryUri			= "http://gateway2.mobilant.net/index.php?key=$HiddenGateWayKey&receiver=$HandyNummer&name=$DisplayText&url=$HalifaxWapURI&service=wap";
	
	$HttpObj			= new HTTPRequest($QueryUri);
	$StatusCode			= $HttpObj->DownloadToString();
	
#	$request			= fopen($QueryUri,"r");
#	$StatusCode			= trim(fread($request,10)); 
#	fclose($request);
	list(,$StatusCode) = explode(":", $StatusCode);
	return $StatusCode;

}; # function SendWapPush( $HandyNummer ){




?>

