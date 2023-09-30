package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import java.util.*;
/*******************************************/
import de.hgnut.Misc.*;
import de.hgnut.GnuUtil.Messages.*;
/*******************************************/
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;

//++++++++++++++++++++++++++++++++++++++++++
//Zeigt eine Egebnisliste an
public class ListScreen  extends List implements Runnable, CommandListener{
/*******************************************/
	private GuiActionListener listener;	
	private Command currentCommand;
	private static Thread commandThread;
	private Vector hits;
	private Image image[] = new Image[11];
	private boolean fake = true;
/*******************************************/
	public ListScreen(GuiActionListener listener){
		super("BitJoe - Suchergebnis", Choice.IMPLICIT);
		setFitPolicy(Choice.TEXT_WRAP_ON);		
		this.listener = listener;
		this.addCommand(Constant.cancelCommand);
		//this.addCommand(Constant.exitCommand);
		//this.addCommand(Constant.herunterladenCommand);
	    this.setCommandListener(this);
	    getImages();		
	}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	private void getImages(){
		try{
		 for(int i = 0; i < image.length; i++){	
		   image[i] = Image.createImage("/images/balken_"+i+".png");
		 }  
	    }catch(IOException ioe){
	    	System.out.println("Also hier "+ioe.toString());
	    }
	}	
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
/*******************************************/
	public void setHits(Vector hits){
		this.deleteAll();
		this.hits = hits;
		this.fake = true;
		
		 for (int i = 0; i < this.hits.size(); i++) {
	        	ProxySearchReply psr = (ProxySearchReply)hits.elementAt(i);
	        	  //System.out.println(psr.toGUIString());
            		//this.append(psr.toGUIString() ,null);
            		int score = psr.getFileScore();
            		if(score < 1000){
            			fake = false;
            		}	 
            		//System.out.println("score= "+ score);
            		int imageNum = 0;
            		if(score >= 1000) imageNum = 10;
            		if(score >= 30 && score < 1000) imageNum = 9;  
            		if(score >= 27 && score < 30) imageNum = 8;
            		if(score >= 24 && score < 27) imageNum = 7;
            		if(score >= 21 && score < 24) imageNum = 6;
            		if(score >= 18 && score < 21) imageNum = 5;
            		if(score >= 15 && score < 18) imageNum = 4;
            		if(score >= 12 && score < 15) imageNum = 3;
            		if(score >= 9 && score < 12) imageNum = 2;
            		if(score >= 6 && score < 9) imageNum = 1;
            		if(score < 6) imageNum = 0;
            		//System.out.println("score: "+score +" imageNum: "+ imageNum);
            		//System.out.println("toGUISTRING: "+psr.toGUIString());
            	    this.append(psr.toGUIString() , image[imageNum]);

		}
		if(fake){
			//System.out.println("fake: " + fake);
           new Thread( new Runnable() {
            public void run() {
            try{
              Thread.sleep(4000);
            }catch(Exception e){
            }
            listener.guiActionPerformed(new GuiAction(Constant.LISTSCREEN,null,1000,Constant.okCommand));
           };
          }).start();
        }
	}
/*******************************************/
	public void run(){
		if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand && currentCommand != Constant.cancelCommand){
		   currentCommand = Constant.okCommand;
		}
		if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));
		}else if (currentCommand == Constant.cancelCommand){
        		listener.guiActionPerformed(new GuiAction(Constant.LISTSCREEN,null,0,currentCommand));
        	}else if (currentCommand == Constant.okCommand){
        	//++++++++++++++++++++++++++++++++++++++++++++++	
        		Constant.index = this.getSelectedIndex();
        	//++++++++++++++++++++++++++++++++++++++++++++++	
        	Constant.FILENAME = getString(Constant.index); 
        	//Constant.FILENAME = "Crazy Frog";
        	//System.out.println("Filename1: "+Constant.FILENAME);
        	//System.out.println(((ProxySearchReply)hits.elementAt(Constant.index)).getFileScore());
        	if(((ProxySearchReply)hits.elementAt(Constant.index)).getFileScore() > 1000)
        	   Constant.index = 1000;
        	  //listener.guiActionPerformed(new GuiAction(Constant.LISTSCREEN,null,Constant.index,currentCommand));	
        	//	Constant.FILENAME = Constant.FILENAME.substring(0, Constant.FILENAME.indexOf(' '));
        	//	System.out.println("Filename2: "+Constant.FILENAME);
        	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
			listener.guiActionPerformed(new GuiAction(Constant.LISTSCREEN,null,Constant.index,currentCommand));
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			//System.out.println("Paul ListScreen: "+ index);
			//System.out.println("ListScreenIndex: "+ index);
        	}
        	 synchronized(this){
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


        				