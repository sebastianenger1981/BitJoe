<?php
//
//   Skulls! Multi-Network WebCache (PHP)
//
//   Copyright (C) 2005-2006 by ale5000
//   Sources of this script can be downloaded here: http://sourceforge.net/projects/skulls/
//
//   This program is free software; you can redistribute it and/or
//   modify it under the terms of the GNU General Public License
//   as published by the Free Software Foundation; either version 2
//   of the License, or (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

include "vars.php";

if( !defined("DATA_DIR") && !file_exists("vars.php") )
	die("ERROR: The file vars.php is missing.");

#if(!$ENABLED || basename($_SERVER["PHP_SELF"]) == "index.php")
#{
#	header("Status: 404 Not Found");
#	header("Content-Type: text/plain");
#	die("ERROR: Service disabled\r\n");
#}

if($_SERVER["REMOTE_ADDR"] == "196.31.80.247")
{
	header("Status: 404 Not Found");
	if(LOG_HAMMERING_CLIENTS)
	{
		include "log.php";
		Logging("hammering_clients", NULL, NULL, NULL);
	}
	die();
}

define( "NAME", "Skulls" );
define( "VENDOR", "SKLL" );
define( "SHORT_VER", "0.2.2" );
define( "VER", SHORT_VER." Beta" );

$SUPPORTED_NETWORKS[] = "Gnutella";
$SUPPORTED_NETWORKS[] = "Gnutella2";

$networks_count = count($SUPPORTED_NETWORKS);
define( "NETWORKS_COUNT", $networks_count );

function InizializeNetworkFiles($net){
	$net = strtolower($net);
	if( !file_exists(DATA_DIR."/hosts_".$net.".dat") ) fclose( fopen(DATA_DIR."/hosts_".$net.".dat", "x") );
}

function Inizialize($supported_networks){
	if( !file_exists(DATA_DIR."/runnig_since.dat") )
	{
		if( !file_exists(DATA_DIR."/") ) mkdir(DATA_DIR."/", 0777);

		$file = fopen( DATA_DIR."/runnig_since.dat", "w" );
		if( !$file )
			die("ERROR: Writing file failed\r\n");
		else
		{
			flock($file, 2);
			fwrite($file, gmdate("Y/m/d h:i:s A"));
			flock($file, 3);
			fclose($file);
		}

		if( !file_exists(DATA_DIR."/caches.dat") ) fclose( fopen(DATA_DIR."/caches.dat", "x") );
		if( !file_exists(DATA_DIR."/failed_urls.dat") ) fclose( fopen(DATA_DIR."/failed_urls.dat", "x") );
	}

	for( $i = 0; $i < NETWORKS_COUNT; $i++ )
		InizializeNetworkFiles( $supported_networks[$i] );

	if( STATS_ENABLED && !file_exists("stats/requests.dat") )
	{
		if( !file_exists("stats/") ) mkdir("stats/", 0777);

		$file = fopen( "stats/requests.dat", "x" );
		flock($file, 2);
		fwrite($file, "0");
		flock($file, 3);
		fclose($file);

		if( !file_exists("stats/update_requests_hour.dat") ) fclose( fopen("stats/update_requests_hour.dat", "x") );
		if( !file_exists("stats/other_requests_hour.dat") ) fclose( fopen("stats/other_requests_hour.dat", "x") );
	}
}

function NetsToString()
{
	global $SUPPORTED_NETWORKS;
	$nets = "";

	for( $i=0; $i < NETWORKS_COUNT; $i++ )
	{
		if($i) $nets .= "-";
		$nets .= $SUPPORTED_NETWORKS[$i];
	}
	return $nets;
}

function Pong($multi, $net, $client, $supported_net){
	if($_SERVER["REMOTE_ADDR"] == "127.0.0.1")	// Prevent caches that incorrectly point to 127.0.0.1 to being added to cache list
		return;

	if( $multi || $supported_net )
	{
		if($supported_net && $net == "gnutella")
			print "PONG ".NAME." ".VER."\r\n";

		$nets = strtolower( NetsToString() );
		if( $client == "TEST" && !$multi && $net == "gnutella2" )
			print "I|pong|".NAME." ".VER."|gnutella2|COMPAT|".$nets."|TCP\r\n";	// Workaround for compatibility with Bazooka
		elseif( $client == "GCII" && !$multi && $net == "gnutella2" )
			print "I|pong|".NAME." ".VER."||COMPAT|".$nets."|TCP\r\n";			// Workaround for compatibility with PHPGnuCacheII
		else
			print "I|pong|".NAME." ".VER."|".$nets."|TCP\r\n";
	}
}

function Support($supported_networks)
{
	for( $i = 0; $i < NETWORKS_COUNT; $i++ )
		print "I|support|".strtolower($supported_networks[$i])."\r\n";
}

