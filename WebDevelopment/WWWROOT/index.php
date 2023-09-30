<?php

require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/ip2country.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

### Referer
$refPP		= deleteSqlChars($_REQUEST["r"]);
$grpPP		= deleteSqlChars($_REQUEST["g"]);
$refUID		= "";
$referingUrl	= htmlspecialchars(urldecode($_SERVER["HTTP_REFERER"]));
$RemoteIP	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
$iplook 	= new ip2country($RemoteIP);	# ip2country.inc.php

if ( $iplook->LookUp() ){
	$land = $iplook->Prefix1;
} else {
	$land = "NA";
};

IndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, "" );
LogAccessIndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, "" );
exit(0);

?>