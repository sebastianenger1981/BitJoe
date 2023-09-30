import javax.microedition.io.*;
import java.io.*;

class Server implements Runnable{

private static boolean dorun=false;
public void run(){
	boolean inited = false;
	while(!inited)
	try{
		init();
		inited=true;
		dorun=true;
	}catch(Exception e){
		System.out.println("Caugth Exception in Server.java Anfang");
		e.printStackTrace();
		System.out.println("Caugth Exception in Server.java Ende");
		inited=false;
	}
}

static void stop(){
	dorun=false;
}

public static void init()throws IOException{
	// Create the server listening socket for port 3141 
	ServerSocketConnection scn = (ServerSocketConnection)Connector.open("socket://:3142");
	while(dorun){
		   // Wait for a connection. Hier wartet er wirklich!!!!
		   //Das muss man also nutzen
		   SocketConnection sc = (SocketConnection) scn.acceptAndOpen();
		
		   // Set application specific hints on the socket.
		   sc.setSocketOption(SocketConnection.DELAY, 0);
		   sc.setSocketOption(SocketConnection.LINGER, 0);
		   sc.setSocketOption(SocketConnection.KEEPALIVE, 1);
		   sc.setSocketOption(SocketConnection.RCVBUF, 128);
		   sc.setSocketOption(SocketConnection.SNDBUF, 128);
		
		   // Get the input stream of the connection.
		   DataInputStream is = sc.openDataInputStream();
		
		   // Get the output stream of the connection.
		   DataOutputStream os = sc.openDataOutputStream();
	
		System.out.print("Server Lese a = ");
		//int a = is.readByte();
		int a = is.read();
		System.out.println(a);
		System.out.print("Server Lese b = ");
		int b = is.read();
		System.out.println(b);
		System.out.println("Server schreibe c ="+a*b);
		try{
		os.write(a*b);}catch(Exception e){e.printStackTrace();}		
	
	   	// Read the input data.
   		//String result = is.readUTF();
   		// Echo the data back to the sender.
   		//os.writeUTF(result);
		   // Close everything.
		   is.close();
		   os.close();
		   sc.close();		  
	}
  }
}