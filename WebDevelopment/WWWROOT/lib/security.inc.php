<?php

require_once("/srv/server/wwwroot/lib/config.inc.php");

#setze den error handler auf eine spezifische funktion - in diesem fall soll nix ausgegeben werden
set_error_handler("beQuietSecurity"); 
function beQuietSecurity() { return; };


#######################################################################
###################### wenn am tag zuoft gesucht wurde -> banned until 0:00
#######################################################################

function check_accessed_times( $path, $maxaccess ) {

	# bots bekommen keinen zugriff
	if ( preg_match("#(googlebot)|(msnbot|Lycos_Spider|eMiragorobot|Slurp|Ask Jeeves|WebCrawler|Scooter|Google)|(bot)#si", $_SERVER['HTTP_USER_AGENT']) ) {
		return 0;
	};

	$current_day	= strtolower(date("Ymd"));
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$Path		= $path;

	$check_handle	= fopen("$Path/check_access.$remote_ip","r");
	$last_access	= fgets($check_handle, 100);
	trim($last_access);
	fclose($check_handle);

	list($iplog,$times,$myday) = explode ("#", $last_access);
	trim($iplog); trim($times); trim($myday);	

	# nur wenn der gleiche tag ist, checke,sonst alles ok!
	# if ( preg_match("/$current_day/", $myday) ) {
	if ( $current_day == $myday ) {	
		
		### echo "same day  $current_day == $myday";

		# heute schon ueber MAXREQUESTPERDAY mal zugegriffen -> banne diese ip bis 0 Uhr
		if ( $times >= $maxaccess ) {		
	
			require_once("lib/html.inc.php");
			WebServiceAbusePage();
			exit(0);	
			# return 0;
				
		} else { 
			
			$newtimes 	= $times+1;
			$log_handle 	= fopen("$Path/check_access.$remote_ip","w");
			fputs($log_handle,"$remote_ip#$newtimes#$current_day");
			fclose($log_handle);
			
			#### echo "ADDING $remote_ip#$newtimes#$current_day";
			return 1;
	
		}; # if ( $times >= MAXREQUESTPERDAY ) {		
	
	} elseif ( $current_day != $myday ) {
	
		### echo "other day  '$current_day' != '$myday' ";

		# ip hat heute noch nicht zugegriffen,darum den ersten eintrag machen! 
		$notimes = "0";
		$log_handle = fopen("$Path/check_access.$remote_ip","w");
		fputs($log_handle,"$remote_ip#$notimes#$current_day");
		fclose($log_handle);
	
		return 1;

	}; #  if ( $current_day == $myday ) {	

	return 1;

};# function check_accessed_times() {




#######################################################################
###################### boese sonderzeichen entfernen
#######################################################################

