<?php

session_start();
session_name("BITJOEPARIS");
session_unset();
session_destroy();

header("HTTP/1.1 307 Temporary Redirect"); 
# header ("Location: http://www.bitjoe.de/"); 
header ("Location: /"); 
exit(0);

?>