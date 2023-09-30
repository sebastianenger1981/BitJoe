<?php
////////// 
// PHPGnuCacheII
// http://gwcii.sourceforge.net/
// Copyright (C) 2004 Joe Julian
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// 
//  Original code by Joe Julian <joe@julianfamily.org>
//                   PO Box 1156
//                   Carnation, WA 98014 USA
//  Stat Page by Nicholas Venturella <nick2588[at]fastmail.fm> 
//////////

define(DEBUG, false);  // Enable for some debugging output
if(!DEBUG) error_reporting(0);

require "config/config.inc.php";

define(SHORT_VERSION,  '2.1.1');
define(SCRIPT_VERSION, 'PHPGnuCacheII '.SHORT_VERSION. 
                       (URL_VALIDATION ? '' : 'fsock URL-Validation disabled'));
define(SHORT_CLIENT,   'GCII');

define(MENU_BAR,       '<P>['.
					   '<A HREF="http://www.zoozle.org/">eMule, Bit Torrent, Usenet Search Engine Site</A> | '.
					   '<A HREF="'.MY_URL.'">Home</A> | '.
                       '<A HREF="'.MY_URL.'?stats=1">Statistics</A> | '.
                       '<A HREF="'.MY_URL.'?data=1">Data</A> | '.
                       '<A HREF="http://gcachescan.jonatkins.com">Webcache Scan Report</A> | '.
                       '<A HREF="http://gcachescan.jonatkins.com/cgi-bin/gcachedetail.cgi?'.
                                    MY_URL.'">Webcache Individual Report</A>'.
                       ']</P>');

if (DEBUG) header("Content-type: text/plain");

$delay = DELAYED_WRITE ? "DELAYED" : "";

$task_list = array( 'client', 'version', 'net', 'cluster', 'get', 'update', 'ping', 'data', 'ip', 'url', 
                    'urlfile', 'hostfile', 'statfile', 'stats'); // Commands that we accept. Order counts.

function get_client_def($client) {
  $sqlq="SELECT * FROM clients WHERE client=\"$client\"";
  $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
  return mysql_fetch_row($result);   
}

function getmicrotime(){ 
   list($usec, $sec) = explode(" ",microtime()); 
   return ((float)$usec + (float)$sec); 
   } 

$time_start = getmicrotime();

function GetIP()
{
   if (getenv("HTTP_CLIENT_IP") && strcasecmp(getenv("HTTP_CLIENT_IP"), "unknown"))
           $ip = getenv("HTTP_CLIENT_IP");
       else if (getenv("HTTP_X_FORWARDED_FOR") && strcasecmp(getenv("HTTP_X_FORWARDED_FOR"), "unknown"))
           $ip = trim(array_pop(split(",",getenv("HTTP_X_FORWARDED_FOR"))));
       else if (getenv("REMOTE_ADDR") && strcasecmp(getenv("REMOTE_ADDR"), "unknown"))
           $ip = getenv("REMOTE_ADDR");
       else if (isset($_SERVER['REMOTE_ADDR']) && $_SERVER['REMOTE_ADDR'] && strcasecmp($_SERVER['REMOTE_ADDR'], "unknown"))
           $ip = $_SERVER['REMOTE_ADDR'];
       else
           $ip = "unknown";
   return($ip);
}

// Task Definition
class Task
{
   var $client;
   var $version;
   var $response;
   var $entry; 
   var $tally;
   var $index;
   var $update;
   var $ver2;

   // Add requests to the task queue
   function Enqueue($name, $data) {
      $this->entry[$this->tally++]=$name;
      $this->entry[$name]=$data;
   }

