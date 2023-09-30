<?php

$info = "";
$radiobox = $_REQUEST["tos"];
if ( !isset($radiobox) || $radiobox != 1 ) {
	$info = "<span STYLE=\"color: red\">Bitte lese die BitJoe AGBs!</span>";
} else {

	header("HTTP/1.1 307 Temporary redirect");
	header("location: http://www.bitjoe.de/download/BitJoe.zip");
	exit;
};

echo <<<END
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
 <HEAD>
  <TITLE>BitJoe akzeptiere die AGBs</TITLE>
  <META NAME="Generator" CONTENT="EditPlus">
  <META NAME="Author" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Description" CONTENT="">
   <meta name="ROBOTS" content="NOINDEX,NOFOLLOW">
 </HEAD>
 <BODY>

<center><a href="http://www.bitjoe.de/download/download_en.php" rel="nofollow" target="_self"><img src="us.gif" alt="english" border="0" /></a>&nbsp;&nbsp;-&nbsp;&nbsp;<a href="http://www.bitjoe.de/download/download_de.php" rel="nofollow" target="_self"><img src="de.gif" alt="deutsch" border="0" /></a>
<br /> <br />
<iframe src="http://www.bitjoe.de/TOS/tos_deutsch.html" rel="nofollow,noindex" width="800" height="350" scrolling="yes" framespacing="0" frameborder="no" border="0" align="center" ></iframe>
<br /> <br />
<form method="get" action="download_de.php" name="searchfield" target="_self">	
<input type="hidden" name="tos" value="1" />
<input type="submit" value="akzeptiere die AGBs und downloade BitJoe " /> 
</form>

<br /><br />

<a href="http://m.bitjoe.de/">Installiere BitJoe direkt von deinem Handy aus ( ausser Blackberry )</a>


</center>
 </BODY>
 </HTML>
END;

exit;

?>