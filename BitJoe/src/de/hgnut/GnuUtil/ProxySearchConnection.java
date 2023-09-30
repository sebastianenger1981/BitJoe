package de.hgnut.GnuUtil;
/***************************************************/
import javax.microedition.io.*;
import java.io.*;
import java.util.*;
import de.hgnut.GnuUtil.Messages.*;
import de.hgnut.Misc.*;
import javax.microedition.pki.*;
//++++++++++++++++++++++++++++++++
//import com.tinyline.util.GZIPInputStream;
//import net.sourceforge.lightcrypto.Crypt;
//import net.sourceforge.lightcrypto.CryptoException;
import com.jicoma.ic.Crypt;

import com.jicoma.ic.ConnectData;

import de.hgnut.Gui.StatusScreen;
import de.hgnut.Gui.SearchScreen;

import javax.microedition.rms.RecordStore;
import com.twmacinta.util.*;
import javax.microedition.lcdui.Display;
//++++++++++++++++++++++++++++++++
/***************************************************/
public class ProxySearchConnection extends Thread{
/***************************************************/
	public Vector results;
	public boolean status = false;
/***************************************************/
	private boolean chrashed = false;
	private String remote_ip;
	private int remote_port;

	private InputStream in;
	private OutputStream out;
	private GZIPInputStream gis;
	private String to_search;
	private String id = null;
//+++++++++++++++++++++++++++++++++++++
    private Crypt cr;	
	private int i1 = 0;
	private int i2 = 0;
	private int i3 = 0;
	private int i4 = 0;
	
	public static String message ="";
	private StatusScreen statusS;
	private Display display;
	private SearchScreen searchS;
	
	private ConnectData cd;
	//private int z = 0;
	
	RecordStore pass;
//+++++++++++++++++++++++++++++++++++++	
	
/***************************************************/
	public ProxySearchConnection(String ip, int port, String to_search, Crypt cr, StatusScreen statusS, Display display, ConnectData cd, SearchScreen searchS ){
		this.remote_ip   = ip;
		this.remote_port = port;
		this.to_search = to_search;
		results = new Vector();
		//++++++++++++++++++++++++++++++++++++
		this.cr = cr;
		this.statusS = statusS;
		this.display = display;
		this.searchS = searchS;
		this.cd = cd;
		System.out.println("cd "+ cd);
		//++++++++++++++++++++++++++++++++++++ 
	}
/***************************************************/
	public void run(){
		try{ 
			doSearch();
			if(validateID(id)){
				int attemp=0;
				int time = Constant.firstWaitTimer;
				Constant.holeTime = time;
				//boolean t = false;
				do{
				//WENN ZEIT ODER ATTEMPS ÄNDERN DANN AUCH IN MAIN2.java ändern
					attemp++;
					/*try {
						synchronized (this){wait(time);}
					}catch (InterruptedException ie){
						System.out.println("ProxySearchConnection.run()->do{}while();");
						ie.printStackTrace();
					}*/
					//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					for(int i = 0; i < time; i = i + 1000){
						if(status){
							Constant.time = 0;
							break;
						}	
						Constant.time = i;
						String s =(100000 / Constant.holeTime * Constant.time/1000) +" % fertig";
						for(int j = s.length(); j < 20; j++ ){
							s = s + " ";
						}	
						Constant.label = s;
					try{
					  Thread.currentThread().sleep(1000);
					}catch (InterruptedException ie){
						System.out.println("ProxySearchConnection.run()->do{}while();");
						ie.printStackTrace();
					 }
				    }
				    Constant.time = time;
				    Constant.label= "100 % fertig       ";
					//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					//time=Constant.secondWaitTimer;
					Constant.time = time;
					Constant.holeTime = time;
					if(!status){
					 System.out.println("Versuche Treffer abzuholen");
					 status = readResults();
					 System.out.println("attemp = "+attemp+" chrashed = "+chrashed);
				    }
					if(!status&&!(attemp<1))status = true;
					if(!status&&chrashed)status = true;
				}while(!status);
				//+++++++++++++++++++++++++++++++++++++++++++
				Constant.time = 0;
				Constant.pbDone = true;
				Constant.label="  0 % fertig           ";
				Constant.holeTime = Constant.firstWaitTimer;
				//+++++++++++++++++++++++++++++++++++++++++++
			}
			status = true;
		}catch(Exception e){
			System.out.println("ProxySearchConnection.run()");
			e.printStackTrace();
		}
	}
