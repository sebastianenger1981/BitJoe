<?php

require_once("/srv/server/wwwroot/lib/payment.inc.php");
require_once("/srv/server/wwwroot/lib/functions.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/sql.inc.php");
require_once("/srv/server/wwwroot/lib/security.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");





function BezahlPageStep1(){

	# Prize
	$prize3								= Prize3();
	$prize6								= Prize6();
	$prize12							= Prize12();
	$prize24							= Prize24();
	$prizeLOW							= KOSTENVOLUMELOW;
	$prizeBIG							= KOSTENVOLUMEBIG;
	$prizeHandy							= KOSTENVOLUMEHANDY;
	$prizeFlatHandy						= KOSTENFLATHANDY;

	$BUY_VOLUMENHANDY_SUCCESS			= BUY_HANDYTARIF_1_SUCCESS;
	$BUY_VOLUMENHANDY_SUCCESS_DOWNLOADS	= BUY_HANDYTARIF_1_SUCCESS * DOWNLOADSOURCEMULTIPLY;


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Suchmaschine" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>Handy Downloads - Anmeldung zum Pro User - Schritt 1/3</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="762">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe flatrate für handys und mobile phones" width="778" height="187"></td>
        </tr>
          <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="206" valign="top">
	<p align="center">Wenn Sie Ihre Zugangsdaten schon haben, loggen Sie sich bitte hier ein:</p>
	<p align="left">
	<b>User Login</b><form method="POST" action="/login/">
		<table border="0" width="100%">
			<tr>
				<td width="127">Benutzername:</td>
				<td>
				<input type="text" name="mobilephone" value="$number" size="20"></td>
			</tr>
			<tr>
				<td width="127">PIN / Passwort:</td>
				<td>
				<input type="password" name="pin" value="$pin" size="20"></td>
			</tr>
			<tr>
				<td width="127">&nbsp;</td>
				<td><input type="submit" value="einloggen"></td>
			</tr>
		</table>
		<p align="left">&nbsp;</p>
		
		<br>
	</form>
	<p align="center">
	&nbsp;</td>
  </tr>

 <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="124" valign="top">
		
		<table border="1" width="100%" height="139" style="border-collapse: collapse" bordercolor="#C0C0C0">
	
			<tr>
				<td width="21%" align="left" bordercolor="#C0C0C0"><b>
					Flatrate-Tarif</b>
				</td>
				<td width="14%" align="left" bordercolor="#C0C0C0">
					<p align="center"><b>Preis</b>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%"><b>
					&nbsp; Kaufen per</b>
				</td>
			</tr>
			<tr>
				<td width="21%" align="left" bordercolor="#C0C0C0">
					18 Monate <span class="small-text">($prize24[1] EUR pro Monat)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prize24[0] EUR
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">

				 <table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					
					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>
					
					 <td width="70" align="center">  
					
						<img border="0" src="/images/button_anmeldung_paypal.jpg" width="65" height="31" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal" />
					
					</td>

					<td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>


				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					12 Monate <span class="small-text">($prize12[1] EUR pro Monat)</span>
				</td> 
				<td align="right" bordercolor="#C0C0C0"><font face="Arial"> 
					$prize12[0] EUR</font></td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					
					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					
						<img border="0" src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" />
		
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					6 Monate <span class="small-text">($prize6[1] EUR pro Monat)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					<font face="Arial">$prize6[0] EUR</font>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr> 
					
					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>

					 <td width="70" align="center">  

						<img src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" />
						
					</td>

					<td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>
			<tr>

				<td align="left" bordercolor="#C0C0C0">
					1 Monat <span class="small-text"></span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					<font face="Arial">$prize3[0] EUR</font>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr> 
					
					 <td width="80" align="center">  
						<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="80" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>

					 <td width="80" align="center">  

						<img src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 1 Monat Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate mit Paypal">
						
					</td>

					 <td width="80" align="center">  
						<img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Telefonanruf" width="65" height="31" />
					</td>

					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					  <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>

			

			<tr>
				<td align="left" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="right" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
				&nbsp;</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0"><b>
				Volumentarif</b></td>
				<td align="right" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="left" bordercolor="#C0C0C0" width="50%">
				&nbsp;</td>
			</tr>
			
				
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					$BUY_VOLUMENHANDY_SUCCESS Suchanfragen <span class="small-text">(bis zu $BUY_VOLUMENHANDY_SUCCESS_DOWNLOADS Downloads)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prizeHandy EUR 
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					 <td width="70" align="center">  
									
						<img src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie den BitJoe.de Volumentarif Handy mit Paypal" alt="Bezahlen Sie den BitJoe.de Volumentarif Handy mit Paypal" />
					
					</td>

					 <td width="70" align="center">  
						<img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie den BitJoe.de Volumentarif Handy per Telefonanruf" width="65" height="31" />
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>

			</table>
	</td>
    <td width="14" height="124" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

<!-- 
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe mit 128 bit AES verschlüsselung" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

-->


 <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="40" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<br><br>
			Bitte best&auml;tigen Sie die AGB, um zum Nächsten Schritt der Anmeldung zu kommen.
			<br><br>
			<form method="POST" action="/anmeldung-pro-user/agb.php">
				<input type="checkbox" name="agb" value="1"> ich habe die <a href="http://www.bitjoe.de/AGB/" rel="nofollow,noindex" target="_blank">AGB</a> zur Kenntnis genommen und akzeptiere diese - </p>
				<input type="submit" value="AGB best&auml;tigen">	
			</form>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

	

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function BezahlPageStep1(){


function BezahlPageStep2(){

	#START: SQL COMMANDOS Ausfüllen mit werten füllen, standart user
	$UserName				= generatePasswordForHandyAnmeldung();		# functions.inc.php	- PIN für user generieren
	$UserPIN				= generatePasswordForHandyAnmeldung();				
	$web_up_MD5				= md5($UserName.$UserPIN);
	$overall_searches		= BITJOEHANDY_STANDART_VOLUME_OVERALL;
	$successfull_searches 	= BITJOEHANDY_STANDART_VOLUME_SUCCESS;
	$TABLE1					= BJPARIS_TABLE;
	$REMOTE					= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$SqlQueryBJTABLE		= "";

	# Achtung: BitJoeHandy anmeldungen dürfen sich das update nicht kostenlos nochmals zusenden lassen, sie müssen für ein update bezahlen
	$SqlQueryBJTABLE		= "INSERT INTO `$TABLE1` ( `web_mobilephone`,`web_mobilephone_full`,`web_ref_PP`,`web_grp_PP`,`web_ref_UID`,`web_ref_URL`, `web_lead_istracked`,`web_signup_date`,`web_signup_remote`,`web_servicetype`, `web_password`,`web_up_MD5`, `web_country`,`web_testaccount`,`hc_contingent_volume_success`,`hc_contingent_volume_overall`, `hc_userType`,`hc_abuse`,`web_resend_wappush`) VALUES ( '$UserName','$UserName', '$refPP', '$grpPP', '0', 'Anmeldung_Pro_User', '0', NOW(), '$REMOTE', '1', '$UserPIN', '$web_up_MD5' , 'DE' , '0', '$successfull_searches', '$overall_searches', '3', '0', '0' );";

	$TABLE3					= BILL_TABLE;
	$SqlQueryBILL_TABLE		= "";
	$SqlQueryBILL_TABLE		= "INSERT INTO `$TABLE3` ( `bill_mobilephone`) VALUES ( '$MobilePhone' );";

	session_start();
	session_name("BITJOEPARIS");
	$SessionId						= session_id();
	$_SESSION['username'] 			= $UserName;
	$_SESSION['userpassword'] 		= $UserPIN;

	# stelle die Daten in die SQL Datenbank ein
	$MySqlArray1 					= doSQLQuery($SqlQueryBJTABLE);
	$MySqlArray2 					= doSQLQuery($SqlQueryBILL_TABLE);

	$volumeHandySearchesCall2PayURI		= generateMicropaymentBillingURIforVolumeHandyCallToPay( $UserName );	# 5 suchen

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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de - Anmeldung zum Pro User - Schritt 2/3</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="762">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe flatrate für handys und mobile phones" width="778" height="187"></td>
        </tr>
          <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
 
  
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="206" valign="top">
	<p align="center">Wenn Sie Ihre Zugangsdaten schon haben, loggen Sie sich bitte hier ein:</p>
	<p align="left">
	<b>User Login</b><form method="POST" action="/login/">
		<table border="0" width="100%">
			<tr>
				<td width="127">Benutzername:</td>
				<td>
				<input type="text" name="mobilephone" value="$number" size="20"></td>
			</tr>
			<tr>
				<td width="127">PIN / Passwort:</td>
				<td>
				<input type="password" name="pin" value="$pin" size="20"></td>
			</tr>
			<tr>
				<td width="127">&nbsp;</td>
				<td><input type="submit" value="einloggen"></td>
			</tr>
		</table>
		<p align="left">&nbsp;</p>
		
		<br>
	</form>
	<p align="center">
	&nbsp;</td>
    <td width="14" height="206" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>

			Bezahlen Sie für die www.bitjoe.de Pro-Anmeldung mit einem <a href="$volumeHandySearchesCall2PayURI" title="Bezahlen Sie den www.bitjoe.de Pro-Anmeldung mit einem Telefonanruf für 2,99 EUR" target="_blank" rel="nofollow"> Telefonanruf für 2,99 EUR</a> - 
			<a href="$volumeHandySearchesCall2PayURI" title="Bezahlen Sie den www.bitjoe.de Pro-Anmeldung mit einem Telefonanruf für 2,99 EUR" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie den www.bitjoe.de Pro-Anmeldung mit einem Telefonanruf für 2,99 EUR" width="65" height="31" /></a>

			<br><br>

			<a href="/anmeldung-pro-user/prouser.php" title="Anmeldung zum Pro User - Schritt 3/3" target="_self">Weiter mit der Anmeldung zum Pro User - Schritt 3/3</a>
	
			<br><br><br><br><br>

		</tr>
		</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe mit 128 bit AES verschlüsselung" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function BezahlPageStep2(){




function BezahlPageStep3( $phonenumber, $emailadresse, $error ){


	$SqlQuery 			= "SELECT `hc_userType` AS VALUE FROM `bjparis` WHERE `web_mobilephone` = '$phonenumber' LIMIT 1;";
	$MySqlArrayCheck 	= doSQLQuery($SqlQuery);

	$sql_results		= mysql_fetch_array($MySqlArrayCheck);
	$IsUserType			= $sql_results["VALUE"];	# alles außer 2 ist free user
	
	session_start();
	session_name("BITJOEPARIS");
	$_SESSION['IsUserType'] 	= $IsUserType;


	if ( $IsUserType == 2 ){
		
		# user hat bezahlt also darf er sich auch per sms die software zusenden lassen

		$extra = <<<END

			<input type="checkbox" name="sms" value="1" checked> per SMS und WAP-Push SMS </p> - 
				<select size="1" name="prenumber">
					<option value="DE" disabled style="color:#666666;">Deutschland</option>
					<option value="0150" $de>0150</option>
					<option value="01505">01505</option>
					<option value="0151">0151</option>
					<option value="0152">0152</option>
			
					<option value="01520">01520</option>
					<option value="0155">0155</option>
					<option value="01550">01550</option>
					<option value="0157">0157</option>
					<option value="0159">0159</option>
					<option value="0160">0160</option>
			
					<option value="0161">0161</option>
					<option value="0162">0162</option>
					<option value="0163">0163</option>
					<option value="0169">0169</option>
					<option value="0170">0170</option>
					<option value="0171">0171</option>
			
					<option value="0172">0172</option>
					<option value="0173">0173</option>
					<option value="0174">0174</option>
					<option value="0175">0175</option>
					<option value="0176">0176</option>
					<option value="0177">0177</option>
			
					<option value="0178">0178</option>
					<option value="0179">0179</option>
					<option value="AT" disabled style="color:#666666;">&Ouml;sterreich</option>
					<option value="0650" $at>0650</option>
					<option value="0660">0660</option>
					<option value="0663">0663</option>
			
					<option value="0664">0664</option>
					<option value="0676">0676</option>
					<option value="0699">0699</option>
					<option value="AT" disabled style="color:#666666;">Schweiz</option>
					<option value="076" $ch>076</option>
					<option value="077">077</option>
					<option value="078">078</option>
					<option value="079">079</option>
				</select> 
				<input type="text" name="mobilephone" size="20"><p><br>
			</p>

END;

	}; # if ( $IsUserType == 2 ){



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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de - Anmeldung zum Pro User - Schritt 2/3</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="762">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe flatrate für handys und mobile phones" width="778" height="187"></td>
        </tr>
          <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
 

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>

			Ich möchte meine Nutzerdaten und die BitJoe-Software: <br><br>
			
			<form method="POST" action="/anmeldung-pro-user/prouser.php">
				
				$extra

			<br>
				<input type="checkbox" name="email" value="1"> per E-Mail </p> - <input type="text" name="emailadresse" value="$emailadresse" size="50"> <br>
				<input type="submit" value="Zugangssoftware zusenden">	
			</form>
			
			<br><br><br><br><br>
		$error
		<br><br>
		</tr>
		</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe mit 128 bit AES verschlüsselung" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function BezahlPageStep3( ){








function LoginPageScreen4aUserwahl( $phone ){

	# Abschnitt Screen 4 - Userauswahl ob er Internet auf seinem Handy hat


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Login f&uuml;r Neukunden - Hilfe zur Konfiguration der Interneteinstellungen</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">

		<table border="0" width="100%" height="139">
			<tr>
				<td width="50" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>			
			</tr>
			<tr>
				<td></td>
				<td width="644" align="center">

					<!-- later: send user a WAP OTA SMS Message -->

					<font size="2" color="#666666">Interneteinstellungen auf Dein Handy zusenden f&uuml;r </font>

					<font size="2" color="#666666"><a href="http://www.nokia.de/A4421175" rel="nofollow" target="_blank">Nokia</a></font> |
					<font size="2" color="#666666"><a href="http://www.sonyericsson.com/cws/support/phones/detailed/phonesetupwap?cc=de&lc=de" rel="nofollow" target="_blank">Sony Ericsson</a></font> | 
					<font size="2" color="#666666"><a href="https://hellomoto.wdsglobal.com/site/phonefirst?step=landing.vm&preferredPhoneName=&locale=&preferredCountryName=" rel="nofollow" target="_blank">Motorola</a></font> | 
					<font size="2" color="#666666"><a href="http://de.samsungmobile.com/supports/configurephone/wapSetting.do" rel="nofollow" target="_blank">Samsung</a></font> 
					<p>&nbsp;</p>

					<p><font size="2" color="#666666">Hilfe zur Einrichtung des Internetzuganges auf deinem Handy speziell f&uuml;r Deinen Handy Provider: </font>
					<p><font size="2" color="#C90735">
					<a href="https://www.vodafone.de/jsp/Delegate?name=MTCS" rel="nofollow" target="_blank">
					<font color="#666666">Vodafone</font></a></font><font size="2" color="#666666">, </font><font size="2" color="#C90735">
					<a href="https://www.csp.t-mobile.net/rdm/?pt=TMDEUP">

					<font color="#666666">T</font></a><a href="https://www.csp.t-mobile.net/rdm/?pt=TMDEUP" rel="nofollow" target="_blank"><font color="#666666">-Online</font></a></font><font size="2" color="#666666">, </font><font size="2" color="#C90735">
					<a href="http://www.eplus.de/dienste/13/13_3/13_3.asp" rel="nofollow" target="_blank">
					<font color="#666666">e-plus</font></a></font><font size="2" color="#666666">, </font><font size="2" color="#C90735">
					<a href="http://www.o2online.de/nw/support/mobilfunk/handy/settings/index.html?o2_type=goto&o2_label=einstellungen" rel="nofollow" target="_blank">
					<font color="#666666">O2</font></a></font><p><font size="2" color="#C90735">
					<a href="http://www.orange.ch/vrtmobilephones/configure/?.portal_action=.changeLanguage&.portlet=configure&language=de" rel="nofollow" target="_blank">

					<font color="#666666">Orange</font></a></font><font size="2" color="#666666">, </font>
					<font size="2" color="#C90735">
					<a href="http://www.sunrise.ch/kundendienst/kun_produkteunddienste/handyeinrichten.html" rel="nofollow" target="_blank">
					<font color="#666666">sunrise</font></a></font><font size="2" color="#666666">, </font>
					<font size="2" color="#C90735">
					<a href="http://www.swisscom-mobile.ch/scm/kd_mms_wap_email_internet_einrichten-de.aspx" rel="nofollow" target="_blank">
					<font color="#666666">swisscom</font></a></font><font size="2" color="#666666">, </font><font size="2" color="#C90735">

					<a href="http://www.tele2.ch/de/gprs-einstellungen-per-sms.html" rel="nofollow" target="_blank">
					<font color="#666666">Tele2</font></a></font><p><font size="2">
					<a href="http://www.a1.net/privat/handyinterneteinstellungen" rel="nofollow" target="_blank">
					<font color="#666666">A1</font></a><font color="#666666">,
					</font>
					<a href="http://www.drei.at/portal/de/privat/service/Service_Startseite.html" rel="nofollow" target="_blank">
					<font color="#666666">Drei</font></a><font color="#666666">, </font> <a href="http://www.one.at/" rel="nofollow" target="_blank">

					<font color="#666666">One</font></a><font color="#666666">,
					</font>
					<a href="http://www.telering.at/Content.Node/support/2674.php" rel="nofollow" target="_blank">
					<font color="#666666">Telering</font></a></font>
					</font></p>

					<br><br>

					<form method="POST" action="/login2/internetsettings2.php">
						<input type="hidden" name="working" value="ja">
						<input type="submit" value="Ja, Internet funktioniert jetzt. Schick mir die Bitjoe Software.!">
					</form>
						
					<form method="POST" action="/login2/internetsettings2.php">
						<input type="hidden" name="working" value="nein">
						<input type="submit" value="Nein, Internet funktioniert immer noch nicht. Ich möchte Support.">
					</form>

				</td>
			</tr>			
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

     <td width="749" height="74" valign="top">
	<p align="left">
    </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function LoginPageScreen4aUserwahl( $phone ){




function LoginPageScreen4( $phone ){

	# Abschnitt Screen 4 - Userauswahl ob er Internet auf seinem Handy hat


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Login f&uuml;r Neukunden - Konfiguration Interneteinstellungen</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">

		<table border="0" width="100%" height="139">
			<tr>
				<td width="50" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>			
			</tr>
			<tr>
				<td></td>
				<td width="644" align="center">
					<font size="4"><b>
						Um die 60 Downloads zu erhalten ben&ouml;tigt Dein Handy Internet!<br>
						Sollen wir Dir die Interneteinstellungen zuschicken?
					</b></font>

					<br><br>

					<form method="POST" action="/login2/internetsettings.php">
						<input type="hidden" name="needed" value="ja">
						<input type="submit" value="Ja, ich ben&ouml;tige die Einstellungen!">
					</form>
						
					<form method="POST" action="/login2/internetsettings.php">
						<input type="hidden" name="needed" value="nein">
						<input type="submit" value="Nein, Internet funktioniert bereits auf meinem Handy">
					</form>

				</td>
			</tr>			
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

     <td width="749" height="74" valign="top">
	<p align="left">
    </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function LoginPageScreen4( $phone, $error ){






function LoginPageScreen3( $land, $error, $number, $pin, $addional ){

	# screen 3 nach userneuanmeldung

	if ( strlen($land) > 1 && strlen($land) < 4 ){

		if ( strstr($land, "DE") ){
			$de = "selected";
		} elseif ( strstr($land, "CH") ){
			$ch = "selected";
		} elseif ( strstr($land, "AT") ){
			$at = "selected";
		} elseif ( strstr($land, "GB") ){
			$uk = "selected";
		} else {
			$na = "selected";
		};

	}; # if ( strlen($Checked) == 2 || strlen($Checked) == 3 ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Login f&uuml;r Neukunden</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="762">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe flatrate für handys und mobile phones" width="778" height="187"></td>
        </tr>
          <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="206" valign="top">

	<p align="left">
	<span style="font-size: 8pt;">Du bist hier:</span> <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;"> Benutzername &uuml;berpr&uuml;fen | <b style="FONT-SIZE: 8pt; COLOR: #000000;"><u>Login</u></b> | <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;">Interneteinstellungen</b> | <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;">Starten</b>
	</p>

	<p>&nbsp;</p>

	<p align="center">

		$addional

		<font size="4">

			<b>Du erhälst in wenigen Sekunden eine SMS mit den Zugangsdaten.</b><br>
			Trage deine Benutzername und den PIN aus der SMS hier ein, um die Handy Download Software zu erhalten.
		</font>
	</p>

	<p>&nbsp;</p>

	<p align="left">
	
	<b>User Login</b><form method="POST" action="/login2/">
		<table border="0" width="100%">
			<tr>
				<td width="127">Benutzername:</td>
				<td>
				<input type="text" name="mobilephone" value="$number" size="20"></td>
			</tr>
			<tr>
				<td width="127">PIN / Passwort:</td>
				<td>
				<input type="password" name="pin" value="$pin" size="20"></td>
			</tr>
			<tr>
				<td width="127">&nbsp;</td>
				<td><input type="submit" value="einloggen"></td>
			</tr>
		</table>
		<p align="left">&nbsp;</p>
		
		$error
		<br>
	</form>
	<p align="center">
	&nbsp;</td>
    <td width="14" height="206" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr height="10">
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer" height="132">
	&nbsp;</td>
    <td width="749" valign="top" height="132">
	<form method="POST" action="/signup.php">
		<p align="center"><b>Neukunde?</b> - kein Problem! 
		Einfach Deine Benutzername eingeben und gratis testen*</p>
		<center>Deine Benutzername: 
		<select size="1" name="prenumber">
			<option value="DE" disabled style="color:#666666;">Deutschland</option>
			<option value="0150" $de>0150</option>
			<option value="01505">01505</option>
			<option value="0151">0151</option>
			<option value="0152">0152</option>
	
			<option value="01520">01520</option>
			<option value="0155">0155</option>
			<option value="01550">01550</option>
			<option value="0157">0157</option>
			<option value="0159">0159</option>
			<option value="0160">0160</option>
	
			<option value="0161">0161</option>
			<option value="0162">0162</option>
			<option value="0163">0163</option>
			<option value="0169">0169</option>
			<option value="0170">0170</option>
			<option value="0171">0171</option>
	
			<option value="0172">0172</option>
			<option value="0173">0173</option>
			<option value="0174">0174</option>
			<option value="0175">0175</option>
			<option value="0176">0176</option>
			<option value="0177">0177</option>
	
			<option value="0178">0178</option>
			<option value="0179">0179</option>
			<option value="AT" disabled style="color:#666666;">&Ouml;sterreich</option>
			<option value="0650" $at>0650</option>
			<option value="0660">0660</option>
			<option value="0663">0663</option>
	
			<option value="0664">0664</option>
			<option value="0676">0676</option>
			<option value="0699">0699</option>
			<option value="AT" disabled style="color:#666666;">Schweiz</option>
			<option value="076" $ch>076</option>
			<option value="078">078</option>
			<option value="079">079</option>
		</select> 
		<input type="text" name="mobilephone" size="20"><p><br>
		<input type="submit" value="" class="newuser-submit">
	</p>
	</form>
	</td>
    <td width="14" valign="top" background="/images/shadow_left.gif" alt="spacer" height="90">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer"
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe mit 128 bit AES verschlüsselung" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function LoginPageScreen3( $land, $error, $number, $pin ){


function ResendSoftwarePage( $phone, $error ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Software nochmal zusenden lassen</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">

		<table border="0" width="100%" height="139">
			<tr>
				<td width="244" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>
				<td align="left" height="83">
					<p align="right">
					<font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>
			<tr>
				<td width="244" align="left"></td>
				<td align="left">
				</td>
			</tr>
			<tr>
				<td width="344" align="left">$error</td>
				<td align="left">
				</td>
			</tr>
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

     <td width="749" height="74" valign="top">
	<p align="left">
    </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> | 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function ResendSoftwarePage( $phone, $error ){



function NachAnmeldungSimple(){


echo <<<END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Language" content="de">
<meta http-equiv="content-type" content="text/html; charset=utf8" />
<meta http-equiv="refresh" content="10;URL=http://www.bitjoe.de/hilfe/">
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
		</table>
	<p>&nbsp;</p>
	<p>&nbsp;</p>
	<p align="center"><font color="#C90735" size="4"><b>Du erh&auml;ltst in K&uuml;rze:</b></font></p>

	<p align="center">&nbsp;</p>
	<p align="center"><font color="#C90735" size="4"><b>1 x SMS mit den Zugangsdaten</b></font></p>
	<p align="center">&nbsp;</p>
	<p align="center"><font color="#C90735" size="4"><b>1 x WAP-Push SMS 
	(Dienstmitteilung) f&uuml;r den Download der Handysoftware</b></font></p>
	<p align="center">&nbsp;</p>
	<p align="center"><a href="http://www.bitjoe.de/hilfe/">weiter zu Schritt 2</a></td>
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

/*
sleep(6);
NachAnmeldung( );
*/

return 1;

}; # function NachAnmeldungSimple( ){





function NachAnmeldung( ){


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
<table width="778" border="0" cellpadding="0" cellspacing="0" height="850" style="margin: 0px">

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" rowspan="2">

	&nbsp;</td>
    <td width="749" height="2126" valign="top">
	<table border="0" width="100%" style="border-collapse: collapse">
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			<p align="center">
			&nbsp;</p>
			<p align="center">

			<img border="0" src="/images/logo-klein.png" width="186" height="48"></p>
			<p>&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			<p><font color="#C90735" size="5"><b>Schritt 2</b></font></p>

			<p>&nbsp;</p>
			<p><font size="4"><b>a) Lerne wie BitJoe funktioniert:</b></font><p align="center">
			&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">

			
			<p align="center">
			
			<iframe src="http://www.bitjoe.de/flashplayer/bitjoe_flashplayer.html" width="640" height="520" frameborder="0" scrolling="no"></iframe>
			
			</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">

			&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			<p align="center">&nbsp;</p>
			<p><font size="4"><b>b)</b></font><b><font size="4"> 
			Folge der Anleitung:</font></b></td>

			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>

			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			<img border="0" src="/images/dot1.png" width="26" height="26">&nbsp;&nbsp; 
			WAP-Push SMS wird auf Dein Handy gesendet (dauert ggf. einige 
			Minuten)</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%" height="21">&nbsp;</td>
			<td colspan="2" align="left" height="21">&nbsp;</td>

			<td width="7%" height="21">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			<img border="0" src="/images/dot2.png" width="26" height="26">&nbsp;&nbsp; 
			In der SMS das laden der BitJoe Software bestätigen</td>
			<td width="7%">&nbsp;</td>
		</tr>

		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">
			<img border="0" src="/images/dot3.png" width="26" height="26">&nbsp;&nbsp; 
			BitJoe Software Installation bestätigen</td>

			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2" align="left">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>

			<td colspan="2" align="left">
			<img border="0" src="/images/dot4.png" width="26" height="26">&nbsp;&nbsp; 
			BitJoe Software starten und <b><a href="http://www.bitjoe.de/AGB">
			AGB</a></b> 
			zustimmen (Hinweis: BitJoe ist <b>kein</b> Abo!)</td>
			<td width="7%">&nbsp;</td>
		</tr>

		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">

			<img border="0" src="/images/dot5.png" width="26" height="26">&nbsp;&nbsp; 
			Deine Benutzername und Deinen
			<p><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4-stelligen PIN aus der 
			SMS</b></p>
			<p>&nbsp;eintragen und bestätigen.</td>
			<td align="center" width="42%">
			<img border="0" src="/images/BitJoe_SonyEricsson_K750_2.png" width="176" height="221"></td>
			<td width="7%">&nbsp;</td>
		</tr>

		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">&nbsp;</td>
			<td align="center" width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">

			<img border="0" src="/images/BitJoe_SonyEricsson_K750_1.png" width="176" height="221"></td>
			<td align="center" width="42%">
			<img border="0" src="/images/dot6.png" width="26" height="26">&nbsp;&nbsp; 
			Auswählen was Du suchen willst.<p>&nbsp;</p>
			<p><font size="1">Hinweis: mit Cursor- oder Mitteltaste kannst Du 
			auswählen</font></td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>

			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">&nbsp;</td>
			<td align="center" width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">
			<img border="0" src="/images/dot7.png" width="26" height="26">&nbsp;&nbsp; 
			Wähle jetzt &#8222;Suchen&#8220;</td>

			<td align="center" width="42%">
			<img border="0" src="/images/BitJoe_SonyEricsson_K750_8.png" width="176" height="221"></td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">&nbsp;</td>
			<td align="center" width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>

		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">
			<img border="0" src="/images/BitJoe_SonyEricsson_K750_18.png" width="176" height="221"></td>
			<td align="center" width="42%">
				<img border="0" src="/images/dot8.png" width="26" height="26">&nbsp;&nbsp; 
			Gebe den Suchbegriff ein und drücke dann &#8222;Absenden&#8220;.Ein kurzer bzw. ein einzelner Suchbegriff bringt mehr Treffer als mehrere Suchbegriffe.<p><font size="2" color="#C90735">

			Hinweis: es wird eine Internetverbindung benötigt</font></p>
			<p>&nbsp;</p>
			<p><font size="1" color="#666666">Internethilfe: </font>
			<p><font size="1" color="#C90735">
			<a href="https://www.vodafone.de/jsp/Delegate?name=MTCS" rel="nofollow">
			<font color="#666666">Vodafone</font></a></font><font size="1" color="#666666">, </font><font size="1" color="#C90735">
			<a href="https://www.csp.t-mobile.net/rdm/?pt=TMDEUP">

			<font color="#666666">T</font></a><a href="https://www.csp.t-mobile.net/rdm/?pt=TMDEUP" rel="nofollow"><font color="#666666">-Online</font></a></font><font size="1" color="#666666">, </font><font size="1" color="#C90735">
			<a href="http://www.eplus.de/dienste/13/13_3/13_3.asp" rel="nofollow">
			<font color="#666666">e-plus</font></a></font><font size="1" color="#666666">, </font><font size="1" color="#C90735">
			<a href="http://www.o2online.de/nw/support/mobilfunk/handy/settings/index.htmll?o2_type=goto&o2_label=einstellungen" rel="nofollow">
			<font color="#666666">O2</font></a></font><p><font size="1" color="#C90735">
			<a href="http://www.orange.ch/vrtmobilephones/configure/?.portal_action=.changeLanguage&.portlet=configure&language=de" rel="nofollow">

			<font color="#666666">Orange</font></a></font><font size="1" color="#666666">, </font>
			<font size="1" color="#C90735">
			<a href="http://www.sunrise.ch/kundendienst/kun_produkteunddienste/handyeinrichten.html" rel="nofollow">
			<font color="#666666">sunrise</font></a></font><font size="1" color="#666666">, </font>
			<font size="1" color="#C90735">
			<a href="http://www.swisscom-mobile.ch/scm/kd_mms_wap_email_internet_einrichten-de.aspx" rel="nofollow">
			<font color="#666666">swisscom</font></a></font><font size="1" color="#666666">, </font><font size="1" color="#C90735">

			<a href="http://www.tele2.ch/de/gprs-einstellungen-per-sms.htmll" rel="nofollow">
			<font color="#666666">Tele2</font></a></font><p><font size="1">
			<a href="http://www.a1.net/privat/handyinterneteinstellungen" rel="nofollow">
			<font color="#666666">A1</font></a><font color="#666666">,
			</font>
			<a href="http://www.drei.at/portal/de/privat/service/Service_Startseite.htmll" rel="nofollow">
			<font color="#666666">Drei</font></a><font color="#666666">, </font> <a href="http://www.one.at/">

			<font color="#666666">One</font></a><font color="#666666">,
			</font>
			<a href="http://www.telering.at/Content.Node/support/2674.php" rel="nofollow">
			<font color="#666666">Telering</font></a></font></td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>

			<td width="45%" align="center">&nbsp;</td>
			<td align="center" width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">
			<img border="0" src="/images/dot9.png" width="26" height="26">&nbsp;&nbsp; 
			Wähle aus der Trefferliste aus was Du downloaden willst.</td>

			<td align="center" width="42%">
			<img border="0" src="/images/BitJoe_SonyEricsson_K750_17.png" width="176" height="221"></td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">&nbsp;</td>
			<td align="center" width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>

		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%" align="center">
			<img border="0" src="/images/BitJoe_SonyEricsson_K750_23.png" width="176" height="221"></td>
			<td align="center" width="42%">
			<img border="0" src="/images/dot10.png" width="26" height="26">&nbsp; 
			Wähle jetzt aus wo Du in Deinem Handy speichern möchtest<p>&nbsp;</p>
			<p><font size="1">Hinweis: in dem Ordner in dem Du speichern 
			möchtest musst Du &quot;<i>HIER SPEICHERN</i>&quot; wählen. (Systemordner 
			gehen ggf. nicht)</font></td>

			<td width="7%">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%">&nbsp;</td>
			<td width="45%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
		<tr>

			<td width="6%">&nbsp;</td>
			<td colspan="3">&nbsp;<p>&nbsp;</p>
			<p align="center">
			<img border="0" src="/images/dot11.png" width="26" height="26">
		
			Empfehle BitJoe an einen Freund:
			<p align="center">
			&nbsp;<form method="POST" action="/login/tellafriend.php">
					<p align="center">
					<select size="1" name="prenumber">

						<option value="DE" disabled style="color:#666666;">
						Deutschland</option>
						<option value="0150" selected>0150</option>
						<option value="01505">01505</option>
						<option value="0151">0151</option>
						<option value="0152">0152</option>

				
						<option value="01520">01520</option>
						<option value="0155">0155</option>
						<option value="01550">01550</option>
						<option value="0157">0157</option>
						<option value="0159">0159</option>
						<option value="0160">0160</option>

				
						<option value="0161">0161</option>
						<option value="0162">0162</option>
						<option value="0163">0163</option>
						<option value="0169">0169</option>
						<option value="0170">0170</option>
						<option value="0171">0171</option>

				
						<option value="0172">0172</option>
						<option value="0173">0173</option>
						<option value="0174">0174</option>
						<option value="0175">0175</option>
						<option value="0176">0176</option>
						<option value="0177">0177</option>

				
						<option value="0178">0178</option>
						<option value="0179">0179</option>
						<option value="AT" disabled style="color:#666666;">
						Österreich</option>
						<option value="0650">0650</option>
						<option value="0660">0660</option>

						<option value="0663">0663</option>
				
						<option value="0664">0664</option>
						<option value="0676">0676</option>
						<option value="0699">0699</option>
						<option value="AT" disabled style="color:#666666;">
						Schweiz</option>

						<option value="076">076</option>
						<option value="078">078</option>
						<option value="079">079</option>
					</select> 
					<input type="text" name="mobilephone" size="15"> <input type="submit" style="width:168px;" value="BitJoe per SMS empfehlen!"></p>
			</form></td>
		</tr>

		<tr>
			<td width="6%">&nbsp;</td>
			<td colspan="2">
								&nbsp;<p>&nbsp;</p>
								<p>&nbsp;</p>
								<p align="center"><font size="2">
								<a href="http://www.bitjoe.de/login/tarif.php">
								Guthaben aufladen</a> 
								| <a href="http://www.bitjoe.de/login/tellafriend.php">

								Weiterempfehlen</a> 
								| <a href="http://www.bitjoe.de/login/usecoupon.php">
								Gutschein einlösen</a>
								| <a href="http://www.bitjoe.de/logout.php">
								logout</a></font>
			</td>
			<td width="7%">&nbsp;</td>

		</tr>
	</table>
	</td>
    <td width="14" height="2247" valign="top" background="/images/shadow_left.gif" rowspan="2">
	&nbsp;</td>
  </tr>
  <tr>
    <td width="749" height="125" valign="top">
	<p align="left">

		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
			<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a></td>
			<td width="110" align="center">

			<a class="nav" href="http://www.bitjoe.de/login">User-Login</a>
			</td>
			<td align="center" width="110">
			<a class="nav" href="http://www.bitjoe.de/faq.html">FAQ</a></td>
			<td width="110">
			<p align="center">
			<a class="nav" href="http://www.bitjoe.de/support.html">Support</a></td>

			<td width="110">
			<p align="center">
			<a class="nav" href="http://www.bitjoe.de/software.html">Software</a></td>
			<td width="110">
			<p align="center">
			<a class="nav" href="http://www.bitjoe.de/funktioniert.html">Wie 
			funktioniert's?</a></td>
		</tr>
	</table>

	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="right" class="small-text">
		
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">
		Partnerprogramm</a> 
		| 
		<a rel="nofollow" class="small-text" href="http://www.bitjoe.de/impressum.html">

		Impressum</a> |
		<a rel="nofollow" class="small-text" href="http://www.bitjoe.de/AGB">AGB</a></p>
	</td>
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

}; # function NachAnmeldung( ){




function UseCouponPage( $phone, $error ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Gutschein einl&ouml;sen</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">

		<table border="0" width="100%" height="139">
			<tr>
				<td width="244" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>
				<td align="left" height="83">
					<p align="right"><font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>
			<form method="POST" action="/login/usecoupon.php">	
			<tr>
				<td width="244" align="left">Gutscheincode:</td>
				<td align="left"><input type="text" name="couponcode" size="10"></td>
			</tr>
			<tr>
				<td width="244" align="left">$error</td>
				<td align="left">
					<input type="submit" value="Einl&ouml;sen">
				</td>
			</tr>
			</form>
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

     <td width="749" height="74" valign="top">
	<p align="left">
    </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
			<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function UseCouponPage( $error ){



function PasswordPage( $error ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Passwort Erinnerung</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html"  rel="nofollow" ><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">

		<table border="0" width="100%" height="139">
			<tr>
				<td width="244" align="left" height="83"><b>
				Passwort Erinnerung </b></td>
				<td align="left" height="83">
					<p align="right">
					<font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>
			<form method="POST" action="/password.php" name="vw">	
			<tr>
				<td width="244" align="left">Deine Benutzername:</td>
				<td align="left"><input name="mobilephone" value="" ></td>
			</tr>
			<tr>
				<td width="244" align="left">$error</td>
				<td align="left">
					<input type="submit" value="PIN anfordern">
				</td>
			</tr>
			</form>
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

     <td width="749" height="74" valign="top">
	<p align="left">
    </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport  - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function PasswordPage( $MobilePhone, $error ){



function TellAFriendPage( $phone, $error ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de an deine Freunde weiterempfehlen</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">

		<table border="0" width="100%" height="139">
			<tr>
				<td width="244" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>
				<td align="left" height="83">
					<p align="right">
					<font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>
			<form method="POST" action="/login/tellafriend.php">
			<tr>
				<td width="244" align="left">Handy vom Freund:</td>
				<td align="left">
					<select size="1" name="prenumber">
						<option value="DE" disabled style="color:#666666;">Deutschland</option>
						<option value="0150" selected>0150</option>
						<option value="01505">01505</option>
						<option value="0151">0151</option>
						<option value="0152">0152</option>
				
						<option value="01520">01520</option>
						<option value="0155">0155</option>
						<option value="01550">01550</option>
						<option value="0157">0157</option>
						<option value="0159">0159</option>
						<option value="0160">0160</option>
				
						<option value="0161">0161</option>
						<option value="0162">0162</option>
						<option value="0163">0163</option>
						<option value="0169">0169</option>
						<option value="0170">0170</option>
						<option value="0171">0171</option>
				
						<option value="0172">0172</option>
						<option value="0173">0173</option>
						<option value="0174">0174</option>
						<option value="0175">0175</option>
						<option value="0176">0176</option>
						<option value="0177">0177</option>
				
						<option value="0178">0178</option>
						<option value="0179">0179</option>
						<option value="AT" disabled style="color:#666666;">&Ouml;sterreich</option>
						<option value="0650">0650</option>
						<option value="0660">0660</option>
						<option value="0663">0663</option>
				
						<option value="0664">0664</option>
						<option value="0676">0676</option>
						<option value="0699">0699</option>
						<option value="AT" disabled style="color:#666666;">Schweiz</option>
						<option value="076">076</option>
						<option value="078">078</option>
						<option value="079">079</option>
					</select> 
					<input type="text" name="mobilephone" size="20">
				</td>
			</tr>
			<tr>
				<td width="244" align="left">$error</td>
				<td align="left">
					<input type="submit" value="Senden">
				</td>
			</tr>
			</form>
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

     <td width="749" height="74" valign="top">
	<p align="left">
    </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function TellAFriendPage( $phone, $error ){


function TarifePage( $MobilePhone ){

	# call to pay
	$threeMonthsFlatCall2PayURI 		= generateMicropaymentBillingURIforThreeMonthsFlatCallToPay( $MobilePhone );	# flat
	$volumeTenSearchesCall2PayURI		= generateMicropaymentBillingURIforVolumeLowCallToPay( $MobilePhone );		# 10 suchen
	$volumeThirtySearchesCall2PayURI 	= generateMicropaymentBillingURIforVolumeBigCallToPay( $MobilePhone );	# 30 suchen
	$volumeHandySearchesCall2PayURI		= generateMicropaymentBillingURIforVolumeHandyCallToPay( $MobilePhone );	# 5 suchen
	$flatrate5daysCall2Pay				= generateBillingURIforFiveDaysFlatCall2Pay( $MobilePhone );				# flatrate für 5 tage

	# ebank
	$threeMonthsFlatEbankURI			= generateBillingURIforThreeMonthsFlateBank( $MobilePhone );	# 3 monats flat ebank
	$sixMonthsFlatEbankURI				= generateBillingURIforSixMonthsFlateBank( $MobilePhone );	# 6 monats flat ebank
	$twelveMonthsFlatEbankURI			= generateBillingURIforTwelveMonthsFlateBank( $MobilePhone );	# 12 monats flat ebank
	$twentyfourMonthsFlatEbankURI		= generateBillingURIforTwentyFourMonthsFlateBank( $MobilePhone );	# 24 monats flat ebank
	$flatrate5dayseBank					= generateBillingURIforFiveDaysFlateBank( $MobilePhone );	# 5 tages flat ebank

	# lastschrift
	$threeMonthsFlatLastschriftURI		= generateBillingURIforThreeMonthsFlatLastschrift( $MobilePhone );	# 3 monats flat lastschrift
	$sixMonthsFlatLastschriftURI		= generateBillingURIforSixMonthsFlatLastschrift( $MobilePhone );	# 6 monats flat lastschrift
	$twelveMonthsFlatLastschriftURI		= generateBillingURIforTwelveMonthsFlatLastschrift( $MobilePhone );	# 12 monats flat lastschrift
	$twentyfourMonthsFlatLastschriftURI	= generateBillingURIforTwentyFourMonthsFlatLastschrift( $MobilePhone );	# 24 monats flat lastschrift
	$flatrate5daysLastschrift			= generateBillingURIforFiveDaysFlatLastschrift( $MobilePhone ); # 5 tages flat

	## $test	= _testCall($MobilePhone);

	# paypal
	$paypal3							= generatePaypalThreeMonths( $MobilePhone );	# paypal NEU : 1 monate - array
	$paypal6							= generatePaypalSixMonths( $MobilePhone );		# paypal 6 monate - array
	$paypal12							= generatePaypalTwelveMonths( $MobilePhone );		# paypal 12 monate - array
	$paypal24							= generatePaypalTwentyFourMonths( $MobilePhone );		# paypal 24 monate - array
	$paypalLOW							= generatePaypalLOW( $MobilePhone );		# paypal volume low - array
	$paypalBIG							= generatePaypalBIG( $MobilePhone );		# paypal volume big - array
	$paypalHandy						= generatePaypalHandy( $MobilePhone );		# paypal volume handy - array
	$paypalFlatHandy					= generatePaypalFlatHandy( $MobilePhone );	# paypal für 5 tages flatrate

	# Prize
	$prize3								= Prize3();
	$prize6								= Prize6();
	$prize12							= Prize12();
	$prize24							= Prize24();
	$prizeLOW							= KOSTENVOLUMELOW;
	$prizeBIG							= KOSTENVOLUMEBIG;
	$prizeHandy							= KOSTENVOLUMEHANDY;
	$prizeFlatHandy						= KOSTENFLATHANDY;

	$BUY_VOLUMENHANDY_SUCCESS			= BUY_HANDYTARIF_1_SUCCESS;
	$BUY_VOLUMENHANDY_SUCCESS_DOWNLOADS	= BUY_HANDYTARIF_1_SUCCESS * DOWNLOADSOURCEMULTIPLY;


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Tarif upgraden und Flatrate kaufen</title>

</head>
<body style="margin:0px">
<div align="center">

<table width="778" border="0" cellpadding="0" cellspacing="0" height="772">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
 
           <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe handy flatrates" width="778" height="187"></td>
        </tr>
      <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="124" valign="top">
		
		<table border="1" width="100%" height="139" style="border-collapse: collapse" bordercolor="#C0C0C0">
			<tr>
				<td width="34%" align="left" height="60" bordercolor="#C0C0C0">
					<b>&Uuml;bersicht f&uuml;r $MobilePhone </b>
				</td>
				<td align="left" height="60" bordercolor="#C0C0C0" colspan="2">
					<p align="right">
					<font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0" colspan="3">
					<i>Bitte w&auml;hlen Sie den gew&uuml;nschten Tarif und 
					die gew&uuml;nschte Bezahlweise aus .</i><p>&nbsp;
				</td>
			</tr>
			<tr>
				<td width="21%" align="left" bordercolor="#C0C0C0"><b>
					Flatrate-Tarif</b>
				</td>
				<td width="14%" align="left" bordercolor="#C0C0C0">
					<p align="center"><b>Preis</b>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%"><b>
					&nbsp; Kaufen per</b>
				</td>
			</tr>
			<tr>
				<td width="21%" align="left" bordercolor="#C0C0C0">
					18 Monate <span class="small-text">($prize24[1] EUR pro Monat)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prize24[0] EUR
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">

				 <table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					
					 <td width="70" align="center">  
					<a href="$twentyfourMonthsFlatLastschriftURI" title="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per Lastschrift" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per Lastschrift" width="65" height="31" /></a>
					</td>

					 <td width="70" align="center">  
					<a href="$twentyfourMonthsFlatEbankURI" title="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per &Uuml;berweisung" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per &Uuml;berweisung" width="65" height="31" /></a>
					</td>
					
					 <td width="70" align="center">  
					<form method="post" action="https://www.paypal.com/cgi-bin/webscr" target="_blank">
						<input type="image" src="/images/button_anmeldung_paypal.jpg" width="65" height="31" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal">
						<input type="hidden" name="cmd" value="_xclick">
						<input type="hidden" name="return" value="http://www.bitjoe.de/login/">
						<input type="hidden" name="business" value="support@bitjoe.at">
						<input type="hidden" name="item_name" value="$paypal24[1]">
						<input type="hidden" name="item_number" value="$paypal24[0]">
						<input type="hidden" name="amount" value="$paypal24[2]">
						<input type="hidden" name="currency_code" value="EUR">
						<input type="hidden" name="bn"  value="ButtonFactory.PayPal.001">
					</form>
					</td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
				  </tr>  
				</table>


				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					12 Monate <span class="small-text">($prize12[1] EUR pro Monat)</span>
				</td> 
				<td align="right" bordercolor="#C0C0C0"><font face="Arial"> 
					$prize12[0] EUR</font></td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					
					 <td width="70" align="center">  
					<a href="$twelveMonthsFlatLastschriftURI" title="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per Lastschrift" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per Lastschrift" width="65" height="31" /></a>
					</td>

					 <td width="70" align="center">  
					<a href="$twelveMonthsFlatEbankURI" title="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per &Uuml;berweisung" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per &Uuml;berweisung" width="65" height="31" /></a>
					</td>

					 <td width="70" align="center">  
					<form method="post" action="https://www.paypal.com/cgi-bin/webscr" target="_blank">
						<input type="image" src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal">
						<input type="hidden" name="cmd" value="_xclick">
						<input type="hidden" name="return" value="http://www.bitjoe.de/login/">
						<input type="hidden" name="business" value="support@bitjoe.at">
						<input type="hidden" name="item_name" value="$paypal12[1]">
						<input type="hidden" name="item_number" value="$paypal12[0]">
						<input type="hidden" name="amount" value="$paypal12[2]">
						<input type="hidden" name="currency_code" value="EUR">
						<input type="hidden" name="bn"  value="ButtonFactory.PayPal.001">
					</form>
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					6 Monate <span class="small-text">($prize6[1] EUR pro Monat)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					<font face="Arial">$prize6[0] EUR</font>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr> 
					
					 <td width="70" align="center">  
					<a href="$sixMonthsFlatLastschriftURI" title="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per Lastschrift" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per Lastschrift" width="65" height="31" /></a>
					</td>

					 <td width="70" align="center">  
					<a href="$sixMonthsFlatEbankURI" title="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per &Uuml;berweisung" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per &Uuml;berweisung" width="65" height="31" /></a>
					</td>

					 <td width="70" align="center">  
					<form method="post" action="https://www.paypal.com/cgi-bin/webscr" target="_blank">
						<input type="image" src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal">
						<input type="hidden" name="cmd" value="_xclick">
						<input type="hidden" name="return" value="http://www.bitjoe.de/login/">
						<input type="hidden" name="business" value="support@bitjoe.at">
						<input type="hidden" name="item_name" value="$paypal6[1]">
						<input type="hidden" name="item_number" value="$paypal6[0]">
						<input type="hidden" name="amount" value="$paypal6[2]">
						<input type="hidden" name="currency_code" value="EUR">
						<input type="hidden" name="bn"  value="ButtonFactory.PayPal.001">
					</form>
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					1 Monat <span class="small-text"></span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prize3[0] EUR
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr> 
					
					 <td width="80" align="center">  
					<a href="$threeMonthsFlatLastschriftURI" title="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Lastschrift" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Lastschrift" width="65" height="31" /></a>
					</td>

					 <td width="80" align="center">  
					<a href="$threeMonthsFlatEbankURI" title="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per &Uuml;berweisung" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per &Uuml;berweisung" width="65" height="31" /></a>
					</td>

					 <td width="80" align="center">  
					<form method="post" action="https://www.paypal.com/cgi-bin/webscr" target="_blank">
						<input type="image" src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 1 Monat Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate mit Paypal">
						<input type="hidden" name="cmd" value="_xclick">
						<input type="hidden" name="return" value="http://www.bitjoe.de/login/">
						<input type="hidden" name="business" value="support@bitjoe.at">
						<input type="hidden" name="item_name" value="$paypal3[1]">
						<input type="hidden" name="item_number" value="$paypal3[0]">
						<input type="hidden" name="amount" value="$paypal3[2]">
						<input type="hidden" name="currency_code" value="EUR">
						<input type="hidden" name="bn"  value="ButtonFactory.PayPal.001">
					</form>
					</td>

					 <td width="80" align="center">  
					<a href="$threeMonthsFlatCall2PayURI" title="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Telefonanruf" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Telefonanruf" width="65" height="31" /></a>
					</td>

					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>

			<tr>
				<td align="left" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="right" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
				&nbsp;</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0"><b>
				Volumentarif</b></td>
				<td align="right" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="left" bordercolor="#C0C0C0" width="50%">
				&nbsp;</td>
			</tr>
		
			
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					$BUY_VOLUMENHANDY_SUCCESS Suchanfragen <span class="small-text">(bis zu $BUY_VOLUMENHANDY_SUCCESS_DOWNLOADS Downloads)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prizeHandy EUR 
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					 <td width="70" align="center">  
					
					<form method="post" action="https://www.paypal.com/cgi-bin/webscr" target="_blank">
						<input type="image" src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie den BitJoe.de Volumentarif Handy mit Paypal" alt="Bezahlen Sie den BitJoe.de Volumentarif Handy mit Paypal">
						<input type="hidden" name="cmd" value="_xclick">
						<input type="hidden" name="return" value="http://www.bitjoe.de/login/">
						<input type="hidden" name="business" value="support@bitjoe.at">
						<input type="hidden" name="item_name" value="$paypalHandy[1]">
						<input type="hidden" name="item_number" value="$paypalHandy[0]">
						<input type="hidden" name="amount" value="$paypalHandy[2]">
						<input type="hidden" name="currency_code" value="EUR">
						<input type="hidden" name="bn"  value="ButtonFactory.PayPal.001">
					</form>
					</td>

					 <td width="70" align="center">  
					<a href="$volumeHandySearchesCall2PayURI" title="Bezahlen Sie den BitJoe.de Volumentarif Handy per Telefonanruf" target="_blank" rel="nofollow"><img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie den BitJoe.de Volumentarif Handy per Telefonanruf" width="65" height="31" /></a>
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>

			</table>
	</td>
    <td width="14" height="124" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="19" valign="top">
	&nbsp;</td>
    <td width="14" height="19" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="131" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
			<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function TarifePage( $MobilePhone ){




function LoginFlatratePage( $phone, $date ){

	$tipdestages = readTipDesTages();

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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de - Willkommen</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">
		
		<table border="0" width="100%" height="139">
			<tr>
				<td width="244" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>
				<td align="left" height="83">
					<p align="right">
					<font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>	
			<tr>
				<td width="244" align="left">Tarif:</td>
				<td align="left">Flatrate</td>
			</tr>
			<tr>
				<td width="244" align="left">G&uuml;ltig bis:</td>
				<td align="left">$date ( <a href="/login/tarif.php">Flatrate 
				verl&auml;ngern</a> )</td>
			</tr>
		</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

    <td width="749" height="74" valign="top">
	<p align="left">
	
	<b class="tip">Tip des Tages:</b> $tipdestages </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
			<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function LoginFlatratePage( $phone, $date ){


function LoginPage( $land, $error, $number, $pin ){

	if ( strlen($land) > 1 && strlen($land) < 4 ){

		if ( strstr($land, "DE") ){
			$de = "selected";
		} elseif ( strstr($land, "CH") ){
			$ch = "selected";
		} elseif ( strstr($land, "AT") ){
			$at = "selected";
		} elseif ( strstr($land, "GB") ){
			$uk = "selected";
		} else {
			$na = "selected";
		};

	}; # if ( strlen($Checked) == 2 || strlen($Checked) == 3 ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Login</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="762">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe flatrate für handys und mobile phones" width="778" height="187"></td>
        </tr>
          <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="206" valign="top">
	<p align="left">
	<b>User Login</b><form method="POST" action="/login/">
		<table border="0" width="100%">
			<tr>
				<td width="127">Benutzername:</td>
				<td>
				<input type="text" name="mobilephone" value="$number" size="20"></td>
			</tr>
			<tr>
				<td width="127">PIN / Passwort:</td>
				<td>
				<input type="password" name="pin" value="$pin" size="20"></td>
			</tr>
			<tr>
				<td width="127">&nbsp;</td>
				<td><input type="submit" value="einloggen"></td>
			</tr>
		</table>
		<p align="left">&nbsp;</p>
		
		$error
		<br>
	</form>
	<p align="center">
	&nbsp;</td>
    <td width="14" height="206" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>

  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">	&nbsp;</td>
     <td width="14" valign="top" background="/images/shadow_left.gif" height="90">&nbsp;</td>
	<td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe mit 128 bit AES verschlüsselung" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function LoginPage( $land, $error, $number, $pin ){



function SignupPage( $phone, $SearchVolume ){

	$tipdestages = readTipDesTages();

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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />
	<title>BitJoe.de - Anmeldung zur BitJoe Handy Download Suche</title>

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
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="139" valign="top">
		
		<table border="0" width="100%" height="139">
			<tr>
				<td width="244" align="left" height="83"><b>
				&Uuml;bersicht f&uuml;r $phone </b></td>
				<td align="left" height="83">
					<p align="right">
					<font size="2">
					<a href="/login/tarif.php">Guthaben aufladen</a> 
					| <a href="/login/tellafriend.php">Weiterempfehlen</a> 
					| <a href="/login/usecoupon.php">Gutschein einl&ouml;sen</a> |
					<p></p>
					 <a href="/login/resendsoftware.php">Software zusenden</a>
					| <a href="/logout.php">logout</a></font>
				</td>
			</tr>
			<tr>
				<td width="244" align="left">Tarif:</td>
				<td align="left">Volumentarif (
				<a href="/login/tarif.php">zu Flatrate-Tarif wechseln</a> )</td>
			</tr>
			<tr>
				<td width="244" align="left">verbleibende 
				Suchanfragen:</td>
				<td align="left">$SearchVolume (
				<a href="/login/tarif.php">Guthaben aufladen</a> )</td>
			</tr>
			<tr>
				<td align="left" colspan="2">&nbsp;</td>
			</tr>
			</table>
	</td>
    <td width="14" height="139" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>

    <td width="749" height="74" valign="top">
	<p align="left">
	
	<b class="tip">Tip des Tages:</b> $tipdestages </td>

  <td width="14" height="74" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="130" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function SignupPage( $phone, $SearchVolume ){



function IndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, $ErrorMessage ){


/*
	$referingUrl	= referer url						- wird bestimmt über htmlspecialchars(urldecode($_SERVER["HTTP_REFERER"]));
	$refPP		= referer des partnerprogrammes				- dieser referer hat priorität gegenüber dem referer des users
	$refUID		= referer des users programmes ( user wirbt user )	- wird erst später eingebaut
	$land		= DE AT CH NA
	
	#	echo "you came from $referingUrl<br>";
	#	echo "your PP ref is $refPP<br>";
	#	echo "$de, $ch, $at, $na<br>";
*/

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
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	www.bitjoe.de
-->

<head>
	<meta http-equiv="Content-Language" content="de" />
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "Handy Download Suchmaschine BitJoe.de - lädt für dich MP3, Spiele, Videos und Bilder direkt aus dem Internet auf dein Handy." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de - Handy Download Suchmaschine</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="850" style="margin: 0px">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top" background="/images/header_top2.jpg" alt="Bitjoe - Deine Handy Download Flatrate Anbieter">

<center>
	<table border="0" width="191" cellspacing="1">
		<tr>
			<td height="27" valign="bottom" align="left" width="81" class="login">Benutzername</td>
			<td height="27" valign="bottom" align="left" width="50" class="login">Passwort</left></td>
			<td height="27" valign="bottom" align="left" width="50">&nbsp;</td>
		</tr>
		<tr>
		<form method="POST" action="/login/" name="vw">
			<td align="left" width="81">
				<input name="mobilephone" value="" class="login-input">
			</td>
			<td align="left" width="54">
				<input name="pin" value="" type="password" class="login-input2">
			</td>
		
			<td align="left" width="50">
				<input type="submit" value="Login" class="login-submit">
			</td>
		</form>
		</tr>
		<tr>
			<td align="left" width="81">&nbsp;</td>
			<td align="left" colspan="2" class="login">
				<a href="/password.php"><font color="#999999">Passwort vergessen</font></a>
			</td>
		</tr>
	</table>
        </center>
        </tr>
      <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="328" valign="top">
	<p align="center">

	<img border="0" src="/images/work1e3a.png" alt="Bitjoe Handy Download Flatrate - bis zu 60 Handy Downloads gratis mit der brandaktuellen Bitjoe Software" width="639" height="314" />
	</td>
    <td width="14" height="328" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr height="10">
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer" height="90">
	&nbsp;</td>
    <td width="749" valign="top" height="90">
	<center>
<a href="http://www.bitjoe.de/download/" rel="nofollow"><img border="0" src="/images/download.png" alt="Bitjoe Handy Download der Software" width="400" height="40" /></a>
	<br><br><font size="1">
alternativer Download: <a href="http://www.bitjoe.de/download/BitJoe.jad" target="_blank" rel="nofollow">jad</a> | <a href="http://www.bitjoe.de/download/BitJoe.jar" target="_blank" rel="nofollow">jar</a> | <a href="http://www.bitjoe.de/download/BitJoe.zip" target="_blank" rel="nofollow">zip</a>
</font></center>
	</td>
    <td width="14" valign="top" background="/images/shadow_left.gif" alt="spacer" height="90">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe.de mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe.de mit 128 bit AES verschl&uuml;sselung f&uuml;r deine gr&ouml;sstm&ouml;gliche sicherheit" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe.de durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe.de mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe.de ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" title="Hier kannst du dir die neueste Bitjoe.de Software zum kostenlosen testen besorgen" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" title="Hier erkl&auml;ren wir, wie genau BitJoe.de funktoniert" class="nav" rel="nofollow">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">&nbsp;</p>
	<p align="left" class="small-text">*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste kompatibeler Handys</a></p>
	<p align="right" class="small-text">
	<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support |
	<!--
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> | 
		-->
		<font size="1" ><a href="http://www.runterladen.de/download/24593.html" title="Handy MP3 Video Java Games Download" style="color: #808080">BitJoe auf runterladen.de</a></font> |
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="125" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

/*
	$refPP_isValid	= checkRefererPP( $refPP ); 				# functions.inc.php
	$grpPP_isValid	= checkRefererPP( $grpPP ); 


	if ( $refPP_isValid == 1 && $grpPP_isValid == 1 ){
	
		# http://localhost/ads/affiliate/affiliate.php?id=2&amp;group=1
		$BJ_PARIS_PP_URI_CODE 	= PP_TRACKING_URI ."?id=$refPP&group=$grpPP";
		$BJ_PARIS_PP_IMAGE_CODE = "<!-- This Link is Tracking the Leads from Referer $refPP and Campaign $grpPP--><img src=\"$BJ_PARIS_PP_URI_CODE\" height=\"1\" weight=\"1\" />";
		
	}; # if ( $refPP_isValid == 1 ){


	if ( strlen($land) > 1 && strlen($land) < 4 ){

		if ( strstr($land, "DE") ){
			$de = "selected";
		} elseif ( strstr($land, "CH") ){
			$ch = "selected";
		} elseif ( strstr($land, "AT") ){
			$at = "selected";
		} elseif ( strstr($land, "GB") ){
			$uk = "selected";
		} else {
			$na = "selected";
		};

	}; # if ( strlen($Checked) == 2 || strlen($Checked) == 3 ){


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de - Handy Download Suchmaschine</title>

</head>
<body style="margin:0px">
<div align="center">
<table width="778" border="0" cellpadding="0" cellspacing="0" height="850" style="margin: 0px">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="187" colspan="5" valign="top" background="/images/header_top2.jpg" alt="Bitjoe - Deine Handy Download Flatrate Anbieter">

<center>
	<table border="0" width="191" cellspacing="1">
		<tr>
			<td height="27" valign="bottom" align="left" width="81" class="login">Benutzername</td>
			<td height="27" valign="bottom" align="left" width="50" class="login">PIN</left></td>
			<td height="27" valign="bottom" align="left" width="50">&nbsp;</td>
		</tr>
		<tr>
		<form method="POST" action="/login/" name="vw">
			<td align="left" width="81">
				<input name="mobilephone" value="" class="login-input">
			</td>
			<td align="left" width="54">
				<input name="pin" value="" type="password" class="login-input2">
			</td>
		
			<td align="left" width="50">
				<input type="submit" value="Login" class="login-submit">
			</td>
		</form>
		</tr>
		<tr>
			<td align="left" width="81">&nbsp;</td>
			<td align="left" colspan="2" class="login">
				<a href="/password.php"><font color="#999999">PIN vergessen</font></a>
			</td>
		</tr>
	</table>
        </center>
        </tr>
      <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="328" valign="top">
	<p align="center">

	
	<img border="0" src="/images/work1e3.png" alt="Bitjoe Handy Download Flatrate - bis zu 60 Handy Downloads gratis mit der brandaktuellen Bitjoe Software" width="639" height="314"></td>
    <td width="14" height="328" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr height="10">
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer" height="90">
	&nbsp;</td>
    <td width="749" valign="top" height="90">
	<form method="POST" action="/signup.php">
		<center>Deine Benutzername: 
		<select size="1" name="prenumber">
			<option value="DE" disabled style="color:#666666;">Deutschland</option>
			<option value="0150" $na $de>0150</option>
			<option value="01505">01505</option>
			<option value="0151">0151</option>
			<option value="0152">0152</option>
	
			<option value="01520">01520</option>
			<option value="0155">0155</option>
			<option value="01550">01550</option>
			<option value="0157">0157</option>
			<option value="0159">0159</option>
			<option value="0160">0160</option>
	
			<option value="0161">0161</option>
			<option value="0162">0162</option>
			<option value="0163">0163</option>
			<option value="0169">0169</option>
			<option value="0170">0170</option>
			<option value="0171">0171</option>
	
			<option value="0172">0172</option>
			<option value="0173">0173</option>
			<option value="0174">0174</option>
			<option value="0175">0175</option>
			<option value="0176">0176</option>
			<option value="0177">0177</option>
	
			<option value="0178">0178</option>
			<option value="0179">0179</option>
			<option value="AT" disabled style="color:#666666;">&Ouml;sterreich</option>
			<option value="0650" $at>0650</option>
			<option value="0660">0660</option>
			<option value="0663">0663</option>
	
			<option value="0664">0664</option>
			<option value="0676">0676</option>
			<option value="0699">0699</option>
			<option value="CH" disabled style="color:#666666;">Schweiz</option>
			<option value="076" $ch>076</option>
			<option value="078">078</option>
	
			<option value="079">079</option>
		</select> 
		<input type="text" name="mobilephone" size="15"><p><br>
		<input type="submit" value="" class="newuser-submit">
		
		<!-- if you modifiy these values your leads are not tracked -->
		<input type="hidden" name="refURL" value="$referingUrl">
		<input type="hidden" name="refPP" value="$refPP">
		<input type="hidden" name="grpPP" value="$grpPP">

	</p>
	</form>

	<br>
	<a href="http://www.bitjoe.de/faq.html#_Toc198812473wpa1inet" target="_blank" rel="nofollow"><center style="FONT-SIZE: 12pt; COLOR: #ff0000; TEXT-ALIGN: center;"><b>WICHTIG:</b> WAP Internet wird auf dem Handy ben&ouml;tigt!</center></a>
	
	<br>
	<center style="FONT-SIZE: 10pt; COLOR: #000000; TEXT-ALIGN: center;">
	BitJoe ist eine Handy Software, die f&uuml;r Dich im Internet nach Mp3s, Klingelt&ouml;nen, Videos, Java Spielen und Bildern sucht.<br>
	<b>BitJoe findet und l&auml;dt f&uuml;r Dich aus dem Internet Dateien auf Dein Handy. </b> Du bestimmst, was Du herrunterladen willst.
	<br><br>
	</center>

	<center>$ErrorMessage<br></center>
	
	<font size="1" color="#666666">
	<!--	
		<b style="FONT-SIZE: 8pt; COLOR: #000000; TEXT-ALIGN: center;"><a href="http://www.bitjoe.de/faq.html#_Toc198812473wpa1inet" target="_blank" target="_blank">Deine Handy Internet Einstellungen bekommst du hier! </a></b><br> 
		<font size="2" color="#666666"><a href="http://www.nokia.de/A4421175" rel="nofollow" target="_blank">Interneteinstellung f&uuml;r Nokia Handy zusenden</a></font> | <br>
		<font size="2" color="#666666"><a href="http://www.sonyericsson.com/cws/support/phones/detailed/phonesetupwap?cc=de&lc=de" rel="nofollow" target="_blank">Interneteinstellung f&uuml;r Sony Ericsson Handy zusenden</a></font> | <br>
		<font size="2" color="#666666"><a href="https://hellomoto.wdsglobal.com/site/phonefirst?step=landing.vm&preferredPhoneName=&locale=&preferredCountryName=" rel="nofollow" target="_blank">Interneteinstellung f&uuml;r Motorola Handy zusenden</a></font> | <br>
		<font size="2" color="#666666"><a href="http://de.samsungmobile.com/supports/configurephone/wapSetting.do" rel="nofollow" target="_blank">Interneteinstellung f&uuml;r Samsung Handy zusenden</a></font> | <br>
	
		<a href="https://www.vodafone.de/jsp/Delegate?name=MTCS" rel="nofollow" target="_blank">Vodafone</a> |
		<a href="https://www.csp.t-mobile.net/rdm/?pt=TMDEUP" rel="nofollow" target="_blank">T-Online / D1</a> |
		<a href="http://www.eplus.de/dienste/13/13_3/13_3.asp" rel="nofollow" target="_blank">e-plus</a> |
		<a href="http://www.o2online.de/nw/support/mobilfunk/handy/settings/index.htmll?o2_type=goto&o2_label=einstellungen" rel="nofollow" target="_blank">O2</a> |
		<a href="http://www.orange.ch/vrtmobilephones/configure/?.portal_action=.changeLanguage&.portlet=configure&language=de" rel="nofollow" target="_blank"></a> |
		<a href="http://www.sunrise.ch/kundendienst/kun_produkteunddienste/handyeinrichten.html" rel="nofollow" target="_blank">sunrise</a> |
		<a href="http://www.swisscom-mobile.ch/scm/kd_mms_wap_email_internet_einrichten-de.aspx" rel="nofollow" target="_blank">swisscom</a> |
		<a href="http://www.tele2.ch/de/gprs-einstellungen-per-sms.html" rel="nofollow" target="_blank">Tele2</a> |
		<a href="http://www.a1.net/privat/handyinterneteinstellungen" rel="nofollow" target="_blank">A1</a> |
		<a href="http://www.drei.at/portal/de/privat/service/Service_Startseite.html" rel="nofollow" target="_blank">Drei</a> |
		<a href="http://www.one.at/" rel="nofollow">One</a> |
		<a href="http://www.telering.at/Content.Node/support/2674.php" rel="nofollow" target="_blank">Telering</a> |
	-->
	</center>
	<br><br>

	</td>
    <td width="14" valign="top" background="/images/shadow_left.gif" alt="spacer" height="90">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="80" valign="top" bordercolor="#666666">
	<table border="1" width="100%" style="border-collapse: collapse" bordercolor="#C90735">
		<tr>
			<td>
				<p align="center">
				<img border="0" src="/images/verisign.png" alt="bitjoe.de mit verisign signatur" width="105" height="68">
			</td>
			<td width="145">
				<p align="center">
				<img border="0" src="/images/aes.png" alt="bitjoe.de mit 128 bit AES verschl&uuml;sselung f&uuml;r deine gr&ouml;sstm&ouml;gliche sicherheit" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/onlinedurchs.png" alt="bitjoe.de durchsucht online nach deinen downloads" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/gzip.png" alt="bitjoe.de mit gzip kompression" width="105" height="68">
			</td>
			<td>
				<p align="center">
				<img border="0" src="/images/ueberall.png" alt="bitjoe.de ist weltweit einsetzbar" width="105" height="68">
			</td>
		</tr>
	</table>
	</td>
    <td width="14" height="80" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="125" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
				<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" title="Hier kannst du dir die neueste Bitjoe.de Software zum kostenlosen testen besorgen" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" title="Hier erkl&auml;ren wir, wie genau BitJoe.de funktoniert" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">&nbsp;</p>
	<p align="left" class="small-text">*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">

		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> | 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="125" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  </table>
</div>

$BJ_PARIS_PP_IMAGE_CODE

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

*/

return 1;

}; # function IndexPage( $referingUrl, $refPP, $grpPP, $refUID, $land, $ErrorMessage ){



function WebServiceAbusePage(){

	echo <<<END
	
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<!--
			All rights of the producer and of the owner of this work are reserved.
			UNAUTHORISED copying, hiring, lending, public performance and 
			broadcasting of this material is prohibited.

			Alle Urheber- und Leistungsschutzrechte vorbehalten. Kein Verleih! 
			Keine unerlaubte Vervielfaeltigung, Vermietung, Auffuehrung, Sendung!

			(C)opyright 2004, 2005, 2006, 2007, 2008
			
			www.bitjoe.de
		-->
	<head>
		<meta http-equiv="Content-Language" content="de" />
		<meta http-equiv="content-type" content="text/html; charset=utf8" />
		<meta name="robots" content= "INDEX,FOLLOW" />
		<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
		<meta name="abstract" content= "" />
		<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
		<meta name="author" content= "Swiss Refresh GmbH" />
		<meta name="publisher" content= "Swiss Refresh GmbH" />
		<meta name="page-topic" content= "Handy Download Flatrate" />
		<meta name="revisit-after" content= "7 days" />
		<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
		<link href="/images/favicon.ico" rel="SHORTCUT ICON" />
	</head>

	<body>
	Service Abuse Webpage
	<center><h2>Gesperrt bis 0 Uhr - weil du heute schon zu oft gesucht hast! Probleme an bigfish82@gmail.com berichten! Bannded until 0 o'clock because of too extensive use today. Report Errors to bigfish82@gmail.com !</h2></center>
	
	<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-4460139-1");
pageTracker._initData();
pageTracker._trackPageview();
</script>

	</body></html>

END;

return 1;

}; # function WebServiceAbusePage(){


function ScreenStep2( $MobilePhone, $error ){

$CaptchaID		= generateUniqueID();						# captcha id, die wir an unseren captcah server senden, diese id fragt er dann auf unserem server an
$CaptchaText	= GenerateCatpchaText();					# captcha text
$FilePath		= CAPTCHABITJOELOCALPATH .'/'. $CaptchaID .'.txt';	# in welcher datei speichern wir den captcha text
$CaptchaURI		= CAPTCHAURI . $CaptchaID;

# schreibe Datei
WriteFile( $FilePath, $CaptchaText );

# in der Session das korrekte Captcha speichern
session_start();
session_name("BITJOEPARIS");
$_SESSION['captcha'] = $CaptchaText;


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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />
	<title>BitJoe.de - Benutzername &uuml;berpr&uuml;fen</title>

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
			<td width="550">
				<span style="font-size: 8pt;">Du bist hier:</span> <b style="FONT-SIZE: 8pt; COLOR: #000000;"> <u>Benutzername &uuml;berpr&uuml;fen</u> </b> | <span style="FONT-SIZE: 8pt; COLOR: #a9a9a9;">Login | Interneteinstellungen</b> | Starten</span>
			</td>
		</tr>
		</table>

	<p>&nbsp;</p>
	<p>&nbsp;</p>
	
	<p align="center"><font color="#000000" size="2"><b>Bitte &uuml;berpr&uuml;fe Deine Benutzername!<br> Wenn diese nicht korrekt ist, k&ouml;nnen wir Dir die Handy Download Software nicht aufs Handy senden und Du kannst BitJoe nicht benutzen!</b></font></p>
	<br>



	<p align="center">
		
		<table border="1">
			
			<tr width="40%">
				<br>BitJoe Benutzername Pr&uuml;fung: <br>
				<img src="$CaptchaURI" alt="bitjoe captcha pr&uuml;fung" height="70" width="220" /><br>
				<br>
					<a href="javascript:top.location.reload();" title="Wenn Du Javascript deaktiviert hast, musst du den Button 'Neu Laden' in deinem Browser klicken.">Ich kann die Zeichen nicht erkennen - Seite neu laden!</a><br>
				<br>
			</tr>

			<tr width="80%">
				
				<td width="40%">
					<form method="POST" action="/checksettings.php">
								
						<b>Meine Benutzername ist richtig:</b><br><br>
						Deine Benutzername: <br>
						<input type="text" name="mobilephone" value="$MobilePhone" size="12" disabled> <br>
						
						<br>Gib hier die Zeichen aus dem Bild ein: <br>
						<input type="text" name="captcha" value="" title="Gib hier die Zeichen aus dem Bild ein" size="6">
						<br>
						<br>
						<input type="hidden" name="action" value="correctmobilephone">
						<input type="submit" value="Benutzername ist richtig!" title="Deine Benutzername ist korrekt.">

					</form>
				</td>
				<td width="40%">
					<form method="POST" action="/checksettings.php">
							
						<b>Meine Benutzername &auml;ndern:</b><br><br>
						Deine neue Benutzername: <br>
						<input type="text" name="mobilephone" value="$MobilePhone" size="12"> <br>
					
						<br>Gib hier die Zeichen aus dem Bild ein: <br>
						<input type="text" name="captcha" value="" title="Gib hier die Zeichen aus dem Bild ein" size="6">
						<br>
						<br>
						<input type="hidden" name="action" value="changemobilephone">
						<input type="submit" value="Benutzername &auml;ndern!" title="Beim Eintragen deiner Benutzername ist ein Fehler aufgetreten, &auml;ndere Sie.">

					</form>
				</td>

						<b style="FONT-SIZE: 8pt; COLOR: #ff0000;">$error</b>

			</tr>
			<tr width="80%">
				
			</tr>
		</table>

	</p>

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

}; # function ScreenStep2( $MobilePhone, $error  ){



function TarifePageSimple( ){

	# Prize
	$prize3								= Prize3();
	$prize6								= Prize6();
	$prize12							= Prize12();
	$prize24							= Prize24();
	$prizeLOW							= KOSTENVOLUMELOW;
	$prizeBIG							= KOSTENVOLUMEBIG;
	$prizeHandy							= KOSTENVOLUMEHANDY;
	$prizeFlatHandy						= KOSTENFLATHANDY;

	$BUY_VOLUMENHANDY_SUCCESS			= BUY_HANDYTARIF_1_SUCCESS;
	$BUY_VOLUMENHANDY_SUCCESS_DOWNLOADS	= BUY_HANDYTARIF_1_SUCCESS * DOWNLOADSOURCEMULTIPLY;

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
	<meta http-equiv="content-type" content="text/html; charset=utf8" />
	<meta name="robots" content= "INDEX,FOLLOW" />
	<meta name="description" content= "BitJoe ist eine Handy Software, die für Dich vom Handy aus im Internet nach Mp3s, Klingeltönen, Videos, Java Spielen und Dokumenten sucht und auf Dein Handy runterlädt. BitJoe findet und lädt für Dich aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst." />
	<meta name="abstract" content= "" />
	<meta name="keywords" content= "handy downloads, handy download flatrate, handy download suche, handy p2p, handy mp3, handy klingelton, handy video, handy java spiele" />
	<meta name="author" content= "Swiss Refresh GmbH" />
	<meta name="publisher" content= "Swiss Refresh GmbH" />
	<meta name="page-topic" content= "Handy Download Flatrate" />
	<meta name="revisit-after" content= "7 days" />
	<link href="/css/bitjoe.css" rel="stylesheet" type="text/css" />
	<link href="/images/favicon.ico" rel="SHORTCUT ICON" />

	<title>BitJoe.de Tarif upgraden und Flatrate kaufen</title>

</head>
<body style="margin:0px">
<div align="center">

<table width="778" border="0" cellpadding="0" cellspacing="0" height="772">
  <tr>
    <td height="227" colspan="3" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
 
           <tr>
        <td height="187" colspan="5" valign="top">
		<img border="0" src="/images/header_top2.jpg" alt="bitjoe handy flatrates" width="778" height="187"></td>
        </tr>
      <tr>
        <td width="420" height="40" valign="top"><img src="/images/header_left.jpg" alt="bitjoe flatrate" width="420" height="40" /></td>
          <td width="74" valign="top">
		<a href="http://www.bitjoe.de/anmeldung-pro-user/"><img src="/images/bestellen.png" alt="bitjoe bestellen" width="74" height="22" border="0" /></a>
	</td>
          <td width="131" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/funktioniert.html"><img src="/images/wie_funktionierts.png" alt="so funktioniert bitjoe" width="131" height="22" border="0" /></a>
	</td>
          <td width="72" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/software.html"><img src="/images/software.png" alt="bitjoe software download" width="72" height="22" border="0" /></a>
	  </td>
          <td width="81" valign="top">
		<a rel="nofollow" href="http://www.bitjoe.de/support.html" rel="nofollow"><img src="/images/support.png" alt="bitjoe Support" width="81" height="40" border="0" /></a>
	</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="124" valign="top">
		
		<table border="1" width="100%" height="139" style="border-collapse: collapse" bordercolor="#C0C0C0">
			<tr>
					
			<td width="34%" align="left" height="60" bordercolor="#C0C0C0">
					
				</td>
				<td align="left" height="60" bordercolor="#C0C0C0" colspan="2">
					<p align="right">
					
				</td>
			</tr>

			<tr>
				<td align="left" bordercolor="#C0C0C0" colspan="3">
					<i>Bitte melden Sie sich unter <a href="http://www.bitjoe.de/login/" title="handy downloads">BitJoe Login</a> an und erweitern dort Ihren Tarif.</i><p>&nbsp;
				</td>
			</tr>
			<tr>
				<td width="21%" align="left" bordercolor="#C0C0C0"><b>
					Flatrate-Tarif</b>
				</td>
				<td width="14%" align="left" bordercolor="#C0C0C0">
					<p align="center"><b>Preis</b>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%"><b>
					&nbsp; Kaufen per</b>
				</td>
			</tr>
			<tr>
				<td width="21%" align="left" bordercolor="#C0C0C0">
					18 Monate <span class="small-text">($prize24[1] EUR pro Monat)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prize24[0] EUR
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">

				 <table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					
					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>
					
					 <td width="70" align="center">  
					
						<img border="0" src="/images/button_anmeldung_paypal.jpg" width="65" height="31" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 18 Monats Flatrate mit Paypal" />
					
					</td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
				  </tr>  
				</table>


				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					12 Monate <span class="small-text">($prize12[1] EUR pro Monat)</span>
				</td> 
				<td align="right" bordercolor="#C0C0C0"><font face="Arial"> 
					$prize12[0] EUR</font></td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					
					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 12 Monats Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					
						<img border="0" src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" />
		
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					6 Monate <span class="small-text">($prize6[1] EUR pro Monat)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					<font face="Arial">$prize6[0] EUR</font>
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr> 
					
					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="70" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 6 Monats Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>

					 <td width="70" align="center">  

						<img src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 3 Monats Flatrate mit Paypal" />
						
					</form>
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					1 Monat <span class="small-text"></span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prize3[0] EUR
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr> 
					
					 <td width="80" align="center">  
					<img border="0" src="/images/button_anmeldung_lastschrift.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Lastschrift" width="65" height="31" />
					</td>

					 <td width="80" align="center">  
					<img border="0" src="/images/button_anmeldung_ebank.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per &Uuml;berweisung" width="65" height="31" />
					</td>

					 <td width="80" align="center">  

						<img src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie die BitJoe.de 1 Monat Flatrate mit Paypal" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate mit Paypal">
						
					</td>

					 <td width="80" align="center">  
						<img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie die BitJoe.de 1 Monat Flatrate per Telefonanruf" width="65" height="31" />
					</td>

					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>
					 <td width="80" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>

			

			<tr>
				<td align="left" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="right" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
				&nbsp;</td>
			</tr>
			<tr>
				<td align="left" bordercolor="#C0C0C0"><b>
				Volumentarif</b></td>
				<td align="right" bordercolor="#C0C0C0">&nbsp;</td>
				<td align="left" bordercolor="#C0C0C0" width="50%">
				&nbsp;</td>
			</tr>
			
				
			<tr>
				<td align="left" bordercolor="#C0C0C0">
					$BUY_VOLUMENHANDY_SUCCESS Suchanfragen <span class="small-text">(bis zu $BUY_VOLUMENHANDY_SUCCESS_DOWNLOADS Downloads)</span>
				</td>
				<td align="right" bordercolor="#C0C0C0">
					$prizeHandy EUR 
				</td>
				<td align="left" bordercolor="#C0C0C0" width="65%">
					
					<table border="0" width="100%" style="border-collapse: collapse">  
					<tr>  
					 <td width="70" align="center">  
					
				
						<img src="/images/button_anmeldung_paypal.jpg" border="0" name="submit" title="Bezahlen Sie den BitJoe.de Volumentarif Handy mit Paypal" alt="Bezahlen Sie den BitJoe.de Volumentarif Handy mit Paypal" />
					
					</td>

					 <td width="70" align="center">  
				<img border="0" src="/images/button_anmeldung_phone.jpg" alt="Bezahlen Sie den BitJoe.de Volumentarif Handy per Telefonanruf" width="65" height="31" />
					</td>

					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>
					 <td width="70" align="center">  </td>

				  </tr>  
				</table>

				</td>
			</tr>

			</table>
	</td>
    <td width="14" height="124" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="19" valign="top">
	&nbsp;</td>
    <td width="14" height="19" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
  </tr>
  <tr>
    <td width="15" valign="top" background="/images/shadow_right.gif" alt="spacer">
	&nbsp;</td>
    <td width="749" height="131" valign="top">
	<p align="left">
		&nbsp;</p>
	<table border="1" width="100%" style="border-collapse: collapse;" height="20" class="nav">
		<tr>
			<td width="110">Navigation:</td>
			<td width="110" align="center">
			<a href="http://www.bitjoe.de/" class="nav" title="Handy Download Suche - BitJoe findet und lädt für Dich vom Handy aus dem Internet Dateien auf Dein Handy. Du bestimmst, was Du herrunterladen willst">Home</a>
			</td>
			<td width="110" align="center">
				<a href="/login/" class="nav">User-Login</a>
			</td>
			<td align="center" width="110">
				<a href="http://www.bitjoe.de/faq.html" class="nav">FAQ</a>
			</td>
			<td width="110">
			<p align="center">
				<a href="http://www.bitjoe.de/support.html" rel="nofollow" class="nav">Support</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/software.html" class="nav">Software</a>
			</td>
			<td width="110">
				<p align="center">
				<a href="http://www.bitjoe.de/funktioniert.html" class="nav">Wie funktioniert's?</a>
			</td>
		</tr>
	</table>
	<p align="left" class="small-text">
	&nbsp;</p>
	<p align="left" class="small-text">
	*) zuz&uuml;gl. Transport - <a href="/liste.html" rel="nofollow">Liste Kompatibeler Handys</a></p>
	<p align="right" class="small-text">
		<img src="http://status.icq.com/26/online1.gif" rel="nofollow"/> ICQ Support <b>459793094</b> |
		<a href="http://www.bitjoepartner.com/" target="_blank" class="small-text">Partnerprogramm</a> 
		| 
		<a rel="nofollow" href="http://www.bitjoe.de/impressum.html" class="small-text">Impressum</a> |
		<a rel="nofollow" href="http://www.bitjoe.de/AGB" class="small-text">AGB</a></p></td>
    <td width="14" height="130" valign="top" background="/images/shadow_left.gif" alt="spacer">&nbsp;</td>
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

}; # function TarifePageSimple( ){



?>