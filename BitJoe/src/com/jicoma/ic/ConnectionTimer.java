package com.jicoma.ic;

import javax.microedition.io.SocketConnection;
import java.io.IOException;

public class ConnectionTimer extends Thread{
	
    SocketConnection sc;
    String response;
	
	public ConnectionTimer(SocketConnection sc, String response){
		this.sc = sc;
		this.response = response;
		//System.out.println("Hier komnt der wert: " +SpecialPane.sp);
		
	}
	
	public void run(){
		//System.out.println("SearchDelete Timer run");
		try{
			//System.out.println(BitJoePrefs.OldTimeSetting.get());
			this.sleep(10000);
			
		}catch(InterruptedException ie){
			System.out.println("Interrupted Exception: " + ie);
		}
		System.out.println("Response ConnectionTimer: "+ response);
		/*try{
		 sc.close();
		}catch(IOException ioe){
			System.out.println("ConnectionTimer: "+ ioe);
		}*/	 
		//System.out.println(ht +" "+ input);
					
	}		
}	