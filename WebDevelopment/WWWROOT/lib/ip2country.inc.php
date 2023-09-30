<?php
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// CLASS: ip2country - Find country from netblocks
//
// Copyright (C) 1987-2004 Pascal Toussaint <pascal@pascalz.com>
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 2 of the License, or any later 
// version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// This script uses the IP-to-Country Database
// provided by WebHosting.Info (http://www.webhosting.info),
// available from http://ip-to-country.webhosting.info. 
//
// Download latest database at
// http://ip-to-country.directi.com/downloads/ip-to-country.csv.zip
//
// Look the latest file date (format YYYYMMDD)
// http://ip-to-country.directi.com/downloads/latest
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// $Id: class.ip2country.php,v 1.4 2004/02/01 07:24:54 pascalz Exp $ 
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

require_once("/srv/server/wwwroot/lib/config.inc.php");

// Unquote a string...if quoted
function unquote(&$str)
{
	$str = trim($str);
	
	if (($str[0] == '"')&& ($str[strlen($str) - 1] == '"'))
	{
		$str = substr($str,1,strlen($str) - 2);			
	}
}

// Recreate inet_aton function like in mySQL
// convert Internet dot address to network address
function inet_aton($ip)
{
	$ip_array = explode(".",$ip);
	return ($ip_array[0] * pow(256,3)) + 
		   ($ip_array[1] * pow(256,2)) + 
		   ($ip_array[2] * 256) + 
			$ip_array[3]; 
}

class ip2country
{
	var $CVSFile;				   // the ip-to-country.csv file
	var $IP;					   // IP to looking for

	var $Prefix1;				   // Country prefix (2char) ex.: US
	var $Prefix2;				   // Country prefix (3char) ex.: USA
	var $Country;				   // Country name  ex.: UNITED STATE

	var $UseDB;					   // Use database instead csv file (more fast)

	// db values
	var $db_host;				   // host information for database connection
	var $db_login;				   // login information for database connection
	var $db_password;			   // password information for database connection
	var $db_basename;			   // base information for database connection
	var $db_tablename;			   // Your own table name
	var $db_ip_from_colname;	   // Your own ip_from column name
	var $db_ip_to_colname;		   // Your own ip_to column name
	var $db_prefix1_colname;	   // Your own prefix1 column name
	var $db_prefix2_colname;	   // Your own prefix2 column name
	var $db_country_colname;	   // Your own country column name

	var $_IPn;					   // Private - network address


	// Constructor
	function ip2country($ip,$usedb = false)
	{
		// TODO: Add regex to verify ip is valid
		if ($ip) 
		{
			$this->_IPn = inet_aton($ip);
			$this->IP	= $ip;
		}

		# $this->CVSFile = dirname(__FILE__)."\ip-to-country.csv";
		$this->CVSFile = IP2COUNTRYCSV;
		$this->UseDB = $usedb;
		
		// D�fault value
		$this->db_host			= "localhost";
		$this->db_tablename		= "netblocks";
		$this->db_ip_from_colname	= "ip_from";
		$this->db_ip_to_colname		= "ip_to";
		$this->db_prefix1_colname	= "prefix1";
		$this->db_prefix2_colname	= "prefix2";
		$this->db_country_colname	= "country";
	}

	// Look in file or database
	function LookUp()
	{
		if (!$this->UseDB)
		{
			$fd = fopen ($this->CVSFile, "r");
			while (!feof ($fd)) 
			{
				$line = fgets($fd);
				if ($line)
				{
					list($ip_from,$ip_to,$prefix1,$prefix2,$country) = explode(",",$line);
					
					unquote($ip_from);
					unquote($ip_to);
					unquote($prefix1);
					unquote($prefix2);
					unquote($country);
					
					if (($this->_IPn >= intval($ip_from)) && ($this->_IPn <= intval($ip_to)))
					{
						$this->Prefix1 = $prefix1;
						$this->Prefix2 = $prefix2;
						$this->Country = $country;
						fclose ($fd);
						return true;
					}
				}
			}
			fclose ($fd);
			return false;
		} else {
			/*
			 * The Fastest Way is to import the CSV file in your database and to
			 * set UseDB to true !
			 * I use MySQL but feel free to use your database functions ;)
			 */
			$conn = mysql_connect($this->db_host,$this->db_login,$this->db_password);
			mysql_select_db($this->db_basename,$conn);
			$query = "SELECT ".$this->db_prefix1_colname.",".$this->db_prefix2_colname.",".$this->db_country_colname." FROM ".$this->db_tablename." WHERE ".$this->_IPn.">=".$this->db_ip_from_colname." AND ".$this->_IPn."<=".$this->db_ip_to_colname;
			
			$result = mysql_query($query) or die ("Requ&ecirc;te invalide");
			$row = mysql_fetch_row($result);
			if ($row)
			{
				$this->Prefix1 = $row[0];
				$this->Prefix2 = $row[1];
				$this->Country = $row[2];
				return true;
			} else return false;

			mysql_close($conn);

		}
	}

	// This function intend to look directly on the site but it's often down :(
	function LookRemote()
	{
		$handle = fopen("http://ip-to-country.directi.com/country/name/".$this->IP, 'r');
		$this->Country = fgets($handle, 4096);
		fclose($handle);

		if (trim($this->Country) != "This service is currently down.")
		{
			$handle = fopen("http://ip-to-country.directi.com/country/code2/".$this->IP, 'r');
			$this->Prefix1 = fgets($handle, 4096);
			fclose($handle);

			$handle = fopen("http://ip-to-country.directi.com/country/code3/".$this->IP, 'r');
			$this->Prefix2 = fgets($handle, 4096);
			fclose($handle);

			return true;
		}

		return false;
	}
}

/*
function i2c_realip()
{
    // No IP found (will be overwritten by for
    // if any IP is found behind a firewall)
    $ip = FALSE;
   
    // If HTTP_CLIENT_IP is set, then give it priority
    if (!empty($_SERVER["HTTP_CLIENT_IP"])) {
        $ip = $_SERVER["HTTP_CLIENT_IP"];
    }
   
    // User is behind a proxy and check that we discard RFC1918 IP addresses
    // if they are behind a proxy then only figure out which IP belongs to the
    // user.  Might not need any more hackin if there is a squid reverse proxy
    // infront of apache.
    if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {

        // Put the IP's into an array which we shall work with shortly.
        $ips = explode (", ", $_SERVER['HTTP_X_FORWARDED_FOR']);
        if ($ip) { array_unshift($ips, $ip); $ip = FALSE; }

        for ($i = 0; $i < count($ips); $i++) {
            // Skip RFC 1918 IP's 10.0.0.0/8, 172.16.0.0/12 and
            // 192.168.0.0/16
            if (!preg_match('/^(?:10|172\.(?:1[6-9]|2\d|3[01])|192\.168)\./', $ips[$i])) {
                if (version_compare(phpversion(), "5.0.0", ">=")) {
                    if (ip2long($ips[$i]) != false) {
                        $ip = $ips[$i];
                        break;
                    }
                } else {
                    if (ip2long($ips[$i]) != -1) {
                        $ip = $ips[$i];
                        break;
                    }
                }
            }
        }
    }

    // Return with the found IP or the remote address
    return ($ip ? $ip : $_SERVER['REMOTE_ADDR']);
}
*/
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
?>