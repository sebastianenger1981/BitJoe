package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
/*******************************************/
//Bietet möglichkeiten alls Props einzustellen (Dir,Dateiformate,etc..)
public class KonfigScreen  extends List implements Runnable, CommandListener{
/*******************************************/
	//public int SELECTEDINDEX = -1;
/*******************************************/
	private GuiActionListener listener;	
	private Command currentCommand;
	private static Thread commandThread;
/*******************************************/
	public KonfigScreen(GuiActionListener listener){
		//super("BitJoe - Konfiguration",Choice.EXCLUSIVE);
		//super("BitJoe - Konfiguration", List.IMPLICIT);
		super("BitJoe - Konfiguration", List.MULTIPLE);
		this.listener = listener;
		this.addCommand(Constant.speichernCommand);
		//this.addCommand(Constant.cancelCommand);
		//this.addCommand(Constant.exitCommand);
	        this.setCommandListener(this);
	}
/*******************************************/
	public void init(String index){
		this.deleteAll();
		
		for(int i=0;i<Constant.ALLOWED_FILE_TYPES.length;i++){
			this.append(Constant.ALLOWED_FILE_TYPES[i],null);			
		}
		if(!index.equals("-1") && index.length()> 1){
			//System.out.println("index: "+ index + " index.length: "+ index.length());
			boolean indixes[] = new boolean[index.length()];
			
			 for(int i = 0; i < indixes.length; i++){
				//System.out.println("i: "+ i+ " character "+ index.charAt(i));
				if(index.charAt(i)=='1')
				   indixes[i] = true;
				else
				  indixes[i] = false;    
		    }
		    try{	
		      this.setSelectedFlags(indixes);
		    }catch(IllegalArgumentException iae){
		   	   this.setSelectedIndex(0, true);
		    }
		}else{
		  this.setSelectedIndex(0, true);	
		}
				
	}
/*******************************************/
	public void run(){
		    if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand && currentCommand != Constant.cancelCommand && currentCommand != Constant.speichernCommand){
			   currentCommand = Constant.speichernCommand;
		    }
	        if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));	
		
        	}else if (currentCommand == Constant.cancelCommand){
			listener.guiActionPerformed(new GuiAction(Constant.KONFIGSCREEN,null,0,currentCommand));
        	}else if (currentCommand == Constant.speichernCommand){
        		//sicher die Auswahl, damit Main sie verwenden kann
        		boolean selectedArray_return[] = new boolean[Constant.ALLOWED_FILE_TYPES.length];
        		getSelectedFlags(selectedArray_return);
        		String selectedIndex = "";
        		for(int i = 0; i < selectedArray_return.length; i++){
        			if(selectedArray_return[i]){
        				selectedIndex = selectedIndex + "1";
        			}else{
        				selectedIndex = selectedIndex + "0";
        			}
        					
        		}
        		Constant.SELECTED_FILE_TYPES = selectedIndex;
        		//System.out.println("selected "+Constant.SELECTED_FILE_TYPES);	
        		//SELECTEDINDEX = this.getSelectedIndex();        		
			listener.guiActionPerformed(new GuiAction(Constant.KONFIGSCREEN,null,0,Constant.okCommand));
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