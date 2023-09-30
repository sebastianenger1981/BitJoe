package de.hgnut.GnuUtil;
import javax.microedition.io.*;
import java.io.*;
import java.util.*;
import de.hgnut.GnuUtil.Messages.*;
import de.hgnut.Main;

public class GnuConnection extends Thread{
/************ KONSTANTEN UND VARIABLE ANFANG*/
private SocketConnection sc;
private InputStream in; 
private OutputStream out;
private String remote_ip;
private int remote_port;
private int MODUS = -1;
private boolean ultrapeer = false;
private boolean stopped = false;
private Vector messageBacklog = new Vector();
private SearchReplyMessage sr = null;
/**********************************************/
public boolean statuscon = false;
public boolean statusdownload = false;
public Vector HitMessages = new Vector();
public String filename;
public byte[] file;
protected AsyncSender asyncSender;
/**************************************************/
private final static String SERVER_READY = "GNUTELLA OK\n\n";
private final static String SERVER_REJECT = "JTella Reject\n\n";
private final static String V06_CONNECT_STRING = "GNUTELLA CONNECT/0.6\r\n";
private final static String V06_CONNECT_STRING_COMPARE = "GNUTELLA CONNECT/0.6";
private static final String V06_SERVER_DOWNLOADREADY_COMPARE ="HTTP/1.1 200 OK";
private final static String V06_SERVER_READY = "GNUTELLA/0.6 200 OK\r\n";
private final static String V06_SERVER_READY_COMPARE = "GNUTELLA/0.6 200";
private final static String V06_SERVER_REJECT = "GNUTELLA/0.6 503 Service Unavailable\r\n";
private final static String V06_AGENT_HEADER ="User-Agent: JTella 0.8\r\n";
private final static String V06_X_ULTRAPEER ="X-Ultrapeer: false\r\n";
private final static String V06_X_ULTRAPEER_NEEDED = "X-Ultrapeer-Needed: true\r\n";
private final static String V06_X_TRY_ULTRAPEERS_COMPARE = "X-Try-Ultrapeers:";
private final static String CRLF = "\r\n";
/**************************************************/
public final static int SEARCH  = 0;
public final static int DOWNLOAD= 1;
/************ Konstruktoren Anfang*/
public GnuConnection(){}

public GnuConnection(SearchReplyMessage sr){
	this.sr = sr;
	this.remote_ip =sr.getIPAddress();
	this.remote_port = sr.getPort();
	this.MODUS = DOWNLOAD;
	this.filename = sr.getFileRecord(0).getName();
	this.file = new byte[sr.getFileRecord(0).getSize()];
}

public GnuConnection(String ip, int port, int modus){
	this.remote_ip=ip;
	this.remote_port=port;	
	this.MODUS=modus;
}
/************ Konstruktoren Ende*/
/************ extends Thread Anfang*/
public void run(){
	if(this.MODUS==0)
		runSearch();
	if(this.MODUS==1)
		runDownload();
}
/***********************************/
private void runDownload(){
	try{
		sc = (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port);
		sc.setSocketOption(SocketConnection.LINGER, 5);
		//Nur die etablierten Connections könnend ie IP auslesen, da sonst nicht klar über welchen der x Anschlüsse es gehen soll
		//wird vor allen von den Messages benötigt
		Main.myipaddress = sc.getLocalAddress();
		Main.myport = sc.getLocalPort();
		in = sc.openInputStream();
		out = sc.openOutputStream();
		String greetingData =
			"GET /get/"+sr.getFileRecord(0).getIndex()+"/"+sr.getFileRecord(0).getName()+" HTTP/1.1"+CRLF
		    	+V06_AGENT_HEADER
			+"Host:"+Main.myipaddress+":"+Main.myport+CRLF
	    		+"Connection: Keep-Alive"+CRLF
	    		+"Range: bytes=0-"+CRLF
	    		+CRLF;
		System.out.println(greetingData);
		out.write(greetingData.getBytes());
		out.flush();
		String response = readLine(in);
		System.out.println("Recieved greeting response: " + response);
		System.out.println("from host: " + remote_ip);
		boolean result=true;
		if (!response.startsWith(V06_SERVER_DOWNLOADREADY_COMPARE)){
			System.out.println("Connection rejection: " + remote_ip);				
			result = false;
		}
		if(result){
			response = readLine(in);
			while(response!=null&&response.length()!=0){
				System.out.println(response);
				response = readLine(in);
			}
			for(int i=0;i<file.length;i++){
				file[i] = (byte)in.read();
			}
			statusdownload = true;
			System.out.println("Ende download");
		}
		/*HTTP/1.1 200 OK<cr><lf>
	    	Server: Gnutella<cr><lf>
		Content-type: application/binary<cr><lf>
		Content-length: 4356789<cr><lf>
		<cr><lf>*/
		//aufräumen
		in.close();
		out.close();
		sc.close();
		statuscon = false;
		System.out.println("GnuDownloadConnetion stopped!");
	}catch(Exception e){
		System.out.println("GnuConnection.runDownload()->aussen catch()");
		e.printStackTrace();
	}
}
/***********************************/
private void runSearch(){
	try{
		sc = (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port);
		sc.setSocketOption(SocketConnection.LINGER, 5);
		//Nur die etablierten Connections könnend ie IP auslesen, da sonst nicht klar über welchen der x Anschlüsse es gehen soll
		//wird vor allen von den Messages benötigt
		Main.myipaddress = sc.getLocalAddress();
		Main.myport = sc.getLocalPort();
		in = sc.openInputStream();
		out = sc.openOutputStream();
		String greetingData = V06_CONNECT_STRING
			+ V06_AGENT_HEADER
			+ V06_X_ULTRAPEER
			+ V06_X_ULTRAPEER_NEEDED
			+ "Listen-IP: "+Main.myipaddress+":"+Main.myport+CRLF
			+ "Remote-IP: "+ remote_ip+":"+remote_port+CRLF
			+ CRLF;
		out.write(greetingData.getBytes());
		out.flush();

		String response = readLine(in);
		System.out.println("Recieved greeting response: " + response);
		System.out.println("from host: " + remote_ip);

		boolean result=true;			
		if (!response.startsWith(V06_SERVER_READY_COMPARE)){
			System.out.println("Connection rejection: " + remote_ip);				
			result = false;
		}
			
		/*
		Hier werden die auf jeden Fall mitgelieferten UltraPeers auseinandergenommen
		*/
		boolean foundXTryUltrapeers = false;
		boolean foundXUltrapeer = false;

		while (response != null) {
			if (response.startsWith(V06_X_TRY_ULTRAPEERS_COMPARE)){
				foundXTryUltrapeers = true;
			}
			// Look for ultrapeer status of node
			if ((response.equals("X-Ultrapeer: true"))||
			    (response.equals("X-Ultrapeer: yes"))){
				ultrapeer = true;
				foundXUltrapeer = true;
			}
			if (foundXTryUltrapeers && foundXUltrapeer){
				break;
			}
			response = readLine(in);
			System.out.println(response);
		}
	
		if (result) {
			out.write((V06_SERVER_READY + CRLF).getBytes());
			out.flush();	
			System.out.println("Connection started on: " + remote_ip);			
			//AsyncSender starten
			asyncSender = new AsyncSender();
			asyncSender.start();
			
			//Connection aufgebaut, ab jetzt wird gelauscht und geantwortet
			while(!stopped){
				short[] message = new short[23];
				for (int i = 0; i < message.length; i++){
					try {
						message[i] = (short)in.read();						
					}catch (IOException io) {
						System.out.println("sending keepAlive Ping");
						PingMessage keepAlivePing = new PingMessage();
						keepAlivePing.setTTL((byte)1);
						send(keepAlivePing);						
					}
				}
				if(message[0]==-1){
					System.out.println("message[0]==-1");
					PingMessage keepAlivePing = new PingMessage();
					keepAlivePing.setTTL((byte)1);
					send(keepAlivePing);
				}
				
				Message readMessage = MessageFactory.createMessage(message,this);
				if (null == readMessage) {
					System.out.println("MessageFactory.createMessage() returned null");
					continue;
				}
				int payloadSize = readMessage.getPayloadLength();
				if (!readMessage.validatePayloadSize()){
					System.out.println(
						"Received invalid message from: "
							+ remote_ip
							+ ", message type: "
							+ readMessage.getType());
					continue;
				}
				
				if (payloadSize > 0) {
					short[] payload = new short[payloadSize];
					// Read the payload
					for (int p = 0; p < payloadSize; p++) {
						payload[p] = (short)in.read();
					}
					readMessage.addPayload(payload);
				}
				if(readMessage instanceof SearchReplyMessage){
					HitMessages.addElement(readMessage);
					int filecount = ((SearchReplyMessage)readMessage).getFileCount();
					System.out.println("----------------------");
					System.out.println(((SearchReplyMessage)readMessage).getIPAddress());
					System.out.println(((SearchReplyMessage)readMessage).getPort());
					for(int z=0;z<filecount;z++){
						SearchReplyMessage.FileRecord fr =((SearchReplyMessage)readMessage).getFileRecord(z);						
						System.out.println(fr.getName());
						System.out.println(fr.getIndex());		
						System.out.println(fr.getSize());		
						System.out.println(fr.getHash());		
					}
					
				}
				//if(readMessage instanceof SearchMessage)
				//	System.out.println("SearchCriteria : "+((SearchMessage)readMessage).getSearchCriteria());
				//System.out.println("Read message from " + remote_ip + " : " + readMessage.toString());
				if (readMessage instanceof PingMessage) {
					System.out.println("Responding to ping");
					PongMessage pong = new PongMessage(readMessage.getGUID(),(short)6346,"127.0.0.1",0,0);
					pong.setTTL((byte)readMessage.getTTL());
					send(pong);
				}
			}
			//aufräumen
			in.close();
			out.close();
			sc.close();
			statuscon = false;
			System.out.println("GnuSearchConnetion stopped!");
		}
	}catch(Exception e){
		System.out.println("GnuConnection.runSearch()->aussen catch()");
		e.printStackTrace();
	}
}
/************ extends Thread Ende*/
//schliesst die ganze scheisse
public void stop(){
	this.stopped=true;
	if(this.asyncSender!=null){
		this.asyncSender.shutdown=true;
		synchronized (asyncSender) {
			asyncSender.notify();
		}
	}
}
/******************************/
//liest eine zeile aus dem inputstream
public static String readLine(InputStream in) {
	try{
		StringBuffer line = new StringBuffer();
		int i;
		while ((i = in.read()) != -1) {			
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
			GnuConnection.this.statuscon=true;
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
/*******************************************************************************/
}/*class*/