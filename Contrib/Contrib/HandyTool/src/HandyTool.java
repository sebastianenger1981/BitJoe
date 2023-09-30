/*************************************************************************************/	
import javax.microedition.midlet.*;
import javax.microedition.io.*;
import javax.microedition.lcdui.*;
import java.io.*;
import java.util.*;
import javax.microedition.lcdui.Gauge;

//Zumindest Beta-Status haben erreicht FileBrowser, History und PropManager
//Alles andere ist noch reine Baustelle
//Ich überlege noch, wie ich das abspeichern der datein regel
//wenn ich den DownloadThred ertmal alles in einem Byte[] sammeln lasse und dieses dann
//abspeichere, kann ich zumindst sicher sein, dass die Datei komplett angekommen ist.
//Wenn ich dem DownloadThead aber selber die Kontrolle über den FileBrowser gebe, kann er
//Ohne Zwischenspeichern alles direkt wegschreiben.
//Wenns dann aber kanllt, knallt es richtig-> Korrupte Dateien
/*************************************************************************************/	
public class HandyTool extends MIDlet implements Runnable, CommandListener{
/*************************************************************************************/	
	private Command exitCommand  = new Command("EXIT", Command.EXIT, 2);
	private Command okCommand = new Command("OK", Command.OK, 1);
	private Command cancelCommand = new Command("CANCEL", Command.CANCEL, 1);
	private Command currentCommand;
	private Thread commandThread;

	private String searchString;	
    	private Display display;
	private TextBox searcht;
	private TextBox statust;
	private StringItem msgt;
	private List list;
	private Vector hits;
	
