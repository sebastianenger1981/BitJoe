<?php

header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache"); 

set_error_handler("beQuiet"); 
function beQuiet() { return; };

#srand((double)microtime()*1000000);

require_once("/srv/server/wwwroot/searches/http.inc.php");
require_once("/srv/server/wwwroot/searches/fuzzy.inc.php");

# stopwordliste
$StopWordList	 = array (
							"porn",
							"tit",
							"horny",
							"porno",
							"xxx",
							"ass",
							"sex",
							"lesbian",
							"anal",
							"slut",
							"pussy",
							"shemale",
							"lolita",
							"teen",
							"dick",
							"rape",
							"gay",
							"playboy",
							"toilet",
							"beastiality",
							"adult",
							"erotic",
							"hardcore",
							"fucking", 
							"blowjob", 
							"cock", 
							"erotic", 
							"bitch",
							"fuck",
);


$SearchQueryOrg	= trim(strtolower($_REQUEST["q"]));	# suchwort in kleinbuchstaben und ohne leerzeichen am anfang
$CachePath		= "/server/usenext";
$CacheFile		= $CachePath . "/" . md5( $SearchQueryOrg );
$StrLength		= strlen(file_get_contents($CacheFile));

# echo "Your searched for: '" . $SearchQueryOrg . "'";
# exit;

$usenext_filter_file	= "/srv/server/wwwroot/searches/usenext_blocker.txt";
$FilesToFilter			= file($usenext_filter_file);
$SearchQuery			= $SearchQueryOrg;


foreach ( $FilesToFilter as $toBlock ) {
	
	$toBlock	= trim($toBlock);
	$search		= new Approximate_Search( $toBlock, 1 );	# 3=fuzzy tollerance
	$matches	= $search->search( $SearchQuery );

	if ( strcasecmp($SearchQuery, $toBlock) == 0 || count($matches) >= 1 ){
				
		exit(0);	

	}; # if ( count($matches) >= 1 ) {

}; # foreach ( $FilesToFilter as $toBlock ) {


