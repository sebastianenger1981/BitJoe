package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
/*******************************************/
//Suchmaske
public class SearchScreen  extends TextBox implements Runnable, CommandListener{
/*******************************************/
	public String TOSEARCH = null;
/*******************************************/	
	private GuiActionListener listener;	
	private Command currentCommand;
	private static Thread commandThread;
/*******************************************/
	public SearchScreen(GuiActionListener listener){
	        super("BitJoe - Suchbegriff:", "", 200, 0);
       		this.listener = listener;
       	//this.addCommand(Constant.okCommand);
       	this.addCommand(Constant.absendenCommand);
		this.addCommand(Constant.cancelCommand);
		//this.addCommand(Constant.exitCommand);
	        this.setCommandListener(this);	        	
	}
/*******************************************/
	public void run(){
		
		if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));
		}	
		
		 else if (currentCommand == Constant.cancelCommand){
			listener.guiActionPerformed(new GuiAction(Constant.SEARCHSCREEN,null,0,currentCommand));
        	}else if (currentCommand == Constant.okCommand || currentCommand ==  Constant.ok2Command || currentCommand ==  Constant.absendenCommand){
			TOSEARCH = this.getString();
			//System.out.println("constant.TOSEARCH: "+ Constant.TOSEARCH);
			    //this.insert(" in search Screen run "+ TOSEARCH, this.getCaretPosition()+1);
        		listener.guiActionPerformed(new GuiAction(Constant.SEARCHSCREEN,TOSEARCH,0,Constant.okCommand));
        	}
        	 synchronized (this) {
		       	commandThread = null;
        	}
	}
/*******************************************/
//implements CommandListener
	public void commandAction(Command c, Displayable d){
		synchronized (this) {
			//this.insert("in search Screen Command listener " + commandThread, this.getCaretPosition()+1);
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