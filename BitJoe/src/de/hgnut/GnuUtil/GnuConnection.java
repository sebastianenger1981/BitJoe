package de.hgnut.GnuUtil;


import javax.microedition.io.*;
import java.io.*;
import java.util.*;
import de.hgnut.GnuUtil.Messages.*;
import de.hgnut.Misc.*;
import de.hgnut.*;
//++++++++++++++++++++++++++++++++
//import com.tinyline.util.GZIPInputStream;
import com.jicoma.ic.Crypt;
//import com.jicoma.ic.ConnectionTimer;
//++++++++++++++++++++++++++++++++
public class GnuConnection extends Thread{
/************ KONSTANTEN UND VARIABLE ANFANG*/
private SocketConnection sc;
private InputStream in; 
private OutputStream out;
private String remote_ip;
private int remote_port;
private Vector messageBacklog = new Vector();
private ProxySearchReply psc=null;
private String myipaddress;
private int myport;
/**********************************************/
public boolean statusdownload = false;
public boolean statussave = false;
public boolean finished = false;
public Vector HitMessages = new Vector();
public String filename;
public int fileindex;
public long filesize;
public long id = 0L;
//+++++++++++++++++++++++++++++++++++++++++++++++++++
//public static String zipString;
//+++++++++++++++++++++++++++++++++++++++++++++++++++
protected AsyncSender asyncSender;
/**************************************************/
private final static String V06_CONTENT_LENGTH="Content-Length:";
private final static String V06_SERVER_DOWNLOADREADY_COMPARE1 ="HTTP/1.1 200 OK";
private final static String V06_SERVER_DOWNLOADREADY_COMPARE2 ="HTTP 200 OK";
private final static String V06_SERVER_DOWNLOADREADY_COMPARE3 ="HTTP/1.1 206 Partial Content";
private final static String V06_SERVER_DOWNLOADREADY_COMPARE4 ="HTTP 206 Partial Content";
//private final static String V06_AGENT_HEADER ="User-Agent: BitJoe 0.8\r\n";
//private final static String V06_AGENT_HEADER ="User-Agent: mutella mod 0.4.5\r\n";
private final static String V06_AGENT_HEADER ="User-Agent: Gnutella/0.4\r\n";
private final static String CRLF = "\r\n";
private String TOSAVE;
//++++++++++++++++++++++++++++++++++++++++++++++++++
private Crypt cr;
private long bytes = 0L;
//++++++++++++++++++++++++++++++++++++++++++++++++++
/**************************************************/
public final static int SEARCH  = 0;
public final static int DOWNLOAD= 1;
/************ Konstruktoren Anfang*/
public GnuConnection(){}

public GnuConnection(ProxySearchReply psc, String TOSAVE, Crypt cr){
	this.psc = psc;	
	this.TOSAVE = TOSAVE;
	this.cr=cr;
	//this.filesize = psc.getFileSize();
	//this.file = new byte[filesize];	
}

public GnuConnection(ProxySearchReply psc){
	this.psc=psc;	
	//this.filesize = psc.getFileSize();
	//this.file = new byte[filesize];	
}
/************ Konstruktoren Ende*/
/************ extends Thread Anfang*/
public void run(){
	runDownload();
}
/***********************************/
private void runDownload(){	
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Constant.time = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//Thread aclt = new ProxyDownloadAck(Constant.PROXY_IP,Constant.PROXY_PORT,1,psc, cr);
	//aclt.start();
	int z = 0;
//++++++++++++++++++++++++++++++++++++++++++	
	//int z = Constant.index;
//++++++++++++++++++++++++++++++++++++++++++	
	boolean t = true;
	//MERKEN KEINE WHILE ODER DO{}WHILE SCHLEIFEN MIT MEHREREN PARAMETERN: BRINGEN NUR SCHEISSE
	while(t){
		try{
			//response = null;
			this.remote_ip = ((String)psc.getSource(z)[0]);
			this.remote_port = ((Integer)psc.getSource(z)[1]).intValue();
			this.filename = ((String)psc.getSource(z)[3]);
			this.fileindex = ((Integer)psc.getSource(z)[2]).intValue();
					
			int a = z+1;
			Constant.label ="Versuch: "+a+"/"+psc.getSourcesCount()+"      ";
			System.out.println("Versuche Connection zu "+a+" Versuch: "+a+"/"+psc.getSourcesCount() +". Quelle "+this.remote_ip+":"+this.remote_port);
			try {
                Thread.currentThread().sleep(1000);
            } catch (InterruptedException err) {
            }
            
            
              System.out.println("vor socketConnection");
			  sc = (SocketConnection)Connector.open("socket://"+this.remote_ip+":"+this.remote_port,Connector.READ_WRITE, true);
			  sc.setSocketOption(SocketConnection.LINGER, 5);
			  System.out.println("nach socketConnection");	
			  //sc.setSocketOption(SocketConnection.KEEPALIVE, 5);
			//Nur die etablierten Connections könnend ie IP auslesen, da sonst nicht klar über welchen der x Anschlüsse es gehen soll
			//wird vor allen von den Messages benötigt
			//ConnectionTimer ct = new ConnectionTimer(sc, response);
			//ct.start();
			
			this.myipaddress = sc.getLocalAddress();
			this.myport = sc.getLocalPort();
			Constant.myipaddress =this.myipaddress;
			Constant.myport=this.myport;
			
			
			out = sc.openOutputStream();
			/*String greetingData =
				"GET /get/"+fileindex+"/"+filename+" HTTP/1.1"+CRLF
			    	+V06_AGENT_HEADER
				+"Host:"+this.myipaddress+":"+this.myport+CRLF
		    		+"Connection: Keep-Alive"+CRLF
		    		+"Range: bytes="+bytes+"-"+CRLF
		    		+CRLF;*/
		    //System.out.println("filename :"+ filename);		
		    String greetingData =			  
				"GET /get/"+fileindex+"/"+urlEncoder(filename)+" HTTP/1.1"+CRLF
			    	+V06_AGENT_HEADER
				+"Host:"+this.myipaddress+":"+this.myport+CRLF
		    		+"Connection: Keep-Alive"+CRLF
		    		+"Range: bytes="+bytes+"-"+CRLF
		    		+CRLF;
		    		
		    //System.out.println("greetingData :"+ greetingData);
		    							
			out.write(greetingData.getBytes());
			out.flush();
			
			in = sc.openInputStream();
			//System.out.println("response: "+ response);
			String response = readLine(in,CRLF);
			System.out.println("Recieved greeting response: " + response);
			System.out.println("from host: " + remote_ip);
			boolean result=true;
			System.out.println("Response: "+response);
			if (!response.startsWith(V06_SERVER_DOWNLOADREADY_COMPARE1)&&!response.startsWith(V06_SERVER_DOWNLOADREADY_COMPARE2)&&!response.startsWith(V06_SERVER_DOWNLOADREADY_COMPARE3)&&!response.startsWith(V06_SERVER_DOWNLOADREADY_COMPARE4)){
				//System.out.println("Connection rejection: " + remote_ip);				
				result = false;
			}
			if(result){
				response = readLine(in,CRLF);
				while(response!=null&&response.length()!=0){
					System.out.println(response);
					if(response.startsWith(V06_CONTENT_LENGTH)){
						String tmp = response.substring(response.indexOf(":")+1);
						this.filesize = Integer.parseInt(tmp.trim());
					}
					response = readLine(in,CRLF);
				}
				//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				Constant.label ="Download:         ";
				Constant.holeTime = filesize;
				//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				if(!(bytes > 0))
				FileBrowser.openFileForWrite(this.TOSAVE);
				//if(bytes > 0)
				//in.skip(bytes);
				int d = 100;
				for(this.id=bytes;this.id<filesize;this.id++){
					if(statusdownload)break;
				//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
					Constant.time = this.id;
					bytes = this.id;
					d++;
					if(d > 100){
					  Constant.label ="Download: " + (this.id*100)/filesize +" %";
					  d=0;
					}
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
					if(!FileBrowser.appendToOpendFile(in.read())){
						System.out.println("Download unterbrochen");
						in.close();
					}
					//if(bytes == 3000){
					//	System.out.println("Download unterbrochen : "+ bytes);
					//	in.close();
					//}	
				}
				statusdownload = true;
				statussave = FileBrowser.closeOpendFile();
				if(!statussave){
					System.out.println("kurz vor opend delete");
					FileBrowser.deleteOpendFile();
				}
				if(bytes + 1 < filesize){
					System.out.println("kurz vor  deleteFileorDir bytes:"+ bytes + " filesize: "+ filesize);
					FileBrowser.delFileOrDir(this.TOSAVE);
				}	
				System.out.println("Ende download");
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				Constant.pbDone = true;
				Constant.time = 0;
				Constant.holeTime = Constant.firstWaitTimer;
				Constant.label="Versuch 1:  0 %     ";
				bytes = 0;
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			}			
			in.close();
			out.close();
			sc.close();
		}catch(Exception e){
			//Constant.label ="bin in catch";
			try {
                Thread.currentThread().sleep(1000);
            } catch (InterruptedException err) {
            }
			System.out.println("GnuConnection.runDownload()->aussen catch()");
			e.printStackTrace();
			if(statusdownload){
				z=psc.getSourcesCount();
			}else{	
			 statusdownload = false;
			 statussave = false;
			}	
		}
		//Besser raus aus dem try catch um unbedingtes zählen zu erzwingen
		z++;
		if(statusdownload)t=false;
		if(!(z<psc.getSourcesCount()))t=false;
	}
	System.out.println("GnuDownloadConnetion stopped!");
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		Constant.pbDone = true;
		Constant.time = 0;
		Constant.holeTime = Constant.firstWaitTimer;
		Constant.label="Versuch 1:  0 %     ";
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	psc.finished = statusdownload&&statussave;
	finished=true;
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//aclt = new ProxyDownloadAck(Constant.PROXY_IP,Constant.PROXY_PORT,psc.finished?2:3,psc, cr);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//aclt.start();
}
public void stopDownload(){
	try{
	 //System.out.println("gnu unterbrochen");
	 this.id = filesize;
	 //System.out.println("filezize: "+ filesize);	
	 statusdownload = true;	
	 in.close();
	 out.close();
	 sc.close();
	 //System.out.println("lösche! kurz vor opend delete");
     FileBrowser.deleteOpendFile();
	}catch(Exception e){
	}		 
}	
/************ extends Thread Ende*/
//schliesst die ganze scheisse
public void stop(){
	if(this.asyncSender!=null){
		this.asyncSender.shutdown=true;
		synchronized (asyncSender) {
			asyncSender.notify();
		}
	}
}
/********************************/
//fügt eine message der todo-liste hinzu und informiert den AsyncSender
public void send(Message msg){
	messageBacklog.addElement(new MessageData(msg,false));
	synchronized (asyncSender) {
		asyncSender.notify();
	}
}
/*******************************************************************************/
/**
* Message data stored in the message backlog
*
*/
class MessageData{
	private Message message;
	private boolean priority;
	
