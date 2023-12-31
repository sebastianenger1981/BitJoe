<?php
$ENABLED =							1;

define( "FSOCKOPEN",				1 );	// Disable ONLY if the server have FSOCKOPEN disabled, use admin/test.php to check
define( "CONTENT_TYPE_WORKAROUND",	0 );	// Use admin/test.php to know the right value

define( "STATS_ENABLED",			1 );
define( "KICK_START_ENABLED",		0 );	// KickStart should be DISABLED after populating the webcache

define( "LOG_MAJOR_ERRORS",			1 );	// Enable logging of major errors
define( "LOG_MINOR_ERRORS",			0 );	// Enable logging of minor errors (ONLY for debugging)
define( "LOG_HAMMERING_CLIENTS",	1 );

define( "MAX_HOSTS",				1000000000000000 );	// Maximum number of host stored for EACH network (If there are 2 networks and this value is 25 -> 25 x 2 = 50)
define( "MAX_HOSTS_OUT",			20 );	// Maximum number of host sent in each request

define( "MAX_CACHES",				1000000000000000 );	// Maximum number of cache stored for ALL networks
define( "MAX_CACHES_OUT",			15 );	// Maximum number of cache sent in each request

define( "RECHECK_CACHES",			1 );	// Days to recheck a cache
define( "TIMEOUT",					20 );	// Sockets time out

define( "DATA_DIR", "data" );
?>