/***************************************************/
	private boolean readResults(){
/*
	#     7.1 Suchergebnisse Ranged anfragen 
	#     Status | Flag | IMEI | Lizenzkey | 
 	#     Clientversion | Suchbegriff | Results ID | RANGE FROM | RANGE TO
*/
      //Constant.firstWaitTimer=Constant.absolutWaitTimer; 
		try{		
		//Punkte/r/nDateigröße/r/nsha1/r/nIP:Port;Fileindex;Dateiname/r/nIP:Port;Fileindex;Dateiname/r/n/r/n
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
			SocketConnection sc = (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port);
			System.out.println("Pfad: "+"ssl://"+remote_ip+":"+remote_port);
			//sc.setSocketOption(SocketConnection.LINGER, 30);
			sc.setSocketOption(SocketConnection.KEEPALIVE, 1);
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++				
			in  = sc.openInputStream();
			out = sc.openOutputStream();
			//++++++++++++++++++++++++++++++++++++
			gis = new GZIPInputStream(in);
			//++++++++++++++++++++++++++++++++++++			
			String hello_result =	"result"+"##"+
			            to_search+"##"+
			            id+"##"+
						//Constant.SELECTED_FILE_FAMILY+Constant.SELECTED_FILE_TYPES+"##"+
						Constant.UP_MD5+"##"+
						Constant.SEC_MD5+"##"+
						//UP_MD5+"##"+
						//SEC_MD5+"##"+
						Constant.VERSION+
						Constant.CRLF;
			String cs = cr.performEncrypt(hello_result);
			System.out.println(cs);						
			//out.write(hello_result.getBytes());
			out.write(cs.getBytes());
			out.flush();
			try{
				sleep(4000); 
			}catch(InterruptedException ie){
				System.out.println(ie);
			}		
			//out.close();
			//System.out.println("hello_result "+hello_result);
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			//System.out.println("readLine 2: alt " + i1++);
			//String line = GnuConnection.readLine(in,Constant.CRLF);
			//System.out.println("readLine 2: neu " + i1++);
			String line = GnuConnection.readResult(gis);
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			//System.out.println("line: "+line);
			//statusS.append("line: "+line);
			if(line!=null&&!line.trim().equals(Constant.PROXYNOTREADY)&&!line.trim().equals(Constant.ip_banned)&&!line.trim().equals(Constant.proxy_errora)&&!line.trim().equals(Constant.proxy_errorb)&&!line.trim().equals(Constant.proxy_errorc)&&!line.trim().equals("0")){
				//System.out.println("Treffer vorhanden");
				//Alle Treffer anfang
				while(line!=null&&line.length()>0){
					//System.out.println("Anfang neuer Treffer ");
					//Ein File mehrere Sourcen Anfang
					//Punkte/r/nDateigröße/r/nsha1/r/nIP:Port;Fileindex;Dateiname/r/nIP:Port;Fileindex;Dateiname/r/n/r/n		
					ProxySearchReply psr = new ProxySearchReply();
					int item =0;
					boolean b = true;
					//File wird mit \r\n\r\n beendet == leere Zeile
					while(line!=null&&line.length()>0){
						//System.out.println("Myline : " +line +" " + item);
						switch(item){
				
							case 0:/*Score*/ 
							  //System.out.println("case 0: " + line);
								psr.setFileScore(Integer.parseInt(line.trim()));
								item++;
								break;
							case 1:	/*Size*/
							   //System.out.println("case 1: " + line);							
								if(line.indexOf('.')==-1){									
									psr.setFileSize(Integer.parseInt(line.trim()));
								}
								else{
									psr.setFileSize(Integer.parseInt(line.substring(0,line.indexOf('.')).trim()));
								}
								item++;
								break;
							case 2://*sha1*
							   //System.out.println("case 2: " + line);
								psr.setSHA1(line.trim());
								item++;
								break;
							default:/*ip:port;index;name*/
							    //System.out.println("default: " + line);
							    //System.out.println("default case 1");
							    try{ 
								  String ip    = line.substring(0,line.indexOf(':'));
								  //System.out.println("ip :" +ip); 
								  String port  = line.substring(line.indexOf(':')+1,line.indexOf(';'));
								  //System.out.println("port :" + port);
								  //System.out.println("jfdlksdjflksdjflksj"); 
								  String index = line.substring(line.indexOf(";")+1,line.lastIndexOf(';'));
								  //System.out.println("index :"+line); 
								  String name  = line.substring(line.lastIndexOf(';')+1);
								  //System.out.println("ip: " + ip);
								  //System.out.println("port: "+port);
								  //System.out.println("index: "+index);
								  //System.out.println("name: "+ name);
								  if(name.indexOf('.')< 0)
								  	b= false;
								  						
								  psr.addSource(ip, Integer.parseInt(port),Integer.parseInt(index),name);
								 }catch(IndexOutOfBoundsException ioobe){
								 	System.out.println(ioobe.toString() +" "+ line);
								 }	 
								break;
							}
							//++++++++++++++++++++++++++++++++++++++++++++++++++++++
							//System.out.println("readLine 3:alt " + i2++ );
							//line = GnuConnection.readLine(in,Constant.CRLF);
							//System.out.println("readLine 3:neu " + i2++);
							line = GnuConnection.readResult(gis);
							//+++++++++++++++++++++++++++++++++++++++++++++++++++++
							//System.out.println("line "+line);
					}//while Ein File mehrere Sourcen Ende
					//psr is feritg, muss noch mit globalen Daten gefüllt werden
					psr.FILEFLAG="b,1";
					psr.IMEI="IMEI";
					psr.LIZENZKEY="MILLIONAIRE";
					psr.CLIENTVERSION="1.0";
					psr.to_search=this.to_search;
					psr.RESULTID=id;
					if(b){
					  results.addElement(psr);
				    }
				    b = true;
					//+++++++++++++++++++++++++++++++++++++++++++++++++
					//System.out.println("readLine 4: alt " + i3++);
					//line = GnuConnection.readLine(in,Constant.CRLF);
					//System.out.println("readLine 4: neu " + i3++);
					line = GnuConnection.readResult(gis);
					//+++++++++++++++++++++++++++++++++++++++++++++++++
					//System.out.println("line "+line);
				}//while alle Treffer ende
				//+++++++++++++++++++++
				gis.close();
				//++++++++++++++++++++
				in.close();
				sc.close();
				//out.flush();
			//out.close();
				return true;
			}else{
				System.out.println("Noch keine Treffer "+line);
			}
			if(line!=null&&line.trim().equals(Constant.PROXYNOTREADY)&&line.trim().equals(Constant.proxy_errora)&&!line.trim().equals(Constant.proxy_errorb)&&line.trim().equals(Constant.ip_banned)&&line.trim().equals(Constant.proxy_errorc))
				chrashed=true;
		  //+++++++++++++++++++++++++++++++++++++++++++++++++++
			if(gis!=null)gis.close();
		  //+++++++++++++++++++++++++++++++++++++++++++++++++++		
			if(in!=null)in.close();
			if(out!=null)out.close();
			if(sc!=null)sc.close();	
			return false;
		}catch(Exception e){
			System.out.println("ProxyCon.readResults()");
			e.printStackTrace();
			chrashed=true;
			return false;
		}
	}
