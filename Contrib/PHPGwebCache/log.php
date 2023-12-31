<?php

require_once("/var/www/gwebcache/vars.php");

if( !defined("DATA_DIR") )
	die();

#if( !file_exists("log/") )
#	mkdir("log/", 0777);

$logDir = LOG_DIR;

function Logging($filename, $CLIENT, $VERSION, $NET)
{
	$HTTP_X_FORWARDED_FOR = isset($_SERVER["HTTP_X_FORWARDED_FOR"]) ? $_SERVER["HTTP_X_FORWARDED_FOR"] : "";
	$HTTP_CLIENT_IP = isset($_SERVER["HTTP_CLIENT_IP"]) ? $_SERVER["HTTP_CLIENT_IP"] : "";

	$file = fopen("$logDir".$filename.".log", "a");
	flock($file, 2);
	fwrite($file, gmdate("Y/m/d h:i:s A")." | ".$CLIENT." ".$VERSION." | ".$_SERVER["HTTP_USER_AGENT"]." | ".$NET." | ".$_SERVER["QUERY_STRING"]." | ".$_SERVER["REMOTE_ADDR"]." | ".$HTTP_X_FORWARDED_FOR." | ".$HTTP_CLIENT_IP."\r\n");
	flock($file, 3);
	fclose($file);
}
?>