	/**
	* Constructs message data
	*
	* @param message GNUTella message
	* @param priority priority messages are not subject to dropping
	*/
	MessageData(Message message, boolean priority){
		this.message = message;
		this.priority = priority;
	}
	
	/**
	* Get the message
	*
	* @return message
	*/
	Message getMessage(){
		return message;
	}
	
	/**
	* Check if this is a priority message. Generally, messages originated by
	* the JTella servant are considered priority messages
	*
	* @return priority flag
	*/
	boolean isPriority() {
		return priority;
	}
}

/*******************************************************************************/
/**
* Provides a mechanism to send a message and handle the problem of
* blocking on write, due to an unresponsive servant on the connection
 *
 */
class AsyncSender extends Thread {
	private boolean shutdown = false;
	
	AsyncSender(){}
	
	public Message getMessage() {
		int size = messageBacklog.size();
		
		while (0 == size && !shutdown) {
			try {
				synchronized (this){wait();}				
			}catch (InterruptedException ie){				
				System.out.println("AsnycSender.getMessage()");
				ie.printStackTrace();
			}
			size = messageBacklog.size();
		}
		
		if (shutdown){
			return null;
		}
		Message tmp = ((MessageData)messageBacklog.elementAt(0)).getMessage();
		messageBacklog.removeElementAt(0);
		return tmp;
	}
		
