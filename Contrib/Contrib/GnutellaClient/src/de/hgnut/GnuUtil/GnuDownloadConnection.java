/*
GnuDownloadConnection 
kann:
	1. Verdindung zu einem UltraPeer aufnehmen und File Request absetzen
	2. Verbindung offen halten (auf Pings antworten, selber Pingen)  macht GnuConnection BasisKlasse
	3. Daten entgegen nehmen und speichern
Benötigt:
	1. Vorgefertigte Message-Objecte für
		1.1 Ping (erzeugung und lesen)
		1.2 Pong (erzeugung und lesen)
		1.3 Filerequest
*/
package de.hgnu.GnuUtil;
public class GnuDownloadConnection extends de.hgnut.GnuUtil.GnuConnection{	
	public GnuDownloadConnection(
	//Parameter 1: IP
	//Parameter 2: Port
	//Parameter 3: File to download
	){}
}