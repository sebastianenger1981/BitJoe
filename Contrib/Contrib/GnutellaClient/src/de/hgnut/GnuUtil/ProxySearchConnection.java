package de.hgnut.GnuUtil;

import javax.microedition.io.*;
import java.io.*;
import java.util.*;
import de.hgnut.GnuUtil.*;
import de.hgnut.*;
import de.hgnut.GnuUtil.Messages.*;
import de.hgnut.Misc.*;

public class ProxySearchConnection extends Thread{
/***************************************************/
	private String remote_ip;
	private int remote_port1;
	private SocketConnection sc;
	private InputStream in; 
	private OutputStream out;
	private String to_search;
	private final static String CRLF = "\r\n";
/***************************************************/
	public ProxySearchConnection(String ip, int port1, String to_search){
		this.remote_ip   = ip;
		this.remote_port1 = port1;
		this.to_search=to_search;
	}
/***************************************************/
	public void run(){
		try{
			sc = (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port1);
			sc.setSocketOption(SocketConnection.LINGER, 5);
			//Nur die etablierten Connections k�nnend ie IP auslesen, da sonst nicht klar �ber welchen der x Anschl�sse es gehen soll
			//wird vor allen von den Messages ben�tigt #
			//hier wird es nicht ben�tigt, da keine GnuConnedction, aber feststellen kann ja nicht schaden
			Main.myipaddress = sc.getLocalAddress();
			Main.myport = sc.getLocalPort();
			in = sc.openInputStream();
			out = sc.openOutputStream();
			//SearchString raushauen
			String SearchString ="FIND "+to_search+CRLF;
			out.write(SearchString.getBytes());
			out.flush();
			
			//jetzt lese ich die ID der Suche aus, die ich zur�ckbekomme
			//noch nicht, haben noch keine ID
			String response = GnuConnection.readLine(in);
			System.out.println(response);
			//in.close();
			//out.close();
			//sc.close();
			//Warte 30secs. und hole Suchergebnis
			//this.wait(3000);
			/*sc = (SocketConnection)Connector.open("socket://"+remote_ip+":"+remote_port2);
			Main.myipaddress = sc.getLocalAddress();
			Main.myport = sc.getLocalPort();
			in  = sc.openInputStream();
			out = sc.openOutputStream();
			String line = GnuConnection.readLine(in);
			while(line!=null&&line.length()>0){
				System.out.println(line);
				line = GnuConnection.readLine(in);
			}*/
			//fertige eine SearchReplyMessage wie aus Gnutella bekannt (Download ist darauf vorbereitet)
			//Starte Downloadconnection mit SearchReplyMessage
			//30 secs warten

			
		}catch(Exception e){
			System.out.println("ProxySearchConnection.run()");
			e.printStackTrace();
		}

	}
/***************************************************/
}