   // Do things with those requests
   function Action() {
      if ($this->index >= $this->tally) $this->Finish();  // all done, finish up
      switch ($this->entry[$this->index++]) {
	case 'client':
           // check for a G2 client
           if (strlen($this->entry[client])>4) {
              $this->entry[version] = substr($this->entry[client],4);
              $this->entry[client] =  substr($this->entry[client],0,4);
              $this->ver2 = true;
           }
           break;
	case 'version':
           // do nothing
           break;
        case 'ping':
           if ($this->Validate()) {  // does this pass the simplest of query validations?
              if($this->ver2) { // gwebcache v1 or v2?
                 $this->response = $this->response . 'I|pong|'. SCRIPT_VERSION. "|".MY_URL."\n"; // v2 pong
              } else {
	         $this->response = $this->response . 'PONG ' . SCRIPT_VERSION . "\n"; // v1 pong
              }
           } else {
              $this->response = "ERROR\nInvalid Query Structure\n"; // No client or version. Die!
	   }
           break;
        case 'net':
           $this->ver2=true;
           break;
        case 'ip':
           $sqlq = "SELECT submitted FROM host WHERE ip=\"{$this->entry[ip]}\"";
           $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
           $submitted = strtotime(array_shift(mysql_fetch_row($result)));
           if (!($submitted <= time()-3600)) {
             $this->response .= $this->ver2 ?
                    "I|update|WARNING|Not refreshing IP less than an hour old.\n" :
                    "OK\nWARNING Not refreshing IP less than an hour old.\n";
           } else {
             if($this->Validate()) {
               $this->response = 
                 $this->response . ($this->ValidIP() ? 
                                       $this->Update_Record('ip') : 
                                       ($this->ver2 ? 
                                          "I|update|WARNING|Rejected IP\n" : 
                                          "OK\nWARNING Rejected IP\n"));
             } else {
               $this->response = "ERROR\nInvalid Query Structure\n"; // No client or version. Die!
             }
           }
           break;
        case 'url':
           if (DEBUG) echo "Is shareaza.com? ".(strpos($this->entry['url'],"shareaza")===false);
           $sqlq = "SELECT submitted FROM host WHERE url=\"{$this->entry[url]}\"";
           $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
           $submitted = strtotime(array_shift(mysql_fetch_row($result)));
           if (!($submitted <= time()-3600)) {
             $this->response .= $this->ver2 ?
                    "I|update|WARNING|Not refreshing URL less than an hour old.\n" : 
                    "OK\nWARNING Not refreshing URL less than an hour old.\n";
           } else {
             if($this->Validate()) {
               if(!(strpos($this->entry[url],"shareaza")===false)) {
                 $this->response .= $this->ver2 ? 
                    "I|update|WARNING|Rejected URL|Shareaza doesn't have a cache\n" : 
                    "OK\nWARNING Rejected URL\nShareaza doesn't have a cache\n";
               } elseif (!(strpos($this->entry[url], MY_URL)===false)) {
                 $this->response .= $this->ver2 ?
                    "I|update|WARNING|Rejected URL|".MY_URL." is me\n" : 
                    "OK\nWARNING Rejected URL\n".MY_URL." is me\n";
               } elseif($this->ValidURL() || !URL_VALIDATION) {
                 $this->response .= $this->Update_Record(url);
               } else {
                 $this->response .= $this->ver2 ?
                    "I|update|WARNING|Rejected URL\n" : "OK\nWARNING Rejected URL\n";
               }
             } else {
             $this->response = "ERROR\nInvalid Query Structure\n"; // No client or version. Die!
             }
           }
           break;
        case 'get':
           $this->ver2=true;
           // return data in ver2 format
           if($this->Validate()) {
              $this->response = $this->response . $this->FileV2();
           } else {
              $this->response = "ERROR\nInvalid Query Structure\n"; // No client or version. Die!
           }
           break;
        case 'update':
           $this->ver2=true;
           break;
        case 'urlfile':
           // return the urlfile in ver1 format
           if ($this->Validate()) if (!$this->ver2) $this->response = $this->FileV1('url');
           break;
        case 'hostfile':
           // return the hostfile in ver1 format
           if ($this->Validate()) if (!$this->ver2) $this->response = $this->FileV1('host');
           break;
        case 'cluster':
           $this->ver2=true;
           break;
        case 'statfile':
           // returns 3 numbers each on 1 line from the gnuc1 spec
           if($this->Validate()) {
              $this->response = $this->StatFile();
           } else {
              $this->response = "ERROR\nInvalid Query Structure\n"; // No client or version. Die!
           }
           break;
        case 'stats':
           // returns human readable statistics
           $this->Statistics();
           break;
        case 'data':
           // human readable host and url files
           $this->Data();
           break;
      }
   }