/***************************************************/
	private void doSearch(){
		SocketConnection sc = null;
		try{
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			System.out.println("Pfad vorher: "+"ssl://"+remote_ip+":"+remote_port);
			sc= (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port);
			System.out.println("Pfad: "+"ssl://"+remote_ip+":"+remote_port);
			//SecureConnection sc = (SecureConnection)Connector.open("ssl://"+remote_ip+":"+remote_port);

			
			in = sc.openInputStream();
			gis = new GZIPInputStream(in);
			out = sc.openOutputStream();
			
			to_search=replaceAll(to_search, "\u00E4" , "ae");
			to_search=replaceAll(to_search, "\u00C4" , "Ae");
			to_search=replaceAll(to_search, "\u00F6" , "=F6");
			to_search=replaceAll(to_search, "\u00D6" , "Oe;");
			to_search=replaceAll(to_search, "\u00FC" , "ue");
			to_search=replaceAll(to_search, "\u00DC" , "Ue");
			to_search=replaceAll(to_search, "\u00DF" , "ss");
			to_search=replaceAll(to_search, "#", "");
			to_search=replaceAll(to_search, "\\r", "");
			to_search=replaceAll(to_search, "\\n", "");
			
			
			
			
		
			String SearchString =	"find"+"##"+
			            to_search+"##"+
						Constant.SELECTED_FILE_FAMILY+Constant.SELECTED_FILE_TYPES+"##"+
						Constant.UP_MD5+"##"+
						Constant.SEC_MD5+"##"+
						Constant.VERSION+"##"+
						cd.getVersion()+"##GER"+
						Constant.CRLF;			
						
			//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++			
			
		    System.out.println("suchString: "+ SearchString);		
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			String cs = cr.performEncrypt(SearchString);
			
			out.write(cs.getBytes());
			out.flush();
			
			String response = GnuConnection.readLine(gis);
			
			System.out.println("rs= "+ response);
			
            
			Vector respVec = split(response, "##");
			
			id = respVec.elementAt(0).toString();
			message = (respVec.elementAt(1).toString()).substring(7);
			
			if(id.equals("-1")){
				message = "";
				try{
			     if(gis != null)	
			      gis.close();
			     if(in != null)
			      in.close();
			     if(out != null)
			       out.close();
			     if(sc != null)
			       sc.close();
			}catch(IOException io){
				System.out.println("ProxyCon.doSearch() try -1");
			    io.printStackTrace();
			}
			
			remote_ip = cd.getNextIp();
			if(!remote_ip.equals("0")){
				remote_port = cd.getPort();
				doSearch();
				
			}else{
			
			   Constant.clearRecord = true;
			   status = true;
			   display.setCurrent(Constant.alert_a, searchS);
			 }  
			}else{
				Constant.mes = message;	   
			    statusS.setText(message);
			}    
			   
			if(id.equals("0") || id.equals("1")){
				Constant.error = message;
				Constant.clearRecord = true;
			    status = true;
			}
			
			
			String versions ="";
			try{
			versions = (respVec.elementAt(2).toString());
			}catch(Exception e){
			}
		
			
			if(!versions.equals("")){
			  cd.newData(versions);
			  cd.setRec(versions);	 
		    }
			
			
			
			
					
			if(Constant.STANDART_UP_MD5 == Constant.UP_MD5){
				try{
				  Constant.USER = respVec.elementAt(4).toString();
				  Constant.ID = respVec.elementAt(5).toString();
				  Constant.UP_MD5 = respVec.elementAt(6).toString();
				 writeRecord();
				}catch(Exception e){
					System.out.println("fehler ProxySearchConnection write Record");
					e.printStackTrace();
				}	
			}	
			//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
			if(gis != null)	
			gis.close();
			if(in != null)
			in.close();
			if(out != null)
			out.close();
			if(sc != null)
			sc.close();
		}catch(Exception e){
			
			try{
			if(gis != null)	
			 gis.close();
			if(in != null)
			 in.close();
			if(out != null)
			 out.close();
			if(sc != null)
			 sc.close();
			}catch(IOException io){
				System.out.println("ProxyCon.doSearch() try");
			    e.printStackTrace();
			}
			System.out.println("neue ip neue ip neue ip neue ip");
			remote_ip = cd.getNextIp();
			if(!remote_ip.equals("0")){
				System.out.println("neue Suche neue suche neue suche");
				remote_port = cd.getPort();
				Constant.PROXY_IP = remote_ip;
		        Constant.PROXY_PORT = remote_port;
				doSearch();
			}else{
			System.out.println("ProxyCon.doSearch()");
			e.printStackTrace();
			if(e instanceof CertificateException){
				Certificate cer = ((CertificateException)e).getCertificate();
				System.out.println("Reason. :"+ ((CertificateException)e).getReason());
				System.out.println("Issuser: "+cer.getIssuer());
				System.out.println("NotAfter: "+cer.getNotAfter());
				System.out.println("NotBefore: "+cer.getNotBefore());
				System.out.println("SerialNumber: "+cer.getSerialNumber());
				System.out.println("SigAlgName: "+cer.getSigAlgName());
				System.out.println("Subject: "+cer.getSubject());
				System.out.println("Type: "+cer.getType());
				System.out.println("Version: "+cer.getVersion());
			}
			 id = null;
			}
		}
	}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
