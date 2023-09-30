/*************************************************************************************/	
import javax.microedition.lcdui.Gauge;
import javax.microedition.io.*;
import java.io.*;
import javax.microedition.io.file.*;
/*************************************************************************************/
//!!!GROSSE BAUSTELLE, NIX FERTIG ALLES HALBDURCH
//!!fest verdrahteter Download & noch keine Nutzung von FileBrowser
// Solle auch nicht selber auf FileBrwoser zugreifen, sondern nur byte[] zurücklassen, das dann
//von HandyTool aus weggschrieben wird
//4. Timeout bei Such und download: Der Thread muss selber feststellen ob timeout und sich dann terminieren
public class DownloadThread implements Runnable{
/*************************************************************************************/	
	public byte[] file;
	private Gauge gauge;
	private boolean isrunnig = true;
/*************************************************************************************/	
	public DownloadThread(Object param_id , Gauge _gauge){
		gauge = _gauge;		
	}
/*************************************************************************************/	
	public void run(){
		String url="http://localhost:8080/tomcat.gif";
		StreamConnection c = null;
		InputStream s = null;
		FileConnection filecon = null;
		DataOutputStream fdata = null;
		try{			
			try {
				filecon = (FileConnection)Connector.open("file:///bilder/tomcat.gif");
				if(!filecon.exists()){
					filecon.create();
				}
				fdata = filecon.openDataOutputStream();
				c = (StreamConnection)Connector.open(url);
				s = c.openInputStream();
				int ch;
				int i=0;
				while ((ch = s.read()) != -1) {
					fdata.write(ch);
					i++;
					gauge.setValue(i/10);
				}
				
	         	}finally {
	         		if(filecon!=null)
	   		      		filecon.close();
		       		if (s != null)
	        	       		s.close();
	             		if (c != null)
	                 		c.close();
	         	}
	        }catch(Exception e){
         		System.out.println("Fehler");
         	} 
		isrunnig = false;
	}
/*************************************************************************************/
	public boolean isRunning(){
		return isrunnig;
	}
/*************************************************************************************/
}