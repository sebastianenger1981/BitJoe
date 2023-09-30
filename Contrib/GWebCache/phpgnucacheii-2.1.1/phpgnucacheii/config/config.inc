<?
define(MY_URL,         'http://www.zoozle.net/cc/cc.php'); // set this to how you want to be known

define(MYSQL_SERVER,   'localhost');  // Change to your own settings
define(MYSQL_LOGIN,    'root');
define(MYSQL_PASSWORD, 'PQdfqZHr');
define(MYSQL_DATABASE, 'WebCache');

define(MAX_HOSTS,       100); // Max hosts and IPs to return for each network 20 is about optimal

define(MAX_AGE,         3*24*60*60); // Max age for hosts/urls in seconds (default is 3 days)
				     // Doesn't matter how long you set this, as long as it doesn't 
                                     // expire them so quickly that you don't have enough for MAX_HOSTS

define(URL_VALIDATION,  true); // set this to false if you cannot use fsockopen (like Lycos)

define(DEFAULT_NET,    'gnutella'); //default gnutella2 network if none specified (gnutella version 1
                                     //will always be 'gnutella' no matter what).

define(FSOCK_TIMEOUT,  20); //timout for trying to validate an url

define(DELAYED_WRITE,  true); //use delayed mysql writes, use unless you can't. Makes mysql updates
                              //much faster.
?>