function deleteSpecialChars($del_badchar) {

	if ( strlen($del_badchar) >= MAXINPUTSTRINGLENGHT ) {
		# l�sche alles nach dem 200sten zeichen bei �berlangen eingaben
		$del_badchar = substr($del_badchar, 0, MAXINPUTSTRINGLENGHT);		
	};

	$del_badchar = html_entity_decode($del_badchar);
	$del_badchar = str_replace("\"", "", $del_badchar);
	$del_badchar = str_replace("`", "", $del_badchar);
	$del_badchar = str_replace("'", "", $del_badchar);
	$del_badchar = str_replace("?", "", $del_badchar);
	$del_badchar = str_replace("%", "", $del_badchar);
	$del_badchar = str_replace("$", "", $del_badchar);
	$del_badchar = str_replace("§", "", $del_badchar);
	$del_badchar = str_replace("!", "", $del_badchar);
	$del_badchar = str_replace("&", "", $del_badchar);
	$del_badchar = str_replace("{", "", $del_badchar);
	$del_badchar = str_replace("}", "", $del_badchar);
	$del_badchar = str_replace("(", "", $del_badchar);
	$del_badchar = str_replace(")", "", $del_badchar);
	$del_badchar = str_replace("[", "", $del_badchar);
	$del_badchar = str_replace("]", "", $del_badchar);
	$del_badchar = str_replace("=", "", $del_badchar);
	$del_badchar = str_replace("\\", "", $del_badchar);
	$del_badchar = str_replace("\/", "", $del_badchar);
	$del_badchar = str_replace("#", "", $del_badchar);
	$del_badchar = str_replace(",", "", $del_badchar);
	$del_badchar = str_replace(";", "", $del_badchar);
	$del_badchar = str_replace("|", "", $del_badchar);
	$del_badchar = str_replace("<", "", $del_badchar);
	$del_badchar = str_replace(">", "", $del_badchar);
	$del_badchar = str_replace("/", "", $del_badchar);
	$del_badchar = str_replace("°", "", $del_badchar);
	$del_badchar = str_replace("^", "", $del_badchar);
	$del_badchar = str_replace("*", "", $del_badchar);
	$del_badchar = str_replace("+", "", $del_badchar);
	$del_badchar = str_replace("-", "", $del_badchar);
	# $del_badchar = str_replace(".", "", $del_badchar);
	$del_badchar = str_replace(",", "", $del_badchar);
	$del_badchar = str_replace("ß", "ss", $del_badchar);
	$del_badchar = str_replace("=&szlig;=", "ss", $del_badchar);
	$del_badchar = preg_replace("/\&+\#+(\d)+\;/", " ", $del_badchar);	# entferne html entities

	$del_badchar = preg_replace("/drop/i", "", $del_badchar);
	$del_badchar = preg_replace("/insert/i", "", $del_badchar);
	$del_badchar = preg_replace("/alter/i", "", $del_badchar);
	$del_badchar = preg_replace("/distinct/i", "", $del_badchar);
	$del_badchar = preg_replace("/flush/i", "", $del_badchar);
	$del_badchar = preg_replace("/union select/i", "", $del_badchar);
	$del_badchar = preg_replace("/select/i", "", $del_badchar);
	$del_badchar = preg_replace("/empty/i", "", $del_badchar);
	$del_badchar = preg_replace("/truncate/i", "", $del_badchar);
	$del_badchar = preg_replace("/update/i", "", $del_badchar);
	$del_badchar = preg_replace("/show tables/i", "", $del_badchar);
	$del_badchar = preg_replace("/exec/i", "", $del_badchar);
	$del_badchar = preg_replace("/system/i", "", $del_badchar);
	$del_badchar = preg_replace("/cmd/i", "", $del_badchar);
		 
	return $del_badchar;
	
}; # function deleteSpecialChars($del_badchar) {
	
	
function deleteSqlChars($del_badchar) {

	if ( strlen($del_badchar) >= MAXINPUTSTRINGLENGHT ) {
		# lösche alles nach dem 200sten zeichen bei überlangen eingaben
		$del_badchar = substr($del_badchar, 0, MAXINPUTSTRINGLENGHT);		
	};

	#$del_badchar = html_entity_decode($del_badchar);
	$del_badchar = str_replace("`", "", $del_badchar);
	$del_badchar = str_replace("|", "", $del_badchar);
	$del_badchar = str_replace("<", "", $del_badchar);
	$del_badchar = str_replace(">", "", $del_badchar);
	$del_badchar = str_replace("^", "", $del_badchar);
	$del_badchar = str_replace(" ", "", $del_badchar);
	$del_badchar = preg_replace("/drop/i", "", $del_badchar);
	$del_badchar = preg_replace("/insert/i", "", $del_badchar);
	$del_badchar = preg_replace("/alter/i", "", $del_badchar);
	$del_badchar = preg_replace("/distinct/i", "", $del_badchar);
	$del_badchar = preg_replace("/flush/i", "", $del_badchar);
	$del_badchar = preg_replace("/union select/i", "", $del_badchar);
	$del_badchar = preg_replace("/select/i", "", $del_badchar);
	$del_badchar = preg_replace("/empty/i", "", $del_badchar);
	$del_badchar = preg_replace("/truncate/i", "", $del_badchar);
	$del_badchar = preg_replace("/update/i", "", $del_badchar);
	$del_badchar = preg_replace("/show tables/i", "", $del_badchar);
	$del_badchar = preg_replace("/exec/i", "", $del_badchar);
	$del_badchar = preg_replace("/system/i", "", $del_badchar);
	$del_badchar = preg_replace("/cmd/i", "", $del_badchar);
		 
	return $del_badchar;
	
}; # function deleteSpecialChars($del_badchar) {






