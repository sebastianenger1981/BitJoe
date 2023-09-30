package de.hgnut.Misc;
/*************************************************************************/
import javax.microedition.rms.*;
import java.util.Hashtable;
import java.util.Enumeration;
/*************************************************************************/
public class PropManager{
	private Hashtable properties=null;
	private String RSNAME;
/*************************************************************************/	
	public PropManager(String RSName){
		this.RSNAME=RSName;
		properties=new Hashtable();
		this.load();
	}
/*************************************************************************/	
	public String getProperty(String property){
		//System.out.println("getproperty : " + property);
		try{
		return (String)properties.get(property);
	    }catch(Exception e){
	    	return "1";
	    }	
	}
/*************************************************************************/	
	public void setProperty(String property, String value){
		//System.out.println("setProperty: "+property+" "+value);		
		properties.put(property , value);
	}
/*************************************************************************/	
	public void save(){
		//System.out.println("sssssssssss  "+ RSNAME);		
		try{
			StringBuffer tmp = new StringBuffer();
			Enumeration enu = properties.keys();
			while(enu.hasMoreElements()){
				String key = (String)enu.nextElement();
				//System.out.println("key " + key+" wert " + properties.get(key));
				tmp.append(key+"="+properties.get(key)+",");
			}
			RecordStore.deleteRecordStore(RSNAME);
			RecordStore rs= RecordStore.openRecordStore(RSNAME,true,RecordStore.AUTHMODE_PRIVATE,true);
			byte b[] = tmp.toString().getBytes();
	            	rs.addRecord(b,0,b.length);
	            	rs.closeRecordStore();
	        }catch(Exception e){
	        	System.out.println("Propmanager.save() --> Exception");	        	
	        	e.printStackTrace();
	        }
	}
/*************************************************************************/
	public void load(){				
		try {
			String tmp = null;
			//System.out.println("..............." + RSNAME);			
        		RecordStore rs = RecordStore.openRecordStore(RSNAME,true,RecordStore.AUTHMODE_PRIVATE,true);
        		//System.out.println("Nach open:" + RSNAME);	
        		RecordEnumeration renum = rs.enumerateRecords(null,null,false);
        		//System.out.println("Nach Enumeration:" + RSNAME + " "+ renum);	
        		while(renum.hasNextElement()){
        			//System.out.println("+++++++++ 1234 "+ renum.nextRecord());
        			tmp = new String(renum.nextRecord());
        			//System.out.println("+++++++++ "+tmp);
        			int i=0;
        			int posk = 0;
        			int posg = -1;
        			do{
        				posk = tmp.indexOf(',',i);
        				posg = tmp.indexOf('=',i);
	        			if(posk!=-1){	        				
	        				String key   = tmp.substring(i,posg);
	        				String value = tmp.substring(posg+1,posk);
	        				setProperty(key.trim(),value.trim());
	        				i=posk+1;
					}	        			
	        		}while(posk!=-1);
        		}
 	       		rs.closeRecordStore();
        	}catch(Exception e) {
        		System.out.println("Propmanager.load() --> Exception");
	        	e.printStackTrace();	        	
	        }
	}
/*************************************************************************/
	public String toString(){
		String ret ="";
		Enumeration enu = properties.keys();
		while(enu.hasMoreElements()){
			String key = (String)enu.nextElement();
			String value = (String)properties.get(key);
			ret=ret+key+" : "+value+"\n";
		}
		return ret;
	}
/*************************************************************************/
}