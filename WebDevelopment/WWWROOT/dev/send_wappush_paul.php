<?php

$username = "KU-T6VI";	// hier bitte Ihre Kunden-ID eintragen
$password = "FMBS1ZXA";	// hier bitte das in den Einstellungen definierte Password



function send_wap_push($empfaenger, $text, $url, $versandroute = "")
{
	global $username;
	global $password;
	
	$sms_query = sprintf("http://gateway.mobile-marketing-system.de/send_wap_push.php?username=%s&password=%s&text=%s&recipient=%s&url=%s&route=%s",
		urlencode($username),
		urlencode($password),
		urlencode($text),
		urlencode($empfaenger),
		urlencode($url),
		urlencode($versandroute)
	);

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
}

$result = send_wap_push("015154822782", "Bitjoe Download Software", "http://www.bitjoe.de/software/BitJoe.jad", "route2");

echo $result;

?>