function CheckNetwork($supported_networks, $net){
	for( $i = 0; $i < NETWORKS_COUNT; $i++ )
		if( strtolower($supported_networks[$i]) == strtolower($net) )
			return TRUE;

	return FALSE;
}

function CheckNetworkString($supported_networks, $nets, $multi = TRUE)
{
	if( $multi && strpos($nets, "-") > -1 )
	{
		$nets = explode( "-", $nets );
		$nets_count = count($nets);
		for( $i = 0; $i < $nets_count; $i++ )
			if( CheckNetwork($supported_networks, $nets[$i]) )
				return TRUE;
	}
	else
	{
		if( CheckNetwork($supported_networks, $nets) )
			return TRUE;
	}

	if(LOG_MINOR_ERRORS)
	{
		global $CLIENT, $VERSION, $NET;
		Logging("unsupported_nets", $CLIENT, $VERSION, $NET);
	}

	return FALSE;
}

function TimeSinceSubmissionInSeconds($now, $time_of_submission, $offset){
	$time_of_submission = trim($time_of_submission);
	return $now - ( @strtotime($time_of_submission) + $offset );	// GMT
}

function CheckIPValidity($remote_ip, $ip){
	$ip_port = explode(":", $ip);	// $ip_port[0] = IP	$ip_port[1] = Port

	if( count($ip_port) == 2 &&
		is_numeric($ip_port[1]) &&
		$ip_port[1] > 0 &&
		$ip_port[1] < 65536 &&
		strlen($ip_port[0]) >= 7 &&
		$ip_port[0] == $remote_ip &&
		ip2long($ip_port[0]) == ip2long($remote_ip)
	)
		return TRUE;

	if(LOG_MINOR_ERRORS)
	{
		global $CLIENT, $VERSION, $NET;
		Logging("invalid_ips", $CLIENT, $VERSION, $NET);
	}

	return FALSE;
}

function CheckURLValidity($cache){
	if( strlen($cache) > 10 && !(strpos($cache, "|") > -1) )
		if( substr($cache, 0, 7) == "http://" || substr($cache, 0, 8) == "https://" )
			return TRUE;

	if(LOG_MINOR_ERRORS)
	{
		global $CLIENT, $VERSION, $NET;
		Logging("invalid_urls", $CLIENT, $VERSION, $NET);
	}

	return FALSE;
}

function CheckBlockedCache($cache){
	$cache = strtolower($cache);
	// Lynn Cache 0.4 - Bad webcache: it ignore net parameter, it is outdated, it doesn't clean urls and it also doesn't identify itself when it ping other webcaches so url update doesn't work.
	if(
		$cache == "http://www.exactmobile.co.za/cache.asp" ||
		$cache == "http://www.exactmobile.co.za/cache.asp/" ||
		$cache == "http://www.sexymobile.co.za/cache.asp"
	)
		return TRUE;

	return FALSE;
}

function IsClientTooOld($client, $version){
	if( $version == "" )
		return FALSE;

	$version = (float)$version;

    switch($client)
	{
		case "RAZA":
			if( $version < 2 )
				return TRUE;
			break;
    }

	return FALSE;
}

function CheckFailedUrl($url){
	$file = file(DATA_DIR."/failed_urls.dat");
	$file_count = count($file);

	for ($i = 0, $now = time(), $offset = @date("Z"); $i < $file_count; $i++)
	{
		$read = explode("|", $file[$i]);
		if( strtolower($url) == strtolower($read[0]) )
		{
			$read[1] = trim($read[1]);
			$time_diff = $now - ( @strtotime( $read[1] ) + $offset );	// GMT
			$time_diff = floor($time_diff / 86400);	// Days

			if( $time_diff < 2 ) return TRUE;
		}
	}

	return FALSE;
}

function AddFailedUrl($url){
	$file = fopen(DATA_DIR."/failed_urls.dat", "a");
	flock($file, 2);
	fwrite($file, $url."|".gmdate("Y/m/d h:i:s A")."\r\n");
	flock($file, 3);
	fclose($file);
}

function ReplaceHost($host_file, $line, $ip, $leaves, $net, $cluster, $client, $version){
	$new_host_file = implode("", array_merge( array_slice($host_file, 0, $line), array_slice( $host_file, ($line + 1) ) ) );

	$file = fopen(DATA_DIR."/hosts_".$net.".dat", "w");
	flock($file, 2);
	fwrite($file, $new_host_file.$ip."|".$leaves."|".$cluster."|".$client."|".$version."|".gmdate("Y/m/d h:i:s A")."\r\n");
	flock($file, 3);
	fclose($file);
}

