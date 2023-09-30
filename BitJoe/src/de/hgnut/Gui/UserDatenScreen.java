package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;

import com.jicoma.ic.Crypt;
import java.io.*;
import java.util.*;
import javax.microedition.io.*;
import de.hgnut.GnuUtil.GnuConnection;
import javax.microedition.rms.RecordStore;
import com.twmacinta.util.*;

//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
public class UserDatenScreen  extends Form implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
	private StringItem st;
	private int status = 0;
	
	private InputStream in;
	private OutputStream out;
	private GZIPInputStream gis;
	
	private Crypt cr;
	RecordStore pass;
	//+++++++++++++++++++++++++++++++++++++++++++
	
	//+++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
	public UserDatenScreen(GuiActionListener listener){
		super("BitJoe Info");
		this.listener = listener;
		st = new StringItem("","Haben Sie schon Nutzerdaten erhalten?");
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
			  this.removeCommand(Constant.jaCommand);
			  this.removeCommand(Constant.neinCommand);
			  st.setText("Bitte warten Nutzer wird erstellt...");
			  //try{
			  // Thread.sleep(5000);
			  //}catch(Exception e){
			  //}	 
			  getUser();
			  listener.guiActionPerformed(new GuiAction(Constant.USERDATENSCREEN,null,status,currentCommand));
        	  st.setText("Haben Sie schon Nutzerdaten erhalten?");
        	  this.addCommand(Constant.jaCommand);
		      this.addCommand(Constant.neinCommand);	
        	}else if (currentCommand == Constant.jaCommand){
        		
                listener.guiActionPerformed(new GuiAction(Constant.USERDATENSCREEN,null,0,currentCommand));	
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
   public void setStatus(int status){
   	this.status = status;
   	}
   	public void writeRecord(){
	try{
        		  pass.deleteRecordStore("UP");
        		}catch(Exception e){
                }
                try{  
	       		  pass = RecordStore.openRecordStore("UP" , true);
	       		  
                  String time = Long.toString(System.currentTimeMillis());
	       		  //System.out.println(time);
	       		  byte plainBytesSec[]=time.getBytes();
                  MD5 md5 = new MD5(plainBytesSec);
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
private void getUser(){
	 try{
	 	SocketConnection sc= (SocketConnection)Connector.open("socket://"+Constant.PROXY_IP+":"+Constant.PROXY_PORT);
	 	in = sc.openInputStream();
		gis = new GZIPInputStream(in);
		out = sc.openOutputStream();
		
		String userDate ="createaccount"+"##"+
			            "##"+
						Constant.UP_MD5+"##"+
						Constant.SEC_MD5+"##"+
						Constant.VERSION+
						Constant.CRLF;
		System.out.println("userDaten: "+ userDate);				
		String cs = cr.performEncrypt(userDate);
		out.write(cs.getBytes());
		out.flush();
		
		String response = GnuConnection.readLine(gis);
		System.out.println("UserDaten "+response);
		
		Vector respVec = split(response, "##");
	
		 Constant.USER = respVec.elementAt(0).toString();
		 //System.out.println("USER:" + Constant.USER);
		 Constant.ID = respVec.elementAt(1).toString();
		 //System.out.println("ID:" + Constant.ID);
		 Constant.UP_MD5 = respVec.elementAt(2).toString();
		 //System.out.println("UP_MD5:" + Constant.UP_MD5);
		 writeRecord();		 
	
		if(gis!=null)gis.close();		
		if(in!=null)in.close();
		if(out!=null)out.close();
		if(sc!=null)sc.close();						
						
	 	}catch(Exception e){
			System.out.println("ProxyCon.doSearch()");
			e.printStackTrace();
			
        }
} 
public Vector split(String str, String s) {
        Vector parts = new Vector();
        if ( s != null )
        {  
            int lastfound = 0;
            int pos = 0;
            while ( (lastfound = str.indexOf(s,pos)) != - 1 )
            {
                parts.addElement(str.substring(pos,lastfound));
                pos = lastfound+s.length();
            }
            if ( pos <  str.length() ) parts.addElement(str.substring(pos));
        }
        
        return parts;
    }
public void setCrypt(Crypt cr){
		this.cr = cr;
 }     	   	
}