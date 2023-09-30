<?php


require_once("/srv/server/wwwroot/lib/sms.inc.php");
require_once("/srv/server/wwwroot/lib/html.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");


######### HEADER AUSGABE
header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache");

session_start();
session_name("BITJOEPARIS");
$MobilePhone 			= $_SESSION['mobilephone'];
$MobilePhoneStatus		= checkInput($MobilePhone, "I", 4, 17 );
$MobilePhoneOfSender	= $MobilePhone;

#

if ( $MobilePhoneStatus != 1 || !isset($MobilePhone) ) {
/*
	# echo "'$MobilePhone' -'$MobilePhoneStatus' nicht angemeldet -> leite weiter auf /login/";
	header("HTTP/1.1 307 Temporary Redirect"); 
	header ("Location: /login/"); 
	exit(0);
*/
}; # if ( $MobilePhoneStatus != 1 || !isset($MobilePhone)  ) {


if ( $MobilePhoneStatus == 1 ) {

	ScreenStep2();
		
} elseif ( (strlen($MobilePhone) > 2 || strlen($MobilePin) > 2 ) && ( $MobilePhoneStatus != 1 || $MobilePinStatus != 1 ) ) { 

	$error = formatErrorMessage("Es ist ein Fehler bei der Eingabe der Handynummer oder des Passwortes aufgetreten!");
	exit(0);

} else {	# Login wurde blank ohne parameter aufgerufen

	
}; # if ( $MobilePhoneStatus == 1 && $MobilePinStatus == 1) {


exit(0);











function ScreenStep2(){

$MobilePhone	= $_SESSION['mobilephone'];
$CaptchaID		= generateUniqueID();						# captcha id, die wir an unseren captcah server senden, diese id fragt er dann auf unserem server an
$CaptchaText	= GenerateCatpchaText();					# captcha text
$FilePath		= CAPTCHABITJOELOCALPATH .'/'. $CaptchaID .'.txt';	# in welcher datei speichern wir den captcha text
WriteFile( $FilePath, $CaptchaText );
$CaptchaURI		= CAPTCHAURI . $CaptchaID;


echo <<<END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Language" content="de">
<meta http-equiv="content-type" content="text/html; charset=utf8" />
<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
<title>BitJoe - Einrichtung</title>
</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="506" style="margin: 0px">

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" rowspan="3">

	&nbsp;</td>
    <td width="749" height="466" valign="top">
	<table border="0" width="100%" style="border-collapse: collapse">
		<tr>
			<td width="32">&nbsp;</td>
			<td align="left">
			<p align="center">
			&nbsp;</p>
			<p align="center">

			<img border="0" src="/images/logo-klein.png" width="186" height="48"></p>
			<p>&nbsp;</td>
			<td width="30">&nbsp;</td>
		</tr>
		<tr>
			<td width="550"><span style="font-size: 8pt;">Du bist hier:</span> <b style="FONT-SIZE: 8pt; COLOR: #000000;"> <u>Handynummer &uuml;berpr&uuml;fen</u> </b> | <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;">Login</b> | <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;">Interneteinstellungen</b> | <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;">Starten</b> </td>
		</tr>
		</table>

	<p>&nbsp;</p>
	<p>&nbsp;</p>
	

	<p align="center"><font color="#000000" size="2"><b>Bitte &uuml;berpr&uuml;fe Deine Handynummer!<br> Wenn diese nicht korrekt ist, k&ouml;nnen wir Dir die Handy Download Software nicht aufs Handy senden und Du kannst BitJoe nicht benutzen!</b></font></p>
	<br><br><br>



	<p align="center">
		
		<table border = "1">
			<tr width="80%">
				<td width="40%">
					<form method="POST" action="./auth.php">
									
						Deine Handynummer: <br>
						<input type="text" name="mobilephone" value="$MobilePhone" size="12" disabled> <br>
						
						<br>BitJoe Captcha Pr&uuml;fung: <br>
						<img src="$CaptchaURI" alt="bitjoe captcha pr&uuml;fung" height="70" width="220" /><br>

						<br>Gib hier die Zeichen aus dem Bild ein: <br>
						<input type="text" name="pic" value="" title="Gib hier die Zeichen aus dem Bild ein" size="6"><br>

						<br>
						<a href="javascript:top.location.reload();">Ich kann die Zeichen nicht erkennen</a><br>

						<br>
						<input type="hidden" name="action" value="correct">
						<input type="submit" value="Handynummer ist richtig!" title="Deine Handynummer ist korrekt,du musst die Zeichen aus dem Bild zur Pr&uuml;fung eingeben.">

					</form>

						captchaText=$CaptchaText<br>

				</td>
				<td width="40%">
					<form method="POST" action="./auth.php">
									
						Deine Handynummer: <br>
						<input type="text" name="mobilephone" value="$MobilePhone" size="12"> <br>

						<input type="hidden" name="action" value="change">
						<input type="submit" value="Handynummer &auml;ndern!" title="Beim Eintragen deiner Handynummer ist ein Fehler aufgetreten, &Auml;ndere Sie. Du musst keine Zeichen aus dem Bild angeben.">

					</form>
				</td>
			</tr>
		</table>

	</p>


	<!--
	<p align="center"><font size="4"><b>1 x WAP-Push SMS (Dienstmitteilung) f&uuml;r den Download der Handysoftware</b></font></p>
-->


	<p align="center">&nbsp;</p>
	<td width="14" height="506" valign="top" background="/images/shadow_left.gif" rowspan="3">&nbsp;</td>

  </tr>
  <tr>
    <td width="749" height="40" valign="top">
	&nbsp;</td>
  </tr>
  <tr>
    <td width="749" height="40" valign="top">
	&nbsp;</td>
  </tr>

  </table>
</div>

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

return 1;

}; # function NachAnmeldungSimple( ){


?>