function ReplaceCache($cache_file, $line, $cache, $cache_data, $client, $version){
	$new_cache_file = implode("", array_merge( array_slice($cache_file, 0, $line), array_slice( $cache_file, ($line + 1) ) ) );

	$file = fopen(DATA_DIR."/caches.dat", "w");
	flock($file, 2);
	if($cache != NULL)
		fwrite($file, $new_cache_file.$cache."|".$cache_data[0]."|".$cache_data[1]."|".$client."|".$version."|".gmdate("Y/m/d h:i:s A")."\r\n");
	else
		fwrite($file, $new_cache_file);
	flock($file, 3);
	fclose($file);
}

function PingWebCache($cache){
	global $SUPPORTED_NETWORKS;

	list( , $cache ) = explode("://", $cache, 2);		// It remove "http://" from "cache" - $cache = www.test.com:80/page.php
	$main_url = explode("/", $cache);					// $main_url[0] = www.test.com:80		$main_url[1] = page.php
	$splitted_url = explode(":", $main_url[0], 2);		// $splitted_url[0] = www.test.com		$splitted_url[1] = 80

	if( count($splitted_url) > 1 )
		list($host_name, $port) = $splitted_url;
	else
	{
		$host_name = $main_url[0];
		$port = 80;
	}

	$fp = @fsockopen( $host_name, $port, $errno, $errstr, TIMEOUT );

	if(!$fp)
	{
		//echo "Error ".$errno."\r\n";
		$cache_data[0] = "FAILED";
	}
	else
	{
		$pong = "";
		$oldpong = "";
		$error = "";

		$query = "ping=1&multi=1&client=".VENDOR."&version=".SHORT_VER."&cachename=".NAME;
		if( $main_url[count($main_url)-1] == "bazooka.php" )	// Workaround for Bazooka WebCache
			$query .= "&net=gnutella2";

		fputs( $fp, "GET ".substr( $cache, strlen($main_url[0]), (strlen($cache) - strlen($main_url[0]) ) )."?".$query." HTTP/1.0\r\nHost: ".$host_name."\r\n\r\n");
		while ( !feof($fp) )
		{
			$line = fgets( $fp, 1024 );

			if( strtolower( substr( $line, 0, 7 ) ) == "i|pong|" )
				$pong = $line;
			elseif( substr($line, 0, 4) == "PONG" )
				$oldpong = $line;
			elseif( substr($line, 0, 5) == "ERROR" )
				$error = $line;
		}

		fclose ($fp);

		if( !empty($pong) )
		{
			$received_data = explode( "|", $pong );
			$cache_data[0] = trim($received_data[2]);

			if(count($received_data) > 3)
			{
				if(substr($received_data[3], 0, 4) == "http")	// Workaround for compatibility
					$cache_data[1] = "gnutella-gnutella2";
				else
				{
					$nets = trim($received_data[3]);
					if( $nets == "multi" )
						$nets = "gnutella-gnutella2";

					if( CheckNetworkString($SUPPORTED_NETWORKS, $nets) )
						$cache_data[1] = strtolower($nets);
					else
						$cache_data[0] = "UNSUPPORTED";
				}
			}
			elseif( !empty($oldpong) )
				$cache_data[1] = "gnutella-gnutella2";
			else
				$cache_data[1] = "gnutella2";
		}
		elseif( !empty($oldpong) )
		{
			$cache_data[0] = trim( substr($oldpong, 5) );

			if(substr($cache_data[0], 0, 13) == "PHPGnuCacheII")			// Workaround for compatibility with PHPGnuCacheII
				$cache_data[1] = "gnutella-gnutella2";
			elseif( CheckNetworkString($SUPPORTED_NETWORKS, "gnutella") )
				$cache_data[1] = "gnutella";
			else
				$cache_data[0] = "UNSUPPORTED";
		}
		elseif( strpos(strtolower($error), "network not supported") > -1 )	// Workaround for compatibility with GWCv2 specs
		{																	// FOR WEBCACHES DEVELOPERS: If you want avoid necessity to make double request, make your cache pingable without network parameter when there are ping=1 and multi=1
			$fp = @fsockopen( $host_name, $port, $errno, $errstr, TIMEOUT );

			if(!$fp)
			{
				//echo "Error ".$errno."\r\n";
				$cache_data[0] = "FAILED";
			}
			else
			{
				$pong = "";
				$oldpong = "";

				fputs( $fp, "GET ".substr( $cache, strlen($main_url[0]), (strlen($cache) - strlen($main_url[0]) ) )."?ping=1&multi=1&client=".VENDOR."&version=".SHORT_VER."&cachename=".NAME."&net=gnutella2 HTTP/1.0\r\nHost: ".$host_name."\r\n\r\n");
				while( !feof($fp) )
				{
					$line = fgets($fp, 1024);

					if( strtolower(substr($line, 0, 7)) == "i|pong|" )
					{
						$pong = $line;
						break;
					}
					elseif( substr($line, 0, 4) == "PONG" )
					{
						$oldpong = $line;
						break;
					}
				}

				fclose ($fp);

				$cache_data[1] = "gnutella2";
				if( !empty($pong) )
				{
					list( , , $cache_data[0] ) = explode( "|", $pong );
					$cache_data[0] = trim($cache_data[0]);
				}
				elseif( !empty($oldpong) )
					$cache_data[0] = trim( substr($oldpong, 5) );
				else
					$cache_data[0] = "FAILED";
			}
		}
		else
			$cache_data[0] = "FAILED";
	}

	return $cache_data;
}

