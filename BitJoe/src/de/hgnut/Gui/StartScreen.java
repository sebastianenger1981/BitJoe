package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
/*******************************************/
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;
//++++++++++++++++++++++++++++++++++++++++++
public class StartScreen  extends List implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
	
	//private Image search_m;
	//private Image config_m;
	private Image movie_ico_m;
	private Image bilder_ico_m;
	private Image ring_ico_m;
	private Image mp3_ico_m;
	private Image java_ico_m;
	private Image doc_ico_m;
	private Ticker ticker;
/*******************************************/
	public StartScreen(GuiActionListener listener){
		super("BitJoe's Einstellungen",List.IMPLICIT);
		this.listener = listener;
		//list = new List("BitJoe", Choice.IMPLICIT);
		getImages();
		ticker = new Ticker("Hier kannst Du Dateitypen ausw\u00E4hlen.");
		this.setTicker(ticker);
		if(Constant.ALLOWED_FILE_FAMILYS[3])
			this.append("MP3's/Klingelton",mp3_ico_m);
		else
			this.append("MP3's/Klingelton N/A",mp3_ico_m);
		if(Constant.ALLOWED_FILE_FAMILYS[1])	
			this.append("Bilder/Logos",bilder_ico_m);
		else
			this.append("Bilder/Logos N/A",bilder_ico_m);
		//if(Constant.ALLOWED_FILE_FAMILYS[2])	
		//	this.append("Klingelt\u00F6ne",ring_ico_m);
		//else
		//	this.append("Klingelt\u00F6ne N/A",ring_ico_m);
		
		if(Constant.ALLOWED_FILE_FAMILYS[4])
			this.append("Java Games",java_ico_m);
		else
			this.append("Java Games N/A",java_ico_m);
		if(Constant.ALLOWED_FILE_FAMILYS[0])
			this.append("Videos",movie_ico_m);
		else
			this.append("Videos N/A",movie_ico_m);	
		if(Constant.ALLOWED_FILE_FAMILYS[5])
			this.append("Dokumente", doc_ico_m);
		else
			this.append("Dokumente N/A",doc_ico_m);
		
		this.addCommand(Constant.cancelCommand);
		//this.addCommand(Constant.exitCommand);
		//this.addCommand(Constant.okCommand);
	        this.setCommandListener(this);	    
	}
/*******************************************/
	public void run(){
		if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand && currentCommand != Constant.cancelCommand){
		   currentCommand = Constant.okCommand;
		}
		if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));
			
		}else if (currentCommand == Constant.cancelCommand){
			this.setSelectedIndex(0,true);
			listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,0,currentCommand));			
        	}else if (currentCommand == Constant.okCommand){
	       		//was wurde gewählt
	       		//String action;
	       		//listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,0,currentCommand));
	       	if(this.getSelectedIndex()==0){
				//action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,3,currentCommand));
			}else if(this.getSelectedIndex()==1){
				listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,1,currentCommand));
			}else if(this.getSelectedIndex()==2){
				listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,4,currentCommand));
			}else if(this.getSelectedIndex()==3){
				listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,0,currentCommand));
			}else if(this.getSelectedIndex()==4){
				listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,5,currentCommand));
		    }
	       	//if(this.getSelectedIndex()==0){
			//	action = Constant.SEARCHSCREEN;
			//	listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,action,0,currentCommand));	        	
			//}else if(this.getSelectedIndex()==1){
			//	action = Constant.KONFIGSCREEN;
			//	listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,action,0,currentCommand));	        	
			//}
			this.setSelectedIndex(0,true);
        	}
        	 synchronized (this) {
		       	commandThread = null;
        	}
	}
	private void getImages(){
		try{
		   movie_ico_m = Image.createImage("/images/movie_ico_m.png"); 
		   bilder_ico_m = Image.createImage("/images/bilder_ico_m.png");
		   ring_ico_m = Image.createImage("/images/ring_ico_m.png"); 
		   mp3_ico_m = Image.createImage("/images/mp3_ico_m.png");
		   java_ico_m = Image.createImage("/images/java_ico_m.png");
		   doc_ico_m= Image.createImage("/images/doc_ico_m.png");
	    }catch(IOException ioe){
	    	System.out.println("StartScreen Bilder konnten nicht geladen werden: "+ioe.toString());
	    }
	}	
/*******************************************/
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
/*******************************************/
}