   function StatFile ()
   {
      $sqlq = "SELECT MAX(total) FROM stats";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      list($total) = mysql_fetch_row($result);
      $sqlq = "SELECT COUNT(*) FROM stats WHERE time >= '" . date('Y-m-d G:i:s', time()-3600) . "'";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      list($hourtotal) = mysql_fetch_row($result);
      $sqlq = "SELECT COUNT(*) FROM stats WHERE time >= '" . date('Y-m-d G:i:s', time()-3600) . 
	      "' AND up_req = 1";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      list($updatetotal) = mysql_fetch_row($result);
      return "$total\n$hourtotal\n$updatetotal\n";
   }

   function ValidIP() {
      if (DEBUG) echo "ValidIP for ".$this->entry['ip']."\n";
      $rip = GetIP();
      if (DEBUG) echo "REMORE_ADDR=$rip\n";
      $t_string = "/^$rip\:(\d{1,5})$/";
      $test = preg_match($t_string, $this->entry['ip'], $pmatch);
      if (DEBUG) echo print_r($pmatch);
      if(!$test || $pmatch[1] <= 0 || $pmatch[1] > 65535) return false;
      if (DEBUG) echo "ValidIP\n";
      return true;
   }

   function ValidURL() {
      $parsed = array();
      if (DEBUG) echo "Entering ValidURL with this->entry[url]=".$this->entry['url']."\n";
      $parsed = parse_url($this->entry['url']);
      if (DEBUG) print_r ($parsed);
      $query="GET ".$parsed[path]."?client=".SHORT_CLIENT. "&version=".SHORT_VERSION.
             "&ping=1&net=gnutella2 HTTP/1.0\r\nHost: ".$parsed[host]. "\r\n\r\n";
      if($fp=fsockopen($parsed[host],($parsed[port] ? $parsed[port] : 80),$errno,$errstr,FSOCK_TIMEOUT)) {
         socket_set_timeout($fp,FSOCK_TIMEOUT);
         fputs($fp, $query);
         if (DEBUG) echo $query;
         while (($reply = fgets($fp,1024)) > "\r\n") if (DEBUG) echo "reply=$reply\n";
         while (!feof($fp)) {
            $reply = fgets($fp,1024);
            if (DEBUG) echo "reply=".$reply."\n";
            if (strtolower(substr($reply,0,4)) == "pong") { 
               $this->ver2=false;
               fclose($fp);
               return true;
            }
            if ((strtoupper(substr($reply,0,2)) == "I|") && (strtolower(substr($reply,2,4)) == "pong")) {
               $requested_url = split("\|", $reply, 5);
               $requested_url[3] = rtrim($requested_url[3]);
               if (DEBUG) print_r ($requested_url);
               if (isset($requested_url[3])) {
                  if (($requested_url[3] == $this->entry['url']) || $requested_url[3] == "") {
                     fclose($fp);
                     return true;
                  } else {
                     fclose($fp);
                     $this->entry['url'] = $requested_url[3];
                     if (DEBUG) echo "About to try to reenter ValidURL with this->entry[url]=".$this->entry['url']."\n";
                     if ($this->ValidURL() || !URL_VALIDATION) {
                        if (DEBUG) echo "ValidURL returned something positive\n";
                        return true;
                     } else {
                        if (DEBUG) echo "ValidURL returned something negative\n";
                        return false;
                     }
                  }
               } 
            }
         }
         fclose($fp);
         return false;
      } else {
         if(DEBUG) echo "fsockopen failed";
         return false;
      }
   }
   