function WriteHostFile($ip, $leaves, $net, $cluster, $client, $version){
	global $SUPPORTED_NETWORKS;

	if($leaves != NULL && $leaves < 15)
	{
		print "I|update|WARNING|Leaf count too low\r\n";
		return 4;
	}
	else
	{
		$host_file = file(DATA_DIR."/hosts_".$net.".dat");
		$file_count = count($host_file);
		$host_exists = FALSE;

		for ($i = 0; $i < $file_count; $i++)
		{
			list( $read, ) = explode("|", $host_file[$i], 2);

			if( $ip == $read )
			{
				$host_exists = TRUE;
				break;
			}
		}

		if($host_exists)
		{
			ReplaceHost($host_file, $i, $ip, $leaves, $net, $cluster, $client, $version);
			return 1; // Updated timestamp
		}
		else
		{
			if( $file_count >= MAX_HOSTS )
			{
				ReplaceHost($host_file, 0, $ip, $leaves, $net, $cluster, $client, $version);
				return 3; // OK, pushed old data
			}
			else
			{
				$file = fopen(DATA_DIR."/hosts_".$net.".dat", "a");
				flock($file, 2);
				fwrite($file, $ip."|".$leaves."|".$cluster."|".$client."|".$version."|".gmdate("Y/m/d h:i:s A")."\r\n");
				flock($file, 3);
				fclose($file);
				return 2; // OK
			}
		}
	}
}

function WriteCacheFile($cache, $net, $client, $version){
	list( , $url ) = explode("://", $cache, 2);
	if( $url == $_SERVER["SERVER_NAME"].$_SERVER["PHP_SELF"] )	// It doesn't allow to insert itself in cache list
		return 0; // Exists

	if(CheckFailedUrl($cache))
		return 4; // Failed URL

	$cache_file = file(DATA_DIR."/caches.dat");
	$file_count = count($cache_file);
	$cache_exists = FALSE;

	for ($i = 0; $i < $file_count; $i++)
	{
		list( $read, ) = explode("|", $cache_file[$i], 2);

		if( strtolower($cache) == strtolower($read) )
		{
			list( , , , , , $time ) = explode("|", trim($cache_file[$i]));
			$cache_exists = TRUE;
			break;
		}
	}

	if($cache_exists)
	{
		$time_diff = time() - ( @strtotime( $time ) + @date("Z") );	// GMT
		$time_diff = floor($time_diff / 86400);	// Days

		if( $time_diff < RECHECK_CACHES )
			return 0; // Exists
		else
		{
			$cache_data = PingWebCache($cache);

			if( $cache_data[0] == "FAILED" )
			{
				AddFailedUrl($cache);
				ReplaceCache( $cache_file, $i, NULL, NULL, NULL, NULL );
				return 5; // Ping failed
			}
			elseif( $cache_data[0] == "UNSUPPORTED" )
			{
				AddFailedUrl($cache);
				ReplaceCache( $cache_file, $i, NULL, NULL, NULL, NULL );
				return 6; // Unsupported network
			}
			else
			{
				ReplaceCache( $cache_file, $i, $cache, $cache_data, $client, $version );
				return 1; // Updated timestamp
			}
		}
	}
	else
	{
		if(CheckBlockedCache($cache))
			return 4; // Blocked URL
		else
		{
			$cache_data = PingWebCache($cache);

			if( $cache_data[0] == "FAILED" )
			{
				AddFailedUrl($cache);
				return 5; // Ping failed
			}
			elseif( $cache_data[0] == "UNSUPPORTED" )
			{
				AddFailedUrl($cache);
				return 6; // Unsupported network
			}
			else
			{
				if( $file_count >= MAX_CACHES )
				{
					ReplaceCache( $cache_file, 0, $cache, $cache_data, $client, $version );
					return 3; // OK, pushed old data
				}
				else
				{
					$file = fopen(DATA_DIR."/caches.dat", "a");
					flock($file, 2);
					fwrite($file, $cache."|".$cache_data[0]."|".$cache_data[1]."|".$client."|".$version."|".gmdate("Y/m/d h:i:s A")."\r\n");
					flock($file, 3);
					fclose($file);
					return 2; // OK
				}
			}
		}
	}
}

