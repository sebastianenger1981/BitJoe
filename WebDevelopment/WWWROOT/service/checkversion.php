<?php

# testurl: http://www.bitjoe.de/service/checkversion.php?ip=79.12.3.12&lang=DE&bj_auth=e62526bcf84865dac863350c121e8f88&up_md5=2323232323232323

######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");



$LANG 				= $_REQUEST["lang"];
$IP 				= $_REQUEST["ip"];
$UP_MD5				= $_REQUEST["up_md5"];
$PerlApiAuthKey		= deleteSqlChars($_REQUEST["bj_auth"]);	# security.inc.php - böse zeichen entfernen
$PerlApiKeyStatus	= checkInput($PerlApiAuthKey, "M", 32, 32 );


if ( ( $PerlApiAuthKey != BITJOEPERLAPIACCESSKEY ) || ( $PerlApiKeyStatus != 1 ) ) {
	echo "$PerlApiAuthKey, $PerlApiKeyStatus";	# bei der finalen version gar nichts ausgeben
	exit(0);
}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {




if ( $LANG == 'de' || $LANG == 'DE' ){
	$content	= ReadFile_( CHECKVERSION_DE );
} else{
	$content	= ReadFile_( CHECKVERSIO_EN );
}; # if ( $LANG == 'de' || $LANG == 'DE' ){


list($currentversion,$features) = explode('##', $content );


echo "$currentversion##$features";

LogCheckForNewVersion( $IP, $LANG, $UP_MD5, "$currentversion##$features" );

exit(0);

?>