   function Validate() {
      if (isset($this->entry['client']) && isset($this->entry['version'])) { // this is all I do to validate
         if (strlen($this->entry['client'])==4 ) {
            if (DEBUG) echo "\nValid\n";
            return true;
         }
      }
      if (DEBUG) echo "\nNot Valid: $this->entry['client'] $this->entry['version'] ".strlen($this->entry['client'])."\n";
      return false;
   }
   
   function Finish() {
      global $time_start;
      if ($this->response == "") $this->response = ($this->ver2 ? "I|OK|eol\n" : "OK\n");
      header("Content-type: text/plain");
      echo $this->response;
      if ($this->Validate()) { 
         if (DEBUG) echo "Finish.UpdateStats\n"; 
         $this->UpdateStats(); 
      }
      $time_end = getmicrotime();
      $elapsed = $time_end - $time_start;
      if($this->ver2) echo "I|elapsed|$elapsed\n";
      exit;
   }
   
   function UpdateStats() {
      $sqlq="SELECT MAX(total) FROM stats";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      list($total) = mysql_fetch_row($result);
      $sqlq="SELECT MAX(c_total) FROM stats WHERE client='" . $this->entry['client'] . "' AND ".
            "c_ver='" . $this->entry['version'] ."'";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      list($c_total) = mysql_fetch_row($result);
      if(!isset($this->update)) $this->update = false;
      $sqlq="INSERT $delay INTO stats (up_req, client, c_ver, time, c_total, total) VALUES (" . 
            ($this->update ? "1" : "0") .  ",'" . $this->entry['client'] . "','" . $this->entry['version'] . 
            "','" .  date('Y-m-d G:i:s', time()) . "', " . ++$c_total . ", " . ++$total . ")";
      if (DEBUG) echo "$sqlq\n";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      $sqlq="SELECT MIN(time) FROM stats";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      list($oldest) = mysql_fetch_row($result);
      if(strtotime($oldest) < time()-21600) { // 6 hours
        $sqlq="DELETE FROM stats WHERE time < '" . date('Y-m-d G:i:s', time()-14400) . "'"; // 4 hours
        $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
      }
   }

