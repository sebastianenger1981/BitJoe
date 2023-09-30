<?php


require_once("/srv/server/wwwroot/lib/html.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

session_start();
session_name("BITJOEPARIS");
$MobilePhone = $_SESSION['mobilephone'];
$MobilePhoneStatus	= checkInput($MobilePhone, "M", 4, 17 );

if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {

# echo "'$MobilePhone' -'$MobilePhoneStatus' nicht angemeldet -> leite weiter auf /login/";
	header("HTTP/1.1 307 Temporary Redirect"); 
	header ("Location: /login/"); 
	exit(0);

}; # if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {


TarifePage($MobilePhone);
exit(0);

?>