private String replaceAll(String text, String searchString, String replacementString){
   StringBuffer sBuffer = new StringBuffer();
   int pos = 0;
   while((pos = text.indexOf(searchString)) != -1){
     sBuffer.append(text.substring(0, pos) + replacementString);
     text = text.substring(pos + searchString.length());
   }
   sBuffer.append(text);
   return sBuffer.toString();
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++	
/***************************************************/
	public boolean validateID(String id){
		if(id==null)
			return false;
		if(id.trim().equals(Constant.no_port_left))
			return false;
		if(id.trim().equals(Constant.no_valid1_lizenz))
			return false;
		if(id.trim().equals(Constant.no_valid2_lizenz))
			return false;
		if(id.trim().equals(Constant.no_valid3_lizenz))
			return false;
		if(id.trim().equals(Constant.proxy_errora))
			return false;			
		if(id.trim().equals(Constant.proxy_errorb))
			return false;			
		if(id.trim().equals(Constant.proxy_errorc))
			return false;
		if(id.trim().equals(Constant.ip_banned))
			return false;
		if(id.trim().equals("-1"))
			return false;
		if(id.trim().equals("0"))
			return false;
		if(id.trim().equals("1"))
			return false;					
		return true;
	}
/***************************************************/
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
public void writeRecord(){
	try{
        		  pass.deleteRecordStore("UP");
        		}catch(Exception e){
                }
                try{  
	       		  pass = RecordStore.openRecordStore("UP" , true);
	       		  
                  String time = Long.toString(System.currentTimeMillis());
	       		 
	       		  byte plainBytesSec[]=time.getBytes();
                  MD5 md5 = new MD5(plainBytesSec);
                  byte[] resultSec = md5.doFinal();
                  Constant.SEC_MD5 = md5.toHex(resultSec);
                  
                  
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