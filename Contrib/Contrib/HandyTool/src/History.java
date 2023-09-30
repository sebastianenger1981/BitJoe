import javax.microedition.rms.*;
import java.util.Vector;
/*************************************************************************/
//Kann eine History im RS ablegen und wieder auslesen
public class History{
/*************************************************************************/
	public static void save(Vector history){
		if(history!=null&&history.size()>0){
			try{
				StringBuffer tmpb=new StringBuffer();
				for(int i=0;i<history.size();i++){
					tmpb.append(history.elementAt(i)+",");
				}				
				RecordStore.deleteRecordStore("HandyToolHistoryRS");
				RecordStore rs= RecordStore.openRecordStore("HandyToolHistoryRS",true,RecordStore.AUTHMODE_PRIVATE,true);
				byte b[] = tmpb.toString().getBytes();
		            	rs.addRecord(b,0,b.length);
		            	rs.closeRecordStore();
		        }catch(Exception e){	        	
		        	e.printStackTrace();	        	
		        }
		}
	}
/*************************************************************************/
	public static Vector load(){
		//VERDAMMTE SCHEISSE HAB 30 MINUTEN NACH DEM DUMMEN NULLPOINTER GESUCHT; BIS MIR AUFGEFALLEN IST DASS ICH DEN VECTOR=NULL INIT HABE!!!!!ARGHGGGGGGGGG
		Vector ret = new Vector();
		try {
			String tmp=null;			
        		RecordStore rs= RecordStore.openRecordStore("HandyToolHistoryRS",true,RecordStore.AUTHMODE_PRIVATE,true);
        		RecordEnumeration renum = rs.enumerateRecords(null,null,false);
        		int posk=0;
        		int i = 0;
        		while(renum.hasNextElement()){
        			tmp = new String(renum.nextRecord());        			
        			//suche nach , alles von letzter pos bis , ist mein nächster wert	
        			do{
        				posk = tmp.indexOf(',',i);
	        			if(posk!=-1){
	        				ret.addElement(tmp.substring(i,posk));
	        				i=posk+1;
					}	        			
	        		}while(posk!=-1);
        		}
 	       		rs.closeRecordStore();
        	}catch(Exception e) {        		
	        	e.printStackTrace();	        	
	        }
	        return ret;
	}
/*************************************************************************/
}