function HostFile($net){
	$host_file = file(DATA_DIR."/hosts_".$net.".dat");
	$count_host = count($host_file);

	if($count_host <= MAX_HOSTS_OUT)
		$max_hosts = $count_host;
	else
		$max_hosts = MAX_HOSTS_OUT;

	for( $i = 0; $i < $max_hosts; $i++ )
	{
		list( $host, ) = explode("|", $host_file[$count_host - 1 - $i], 2);
		print($host."\r\n");
	}
}

function UrlFile($net){
	$cache_file = file(DATA_DIR."/caches.dat");
	$count_cache = count($cache_file);

	for( $n = 0, $i = $count_cache - 1; $n < MAX_CACHES_OUT && $i >= 0; $i-- )
	{
		list( $cache, , $cache_net, ) = explode("|", $cache_file[$i], 4);

		$show = FALSE;
		if( strpos($cache_net, "-") > -1 )
		{
			$cache_networks = explode( "-", $cache_net );
			$cache_nets_count = count($cache_networks);
			for( $x=0; $x < $cache_nets_count; $x++ )
			{
				if( $cache_networks[$x] == $net)
				{
					$show = TRUE;
					break;
				}
			}
		}
		elseif( $cache_net == $net )
			$show = TRUE;

		if( $show )
		{
			print($cache."\r\n");
			$n++;
		}
	}
}

function Get($net, $pv){
	$host_file = file(DATA_DIR."/hosts_".$net.".dat");
	$count_host = count($host_file);
	$now = time();
	$offset = @date("Z");

	if($count_host <= MAX_HOSTS_OUT)
		$max_hosts = $count_host;
	else
		$max_hosts = MAX_HOSTS_OUT;

	for( $i=0; $i<$max_hosts; $i++ )
	{
		list( $host, $leaves, $cluster, , , $time ) = explode("|", $host_file[$count_host - 1 - $i]);
		$out = "H|".$host."|".TimeSinceSubmissionInSeconds( $now, $time, $offset )."|".$cluster;
		if( $pv >= 4 )
			$out .= "||".$leaves;

		print($out."\r\n");
	}

	$cache_file = file(DATA_DIR."/caches.dat");
	$count_cache = count($cache_file);
	for( $n = 0, $i = $count_cache - 1; $n < MAX_CACHES_OUT && $i >= 0; $i-- )
	{
		list( $cache, , $cache_net, , , $time ) = explode("|", $cache_file[$i]);

		$show = FALSE;
		if( strpos($cache_net, "-") > -1 )
		{
			$cache_networks = explode( "-", $cache_net );
			$cache_nets_count = count($cache_networks);
			for( $x=0; $x < $cache_nets_count; $x++ )
			{
				if( $cache_networks[$x] == $net)
				{
					$show = TRUE;
					break;
				}
			}
		}
		elseif( $cache_net == $net )
			$show = TRUE;

		if( $show )
		{
			$out = "U|".$cache."|".TimeSinceSubmissionInSeconds( $now, $time, $offset );
			if( $pv >= 4 )
				$out .= "|".( $cache_net != $net ? $cache_net : "" );

			print($out."\r\n");
			$n++;
		}
	}

	if( $count_host == 0 && $count_cache == 0 )
		print("I|NO-URL-NO-HOSTS\r\n");
	elseif( $count_cache == 0 )
		print("I|NO-URL\r\n");
	elseif( $count_host == 0 )
		print("I|NO-HOSTS\r\n");
}

function CleanStats($stat_file, $file_count, $request){
	$file = fopen("stats/".$request."_requests_hour.dat", "w");
	flock($file, 2);

	for($i = 0, $now = time(), $offset = @date("Z"); $i < $file_count; $i++)
	{
		$stat_file[$i] = trim($stat_file[$i]);
		$time_diff = $now - ( @strtotime( $stat_file[$i] ) + $offset );	// GMT
		$time_diff = floor($time_diff / 3600);	// Hours

		if( $time_diff < 1 ) fwrite($file, $stat_file[$i]."\r\n");
	}

	flock($file, 3);
	fclose($file);
}

function ReadStats($request){
	$stat_file = file("stats/".$request."_requests_hour.dat");
	$file_count = count($stat_file);

	$requests = 0;
	$old = 0;
	for($i = 0, $now = time(), $offset = @date("Z"); $i < $file_count; $i++)
	{
		$stat_file[$i] = trim($stat_file[$i]);
		$time_diff = $now - ( @strtotime( $stat_file[$i] ) + $offset );	// GMT
		$time_diff = floor($time_diff / 3600);	// Hours

		if( $time_diff < 1 )
			$requests++;
		else
			$old++;
	}

	if($old + $requests > $requests * 2) CleanStats($stat_file, $file_count, $request);
	return $requests;
}

