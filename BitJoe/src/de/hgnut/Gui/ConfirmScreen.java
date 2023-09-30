package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;

//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
public class ConfirmScreen  extends Form implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
	private StringItem st;
	//+++++++++++++++++++++++++++++++++++++++++++
	
	//+++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
	public ConfirmScreen(GuiActionListener listener){
		super("BItJoe Info");
		this.listener = listener;
		st = new StringItem("","");
		st.setLayout(st.LAYOUT_CENTER);
		this.append(st);
		this.addCommand(Constant.jaCommand);
		this.addCommand(Constant.neinCommand);		
	    this.setCommandListener(this);	    
	}
//++++++++++++++++++++++++++++++++++++++++++++++++

	public void run(){
		//System.out.println("Command "+currentCommand.getLabel());
			
		if (currentCommand == Constant.neinCommand){
			  //System.out.println("zurück");
			  listener.guiActionPerformed(new GuiAction(Constant.CONFIRMSCREEN,null,0,currentCommand));
        	
        	}else if (currentCommand == Constant.jaCommand){
        		
                listener.guiActionPerformed(new GuiAction(Constant.CONFIRMSCREEN,null,0,currentCommand));	
        	}
        	 synchronized (this) {
		       	commandThread = null;
        	}
	}

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
   public void setText(){
   	 st.setText("Wenn Sie Ihre Benutzerdaten \u00E4ndern geht Ihr Zugang mit den Benutzernamen "+ Constant.USER+" f\u00FCr immer verloren! wirklich \u00E4ndern");
   }	
}