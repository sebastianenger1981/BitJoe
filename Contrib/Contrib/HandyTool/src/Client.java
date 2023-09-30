import javax.microedition.io.*;
import java.io.*;

class Client implements Runnable{
	private static Client me;
	public static void start(){
		me = new Client();
		Thread t = new Thread(me);
		t.run();
	}
	public static void stop(){}
	
	public void run(){
		boolean inited = false;
		while(!inited)
		try{
			init();
			inited=true;
		}catch(Exception e){
			System.out.println("Caugth Exception in Client.java Anfang");
			e.printStackTrace();
			System.out.println("Caugth Exception in Client.java Ende");
			inited=false;
		}
	}
	
public static void init() throws IOException{
	SocketConnection sc = (SocketConnection)Connector.open("socket://localhost:3141");
	sc.setSocketOption(SocketConnection.LINGER, 5);
	InputStream in = sc.openInputStream();
    	OutputStream out = sc.openOutputStream();
    	System.out.println("Client Schreibe a = 4");
    	out.write(4);
    	System.out.println("Client Schreibe b = 5");
    	out.write(5);
    	    	
    	StringBuffer ret = new StringBuffer();
    	int ch = 0;
	do{
		ch = in.read();
		System.out.println("Client Lese c ="+ch);
	}while(ch != -1);
	//MERKE; NIE EINEN TEIL SCHLIESSEN SOLANGE DAS GANZE NOCH BENÖTIGT WIRD!
	out.close();
	in.close();
	sc.close();
//    	System.out.println( "ret"+ret );    	
  }
}