	public void run(){
		while(!shutdown){
			Message message = getMessage();
			if (message != null) {
				try {
					byte[] messageBytes = message.getByteArray();
					GnuConnection.this.out.write(messageBytes);
					GnuConnection.this.out.flush();
				}catch (Exception e) {
						System.out.println("AsyncSener.run()->catch");
						e.printStackTrace();
				}
			}
		}
		System.out.println("AsyncSender sagt tschuess!");
	}	
}
/******************************/
//liest eine zeile aus dem inputstream
public static String readLine(InputStream in, String delim){
	try{		
		StringBuffer line = new StringBuffer();
		int i;
		while ((i = in.read()) != -1){
			char c = (char)i;
			if (c == '\n') break;
			if (c == '\r') ;
			else line.append(c);		
		}

		if (line.length() == 0)
			return null;
	
		return line.toString();
	}catch(Exception e){
		System.out.println("redline catch");
		e.printStackTrace();
		return null;
	}
}
/*******************************************************************************/
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Liest eine Zeile aus dem GZIPInputStream
	public static String readLine(GZIPInputStream in){
	try{		
		StringBuffer line = new StringBuffer();
		int i;
		while ((i = in.read()) != -1){
			char c = (char)i;
			//if (c == '#');
			if (c == '\n') break;
			if (c == '\r') ;
			/*if (c == '#') break;
			if (c == '\t') ;*/
			else line.append(c);		
		}
		if (line.length() == 0)
			return null;
				
		return line.toString();
	}catch(Exception e){
		System.out.println("redline catch GZIP");
		e.printStackTrace();
		return null;
	}
  }
 public static String readResult(GZIPInputStream in){
	try{		
		StringBuffer line = new StringBuffer();
		int i;
		while ((i = in.read()) != -1){
			char c = (char)i;
			if (c == '#') break;
			if (c == '\n') break;
			if (c == '\r') ;
			//if (c == '#') break;
			//if (c == '\t') ;
			else line.append(c);		
		}
		if (line.length() == 0)
			return null;
			
		//System.out.println("ReadResult:"+ line.toString());		
		return line.toString();
	}catch(Exception e){
		System.out.println("redline catch GZIP");
		e.printStackTrace();
		return null;
	}
  } 
  public String urlEncoder(String s) {
		if (s == null)
			return s;
		StringBuffer sb = new StringBuffer(s.length() * 3);
		try {
			char c;
			for (int i = 0; i < s.length(); i++) {
				c = s.charAt(i);
				if (c == '&') {
					sb.append("&amp;");
				} else if (c == ' ') {
					sb.append('+');
				} else if (
					(c >= ',' && c <= ';')
						|| (c >= 'A' && c <= 'Z')
						|| (c >= 'a' && c <= 'z')
						|| c == '_'
						|| c == '?') {
					sb.append(c);
				} else {
					sb.append('%');
					if (c > 15) { // is it a non-control char, ie. >x0F so 2 chars
						sb.append(Integer.toHexString((int)c)); // just add % and the string
					} else {
						sb.append("0" + Integer.toHexString((int)c));
						// otherwise need to add a leading 0
					}
				}
			}
 
		} catch (Exception ex) {
			return (null);
		}
		return (sb.toString());
	}   
	
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}/*class*/