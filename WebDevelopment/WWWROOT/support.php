<?php


require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/class.phpmailer.inc.php");


$textfield		= $_REQUEST["textfield"];
$problem 		= $_REQUEST["problem"];
$email			= $_REQUEST["email"];
$name			= $_REQUEST["name"];
$handynummer	= $_REQUEST["handynummer"];


/*
[13:38] Lieblingsesel: Fragen zur Handysoftware -->tec@swissrefresh.ch
[13:39] Lieblingsesel: Fragen zu meinem Account --> accounts@swissrefresh.ch
[13:39] Lieblingsesel: sonstiges --> infos@swissrefreh.ch
[13:40] Lieblingsesel: neueshandy@swiss...

business@swissrefresh.ch

<option value='Fragen zur Handysoftware'>Fragen zur Handysoftware</option>
<option value='Fragen zu meinem Account'>Fragen zu meinem Account</option>
<option value='Sonstiges'>Sonstiges</option>
<option value='B2B'>B2B</option>

*/


if ( checkEmailAddress($email) == 1 ) {

	if ( preg_match("/Handysoftware/i",$problem) || preg_match("/Softwarezusenden/i",$problem) ) {
		$emailto = "tec@swissrefresh.ch";
	} elseif ( preg_match("/Account/i",$problem) ) {
		$emailto = "accounts@swissrefresh.ch";
	} elseif ( preg_match("/Sonstiges/i",$problem) ) {
		$emailto = "infos@swissrefresh.ch";
	} elseif ( preg_match("/B2B/i", $problem) ) {
		$emailto = "business@swissrefresh.ch";
	};

	$mail			= new PHPMailer();
	$mail->From     = "$email";	#$mail->From     = "support@swissrefresh.ch";
	$mail->FromName = "$name";
	$mail->Subject	= "BitJoe.de - Supportanfrage - $problem";
	$mail->AltBody	= "Supportanfrage von $name [$email] [$handynummer] - Problem: [$problem] Nachricht: [$textfield] <br>";
	$mail->MsgHTML("Supportanfrage von $name [$email] [$handynummer] - Problem: [$problem] Nachricht: [$textfield] <br>");
	$mail->AddAddress($emailto, "");

	if(!$mail->Send()) {
	#  echo 'Failed to send mail';
	} else {
	#  echo 'Mail sent';
	};

}; # if ( checkEmailAddress($email) == 1 ) {


echo <<<END


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<!--
	All rights of the producer and of the owner of this work are reserved.
	UNAUTHORISED copying, hiring, lending, public performance and 
	broadcasting of this material is prohibited.

	Alle Urheber- und Leistungsschutzrechte vorbehalten. Kein Verleih! 
	Keine unerlaubte Vervielfaeltigung, Vermietung, Auffuehrung, Sendung!

	(C)opyright 2007, 2008, 2009, 2010, 2011, 2012, 2013
	
	www.bitjoe.de
-->

<head>
	<meta http-equiv="Content-Language" content="de" />
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "" />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "" />

	<meta name="author" content= "" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "1 days" />
	<meta name="keywords" lang="de" content="T" />
	<meta name="keywords" lang="en-us" content="" />
	<meta name="keywords" lang="en" content="" />
	<meta http-equiv="refresh" content="5; url=http://www.bitjoe.de/">
	<meta name="keywords" lang="fr" content="" />

	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Supportanfrage</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="570">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">

      <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe handy flatrates" width="778" height="187"></td>
        </tr>
      <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a rel="nofollow" href="/login/tarif.php"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>

          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/kontakt.html"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>

      </tr>
    </table>

	Wir werden Ihre Anfrage schnellstm&ouml;glich bearbeiten.


<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-4460139-1");
pageTracker._initData();
pageTracker._trackPageview();
</script>

</body>
</html>

END;

exit(0);


/*
	$mail = new phpmailer();	
	$mail->From				= "support@swissrefresh.ch";
	$mail->FromName			= "BitJoe.de";
	$mail->Host				= "";
	$mail->Mailer			= "mail";
	$mail->Helo				= "localhost";
	$mail->Subject			= "BitJoe.de - Supportanfrage";
	$mail->SMTPAuth			= false;
	$mail->Username			= "";
	$mail->Password			= "";
	$mail->ContentType		=  "text/plain";
	$mail->IsHTML			= 1;
	$mail->IsSendmail		= 1;
	$mail->Sendmail			= "/usr/sbin/sendmail";
	$mail->AddAddress($MailTo , "thecerial@gmail.com");
	$mail->Body				= "Supportanfrage von $name [$email] [handynummer] - Problem: [$problem] Nachricht: [$textfield] <br>";
	$mail->Send();			# mail absenden
	$mail->ClearAddresses();
	$mail->ClearAttachments();
*/


?>