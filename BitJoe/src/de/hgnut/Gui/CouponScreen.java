package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import de.hgnut.Misc.*;
//++++++++++++++++++++++++++++++++++++++++++
import java.io.*;
import javax.microedition.io.*;
import com.jicoma.ic.Crypt;
import de.hgnut.GnuUtil.GnuConnection;
//import com.tinyline.util.GZIPInputStream;
//++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
public class CouponScreen  extends Form implements Runnable, CommandListener{
/*******************************************/	
	private GuiActionListener listener;
	private Command currentCommand;
	private static Thread commandThread;
    private TextField couponText = new TextField("Gutschein Nr eingeben:","",24,TextField.ANY);
    private String remote_ip = Constant.PROXY_IP;
    private int remote_port = Constant.PROXY_PORT;
    private InputStream in;
	private OutputStream out;
	private GZIPInputStream gis;
	
	private Crypt cr;
	//+++++++++++++++++++++++++++++++++++++++++++
	
	//+++++++++++++++++++++++++++++++++++++++++++
/*******************************************/
	public CouponScreen(GuiActionListener listener){
		super("Gutschein einl\u00F6sen");
		this.listener = listener;
		this.append(couponText);
		//this.addCommand(Constant.exitCommand);
		this.addCommand(Constant.cancelCommand);
		this.addCommand(Constant.absendenCommand);		
	    this.setCommandListener(this);
	
	}
//++++++++++++++++++++++++++++++++++++++++++++++++

	public void run(){
		if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand && currentCommand != Constant.absendenCommand && currentCommand != Constant.cancelCommand){
			currentCommand = Constant.absendenCommand;
		}	
		if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));
		}else if (currentCommand == Constant.cancelCommand){
			listener.guiActionPerformed(new GuiAction(Constant.STARTSCREEN,null,0,currentCommand));	
        }else if (currentCommand == Constant.absendenCommand){
            if(couponText.getString().length() > 9){
            	listener.guiActionPerformed(new GuiAction(Constant.COUPONSCREEN,"Gutschein wird gepr\u00FCft",0,currentCommand));
            	int error = 2;
            	try{
            	  SocketConnection sc= (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port);
            	  
            	  in = sc.openInputStream();
			      gis = new GZIPInputStream(in);
			      out = sc.openOutputStream();
			      
			      String couponString =	"coupon"+"##"+
			            couponText.getString()+"##"+
			            "0"+"##"+
						Constant.UP_MD5+"##"+
						Constant.SEC_MD5+"##"+
						Constant.VERSION+
						Constant.CRLF;
						
						System.out.println("couponString "+couponString);
						
						String cs = cr.performEncrypt(couponString);
						
			            System.out.println("cryptString coupon:"+cs);				
			            out.write(cs.getBytes());
			            out.flush();
			            
			            String response = GnuConnection.readLine(gis);
			            System.out.println("couponResponse :" + response);
			            if (response.startsWith("-1"))
			              error = -1;
			              
			            if(response.indexOf('=')> -1)
			            response = response.substring(response.indexOf('=')+ 1);
			            
			            System.out.println("couponResponse :" + response);
			            
			            Constant.coupon= response;
			            
			            gis.close();
			            in.close();
			            out.close();
			            sc.close();	
			      	
            	}catch(Exception e){
			    System.out.println("CouponScreen");
			    e.printStackTrace();
			    }				
                listener.guiActionPerformed(new GuiAction(Constant.COUPONSCREEN,null,error,currentCommand));
                
            }    
        } 	
        	
        	 synchronized (this) {
		       	commandThread = null;
        	}
	}
	public void setCrypt(Crypt cr){
		this.cr = cr;
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