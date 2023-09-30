package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
import java.util.Random;
//++++++++++++++++++++++++++++++++++++++++++
import com.jicoma.ic.ProgressBar;
//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
//Fortschritsbalken
public class StatusScreen extends Form implements Runnable, CommandListener{
/*******************************************/
	private Gauge gauge;
//++++++++++++++++++++++++++++++++++++++++++++++++	
	private ProgressBar progressBar;
	private boolean download; 
//++++++++++++++++++++++++++++++++++++++++++++++++	
	private GuiActionListener listener;	
	private Command currentCommand;
	private static Thread commandThread;
	
	//public static String message ="";
/*******************************************/
	public StatusScreen(GuiActionListener listener, String title, boolean download, String name){
		super(name);
		this.listener=listener;
		this.gauge = new Gauge(title,false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
		this.append(gauge);
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if(download){
		 Constant.label= Constant.label= "Versuch 1/           ";
		}else{	
		 Constant.label= Constant.label= "0 % fertig           ";
	    }
		this.progressBar = new ProgressBar(Constant.label, Constant.firstWaitTimer,0);
		new Thread(progressBar).start();
		this.append(progressBar);
		if(download)
	      this.append(Constant.mes);	
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
		this.addCommand(Constant.cancelCommand);
		this.addCommand(Constant.exitCommand);
	    this.setCommandListener(this);
	    this.download = download;
	    	     
	}
/*******************************************/
	/*public void setTitle(String title){
		this.setTitle(title);
		this.gauge.setLabel(title);
	}*/
/*******************************************/
	public void run(){
		if(download){
			if (currentCommand == Constant.exitCommand){
			System.out.println("Constant Exit");
			listener.guiActionPerformed(new GuiAction(Constant.STATUSSCREEN,"download",0,currentCommand));
			
		  }else if (currentCommand == Constant.cancelCommand){
			//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        		listener.guiActionPerformed(new GuiAction(Constant.STATUSSCREEN,"download",Constant.index,currentCommand));
        	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
        	}
        	 synchronized (this) {
		       	commandThread = null;
        	}
		}else if(!download){	
		 if (currentCommand == Constant.exitCommand){
			System.out.println("Constant Exit");
			listener.guiActionPerformed(new GuiAction(Constant.STATUSSCREEN,"status",0,currentCommand));
			
		  }else if (currentCommand == Constant.cancelCommand){
			//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        		listener.guiActionPerformed(new GuiAction(Constant.STATUSSCREEN,"status",Constant.index,currentCommand));
        	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
        	}
        	 synchronized (this) {
		       	commandThread = null;
        	}
        } 	
	}
/*******************************************/
//implements CommandListener
	public void commandAction(Command c, Displayable d){
		synchronized (this) {
			if (commandThread != null) {
                		return;
		   	}
            		currentCommand = c;
            		commandThread = new Thread(this);
            		commandThread.start();
            	}		
	}
/*******************************************/
   public void setText(String text){
   	this.append(text);
   }	
}