	//Nicht gerade elegant, aber zumndest rudimentär tut es das.
	//Es wäre aber besser alle
	//0=anfang; 1= searchScreen; 2 = Listscreen; 3 = StatusScreen; 4 = MsgScreen
	private int status 	= 0; 	
	private int laststatus 	= 0;
	private int nextStatus 	= 0;	
/*************************************************************************************/	
	public HandyTool(){
		//Hole mir Referenz auf das Handydisplay
	        display = Display.getDisplay(this);
	}
/*************************************************************************************/
	//implements MIDlet
	protected void startApp() throws MIDletStateChangeException{		
	try{
		Server.start();
		Client.start();
	}catch(Exception e){
		e.printStackTrace();
	}
		/*
			History TestCode			
		*/
		/*
		Vector vec = History.load();		
		if(vec!=null)
		for(int i=0;i<vec.size();i++){
			System.out.println(i+" "+vec.elementAt(i));
		}
		vec = new Vector();
		vec.addElement("vergagenheit");
		vec.addElement("steinzeit");
		vec.addElement("mythos");
		vec.addElement("daran glaubt keine mehr");
		History.save(vec);
		*/
		/*
			PropManager TestCode
		*/
		
		//PropManager.load();
		//System.out.println("HTM "+PropManager.getProperty("MusikDir"));;
        	//System.out.println("HTM "+PropManager.getProperty("VideoDir"));
        	//PropManager.setProperty("MusikDir","device/blabla");
        	//PropManager.setProperty("VideoDir","device/blablamitbild");
        	//PropManager.save();
        	
        	
        	/*
        		Eigentlicher Start
        	*/
		//searchScreen();
	}
/*************************************************************************************/
        //implements MIDlet
        protected void pauseApp(){
       	}
/*************************************************************************************/	
	//implements MIDlet
        protected void destroyApp(boolean unconditional){
        	Server.stop();
        	Client.stop();
        	//PropManager zertören
        }
/*************************************************************************************/	
	//implements Runnable
        public void run(){        	
        	//Nicht vergessen aufräumarbeiten durchzuführen!!!
        	//Ergebnislisten verwerfen usw. wenn cancel oder exit command kommt
        	if (currentCommand == exitCommand) {
       		//Aus und vorbei der User hat mich nicht mehr lieb :-(
            		destroyApp(false);
 	           	notifyDestroyed();
        	} else if (currentCommand == okCommand) {
       		//muss neue Suche Screen starten
			switch(status){
				case 0: break;
				case 1:	//Searchscreen -> Statusscreen -> Listscreen
					//serhString abfragen und merken
					searchString = searcht.getString();
					nextStatus = 2;
					statusScreen();
					break;
				case 2:	//Listscreen -> Statusscreen -> MsgScreen
					nextStatus = 1;
					statusScreen();
					break;
				case 3:	// Statusscreen -> listscreen (bei suche) / msgscreen (bei download)
					break;
				case 4:	//msgscreen -> lastscreen / Mainscreen (nach download)
					switch(nextStatus){
						case 0:
							break;
						case 1:	searchScreen();
							break;
						case 2:	listScreen();
							break;
						case 3:	statusScreen(); //macht wenig sinn auf sich selbst zurückzuspringen?!?!?
							break;
						case 4:	nextStatus = 1;
							msgScreen("Download beendet");
							break;
						}
					break;					
				default://Fehlerfall
					break;
			}
 	       	}else if (currentCommand == cancelCommand) {
       		//abbruch der aktuellen aktion und zurück zum Mainscreen !!immer!!
            		searchScreen();
        	}
	        synchronized (this) {
            	// signal that another command can be processed
	        	commandThread = null;
        	}
       	}
/*************************************************************************************/	
	//implements CommandListener
	public void commandAction(Command c, Displayable d){
		synchronized (this) {
			if (commandThread != null) {
                		// process only one command at a time
                		return;
		   	}
            		currentCommand = c;
            		commandThread = new Thread(this);
            		commandThread.start();
            	}		
	}
/*************************************************************************************/
	//Baut Suchscreen auf
	void searchScreen(){
		laststatus=status;
		status = 1;
		String s ="";
		//wenn noch alter suchbegriff vorhanden dann vorbelegen
		if(searchString!=null&&searchString.trim().length()>0){
			s = searchString;
		}
	        searcht = new TextBox("Handy Tool - Suchbegriff Eingabe", s, 200, 0);
		searcht.addCommand(exitCommand);
		searcht.addCommand(okCommand);
	        searcht.setCommandListener(this);
	        display.setCurrent(searcht);
	}
/*************************************************************************************/
	//Baut Listenscreen auf
	void listScreen(){
		laststatus=status;		
		status = 2;
		
	        list = new List("HandyTool - Suchergebnis für \""+searchString+"\"", Choice.EXCLUSIVE);
	        for (int i = 0; i < hits.size(); i++) {
            		list.append((String)hits.elementAt(i), null);
		}

		list.addCommand(exitCommand);
		list.addCommand(okCommand);
	        list.setCommandListener(this);
		display.setCurrent(list);
	}
/*************************************************************************************/
	//Baut Statusscreen auf kann nur cancel & exit
	void statusScreen(){
		laststatus=status;
		status = 3;
		Form form = new Form("HandyTool - Statusbildschirm");
		form.addCommand(exitCommand);
		form.addCommand(cancelCommand);
	        form.setCommandListener(this);
		if(laststatus==1){//kommt von der suchmaske und soll Suche durchführen
			Gauge gauge = new Gauge("Suche", false, -1, 0);
			form.append(gauge);	       		
	        	display.setCurrent(form);
			SearchThread st = new SearchThread(searchString, gauge);
			new Thread(st).start();
			while(st.isRunning()){					
				//Frage? Wie regel ich das timeout? s.oben				
			}
			hits = st.hits;
			listScreen();
		}else if(laststatus==2){//kommt von Liste zeigt download
			Gauge gauge = new Gauge("Download", false, 100, 0);
	       		form.append(gauge);
	        	display.setCurrent(form);
			//DownloadThread dt = new DownloadThread(null , gauge);
			//new Thread(dt).start();
			//while(dt.isRunning()){
				//Frage? Wie regel ich das timeout? s.oben
			//}
			msgScreen("Download erfolgreich beendet");
		}else{
			//Dazu sollte es nie kommen. Wäre nicht gut für die Logik
			Gauge gauge = new Gauge("Fehler",false,100,0);
		}
	}
/*************************************************************************************/
	//Baut Meldungsscreen kann nur ok
	void msgScreen(String msg){
		laststatus=status;		
		status = 4;
		Form form = new Form("Handy Tool - Meldung");
	        msgt = new StringItem(msg, "");
		form.addCommand(okCommand);
	        form.setCommandListener(this);	        
	        form.append(msgt);
	        display.setCurrent(form);
	}
/*************************************************************************************/
}