   function Update_Record($type) {
      // set the network if not already set
      if (!isset($this->entry['net'])) $this->entry['net'] = DEFAULT_NET;
      if (!$this->ver2) $this->entry['net']='gnutella';

      // query database to see if this exists already
      $sqlq = 'SELECT hid FROM host WHERE ' . $type . '="' . $this->entry[$type] . 
              '" AND network="' . $this->entry['net'] . '"';
      if (DEBUG) echo "$sqlq\n";
      $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));// get data
      if (list($hid) = mysql_fetch_row($result)) {
         // if it already exists, update it
         $sqlq = 'UPDATE host SET submitted="'.date('Y-m-d G:i:s', time()).'" WHERE hid='.$hid;
         if (DEBUG) echo "$sqlq\n";
         $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: ".mysql_error()));// get data
         $this->update = true;
         return ($this->ver2 ? "I|update|OK\n" : "OK\n");
      } else {
         // if it doesn't exist, add it
         $sqlq = 'INSERT '.$delay.' INTO host ('.$type.', network, submitted) VALUES ("'.$this->entry[$type].'", "'.
                  $this->entry['net'].'","'.date('Y-m-d G:i:s', time()).'")';
         if (DEBUG) echo "$sqlq\n";
         $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: ".mysql_error()));// get data
         $sqlq="SELECT MIN(submitted) FROM host";
         $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
         list($oldest) = mysql_fetch_row($result);
         if(strtotime($oldest) < time()-(MAX_AGE*1.5)) { 
           $sqlq = "DELETE FROM host WHERE submitted < '".date('Y-m-d G:i:s', time()-MAX_AGE)."'";
           if (DEBUG) echo "$sqlq\n";
          $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
         }
         $this->update = true;
         return ($this->ver2 ? "I|update|OK\n" : "OK\n");
      }
   }
   
   function FileV1 ($type) { // return GWebCache version 1 data 
     srand((float)microtime() * 1000000);
     switch ($type) {
       case 'url':
         $sqlq='SELECT url FROM host WHERE url>"" AND network="gnutella" ORDER BY submitted DESC LIMIT '.
                  MAX_HOSTS*2;
         $bad_client_response = "http://www.morpheus-os.com\n";
         break;
       case 'host':
         $sqlq='SELECT ip FROM host WHERE ip AND network="gnutella" ORDER BY submitted DESC LIMIT '.
               MAX_HOSTS*2;
         $bad_client_response = "140.99.15.144:80\n";
         break;
       default:
         return "OK: WARNING: Unknown request type. Never should have gotten here, " . 
                "contact joe@julianfamily.org";
     }  

     if (DEBUG) echo $this->entry['version'][0] . "\n";

     if ($this->entry['client'] == "MMMM" && ($this->entry['version'][0]== '1' 
         || $this->entry['version'][0]=='2')) {
        $response = $bad_client_response;
        if (DEBUG) echo $response;
     } else {
        $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get data

        while ( list($row) = mysql_fetch_row($result)) {
	  if (DEBUG) echo "$row\n";
	  $responses[] = "$row\n"; // return the data in ver 1 format
        }
	shuffle( $responses);
        for( $total_responses = 0; 
	     $total_responses < MAX_HOSTS; 
   	     $total_responses++) {
           $response = $response . array_pop( $responses);
           if (DEBUG) echo "$response\n";
        }
        mysql_free_result($result);
     }
     return $response;
   }

   function FileV2 () { // return GWebCache version 2 data
     srand((float)microtime() * 1000000);

     if (!isset($this->entry['net'])) $this->entry['net'] = DEFAULT_NET;
     $sqlq = 'SELECT ip,submitted FROM host WHERE ip AND network="'.$this->entry['net'].
             '" ORDER BY submitted DESC LIMIT '. MAX_HOSTS*2;
     if (DEBUG) echo "$sqlq\n";
     $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get data
     while ( list($ip,$submitted) = mysql_fetch_row($result)) {
        if (DEBUG) echo "$ip, $submitted\n";
	$host_responses[] = "H|$ip|".(time()-strtotime($submitted))."\n"; // store the data in ver 1 format
     }
     shuffle( $host_responses);

     for( $total_responses = 0; 
	  $total_responses < MAX_HOSTS; 
	  $total_responses++) {
        $response = $response . array_pop( $host_responses);
        if (DEBUG) echo "$response\n";
     }
     mysql_free_result($result);
     
     $sqlq = 'SELECT url,submitted FROM host WHERE url>"" AND network="'.$this->entry['net'].
             '" ORDER BY submitted DESC LIMIT '. MAX_HOSTS*2;
     if (DEBUG) echo "$sqlq\n";
     $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get data
     while ( list($url,$submitted) = mysql_fetch_row($result)) {
        if (DEBUG) echo "$url, $submitted\n";
	$url_responses[] = "U|$url|".(time()-strtotime($submitted))."\n"; // store the data for shuffle later
     }
     shuffle( $url_responses);

     for( $total_responses = 0; 
	  $total_responses < MAX_HOSTS; 
	  $total_responses++) {
        $response = $response . array_pop( $url_responses); // return the data in ver 1 format
        if (DEBUG) echo "$response\n";
     }
     mysql_free_result($result);
     return $response;
   }

   function Statistics() {
      $sqlq = "SELECT MAX(total) FROM stats";
      $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get data
      list($total) = mysql_fetch_row($result);
      $last_hour=time()-3600;
      $second_last_hour=time()-7200;
      $sqlq = "SELECT COUNT(sid),up_req FROM stats WHERE time > '". date('Y-m-d G:i:s', $last_hour) .
              "' GROUP BY up_req";
      $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get data
      while(list($tx,$upd) = mysql_fetch_row($result)) {
         if ($upd == 1) {
            $update = $tx+0;
         } else {
            $requests = $tx+0;
         }
      }
      $sqlq = "SELECT COUNT(sid),up_req FROM stats WHERE time <= '". date('Y-m-d G:i:s', $last_hour) .
              "' AND time > '". date('Y-m-d G:i:s', $second_last_hour) ."' GROUP BY up_req";
      $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get data
      while(list($tx,$upd) = mysql_fetch_row($result)) {
         if($upd == 1) {
            $update_old = $tx+0;
         } else {
            $requests_old = $tx+0;
         }
      }
      $permin=round(($requests_old + $update_old)/60,3);
      ?>
      <HTML>
      <HEAD>
         <TITLE>GWebCacheII Statistics</TITLE>
         <STYLE TYPE="text/css">
            BODY,P,TD  {
               font-family: Tahoma, Arial, Helvetica, sans-serif;
               font-size: 10pt;
            }
            H1 { font-size: 16pt; }
            H3 { font-size: 12pt; }
            TD { font-size: 8pt; white-space: nowrap; }
            TH { font-size: 8pt; font-weight: bold; white-space: nowrap; }
            TD.cent { text-align: center; }
              .lite { background: #EDF3F8; } 
              .lite2 { background: #E1E7ED; } 
              .dark { background: #B9C9DB; } 
            A { color: blue; text-decoration: none; }
            A:Hover { text-decoration: underline; }
            A:Visited { color:darkblue; }
         </STYLE>
      </HEAD>
      <BODY>
         <H1>GWebCacheII Statistics</H1>

         <? echo MENU_BAR ?>

         <TABLE BORDER=0 CELLPADDING=3 CELLSPACING=2>
            <TR><TD CLASS=dark>&nbsp;Total Requests:</TD>
                <TD CLASS=lite>&nbsp;<? echo $total ?></TD> 
            </TR>
            <TR><TD CLASS=dark VALIGN=Top>&nbsp;Requests This Hour:</TD>
                <TD CLASS=lite>&nbsp;<? echo $update ?> Update, <? echo $requests ?> Host/URL-File<BR>
                   &nbsp;(since <? echo date("F j, Y, g:i:s a T", time()-3600) ?>)
                </TD>
            </TR>
            <TR><TD CLASS=dark VALIGN=Top>&nbsp;Requests Last Hour:</TD>
                <TD CLASS=lite>&nbsp;<? echo $update_old ?> Update, <? echo $requests_old ?> Host/URL-File<BR>
                   &nbsp;(<? echo $permin ?> requests/min)
                </TD>
            </TR>
            <TR><TD CLASS=dark>&nbsp;Hosts in Cache:</TD>
                <TD CLASS=lite><?
                $sqlq = "SELECT COUNT(ip),network FROM host GROUP BY network";
                $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get
                while ( list($ip,$network) = mysql_fetch_row($result)) {
                   echo "$ip Hosts (Maximum " . MAX_HOSTS . " returned) in the $network network<BR>";
                }
                ?></TD>
            </TR>
            <TR><TD CLASS=dark>&nbsp;Alternate Caches:</TD>
                <TD CLASS=lite><?
                $sqlq = "SELECT COUNT(url),network FROM host GROUP BY network";
                $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get
                while ( list($url,$network) = mysql_fetch_row($result)) {
                   echo "$url Urls (Maximum " . MAX_HOSTS . " returned) in the $network network<BR>";
                }
                ?></TD>
            </TR>
         </TABLE>
         <BR> 
         <TABLE BORDER=0 CELLPADDING=3 CELLSPACING=2 WIDTH=550> 
         <TR> <TH>Version</TH> <TH>Gets</TH> <TH>Updates</TH> <TH>Grand Total</TH> </TR> 

         <?
         $sqltime = date('Y-m-d G:i:s', $last_hour); 
         $sqlq="SELECT client,c_ver,COUNT(sid),SUM(time>'$sqltime'),SUM(up_req=0),SUM(up_req=1),SUM(up_req=0 AND time>'$sqltime'),SUM(up_req=1 AND time>'$sqltime') FROM stats GROUP BY client,c_ver"; 

         $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get
         $color = ''; 
         while ( list($client,$version,$total,$total_hr,$gets,$updates,$gets_hr,$updates_hr) = mysql_fetch_row($result)) { 
            if ($lastclient!==$client) { 
             
              list($clientr, $clientp, $clienturl) = get_client_def($client);
              if($clientr) {
                echo "<TR><TD CLASS=dark COLSPAN=4><B><A HREF=\"$clienturl\">$clientp</A></B></TD></TR>";
              } else {
                echo "<TR><TD CLASS=dark COLSPAN=4><B>$client</B></TD></TR>";
              }
            } 
            $lastclient = $client; 
             
            echo " 
               <TR> 
                  <TD CLASS=lite$color>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$version</TD> 
                  <TD CLASS=lite$color>$gets_hr this hour, $gets today</TD> 
                  <TD CLASS=lite$color>$updates_hr this hour, $updates today</TD>                                      
                  <TD CLASS=lite$color>$total_hr this hour, $total today</TD> 
               </TR> 
            "; 
            if ($color=='') { $color='2';} else {$color = '';} 
         }
      echo "\n<!-- Config Vars\n MY_URL:      ". MY_URL .
                           "\n MAX_HOSTS:   ". MAX_HOSTS .
                           "\n DEFAULT_NET: ". DEFAULT_NET .
           "\n-->\n\n\n</BODY>\n</HTML>";
      exit;
   }

   function Data() {
      ?>
      <HTML>
         <HEAD>
	    <TITLE>GWebCacheII Data</TITLE>
            <STYLE TYPE="text/css">
               BODY,P,TD  {
                  font-family: Tahoma, Arial, Helvetica, sans-serif;
                  font-size: 10pt;
               }
               H1 { font-size: 16pt; }
               H3 { font-size: 12pt; }
               TD { font-size: 8pt; white-space: nowrap; }
               TH { font-size: 8pt; font-weight: bold; white-space: nowrap; }
               TD.cent { text-align: center; }
               .lite { background: #DFEAF0; } 
               .dark { background: #B9C9DB; } 
               A { color: blue; text-decoration: none; }
               A:Hover { text-decoration: underline; }
               A:Visited { color:darkblue; }
            </STYLE>
         </HEAD>
         <BODY>
            <H1>GWebCacheII Data</H1>

            <? echo MENU_BAR ?>

            <TABLE BORDER=0>
               <TR>
               <TD VALIGN=Top>

               <TABLE BORDER=0 CELLPADDING=3 CELLSPACING=2
      <?
			   $isZoozle = $_REQUEST["zoozle"];

               $color='dark';
               $sqlq='SELECT network FROM host WHERE ip GROUP BY network ORDER BY network';
               $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error())); // get
               while ( list($network) = mysql_fetch_row($result)) {
                  echo "<TR><TH>&nbsp;</TH></TR><TR><TH>Hosts for $network</TH><TH>Updated</TH></TR>";
                  if ( $isZoozle == 1 ) {
					$sqlq="SELECT ip,submitted FROM host WHERE ip AND network='$network' ORDER BY submitted".
							" DESC LIMIT 500";
				  } else {
					$sqlq="SELECT ip,submitted FROM host WHERE ip AND network='$network' ORDER BY submitted".
							" DESC LIMIT ".  MAX_HOSTS;
				  };
                  $result2 = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: ".mysql_error()));
                  while( list($ip,$submitted) = mysql_fetch_row($result2)) {
                     echo "<TR><TD CLASS=$color><A HREF=http://$ip>$ip</A></TD>".
                          "<TD CLASS=$color>". gmdate('D, d M Y H:i:s \G\M\T',strtotime($submitted)) .
                          "</TD></TR>";
                     if ($color=='dark') {$color='lite';} else {$color='dark';}
                  }
               }
      ?>
               </TABLE>
            </TD><TD>&nbsp;&nbsp;</TD> 
               <TD VALIGN=TOP> 
                  <TABLE BORDER=0 CELLPADDING=3 CELLSPACING=2>
      <?
                  $color='dark';
                  $sqlq='SELECT network FROM host WHERE url>"" GROUP BY network ORDER BY network';
                  $result = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: " . mysql_error()));
                  while ( list($network) = mysql_fetch_row($result)) {
                     echo "<TR><TH>&nbsp;</TH></TR><TR><TH>Urls for $network</TH><TH>Updated</TH></TR>";
                     $sqlq="SELECT url,submitted FROM host WHERE url>'' AND network='$network' ORDER BY".
                           " submitted DESC LIMIT " . MAX_HOSTS;
                     $result2 = mysql_query($sqlq) or die(("OK: WARNING: Invalid query: ".mysql_error()));
                     while( list($url,$submitted) = mysql_fetch_row($result2)) {
                        echo "<TR><TD CLASS=$color><A HREF='$url'>$url</A></TD>".
                             "<TD CLASS=$color>". gmdate('D, d M Y H:i:s \G\M\T',strtotime($submitted)) .
                             "</TD></TR>";
                        if ($color=='dark') {$color='lite';} else {$color='dark';}
                     }
                  }
      ?>
                  </TR>
                  </TABLE>
               </TD>
            </TR>
         </TABLE>
      </BODY>
   </HTML>
      <?
   exit;
   }
}


// connect to the database server
if(mysql_pconnect(MYSQL_SERVER, MYSQL_LOGIN, MYSQL_PASSWORD) == FALSE) {
   echo "OK: WARNING: Unable to connect to database server.";
   exit;
}

// select the database
if(mysql_select_db(MYSQL_DATABASE) == FALSE) {
   echo "OK: WARNING: Unable to select database.";
   exit;
}

$tasks = new Task;

foreach($task_list as $task_name) {
    if (isset($_REQUEST[$task_name])) $tasks->Enqueue($task_name, $_REQUEST[$task_name]);
}

if($tasks->tally) {

   while (true) {
      $tasks->Action();
   }
} else {
// show human readable client info
?>
<HTML>
<HEAD>
	<TITLE>GWebCacheII </TITLE>
<STYLE TYPE="text/css">
BODY,P,TD  {
	font-family: Tahoma, Arial, Helvetica, sans-serif;
	font-size: 10pt;
}
H1 { font-size: 16pt; }
H3 { font-size: 12pt; }
TD { font-size: 8pt; white-space: nowrap; }
TH { font-size: 8pt; font-weight: bold; white-space: nowrap; }
TD.cent { text-align: center; }
.lite { background: #DFEAF0; } 
.dark { background: #B9C9DB; } 
A { color: blue; text-decoration: none; }
A:Hover { text-decoration: underline; }
A:Visited { color:darkblue; }
</STYLE>
</HEAD>
<BODY>
<H1>GWebCacheII </H1>

<? echo MENU_BAR ?>

<P><B>
This is a GWebCacheII web-based Gnutella host cache script.
</B></P>

<P>
Running: <? echo getenv('SERVER_SOFTWARE')."<BR>".SCRIPT_VERSION; ?>
<BR>
by Joe Julian<BR>
updates available from <A HREF="http://gwcii.sourceforge.net">gwcii.sourceforge.net</A><BR>
visit <A HREF="http://gnucleus.sourceforge.net/">gnucleus.sourceforge.net</A>
</P>

<P>
<A HREF="http://gwcii.sourceforge.net"><IMG SRC="http://gwcii.sourceforge.net/images/phpgnucacheii<?echo SHORT_VERSION?>.png" ALT="Version Information" WIDTH=200 HEIGHT=100 BORDER=0></A>
</P>

<!-- Warnings:

-->
</BODY>
</HTML>
<?
exit;


}
?>
