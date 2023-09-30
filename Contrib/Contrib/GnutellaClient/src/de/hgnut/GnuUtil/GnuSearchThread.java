package de.hgnut.GnuUtil;
/*
SearchThread kann folgendes:
1. erzeugt GnuSearchConnection Objecte für jeden übergebenen UltraPeer
2. Überwacht diese Connections, filtert Hits und legt diese in einem public static Container ab
3. Muss destroy unterstützen, um ordentlich beendet werden zu können.
	Destroy bedeutet destroy! Alle Connenctions kappen und bis auf die bereits gefilterten Hits alles verwerfen
7. Muss einen Listener für jede Connection haben, kann nicht selber 1 < Connections überwachen-> weiteres Thread-Object
*/
public class GnuSearchThread extends Thread{
	public GnuSearchThread(
	//Parameter1: Liste von UltraPeers >3 <6
	//Parameter2: Suchquery (wenn möglich schon in Gnutella-style)
	//Parameter3: MaxTreffer
	//Parameter4: zusätzliche Filter, die das Gnu-Protokoll nicht unterstüzt, wir aber anbieten wollen
	){
		/*hier werden GnuSearchConnection-Objects erzeugt, die dan mit run() auf die Reise gechickt werde*/
	}
	
	//extends Thread, muss run übeschreiben
	public void run(){
		/*
		for each UltraPeer start Connection
		*/
	}
	
	//zerstört den Thread
	public void destroy(){
		//aufräumen und dann		
	}
	
	
}