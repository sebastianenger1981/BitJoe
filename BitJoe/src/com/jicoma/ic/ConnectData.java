package com.jicoma.ic;

import java.util.Vector;
import java.util.Random;
import javax.microedition.rms.RecordStore;


public class ConnectData{
	
	
	public int prior;
	public int port;
	public String ip;
	public int version;
	
	public int number;
	public int nr = 0;
	
	public int sum = 0;
	
	public String dataA[][];
	public String dataPlain;
	
	private Random random;
	 
	public ConnectData(String data){
	   try{	
		RecordStore rs = RecordStore.openRecordStore("CD" , false);
		
		this.dataPlain = new String(rs.getRecord(1));
		
		System.out.println("plain data aus Record store: "+dataPlain);
		rs.closeRecordStore();
		
		newData(dataPlain);
		
	   }catch(Exception e){
	   	System.out.println("Hier in cd exception");
	    	newData(data);
	   }		
	
		random = new Random();
	}
	public void newData(String data){
		
		System.out.println("ConnectDate: "+ data);
		Vector dataVec = split(data, ";");
		    this.version=Integer.parseInt((dataVec.elementAt(0).toString()).substring(2));
		    System.out.println("Version: "+ version);
		    dataA = new String[dataVec.size()-1][3];
		    Vector dataPart;
			for(int i = 1; i < dataVec.size(); i++){
				 dataPart = split(dataVec.elementAt(i).toString(), ":");
				 
				 dataA[i-1][0]=dataPart.elementAt(0).toString();
				 //System.out.println("ip : "+dataA[i-1][0]);
				 
				 dataA[i-1][1]=dataPart.elementAt(1).toString();
				 //System.out.println("port : "+dataA[i-1][1]);
				 
				 dataA[i-1][2]=dataPart.elementAt(2).toString();
				 sum = sum + Integer.parseInt(dataA[i-1][2]);
				 //System.out.println("prio : "+dataA[i-1][2]);
				  	
			}
			//System.out.println("Summe aller priors: "+ sum);
			
			random = new Random(); 
	}
	
	public void setRec(String data){
		System.out.println("Write to record");
		try{
          RecordStore.deleteRecordStore("CD");
        }catch(Exception e){
        	System.out.println("Fehler delete");
        }
        
		try{	
		RecordStore rs = RecordStore.openRecordStore("CD" , true);
		
		byte bytesR1[] = data.getBytes();
    	rs.addRecord(bytesR1 ,0, bytesR1.length);
		rs.closeRecordStore();
		
	   }catch(Exception e){
	   	System.out.println("Hier in cd write exception");
	    	
	   }
	}
	public String getIp(){
		
		int rand = random.nextInt(sum-1)+1;
		int count= 0;
		//System.out.println("Random: "+rand);
		for(int i = 0; i < dataA.length; i++){
			count = count + Integer.parseInt(dataA[i][2]);
			if(rand <= count){
				this.ip = dataA[i][0];
				this.port = Integer.parseInt(dataA[i][1]);
				this.number = i;
				break;
			}
		}
		//System.out.println("random IP: "+ ip);
		return ip;
	}
	public String getNextIp(){
		if(number == nr){
			nr++;
			System.out.println("fasche nummer : "+ nr);
		}
		if(nr < dataA.length){
		  this.ip = dataA[nr][0];
		  this.port = Integer.parseInt(dataA[nr][1]);
		  nr++;
		  return ip;	
		}else{
			return "0";
		}
	}
	
	public int getPort(){
		return port;
	}
	public int getVersion(){
		return version;
	}
	
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
    
}