# schaue, ob eintrag als cache vorliegt
if (file_exists($CacheFile) && $StrLength >= 100) {
	
	# DEBUG: 
	# echo "Cache hit<br>\n";
		
	$count		= 0;
	$fh			= fopen($CacheFile, 'r') or warn("Error!!");

	while (!feof($fh)) {
		$ResultString .= fread($fh, 2048);
		# echo fread($fh, 2048); 
	}; # while (!feof($fh)) {

	
	foreach ( explode(';', $ResultString ) as $string) {
		list( $lenght, $name, $type ) = explode(',', $string);
		if ( $count <= 10000 ) {
			if ( preg_match("/[\w]/", $name)){
				
				$GoodCount = 0;
				foreach ( $StopWordList as $stopword ) {	# für jeden eintrag der stopwordliste
					$pos = strpos(strtolower($name), $stopword);	# teste, ob der kleine string das word $stopword enthält
					if ( $pos === false ) {	# string nicht gefunden, somit guter Eintrag
						$GoodCount++;			
					};  # if ($pos === false) {
				}; #  foreach ( $StopWordList as $stopword ) {
			
				if ( $GoodCount == count($StopWordList) ){	# wenn keines der stopwörter vorkam, ist goodcount gleich der anzahl der stopwörter
					$name = str_replace("german", "english", strtolower($name) );
					$name = str_replace("deutsch", "english", strtolower($name) );
					echo "$lenght,$name,$type;";
				}; # if ( $GoodCount == count($StopWordList) ){

			}; # if ( preg_match("/[\w]/", $name)){

		}; # if ( $count <= 10000 ) {
		$count++;
	}; # foreach 

	exit(0);

} else {

	# DEBUG: 
	# echo "Cache Miss<br>";

	$results		= queryUsenetServer( $SearchQueryOrg );

	$ArrayFileType	= array(	"0"	=>	"iso",
								"1"	=>	"rar",
								"2"	=>	"zip",
								"3"	=>	"ace",
								"4"	=>	"bin" );

	$RandFileType		= rand(0, 4);
	$Query				= str_replace("%20", " ", $SearchQueryOrg );
	$RandFileLenght		= rand(470540046, 2870540046);					# zwischen 470 - 2,8 GB
	$RandFileLenght		= str_replace("-", "", $RandFileLenght );
	$SearchQueryParts	= explode(" ", $Query );

	foreach ($SearchQueryParts as $Parts){
		$SearchQuery	.= ' ' . ucfirst($Parts);  
	};
	$SearchQuery		= ltrim($SearchQuery);

	$GoodCount1 = 0;
	foreach ( $StopWordList as $stopword ) {
		$pos = strpos(strtolower($SearchQuery), $stopword);
		if ($pos === false) {	# string nicht gefunden, somit guter Eintrag
			$GoodCount1++;			
		};  # if ($pos === false) {
	}; #  foreach ( $StopWordList as $stopword ) {

	if ( $GoodCount1 == count($StopWordList) ){
		echo "$RandFileLenght,$SearchQuery,$ArrayFileType[$RandFileType]; ";
	}; # if ( $GoodCount == count($StopWordList) ){

	$count = 0;

	# foreach ( preg_split("usenext:\?t=+[\w]+[\.]/", $results ) as $string) {
	foreach ( explode("\n", $results ) as $string) {
		list( $lenght, $name, $type ) = explode(',', $string);
		
		if ( $count <= 10000 ) {
			if ( preg_match("/[\w]/", $name)){
				$GoodCount = 0;
				foreach ( $StopWordList as $stopword ) {	# für jeden eintrag der stopwordliste
					$pos = strpos(strtolower($name), $stopword);	# teste, ob der kleine string das word $stopword enthält
					if ( $pos === false ) {	# string nicht gefunden, somit guter Eintrag
						$GoodCount++;			
					};  # if ($pos === false) {
				}; #  foreach ( $StopWordList as $stopword ) {
			
				if ( $GoodCount == count($StopWordList) ){	# wenn keines der stopwörter vorkam, ist goodcount gleich der anzahl der stopwörter
					$name = str_replace("german", "english", strtolower($name) );
					$name = str_replace("deutsch", "english", strtolower($name) );
					echo "$lenght,$name,$type;";
				}; # if ( $GoodCount == count($StopWordList) ){

			}; # if ( preg_match("/[\w]/", $name)){
		}; # if ( $count <= 10000 ) {

		$count++;
	}; # foreach 


	# write cache


	$fh = fopen($CacheFile, 'w') or warn("Error!!");
	fwrite($fh, "$RandFileLenght,$SearchQuery,$ArrayFileType[$RandFileType]; ");
	#	foreach ( preg_split("usenext:\?t=+[\w]+[\.]/", $results ) as $string) {
		foreach ( explode("\n", $results ) as $string) {
			list( $lenght, $name, $type ) = explode(',', $string);
			if ( preg_match("/[\w]/", $name)){
				$name = str_replace("german", "english", strtolower($name) );
				$name = str_replace("deutsch", "english", strtolower($name) );
				fwrite($fh, "$lenght,$name,$type;");
			}; # if ( preg_match("/[\w]/", $name)){
		}; # foreach 
	fclose($fh);
	
	# cache written

	exit(0);

} # if (file_exists($CacheFile)) {




# programm beenden
exit(0);




function queryUsenetServer( $query ){
	
	# wandle " " in "+" um - ohne dem funzt usenext suche nicht !
	$query	= str_replace(" ", "+", $query);

	$url	= 'http://search.usenext.de/search/searchfilegroup_ext?search=' . $query;	
	$obj	= new HTTPRequest($url);
	return $obj->DownloadToString();
	
}; # function QueryUsenetServer( $query ){}




?>