function UpdateStats($request){
	if(!STATS_ENABLED) return;

	$file = fopen("stats/".$request."_requests_hour.dat", "a");
	flock($file, 2);
	fwrite($file, gmdate("Y/m/d h:i A")."\r\n");
	flock($file, 3);
	fclose($file);
}

function KickStart($net, $cache){
	if( !CheckURLValidity($cache) )
		die("ERROR: The KickStart URL isn't valid\r\n");

	list( , $cache ) = explode("://", $cache, 2);		// It remove "http://" from "cache" - $cache = www.test.com:80/page.php
	$main_url = explode("/", $cache);					// $main_url[0] = www.test.com:80		$main_url[1] = page.php
	$splitted_url = explode(":", $main_url[0], 2);		// $splitted_url[0] = www.test.com		$splitted_url[1] = 80

	if(count($splitted_url) == 2)
		list($host_name, $port) = $splitted_url;
	else
	{
		$host_name = $main_url[0];
		$port = 80;
	}

	$fp = @fsockopen( $host_name, $port, $errno, $errstr, TIMEOUT );

	if(!$fp)
	{
		echo "Error ".$errno;
		return;
	}
	else
	{
		fputs( $fp, "GET ".substr( $cache, strlen($main_url[0]), (strlen($cache) - strlen($main_url[0]) ) )."?get=1&hostfile=1&client=".VENDOR."&version=".SHORT_VER."&net=".$net." HTTP/1.0\r\nHost: ".$host_name."\r\n\r\n" );
		while( !feof($fp) )
		{
			$line = fgets( $fp, 1024 );
			if( strtolower( substr($line, 1, 1) ) == "|" )
				echo "<br>";
			echo $line."<br>";

			if( strtolower( substr($line, 0, 2) ) == "h|" )
			{
				$host = explode( "|", $line, 5 );
				if( !isset($host[3]) ) // Cluster
					$host[3] = NULL;
				WriteHostFile( trim($host[1]), NULL, $net, $host[3], "KICKSTART", NULL );
			}
		}
		fclose ($fp);
	}
}


Inizialize($SUPPORTED_NETWORKS);

$PING = !empty($_GET["ping"]) ? $_GET["ping"] : 0;

$PV = !empty($_GET["pv"]) ? $_GET["pv"] : 0;
$NET = !empty($_GET["net"]) ? strtolower($_GET["net"]) : NULL;
$NETS = !empty($_GET["nets"]) ? strtolower($_GET["nets"]) : NULL;	// Currently unsupported
$MULTI = !empty($_GET["multi"]) ? strtolower($_GET["multi"]) : 0;

$IP = !empty($_GET["ip"]) ? $_GET["ip"] : ( !empty($_GET["ip1"]) ? $_GET["ip1"] : NULL );
$CACHE = !empty($_GET["url"]) ? $_GET["url"] : ( !empty($_GET["url1"]) ? $_GET["url1"] : NULL );
$LEAVES = !empty($_GET["x_leaves"]) ? $_GET["x_leaves"] : NULL;
if( $LEAVES != NULL ) $LEAVES = str_replace( "|", "", $LEAVES );
$CLUSTER = !empty($_GET["cluster"]) ? $_GET["cluster"] : NULL;
if( strlen($CLUSTER) > 256 ) $CLUSTER = NULL;
elseif( $CLUSTER != NULL ) $CLUSTER = str_replace( "|", "", $CLUSTER );

$HOSTFILE = !empty($_GET["hostfile"]) ? $_GET["hostfile"] : 0;
$URLFILE = !empty($_GET["urlfile"]) ? $_GET["urlfile"] : 0;
$STATFILE = !empty($_GET["statfile"]) ? $_GET["statfile"] : 0;

$GET = !empty($_GET["get"]) ? $_GET["get"] : 0;
$UPDATE = !empty($_GET["update"]) ? $_GET["update"] : 0;

$CLIENT = !empty($_GET["client"]) ? $_GET["client"] : NULL;
$CLIENT = str_replace( "|", "", $CLIENT );
$VERSION = !empty($_GET["version"]) ? $_GET["version"] : NULL;
$VERSION = str_replace( "|", "", $VERSION );

$SUPPORT = !empty($_GET["support"]) ? $_GET["support"] : 0;

$SHOWINFO = !empty($_GET["showinfo"]) ? $_GET["showinfo"] : 0;
$SHOWHOSTS = !empty($_GET["showhosts"]) ? $_GET["showhosts"] : 0;
$SHOWCACHES = !empty($_GET["showurls"]) ? $_GET["showurls"] : 0;
$SHOWSTATS = !empty($_GET["stats"]) ? $_GET["stats"] : 0;

