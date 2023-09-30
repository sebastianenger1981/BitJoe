package de.hgnut.GnuUtil;
/*
SearchThread kann folgendes:
1. erzeugt GnuSearchConnection Objecte f�r jeden �bergebenen UltraPeer
2. �berwacht diese Connections, filtert Hits und legt diese in einem public static Container ab
3. Muss destroy unterst�tzen, um ordentlich beendet werden zu k�nnen.
	Destroy bedeutet destroy! Alle Connenctions kappen und bis auf die bereits gefilterten Hits alles verwerfen
7. Muss einen Listener f�r jede Connection haben, kann nicht selber 1 < Connections �berwachen-> weiteres Thread-Object
*/
public class GnuSearchThread extends Thread{
	public GnuSearchThread(
	//Parameter1: Liste von UltraPeers >3 <6
	//Parameter2: Suchquery (wenn m�glich schon in Gnutella-style)
	//Parameter3: MaxTreffer
	//Parameter4: zus�tzliche Filter, die das Gnu-Protokoll nicht unterst�zt, wir aber anbieten wollen
	){
		/*hier werden GnuSearchConnection-Objects erzeugt, die dan mit run() auf die Reise gechickt werde*/
	}
	
	//extends Thread, muss run �beschreiben
	public void run(){
		/*
		for each UltraPeer start Connection
		*/
	}
	
	//zerst�rt den Thread
	public void destroy(){
		//aufr�umen und dann		
	}
	
	
}