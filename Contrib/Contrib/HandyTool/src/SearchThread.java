/*************************************************************************************/	
import javax.microedition.lcdui.Gauge;
import java.util.*;
/*************************************************************************************/	
	//4. Timeout bei Such und download: Der Thread muss selber feststellen ob timeout und sich dann terminieren
public class SearchThread implements Runnable{
/*************************************************************************************/	
	public Vector hits = null;
	private boolean isrunnig = true;
	private String txt2search;
	private Gauge gauge;
/*************************************************************************************/	
	public SearchThread(String _txt2search, Gauge _gauge){
		gauge = _gauge;
		_txt2search = txt2search;
		hits = new Vector();
	}
/*************************************************************************************/	
	public void run(){
		hits = new Vector();		
		for(int i=1;i<100;i++){			
			hits.addElement(i+". "+txt2search+" Treffer");
		}		
		isrunnig = false;
		
	}
/*************************************************************************************/	
	public boolean isRunning(){
		return isrunnig;
	}
/*************************************************************************************/
}