if( empty($_SERVER["QUERY_STRING"]) )
	$SHOWINFO = 1;

$KICK_START = !empty($_GET["kickstart"]) ? $_GET["kickstart"] : 0;	// It request hosts from a caches specified in the "url" parameter for a network specified in "net" parameter.

if( !isset($_SERVER) )
	$_SERVER = $HTTP_SERVER_VARS;

$REMOTE_IP = $_SERVER["REMOTE_ADDR"];

if($NET == "gnutella1")
	$NET = "gnutella";
if(LOG_MAJOR_ERRORS || LOG_MINOR_ERRORS)
	include "log.php";


if( $SHOWINFO )
	$web = 1;
elseif( $SHOWHOSTS )
	$web = 2;
elseif( $SHOWCACHES )
	$web = 3;
elseif( $SHOWSTATS )
	$web = 4;
else
	$web = 0;

if($web)
{
	include "web_interface.php";
	ShowHtmlPage($web);
}
elseif( $KICK_START )
{
	if( !KICK_START_ENABLED )
		die("ERROR: Kickstart is disabled\r\n");

	if( !CheckNetworkString($SUPPORTED_NETWORKS, $NET, FALSE) )
		die("ERROR: Network not supported\r\n");

	KickStart($NET, $CACHE);
}
else
{
	header("Connection: close");
	if(!CONTENT_TYPE_WORKAROUND)
		header("Content-Type: text/plain");
	else
		header("Content-Type: application/octet-stream");

	if(STATS_ENABLED)
	{
		$request = file("stats/requests.dat");

		$file = fopen("stats/requests.dat", "w");
		$requests = trim($request[0]) + 1;
		flock($file, 2);
		fwrite($file, $requests);
		flock($file, 3);
		fclose($file);
	}

	if( $CLIENT == NULL )
	{
		header("Status: 404 Not Found");
		print "ERROR: Client unknown - Request rejected\r\n";
		if(LOG_MINOR_ERRORS) Logging("unidentified_clients", $CLIENT, $VERSION, $NET);

		if($CACHE != NULL || $IP != NULL)
			UpdateStats("update");
		else
			UpdateStats("other");

		die();
	}

	if($VERSION == NULL && strlen($CLIENT) > 4)
	{
		$VERSION = substr( $CLIENT, 4 );
		$CLIENT = substr( $CLIENT, 0, 4 );
	}

	if( IsClientTooOld( $CLIENT, $VERSION ) )
	{
		print "ERROR: Client too old - Request rejected\r\n";
		if(LOG_MINOR_ERRORS) Logging("old_clients", $CLIENT, $VERSION, $NET);

		if($CACHE != NULL || $IP != NULL)
			UpdateStats("update");
		else
			UpdateStats("other");

		die();
	}

	if(!$PING && !$GET && !$SUPPORT && !$HOSTFILE && !$URLFILE && !$STATFILE && $CACHE == NULL && $IP == NULL)
	{
		print "ERROR: Invalid command - Request rejected\r\n";
		if(LOG_MAJOR_ERRORS) Logging("invalid_queries", $CLIENT, $VERSION, $NET);
		UpdateStats("other");
		die();
	}

	if( $CACHE != NULL && strpos($CACHE, "://") > -1 )
	{	// Cleaning url
		list( $protocol, $url ) = explode("://", $CACHE, 2);

		if( strpos($url, "/") > -1 )
			list( $url, $other_part_url ) = explode("/", $url, 2);
		else
			$other_part_url = "";

		$other_part_url = str_replace( "./", "", $other_part_url );		// Remove "./" from $other_part_url if present

		$slash = FALSE;
		while( substr( $other_part_url, strlen($other_part_url) - 1, 1 ) == "/" )
		{
			$other_part_url = substr( $other_part_url, 0, strlen($other_part_url) - 1 );
			$slash = TRUE;
		}

		if( substr( $other_part_url, strlen($other_part_url) - 1, 1 ) == "." )
			$other_part_url = substr( $other_part_url, 0, strlen($other_part_url) - 1 );	// Remove dot at the end of $other_part_url if present

		if( strlen($other_part_url) && $slash )
			$other_part_url .= "/";

		if( strpos($url, ":") > -1 )
		{
			list( $host_name, $host_port ) = explode(":", $url, 2);
			$host_port = (int)$host_port;
		}
		else
		{
			$host_name = $url;
			$host_port = 80;
		}

		if( substr( $host_name, strlen($host_name) - 1, 1 ) == "." )
			$host_name = substr( $host_name, 0, strlen($host_name) - 1 );	// Remove dot at the end of $host_name if present

		if( $host_port == 80 )
			$host_port = "";
		else
			$host_port = ":".$host_port;

		$CACHE = $protocol."://".$host_name.$host_port."/".$other_part_url;
	}

	header("X-Remote-IP: ".$REMOTE_IP);
	if($NET == NULL)
		$NET = "gnutella";
	if( CheckNetworkString($SUPPORTED_NETWORKS, $NET, FALSE) )
		$supported_net = TRUE;
	else
	{
		$supported_net = FALSE;
		if(!$MULTI && !$SUPPORT) print "ERROR: Network not supported\r\n";
	}

	if($PING)
		Pong($MULTI, $NET, $CLIENT, $supported_net);
	if($SUPPORT)
		Support($SUPPORTED_NETWORKS);

	if($UPDATE)
	{
		if( $IP != NULL && $supported_net )
		{
			if( CheckIPValidity($REMOTE_IP, $IP) )
			{
				$result = WriteHostFile($IP, $LEAVES, $NET, $CLUSTER, $CLIENT, $VERSION);

				if( $result == 1 ) // Updated timestamp
					print "I|update|OK|Updated host timestamp\r\n";
				elseif( $result == 2 ) // OK
					print "I|update|OK|Host added successfully\r\n";
				elseif( $result == 3 ) // OK, pushed old data
					print "I|update|OK|Host added successfully - pushed old data\r\n";
			}
			else // Invalid IP
				print "I|update|WARNING|Invalid IP"."\r\n";
		}

		if( $CACHE != NULL )
		{
			if(!FSOCKOPEN) // Cache adding disabled
				print "I|update|WARNING|Cache adding is disabled\r\n";
			elseif( CheckURLValidity($CACHE) )
			{
				$result = WriteCacheFile($CACHE, $NET, $CLIENT, $VERSION);

				if( $result == 0 ) // Exists
					print "I|update|OK|Cache already updated\r\n";
				elseif( $result == 1 ) // Updated timestamp
					print "I|update|OK|Updated cache timestamp\r\n";
				elseif( $result == 2 ) // OK
					print "I|update|OK|Cache added successfully\r\n";
				elseif( $result == 3 ) // OK, pushed old data
					print "I|update|OK|Cache added successfully - pushed old data\r\n";
				elseif( $result == 4 ) // Blocked or failed URL
					print "I|update|OK|Blocked URL\r\n";
				elseif( $result == 5 ) // Ping failed
					print "I|update|WARNING|Ping of ".$CACHE." failed\r\n";
				elseif( $result == 6 ) // Unsupported network
					print "I|update|WARNING|Network of webcache not supported\r\n";
			}
			else // Invalid URL
				print("I|update|WARNING|Invalid URL"."\r\n");
		}
	}
	else
	{
		if( $supported_net && ( $IP != NULL || (FSOCKOPEN && $CACHE != NULL) ) )
			print "OK\r\n";

		if( $IP != NULL && $supported_net )
		{
			if( CheckIPValidity($REMOTE_IP, $IP) )
				$result = WriteHostFile($IP, $LEAVES, $NET, $CLUSTER, $CLIENT, $VERSION);
			else // Invalid IP
				print "WARNING: Invalid IP"."\r\n";
		}

		if( $CACHE != NULL )
		{
			if(!FSOCKOPEN) // Cache adding disabled
				print "WARNING: Cache adding is disabled\r\n";
			elseif( CheckURLValidity($CACHE) )
			{
				$result = WriteCacheFile($CACHE, $NET, $CLIENT, $VERSION);

				if( $result == 5 ) // Ping failed
					print "WARNING: Ping of ".$CACHE." failed\r\n";
				elseif( $result == 6 ) // Unsupported network
					print "WARNING: Network of webcache not supported\r\n";
			}
			else // Invalid URL
				print "WARNING: Invalid URL"."\r\n";
		}
	}

	if($GET)
	{
		if( $supported_net )
		{
			Get($NET, $PV);
			if( $PV >= 4 )
				print("I|nets|".strtolower(NetsToString())."\r\n");
		}
	}
	else
	{
		if($HOSTFILE && $supported_net)
			HostFile($NET);

		if($URLFILE && $supported_net)
			UrlFile($NET);

		if($PV >= 4 && ($HOSTFILE || $URLFILE) && $supported_net)
			print("nets: ".strtolower(NetsToString())."\r\n");
	}

	if($CACHE != NULL || $IP != NULL)
		UpdateStats("update");
	else
		UpdateStats("other");

	if($STATFILE && !$PING && !$GET && !$SUPPORT && !$HOSTFILE && !$URLFILE)
	{
		if(STATS_ENABLED)
		{
			$requests = file("stats/requests.dat");
			print trim($requests[0])."\r\n";

			$other_requests = ReadStats("other");
			$update_requests = ReadStats("update");

			print ( $other_requests + $update_requests )."\r\n";
			print $update_requests."\r\n";
		}
		else
			print "WARNING: Statfile disabled\r\n";
	}
}
?>