<?php

header("Content-type: text/html");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: public");  // HTTP/1.1
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: use-cache"); 

# http://www.bitjoe.de/service_agb/service_agb.php?email=thecerial@gmail.com&bj_auth=e62526bcf84865dac863350c121e8f88

# /var/spool/mqueue
require_once("/srv/server/wwwroot/lib/config.inc.php");
require_once("/srv/server/wwwroot/lib/logging.inc.php");
require_once("/srv/server/wwwroot/lib/phpmailer.inc.php");


### Sicherheitscheck
$PerlApiAuthKey 	= $_REQUEST["bj_auth"];
$MailTo 			= $_REQUEST["email"];


###echo "'$PerlApiAuthKey' und ORG: '".BITJOEPERLAPIACCESSKEY."'<br>";

if ( $PerlApiAuthKey != BITJOEPERLAPIACCESSKEY ) {
#	echo "";	# bei der finalen version gar nichts ausgeben
	exit(0);
}; # if ( strcmp($USEDCOUPON , $couponcode) == 0 ) {



$mail = new phpmailer();
$mail->From				= "support@swissrefresh.ch";
$mail->FromName			= "BitJoe.de";
$mail->Host				= "";
$mail->Mailer			= "mail";
$mail->Helo				= "localhost";
$mail->Subject			= "BitJoe.de - AGBs";
$mail->SMTPAuth			= false;
$mail->Username			= "";
$mail->Password			= "";
$mail->ContentType		=  "text/plain";
$mail->IsHTML			= 1;
$mail->IsSendmail		= 1;
$mail->Sendmail			=  "/usr/sbin/sendmail";
$mail->AddAddress($MailTo , "");
$mail->Body				= getAGB();
$mail->Send();			# mail absenden
$mail->ClearAddresses();
$mail->ClearAttachments();

LogAGBRequest( $MailTo );
exit(0);



