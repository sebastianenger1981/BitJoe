import javax.microedition.rms.*;
import java.util.Hashtable;
import java.util.Enumeration;
/*************************************************************************/
//kann Properties in RecordStores ablegen, ersetzt Property aus J2SE
//!! AUF KEINEN FALL , ODER = in KEY ODER VALUE SCHREIBEN
//BRINGT DIE SPEICHERLOGIK ZU FALL

//!!!!! SOLLTE AUF Hashtable.toString() verzichten, macht nur Ärger und ne Sinnvolle rückumwandlung wird auch nicht angeboten
//Wenn also schon selber schreiben, dann richtig. 
/*************************************************************************/
public class PropManager{
	private static Hashtable properties=null;
/*************************************************************************/	
	public static String getProperty(String property){
		if(properties==null)properties=new Hashtable();
		return (String)properties.get(property);
	}
/*************************************************************************/	
	public static void setProperty(String property, String value){
		if(properties==null)properties=new Hashtable();
		properties.put(property , value);
	}
/*************************************************************************/	
	public static void save(){		
		try{
			//So ging das früher
			//String tmp = properties.toString();
			//Hier die neue Methode, ohne {} dafür mit , hinter letzem Eintrag
			StringBuffer tmp = new StringBuffer();
			Enumeration enu = properties.keys();
			while(enu.hasMoreElements()){
				String key = (String)enu.nextElement();
				tmp.append(key+"="+properties.get(key)+",");
			}
			RecordStore.deleteRecordStore("HandyToolPropertyRS");
			RecordStore rs= RecordStore.openRecordStore("HandyToolPropertyRS",true,RecordStore.AUTHMODE_PRIVATE,true);
			byte b[] = tmp.toString().getBytes();
	            	rs.addRecord(b,0,b.length);
	            	rs.closeRecordStore();
	        }catch(Exception e){	        	
	        	e.printStackTrace();	        	
	        }
	}
/*************************************************************************/
	public static void load(){				
		try {
			String tmp=null;
			properties =  new Hashtable();
        		RecordStore rs= RecordStore.openRecordStore("HandyToolPropertyRS",true,RecordStore.AUTHMODE_PRIVATE,true);
        		RecordEnumeration renum = rs.enumerateRecords(null,null,false);
        		while(renum.hasNextElement()){
        			tmp = new String(renum.nextRecord());
        			System.out.println("tmp load = "+tmp);
        			//FUCK ES GIBT KEINEN STRINGTOKENIZER!!!!!!!!! FUCK FUCK FUCK!!!!!!!!!!!
        			//String nach , trennen, dann die einzelnen abschnitte nach = trennen und als key&value in hashtable packen
        			//WAS EINE SCHEISS ARBEIT!!!!!!!!
        			int i=0;
        			int posk = 0;
        			int posg = -1;
        			do{
        				posk = tmp.indexOf(',',i);
        				posg = tmp.indexOf('=',i);
	        			if(posk!=-1){	        				
	        				String key   = tmp.substring(i,posg);
	        				String value = tmp.substring(posg+1,posk);
	        				
	        				properties.put(key.trim(),value.trim());
	        				i=posk+1;
					}	        			
	        		}while(posk!=-1);
        			
        			
        		}
 	       		rs.closeRecordStore();
        	}catch(Exception e) {        		
	        	e.printStackTrace();	        	
	        }
	}
/*************************************************************************/
}