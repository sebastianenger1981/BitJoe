<?php

require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/http.inc.php");


function SendAnmeldungsDatenLogin2( $HandyNummer, $MobilePhoneBeauty, $Pin ){

	$SmsMessage	= "BitJoe Zugangsdaten: Handynummer: $HandyNummer, PIN: $Pin - Einfach unter www.bitjoe.de/login2/ einloggen und Handy Download Software aufs Handy bekommen.";
	$SmsMessage	= urlencode($SmsMessage);
	
	$tmp		= $MobilePhoneBeauty;
	$tmp		= substr($tmp, 0, 4); 

	if ( $tmp == '0049' ){
		# low cost sms plus nach deutschland
		$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($MobilePhoneBeauty) . "&message=" . $SmsMessage . "&originator=BitJoe.de" . "&type=low";
	} else{
		# direkt plus nach ausland
		$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($MobilePhoneBeauty) . "&message=" . $SmsMessage . "&originator=BitJoe.de";# . "&type=low";
	}; # if ( $tmp == '0049' ){



#	$r 			= new HTTPRequest($MessageURI);
#	$status 	= $r->DownloadToString();
	

	ini_set('default_socket_timeout',3);
	$request	= fopen($MessageURI,"r");
	$status		= trim(fread($request,10)); 
	fclose($request);

	list(,$status) = explode(":", $status);

	$File		= "/srv/server/logs/sms_wantedtosend.txt";
	$DateTime	= date("Y-m-d h.i.s");
	$fh			= fopen($File, 'a');
	flock($fh, LOCK_EX);
	$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$status#mobilant\n";
	fwrite($fh,$string );
	fclose($fh);

	return trim($status);
	
}; # function SendAnmeldungsDatenLogin2( $HandyNummer, $MobilePhoneBeauty, $Pin ){



function SendAnmeldungsDaten( $HandyNummer, $MobilePhoneBeauty, $Pin ){

	$SmsMessage	= "Deine BitJoe Zugangsdaten lauten: Handynummer: $HandyNummer, PIN: $Pin - Hilfe zur Benutzung von BitJoe gibt es unter www.bitjoe.de/hilfe!";
	$SmsMessage	= urlencode($SmsMessage);
	

	$tmp		= $MobilePhoneBeauty;
	$tmp		= substr($tmp, 0, 4); 

	if ( $tmp == '0049' ){
		# low cost sms plus nach deutschland
		$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($MobilePhoneBeauty) . "&message=" . $SmsMessage . "&originator=BitJoe.de" . "&type=low";
	} else{
		# direkt plus nach ausland
		$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($MobilePhoneBeauty) . "&message=" . $SmsMessage . "&originator=BitJoe.de";# . "&type=low";
	}; # if ( $tmp == '0049' ){


#	$r 			= new HTTPRequest($MessageURI);
#	$status 	= $r->DownloadToString();
	
	ini_set('default_socket_timeout',3);
	$request	= fopen($MessageURI,"r");
	$status		= trim(fread($request,10)); 
	fclose($request);

	list(,$status) = explode(":", $status);

	$File		= "/srv/server/logs/sms_wantedtosend.txt";
	$DateTime	= date("Y-m-d h.i.s");
	$fh			= fopen($File, 'a');
	flock($fh, LOCK_EX);
	$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$status#mobilant\n";
	fwrite($fh,$string );
	fclose($fh);

	return trim($status);
	
}; # function SendTellAFriendMessage( $PhoneNumberTo, $PhoneNumberFrom ){




function SendPasswordReminder( $PhoneNumberTo, $SmsMessage ){

	$SmsMessage	= urlencode($SmsMessage);
	$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($PhoneNumberTo) . "&message=" . $SmsMessage . "&originator=BitJoe.de"."&type=low";

#	$r 			= new HTTPRequest($MessageURI);
#	$status 	= $r->DownloadToString();

	ini_set('default_socket_timeout',3);
	$request	= fopen($MessageURI,"r");
	$status		= trim(fread($request,10)); 
	fclose($request);

	list(,$status) = explode(":", $status);

	$File		= "/srv/server/logs/sms_wantedtosend.txt";
	$DateTime	= date("Y-m-d h.i.s");
	$fh			= fopen($File, 'a');
	flock($fh, LOCK_EX);
	$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$status#mobilant\n";
	fwrite($fh,$string );
	fclose($fh);

	return trim($status);
	
}; # function SendPasswordReminder( $PhoneNumberTo, $SmsMessage ){



function SendTellAFriendMessage( $PhoneNumberTo, $PhoneNumberFrom ){

	$SmsMessage	= TELL_A_FRIEND_TEXT;
	$SmsMessage	= urlencode($SmsMessage);
	$MessageURI	= "http://gateway2.mobilant.net/index.php?key=" . MOBILANTHIDDENKEY . "&service=sms&receiver=" . trim($PhoneNumberTo) . "&message=" . $SmsMessage . "&originator=". trim($PhoneNumberFrom) . "&type=low";

#	$r 			= new HTTPRequest($MessageURI);
#	$status 	= $r->DownloadToString();
	
	ini_set('default_socket_timeout',3);
	$request	= fopen($MessageURI,"r");
	$status		= trim(fread($request,10)); 
	fclose($request);

	list(,$status) = explode(":", $status);

	$File		= "/srv/server/logs/sms_wantedtosend.txt";
	$DateTime	= date("Y-m-d h.i.s");
	$fh			= fopen($File, 'a');
	flock($fh, LOCK_EX);
	$string		= "$DateTime#TO=$MobilePhoneBeauty#$HandyNummer#$Pin#$status#mobilant\n";
	fwrite($fh,$string );
	fclose($fh);

	return trim($status);
	
}; # function SendTellAFriendMessage( $PhoneNumberTo, $PhoneNumberFrom ){


	#$SmsMessage	= "BitJoe Update - Deine Zugangsdaten : Handynummer: $HandyNummer, PIN: $Pin - Hilfe zur Benutzung von BitJoe gibt es unter www.bitjoe.de/hilfe!";

?>

