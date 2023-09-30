package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;

//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
public class WelcomeScreen  extends List implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
	//+++++++++++++++++++++++++++++++++++++++++++
	private Image movie_ico_m;
	private Image bilder_ico_m;
	private Image ring_ico_m;
	private Image mp3_ico_m;
	private Image java_ico_m;
	private Image doc_ico_m;
	private Image gutschein_m;
	private Image config_m;
	private Image user2_m;
	//+++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
	public WelcomeScreen(GuiActionListener listener){
		super("BitJoe's Men\u00FC",List.IMPLICIT);
		getImages();
		this.listener = listener;
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
			
		this.append("Nutzerdaten", user2_m);	
		this.append("Gutschein einl\u00F6sen", gutschein_m);
		this.append("Einstellungen", config_m);	
			
		this.addCommand(Constant.exitCommand);
		//this.addCommand(Constant.okCommand);		
	        this.setCommandListener(this);	    
	}
//++++++++++++++++++++++++++++++++++++++++++++++++
private void getImages(){
		try{
		 
		   movie_ico_m = Image.createImage("/images/movie_ico_m.png"); 
		   bilder_ico_m = Image.createImage("/images/bilder_ico_m.png");
		   ring_ico_m = Image.createImage("/images/ring_ico_m.png"); 
		   mp3_ico_m = Image.createImage("/images/mp3_ico_m.png");
		   java_ico_m = Image.createImage("/images/java_ico_m.png");
		   doc_ico_m= Image.createImage("/images/doc_ico_m.png");
		   gutschein_m= Image.createImage("/images/gutschein_m2.png");
		   config_m = Image.createImage("/images/config_m.png");
		   user2_m = Image.createImage("/images/user2_m.png");  
	    }catch(IOException ioe){
	    	System.out.println("WelcomeScreen Bilder konnten nicht geladen werden: "+ioe.toString());
	    }
	}	

//++++++++++++++++++++++++++++++++++++++++++++++++	
/*******************************************/
	public void run(){
		if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand){
			currentCommand = Constant.okCommand;
		}	
		if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));
        	}else if (currentCommand == Constant.okCommand){
	       		String action;
	       	if(this.getSelectedIndex()==0){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,3,currentCommand));
			}else if(this.getSelectedIndex()==1){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,1,currentCommand));
			}else if(this.getSelectedIndex()==2){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,4,currentCommand));
			}else if(this.getSelectedIndex()==3){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,0,currentCommand));
			}else if(this.getSelectedIndex()==4){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,5,currentCommand));
			}else if(this.getSelectedIndex()==5){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,8,currentCommand));
			}else if(this.getSelectedIndex()==6){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,7,currentCommand));
			}else if(this.getSelectedIndex()==7){
				action = Constant.WELCOMESCREEN;
				listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,action,6,currentCommand));	
			}
        	}
        	 synchronized (this) {
		       	commandThread = null;
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