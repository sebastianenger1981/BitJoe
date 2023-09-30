<?php

/*
	Autor:		Sebastian Enger
	Copyright:	Sebastian Enger
	LastMod:	7.6.2007 / 23.07 Uhr
	Hint:		Leite auf eine vorgegebene Seite um mit hilfe von geotargeting!
*/

require_once ("/home/wwwroot/download/geoip.inc.php");
$gi = geoip_open("/home/wwwroot/download/GeoIP.dat", GEOIP_STANDARD);

$remote_ip		= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
$CountryCode	= geoip_country_code_by_addr($gi, $remote_ip);

if ( strcasecmp( $CountryCode , "de") == 0 || strcasecmp( $CountryCode , "at") == 0 || strcasecmp( $CountryCode , "ch") == 0 ) {

	readfile("de/index.html");
	exit(0);

} else {

	readfile("en/index.html");
	exit(0);

};

exit(0);

?>