/* L�sche gef�hrliche SQL-Commandos und versuche so SQL-Injection zu verhindern
$del_badchar = str_ireplace("drop", "", $del_badchar);
$del_badchar = str_ireplace("insert", "", $del_badchar);
$del_badchar = str_ireplace("alter", "", $del_badchar);
$del_badchar = str_ireplace("distinct", "", $del_badchar);
$del_badchar = str_ireplace("flush", "", $del_badchar);
$del_badchar = str_ireplace("union select", "", $del_badchar);
$del_badchar = str_ireplace("select", "", $del_badchar);
$del_badchar = str_ireplace("empty", "", $del_badchar);
$del_badchar = str_ireplace("truncate", "", $del_badchar);
$del_badchar = str_ireplace("update", "", $del_badchar);
$del_badchar = str_ireplace("show tables", "", $del_badchar);
$del_badchar = str_ireplace("exec", "", $del_badchar);
$del_badchar = str_ireplace("system", "", $del_badchar);
$del_badchar = str_ireplace("cmd", "", $del_badchar);
 */


/*
function HTTPStatus($num) {
   
   static $http = array (
       100 => "HTTP/1.1 100 Continue",
       101 => "HTTP/1.1 101 Switching Protocols",
       200 => "HTTP/1.1 200 OK",
       201 => "HTTP/1.1 201 Created",
       202 => "HTTP/1.1 202 Accepted",
       203 => "HTTP/1.1 203 Non-Authoritative Information",
       204 => "HTTP/1.1 204 No Content",
       205 => "HTTP/1.1 205 Reset Content",
       206 => "HTTP/1.1 206 Partial Content",
       300 => "HTTP/1.1 300 Multiple Choices",
       301 => "HTTP/1.1 301 Moved Permanently",
       302 => "HTTP/1.1 302 Found",
       303 => "HTTP/1.1 303 See Other",
       304 => "HTTP/1.1 304 Not Modified",
       305 => "HTTP/1.1 305 Use Proxy",
       307 => "HTTP/1.1 307 Temporary Redirect",
       400 => "HTTP/1.1 400 Bad Request",
       401 => "HTTP/1.1 401 Unauthorized",
       402 => "HTTP/1.1 402 Payment Required",
       403 => "HTTP/1.1 403 Forbidden",
       404 => "HTTP/1.1 404 Not Found",
       405 => "HTTP/1.1 405 Method Not Allowed",
       406 => "HTTP/1.1 406 Not Acceptable",
       407 => "HTTP/1.1 407 Proxy Authentication Required",
       408 => "HTTP/1.1 408 Request Time-out",
       409 => "HTTP/1.1 409 Conflict",
       410 => "HTTP/1.1 410 Gone",
       411 => "HTTP/1.1 411 Length Required",
       412 => "HTTP/1.1 412 Precondition Failed",
       413 => "HTTP/1.1 413 Request Entity Too Large",
       414 => "HTTP/1.1 414 Request-URI Too Large",
       415 => "HTTP/1.1 415 Unsupported Media Type",
       416 => "HTTP/1.1 416 Requested range not satisfiable",
       417 => "HTTP/1.1 417 Expectation Failed",
       500 => "HTTP/1.1 500 Internal Server Error",
       501 => "HTTP/1.1 501 Not Implemented",
       502 => "HTTP/1.1 502 Bad Gateway",
       503 => "HTTP/1.1 503 Service Unavailable",
       504 => "HTTP/1.1 504 Gateway Time-out"        
   );
   
   header($http[$num]);
*/


?>