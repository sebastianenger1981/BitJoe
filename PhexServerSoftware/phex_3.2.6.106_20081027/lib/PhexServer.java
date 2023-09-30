
package com.jicoma.ic; 

//import phex.gui.tabs.search.cp.KeywordSearchBox;
import phex.gui.tabs.search.cp.SearchControlPanel;
import java.net.*;
import java.io.*;
import javax.swing.*;
import phex.gui.tabs.search.SearchTab;
import java.util.ArrayList;
import phex.download.RemoteFile;
import phex.gui.tabs.search.cp.SearchActivityBox;
import phex.gui.tabs.search.SearchResultsDataModel;
import phex.gui.tabs.search.filterpanel.QuickFilterPanel;
import java.util.Hashtable;
import phex.gui.tabs.search.SearchListPanel;
import com.jicoma.ic.PhexServerThread;

public class PhexServer implements Runnable{
        
 private ServerSocket service;
 //private KeywordSearchBox ksb;
 private SearchControlPanel scp;
 private SearchResultsDataModel srdm;
 private SearchListPanel slp;
 private ArrayList<String> al;
 private RemoteFile rf;
 private StringBuffer sb;
 private Hashtable ht;
 private final String z = ";!$#%&";
 private PrintWriter sending;
 private String token = "";
 
   //public PhexServer(KeywordSearchBox ksb){
   public PhexServer(SearchControlPanel scp, SearchListPanel slp){
   	 this.scp=scp;
   	 this.slp=slp;
   	 al = new ArrayList(); 
    	try{
        service = new ServerSocket(BitJoePrefs.PhexServerPortSetting.get());
        }catch(IOException e){
        	System.out.println(e);
        }
        try {
        	String text ="";
           BufferedReader in = new BufferedReader(new FileReader("token.conf"));
           if((text = in.readLine()) != null){
           	 token = text;
           }	 
           in.close();
           }
        catch (IOException e) {
           System.out.println("Datei token.conf nicht gefunden");
           System.exit(-1); 
        }
        ht = new Hashtable();
        try {
        	String text ="";
           BufferedReader in = new BufferedReader(new FileReader("whitelist.conf"));
           while((text = in.readLine()) != null){
           	 al.add("/"+text);
           	 //System.out.println(text);
           }	 
           in.close();
           }
        catch (IOException e) {
           System.out.println("Datei whitelist.conf nicht gefunden");
           System.exit(-1); 
        }
       		 
    }
    private boolean checkIp(String ip){
    	if(ip.length() > 7){
    		if(al.contains(ip)){
    			return true;
    		}else{
    			return false;
    		}		
    		
    	}else{
    		return false;
    	}	
    }		
     
     
    public void run(){ 
        Socket socket = null;
        while(true){
        	try{
        		socket = service.accept();
          //System.out.println(serverSocket.getInetAddress());
          //if(socket.getInetAddress().toString().endsWith("127.0.0.1")){
          if(checkIp(socket.getInetAddress().toString())){	
	        new PhexServerThread(scp,slp,token,socket,ht).start();
	         Thread.sleep(BitJoePrefs.SocketDelaySetting.get());
	         while(scp.getBlock()){
	        	Thread.sleep(BitJoePrefs.SocketDelaySetting.get());
	         }	
	        
	      }else{
	      	socket.close();
	      }	
           	  
           	}catch(IOException ioe){
           		ioe.printStackTrace();
            }catch(InterruptedException ie){
            	ie.printStackTrace();
            }			
        }	
    }
    
}
