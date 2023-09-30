<?php
require "config.inc.php";

if(mysql_pconnect(MYSQL_SERVER, MYSQL_LOGIN, MYSQL_PASSWORD) == FALSE) {
   echo "OK: WARNING: Unable to connect to database server.";
   exit;
}

// select the database
if(mysql_select_db(MYSQL_DATABASE) == FALSE) {
   echo "OK: WARNING: Unable to select database.";
   exit;
}

$client= 	array("ACQL", "ACQX", "BEAR", "COCO", "GCII", "GIFT", "GNUC", "GPUX", "GTKG", "LIME",
		      "MLDK", "MMMM", "MRPH", "MNAP", "MUTE", "PHEX", "POST", "RAZA", "SWAP", "TEST",
		      "TFLS", "NOVA");
$description= 	array("acqlite", "Acquisition", "Bearshare", "CocoGnut", "PHPGnuCacheII", "giFT", "Gnucleus",
		      "GPU", "gtk-gnutella", "Limewire", "MLDonkey", "Morpheus", "Morpheus", "MyNapster",
		      "Mutella", "Phex", "New WebCache Added", "Shareaza", "Swapper", "Various GWebCaches", 
		      "TrustyFiles", "Nova");
$url= 		array("http://www.versiontracker.com/dyn/moreinfo/macosx/20816&vid=121174",
		      "http://www.acquisitionx.com/",
		      "http://www.bearshare.com/",
		      "http://www.alpha-programming.co.uk/software/cocognut/",
		      "http://gwcii.sourceforge.net/",
                      "http://gift.sourceforge.net/",
		      "http://gnucleus.sourceforge.net/Gnucleus/",
		      "http://sourceforge.net/projects/gpu/",
		      "http://gtk-gnutella.sourceforge.net/",
		      "http://www.limewire.com/",
		      "http://www.nongnu.org/mldonkey/",
		      "http://www.morpheus.com/",
		      "http://www.morpheus.com/",
		      "http://www.mynapster.com/",
		      "http://mutella.sourceforge.net/",
		      "http://phex.sourceforge.net/",
		      "http://gwcii.sourceforge.net/",
                      "http://www.shareaza.com/",
		      "http://www.revolutionarystuff.com/swapper/",
                      "http://www.google.com/search?num=100&hl=en&ie=UTF-8&oe=UTF-8&q=gnutella+web+cache",
		      "http://www.trustyfiles.com/",
		      "http://novap2p.sourceforge.net/");

$i=-1;
while($client[++$i]) {
  $sqlq="REPLACE INTO clients (client, description, url) VALUES (\"{$client[$i]}\", \"{$description[$i]}\", \"{$url[$i]}\")";
  $result = mysql_query($sqlq) or die (("OK: WARNING: Invalid query: " . mysql_error()));
}

?>
