package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
//++++++++++++++++++++++++++++++++++++++++++
import java.io.IOException;

import java.io.*;
import javax.microedition.io.*;
import com.jicoma.ic.Crypt;
import de.hgnut.GnuUtil.GnuConnection;
//import com.tinyline.util.GZIPInputStream;
import javax.microedition.midlet.MIDlet;


//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
public class AufladeScreen  extends Form implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
	private String remote_ip = Constant.PROXY_IP;
    private int remote_port = Constant.PROXY_PORT;
    private InputStream in;
	private OutputStream out;
	private GZIPInputStream gis;
	private Crypt cr;
	private MIDlet midlet;
	private String tel = "";
	private String rate ="";
	private StringItem item1;
	private Spacer spacer; 
	//+++++++++++++++++++++++++++++++++++++++++++
	
	//+++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
	public AufladeScreen(GuiActionListener listener, MIDlet midlet){
		//super("BitJoe's AGB", List.IMPLICIT);
		super("Konto Aufladen");
		this.listener = listener;
		this.midlet = midlet;
		//this.append("Ich habe die AGB gelesen und", null);
		item1 = new StringItem("","Bitte warten Verbinde mit Server");
		spacer = new Spacer(0,40);
		item1.setLayout(Item.LAYOUT_CENTER);
		this.append(item1);
		this.append(spacer);
		this.setTicker(new Ticker("Hinweis: Anruf unbedingt so lange halten bis die Gegenseite ihn bendet, um eine Gutschrift zu erhalten."));
		//this.append("       ", null);
		//this.append("         AGB lesen", null);
		//this.setFont(1, Font.getFont(Font.FACE_SYSTEM,Font.STYLE_BOLD, Font.SIZE_LARGE));	
		//this.addCommand(Constant.lehneabCommand);
		//this.addCommand(Constant.stimmezuCommand);
			    
	}
//++++++++++++++++++++++++++++++++++++++++++++++++

	public void run(){
		    if(currentCommand == null){
		     //System.out.println("Command: "+currentCommand);
		     //System.out.println("Rate :" + rate);
		     fillAcount(rate);
		     if(!tel.equals("")&& !tel.equals("0") && !tel.equals("-1"))
		     this.addCommand(Constant.anrufenCommand);
		     
		     this.addCommand(Constant.cancelCommand);		
	         this.setCommandListener(this);
		    }else if(currentCommand == Constant.anrufenCommand){
		    	if(!tel.equals("")&& !tel.equals("0")){
		    		platformReq();
		    		try{
		    			Thread.sleep(4000);
		    		}catch(InterruptedException ie){
		    			ie.printStackTrace();
		    		}		
		    	}
		    	listener.guiActionPerformed(new GuiAction(Constant.AUFLADESCREEN,tel,0,currentCommand));
		    	//this.deleteAll();
		    	currentCommand=null;
		    	this.item1.setText("Bitte warten Verbinde mit Server");
		    	//this.commandListener=null;	
		    }else if(currentCommand == Constant.cancelCommand){
		    	listener.guiActionPerformed(new GuiAction(Constant.AUFLADESCREEN,tel,0,currentCommand));
		    	//this.deleteAll();
		    	currentCommand=null;
		    	this.item1.setText("Bitte warten Verbinde mit Server");
		    	//this.commandListener=null;
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
public boolean fillAcount(String money){
   	 try{
            	  SocketConnection sc= (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port);
            	  
            	  in = sc.openInputStream();
			      gis = new GZIPInputStream(in);
			      out = sc.openOutputStream();
			      
			      String kontoString =	"paymentenhanced"+"##"+
			            money+"####"+
						Constant.UP_MD5+"##"+
						Constant.SEC_MD5+"##"+
						Constant.VERSION+
						Constant.CRLF;
						
						System.out.println("KontoString "+kontoString);
						System.out.println(cr);
						String cs = cr.performEncrypt(kontoString);
						
			            System.out.println("cryptString Konto:"+cs);				
			            out.write(cs.getBytes());
			            out.flush();
			            
			            String response = GnuConnection.readLine(gis);
			            System.out.println("KontoResponse :" + response);
			            this.tel = response.substring(0,response.indexOf("##"));
			            System.out.println("tel :" + tel);
			 
			            if(response.indexOf('=')> -1)
			            response = response.substring(response.indexOf('=')+ 1);
			            try{
			             this.delete(this.size()-1);
			            }catch(Exception ex){
			            }	
			            this.item1.setText(response);
			            
			            System.out.println("KontoResponse :" + response);
			            
			            Constant.coupon= response;
			            
			            gis.close();
			            in.close();
			            out.close();
			            sc.close();	
			      	
            	}catch(Exception e){
			    System.out.println("KontoScreen");
			    e.printStackTrace();
			    return false;
			    }
			    //try{
			    //	midlet.platformRequest("tel:"+tel);
			    //}catch(ConnectionNotFoundException cnfe){
			    //	Constant.coupon = cnfe.getMessage();
			    //	cnfe.printStackTrace();
			    //}		
   	 return true;
   }
   public void setCrypt(Crypt cr){
		this.cr = cr;
   }
   private void platformReq(){
   	 if(!this.tel.equals("") && !this.tel.equals("0")){
   	   try{
		 midlet.platformRequest("tel:"+this.tel);
	   }catch(ConnectionNotFoundException cnfe){
		 Constant.coupon = cnfe.getMessage();
		 cnfe.printStackTrace();
	   }
     }
   }
   public void setRate(String rate){
   	 this.rate=rate;
   	 commandThread = new Thread(this);
     commandThread.start();
   }
   public void setText(String text){
   	//System.out.println("Der Text :" + text);
   	this.append("."+text);
   }	
   	
}