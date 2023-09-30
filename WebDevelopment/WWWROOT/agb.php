<?php

require_once("/srv/server/wwwroot/lib/html.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

### Referer
$agb		= $_REQUEST["agb"];

if ( $agb == 1 ) {

	BezahlPageStep2();

} else {

	BezahlPageStep1();

}; # if ( $agb == 1 ) {

exit(0);

?>