function getAGB(){

$Agb =<<< END
Allgemeine Gesch�ftsbedingungen

1.	Vertragsgegenstand
1.1	Die nachfolgenden Bedingungen beschreiben die Nutzungs-bedingungen der von swiss refresh GmbH zur Verf�gung gestellten Software. Durch die Aufnahme der Benutzung der Software anerkennt der Nutzer diese AGB und sie werden zum Vertragsinhalt zwischen Nutzer und swiss refresh GmbH.
1.2	Diese AGB k�nnen jederzeit von swiss refresh GmbH ge�ndert werden. �nderungen werden dem Nutzer jeweils zwei Wochen vor Inkrafttreten auf das Handy per SMS mitgeteilt. Ist der Nutzer mit den �nderungen nicht einverstanden, so kann er den Vertrag mit swiss refresh GmbH k�ndigen und erh�lt allenfalls bezahlte Geb�hren anteilsm�ssig zur�ck.
1.3	swiss refresh GmbH ist berechtigt Leistungen durch Dritte erbringen zu lassen.
2.	Bereitstellen der Software / Nutzung
2.1	swiss refresh GmbH stellt dem Nutzer die Software nach Eingabe eines von swiss refresh GmbH dem Nutzer ausgestellten PIN zur pers�nlichen Nutzung und zum privaten Gebrauch auf seinem Handy zur Verf�gung. Der Nutzer legitimiert sich f�r die Nutzung der Software jeweils durch Handy-Nummer und PIN. 
2.2	Jeder Nutzer kann monatlich h�chstens 1000 Suchabfragen durchf�hren.
2.3	Der Nutzer verpflichtet sich mit der Software gefundene Dateien nicht zu laden, wenn  er weiss oder annehmen muss, dass diese Dateien un�recht���m�ssig angeboten werden. swiss refresh GmbH bietet nur einen Suchdienst an und stellt selber keine Dateien f�r den download auf das Handy bereit. swiss refresh GmbH hat keinen Einfluss und keine M�glichkeit der �berwachung der durch die Abfrage gefundenen Datei-Inhalte. 
2.4	swiss refresh GmbH �bernimmt keine Haftung f�r die Aktualit�t, Vollst�ndigkeit oder Richtigkeit �bermittelter Software und Dateien, ihre zeitnahe und fehlerfreie technische �bermittlung oder die Lauff�higkeit von Software und Dateien auf dem Handy des Nutzers.
3.	Geb�hren
3.1	Jede Suchabfrage (Abfrage) �ber die Software ist geb�hrenpflichtig. Vorbehalten ist Ziff. 3.4 hiernach. Die Geb�hren pro Abfrage sind vom gew�hlten Tarifmodel abh�ngig (Per Abfrage �ber Mehrwertdienste; Flatratevariante mit fester Laufzeit unabh�ngig von der Nutzung) und werden dem Nutzer im Voraus belastet.  Sie sind einsehbar in der Seite www.bitjoe.de/tarif. Eine Einzel-Abfrage kostet maximal � 0,99. Die Kosten des Mobilfunkanbieters f�r den Zugang zum Internet fallen zus�tzlich an.
3.2	Die Bezahlung erfolgt entweder �ber das Internet unter der Adresse www.bitjoe.de/login/tarif.php f�r alle Tarifmodelle oder �ber das Handy f�r das Tarifmodel Geb�hr per Abfrage �ber Mehrwertdienste.
3.3	Zur Erhebung der Geb�hren werden Drittanbieter wie PayPal oder Mehrwertdienste in Anspruch genommen. Je nach Art der Tarifvariante sind die Bedingungen der jeweiligen Dritten f�r die Zahlung anwendbar. Die Wahl der Tarifvariante und der Zahlungsart erfolgt sp�testens bei der ersten kostenpflichtigen Abfrage. swiss refresh GmbH hat keinen Zugang zu den pers�nlichen Daten, welche bei diesen Drittanbietern vom Nutzer erhoben werden.
3.4	Die ersten vier Abfragen mit gesamthaft bis zu 60 Suchresultaten sind gratis. 
4.	Personendaten
4.1	swiss refresh GmbH erhebt keine Personendaten sondern verwaltet das Verh�ltnis zum Benutzer ausschliesslich �ber die Handy-Nummer und den PIN des Benutzers.
4.2	Die Abfragen werden nur zu statistischen Zwecken und zur Verbesserung der Suchresultate ohne Verbindung zum anfragenden Benutzer registriert.
5.	Haftungsbeschr�nkung
5.1	swiss refresh GmbH haftet gleich aus welchem Rechtsgrund nur f�r Vorsatz und grobe Fahrl�ssigkeit. Im Falle der Verletzung wesentlicher Vertragspflichten haftet swiss refresh GmbH jedoch f�r jedes schuldhafte Verhalten seiner Mitarbeiter und Erf�llungsgehilfen. Soweit zul�ssig ist die Haftung von swiss refresh GmbH der H�he nach auf die bei Vertragsschluss typischerweise vorhersehbaren Sch�den begrenzt.
5.2	swiss refresh GmbH bearbeitet die Abfragen unter Einbezug von Systemen Dritter und �bernimmt keine Haftung f�r die st�ndige Verf�gbarkeit der Dienste. Bei vor�bergehendem Ausfall des Systems besteht kein Anspruch auf R�ckverg�tung bezahlter Geb�hren.
5.3	swiss refresh GmbH verweist in den Suchresultaten via Hyperlinks auf andere Seiten oder Dateien Dritter, auf deren Inhalt und Gestaltung swiss refresh GmbH keinen Einfluss hat. Diese Hyperlinks sind lediglich eine Zugangsvermittlung zu fremden Inhalten oder Produkten. F�r Form und Inhalt dieser verlinkten Seiten/Dateien �bernimmt swiss refresh GmbH keine Haftung. Sofern swiss refresh GmbH Kenntnis davon erh�lt, dass solche Seiten/Dateien dem geltenden Recht widersprechen, wird swiss refresh GmbH nach Pr�fung der Sachlage den entsprechenden Hyperlink entfernen bzw. nicht mehr vermitteln.
6.	Dauer und Beendigung 
6.1	Der Vertrag gilt f�r die vom Nutzer gew�hlte Dauer oder Anzahl Abfragen und endet danach automatisch.
6.2	Eine K�ndigung aus wichtigem Grund bleibt vorbehalten.
7.	Salvatorische Klausel
7.1	Sofern einzelne Klauseln dieser AGB ganz oder teilweise unwirksam sein sollten, bleibt die Wirksamkeit der �brigen Nutzungsbedingungen hiervon unber�hrt. Die unwirksame Bestimmung soll durch eine solche ersetzt werden, welche dem Sinn und Zweck der unwirksamen Bestimmung in rechtswirksamer Weise wirtschaftlich am n�chsten kommt. 
7.2	 Sollten Sie zu den Nutzungsbedingungen Fragen haben, wenden Sie sich bitte 
7.2.1	Per E-Mail an: infos@swissrefresh.ch
7.2.2	 per Post an:
swiss refresh GmbH
Moserstr. 48
1800 Schaffhausen
Switzerland
Handelsregister-Nr.: CH-290.4.016.165-3.

8.	Widerrufsbelehrung
8.1	Der Nutzer kann den Vertragsschluss innerhalb von zwei Wochen ohne Angabe von Gr�nden in Textform (z.B. Brief, E-Mail) widerrufen. Die Frist beginnt mit dieser Belehrung. Zur Wahrung der Frist gen�gt die rechtzeitige Absendung des Widerrufs an: 

widerruf@swissrefresh.ch
oder per Post an:
swiss refresh GmbH
Moserstr. 48
1800 Schaffhausen
Switzerland

8.2	Das Widerrufsrecht f�llt dahin, wenn der Nutzer die Leistungen von swiss refresh GmbH durch das Zusenden von Abfragen  in Anspruch genommen hat.
8.3	Im Falle des rechtswirksamen Widerrufs wird eine bereits belastete Geb�hr dem Nutzer gutgeschrieben. 
9.	Anwendbares Recht Gerichtsstand
9.1	Auf diesen Vertrag ist soweit eine Rechtswahl zul�ssig ist ausschliesslich Schweizer Recht anwendbar.
9.2	Die Parteien vereinbaren die Gerichte am Sitz von swiss refresh GmbH als Gerichtsstand.

END;

return $Agb;

}; # function getAGB(){


?>