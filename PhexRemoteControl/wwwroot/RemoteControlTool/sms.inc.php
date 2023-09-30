<?php

function SendSMS( $SmsMessage ){

	$Admins				= array("01607979247");

	foreach ( $Admins as $PhoneNumber ) { 

		$Absender			= "BitJoe Paris";
		$HiddenGateWayKey	= "0efe39e0c019fd11f32044749dbb1ab2";
		$SmsMessage			= urlencode($SmsMessage);
		$QueryUri			= "http://gateway.mobilant.net/?key=" . $HiddenGateWayKey . "&handynr=" . $PhoneNumber . "&text=" . $SmsMessage . "&kennung=". $Absender;
		$request			= fopen($QueryUri,"r");
		$StatusCode			= trim(fread($request,10)); 
		fclose($request);

	}; # foreach ( $Admins as $PhoneNumber ) { 

	return 1;

}; # function SendSMS( $DisplayText ){

?>