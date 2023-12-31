package de.hgnut;

import javax.microedition.io.*;
import javax.microedition.lcdui.*;
import java.io.*;
import java.util.*;
import javax.microedition.lcdui.Gauge;
import javax.microedition.midlet.*;
import de.hgnut.GnuUtil.*;
import de.hgnut.GnuUtil.Messages.*;
import de.hgnut.Misc.*;

public class Main extends MIDlet implements Runnable, CommandListener{
/*****************************************************************/	
	public static String myipaddress;
	public static int myport;
/*****************************************************************/	
	private Command exitCommand  = new Command("EXIT", Command.EXIT, 2);
	private Command okCommand = new Command("OK", Command.OK, 1);
	private Command cancelCommand = new Command("CANCEL", Command.CANCEL, 1);
	private Command currentCommand;
	private TextBox searcht;
	private Thread commandThread;
	private Display display;
	private static GnuConnection con;
/*****************************************************************/	
	//implements MIDlet
	protected void startApp() throws MIDletStateChangeException{	 	
		try{
		//	ProxySearchConnection con = new ProxySearchConnection("85.214.59.105",3381,"test `innerhalb�");
		//	con.start();
//zoozle UltraPeer
//85.214.59.105:8080
			con = new GnuConnection("127.0.0.1",37098,GnuConnection.SEARCH);
			con.start();			
			display = Display.getDisplay(this);
			String s ="etwas";
			searcht = new TextBox("Handy Tool - Suchbegriff Eingabe", s, 200, 0);
			searcht.addCommand(exitCommand);
			searcht.addCommand(okCommand);
		        searcht.setCommandListener(this);
		        display.setCurrent(searcht);
		}catch(Exception e){
			e.printStackTrace();
		}
	}
/*****************************************************************/
	public void destroyApp(boolean unconditional){
	}
/*****************************************************************/
	public void pauseApp(){}
/*****************************************************************/
//implements Runnable
        public void run(){
        try{
        	//Nicht vergessen aufr�umarbeiten durchzuf�hren!!!
        	//Ergebnislisten verwerfen usw. wenn cancel oder exit command kommt
        	if (currentCommand == exitCommand) {
       		//Aus und vorbei der User hat mich nicht mehr lieb :-(
            		destroyApp(false);
 	           	notifyDestroyed();
        	} else if (currentCommand == okCommand) {
        		String tosearch = searcht.getString();
       			SearchMessage smsg = new SearchMessage(tosearch, SearchMessage.GET_BY_NAME,0);
       			con.send(smsg);
       			while(con.HitMessages.size()<1){}//Warte auf Treffer, nicht sehr elegant aber es tut es ertmal}
       			SearchReplyMessage sr = (SearchReplyMessage)con.HitMessages.elementAt(0);
       			con.stop();

       			//und einen download starten mit der erhaltenen ReplyMessage       			
       			con = new GnuConnection(sr);
       			con.start();
       			while(con.statusdownload==false){}
				
       			//String file, byte[] content, boolean overwrite
       			String filename = con.filename;
       			System.out.println(filename);
       			FileBrowser.writeFile(filename,con.file,true);
       			con.stop();
       			destroyApp(false);
       			notifyDestroyed();

 	       	}else if (currentCommand == cancelCommand) {
 	       		destroyApp(false);
 	           	notifyDestroyed();
        	}
	        synchronized (this) {
            	// signal that another command can be processed
	        	commandThread = null;
        	}
        }catch(Exception e){
			System.out.println("Main.run()");
        	e.printStackTrace();
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
/*****************************************************************/
}