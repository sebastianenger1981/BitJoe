package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;
import javax.microedition.rms.RecordStore;
import com.twmacinta.util.*;
//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
public class AnmeldeScreen  extends Form implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
	
	private StringItem userI;
	private StringItem passI;
	//private Spacer spacer;
	private StringItem textI;
	private TextField handyText;
    private TextField idText;
	RecordStore pass;
	
	//+++++++++++++++++++++++++++++++++++++++++++
	
	//+++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
	public AnmeldeScreen(GuiActionListener listener){
		super("BitJoe's Anmeldung");
		this.listener = listener;
		this.userI = new StringItem("Benutzername: ","");
		this.passI = new StringItem("Passwort: ","");
		//this.spacer = new Spacer(20,40);
		this.textI = new StringItem("Benutzerdaten eingeben/\u00E4ndern:",null);
		this.handyText = new TextField("Benutzername:","",24,TextField.ANY);
		this.idText = new TextField("Passwort:","",24,TextField.ANY);
		this.append(userI);
		this.append(passI);
		this.append(textI);
		//this.append(spacer);
		this.append(handyText);
		this.append(idText);
		this.addCommand(Constant.cancelCommand);
		this.addCommand(Constant.speichernCommand);	
	    this.setCommandListener(this);
	    //this.setItemStateListener(this);
	    this.pass = pass;	    
	}
//++++++++++++++++++++++++++++++++++++++++++++++++

	public void run(){
		if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand && currentCommand != Constant.cancelCommand){
			currentCommand = Constant.okCommand;
		}	
		if (currentCommand == Constant.cancelCommand){
			    //try{
        		 // pass.deleteRecordStore("UP");
        		//}catch(Exception e){
                //}
			listener.guiActionPerformed(new GuiAction(Constant.ANMELDESCREEN,null,0,currentCommand));
        	}else if (currentCommand == Constant.okCommand){
        		
        	 if(handyText.getString().length() > 5 && idText.getString().length() > 3){
        	 	if(!handyText.getString().equals(Constant.USER) && !idText.getString().equals(Constant.ID)){
        	 	  if(Constant.USER.equals("") && Constant.ID.equals("")){	
        		    setRecord();  
                    listener.guiActionPerformed(new GuiAction(Constant.ANMELDESCREEN,null,0,currentCommand));
                  }else{
                  	//System.out.println("USERNAME : "+Constant.USER);
                  	listener.guiActionPerformed(new GuiAction(Constant.ANMELDESCREEN,null,1,currentCommand));
                  }	  
                }
              } 	
        	}
        	 synchronized (this) {
		       	commandThread = null;
        	}
	}
	public void setText(){
		//System.out.println("setText......");
		//deleteAll();
		userI.setText(Constant.USER);
		passI.setText(Constant.ID);
		handyText.setString("");
		idText.setString("");
		//System.out.println("setText danach......");
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
  //public void commandAction(Command c, Item i){
  	//System.out.println("Command: "+ c + "Item: "+ i);
  //}
  public void setRecord(){
  	try{
        		    pass.deleteRecordStore("UP");
        		  }catch(Exception e){
                  }
                  try{  
	       		  pass = RecordStore.openRecordStore("UP" , true);
	       		  Constant.USER = handyText.getString().trim();
	       		  Constant.ID = idText.getString().trim();
	       		  String s = Constant.USER+ Constant.ID;
	       		  s = s.toLowerCase().trim();
	       		  
	       		  //this.append(s);
	       		  //System.out.println(s);
	       		  byte plainBytes[]=s.getBytes();
                  MD5 md5 = new MD5(plainBytes);
                  byte[] result = md5.doFinal();
                  Constant.UP_MD5 = md5.toHex(result);
                  
                  //this.append(Constant.UP_MD5);
                  //System.out.println("md51 "+ Constant.UP_MD5);
                  
                  String time = Long.toString(System.currentTimeMillis());
	       		  //System.out.println(time);
	       		  byte plainBytesSec[]=time.getBytes();
                  md5 = new MD5(plainBytesSec);
                  byte[] resultSec = md5.doFinal();
                  Constant.SEC_MD5 = md5.toHex(resultSec);
                  
                  //System.out.println("md52 "+ Constant.SEC_MD5);
                  
                  byte bytesR1[] = Constant.UP_MD5.getBytes();
    	          pass.addRecord(bytesR1 ,0, bytesR1.length);
    	          
    	          byte bytesR2[] = Constant.SEC_MD5.getBytes();
    	          pass.addRecord(bytesR2 ,0, bytesR2.length);
    	          
    	          byte bytesR3[] = Constant.USER.getBytes();
    	          pass.addRecord(bytesR3 ,0, bytesR3.length);
    	          
    	          byte bytesR4[] = Constant.ID.getBytes();
    	          pass.addRecord(bytesR4 ,0, bytesR4.length);
                  
    	          pass.closeRecordStore();
                  }catch(Exception e){
        	       System.out.println("fehler AGB RecordStore: "+e);
                  }
  }		
}