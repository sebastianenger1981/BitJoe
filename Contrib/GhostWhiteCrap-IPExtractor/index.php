<?php

header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache"); 

set_error_handler("beQuiet"); 
function beQuiet() { return; };

# $CACHE = '/gwc/db/peer.cache';
 $CACHE = 'http://www.alpha64.info/Cache/cachelist.txt';

GetGwebCache();
function GetGwebCache(){
	
	$fd = fopen($CACHE,"r");
	if (!$fd) { echo "file access error"; exit;};

	while(!feof($fd)){
		$line = fgets($fd,500);
		#list($spalte1,$spalte2)=preg_split("\s",$line);
		echo "$line - $spalte1,$spalte2<br>";
	}; //while
	fclose($fd);
	exit(0);

};


?>