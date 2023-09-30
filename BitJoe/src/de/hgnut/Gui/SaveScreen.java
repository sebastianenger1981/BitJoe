package de.hgnut.Gui;
/*******************************************/
import javax.microedition.lcdui.*;
import java.util.*;
import java.io.*;
import javax.microedition.io.*;
import javax.microedition.io.file.*;
import de.hgnut.Misc.*;
/*******************************************/
//public class SaveScreen extends Form implements Runnable, CommandListener{
public class SaveScreen implements Runnable, CommandListener{
/*******************************************/
	public String TOSAVE;
	public String DIR;
/*******************************************/
	private Display display;
	private GuiActionListener listener;
	private Command currentCommand;
	private Displayable currentDisplyable;
	private static Thread commandThread;
	private TextBox fileName_new;
	private String currDirName;
	private String FILENEXTENSION;
	private int status = 0;
	private Ticker ticker;
//++++++++++++++++++++++++++++++++++++++++++++++++++	
	//private ListScreen listS;
//++++++++++++++++++++++++++++++++++++++++++++++++++	
/*******************************************/
	private final static String UP_DIRECTORY = "..";
	private final static String MEGA_ROOT = "file:///";
	//private final static String MEGA_ROOT = System.getProperty("fileconn.dir.photos");
	private final static String SEP_STR = "/";
	private final static char   SEP = '/';
	private final static String SAVE_HERE = "* HIER SPEICHERN *";
/*******************************************/
	public SaveScreen(Display display, GuiActionListener listener, String path){
		this.display = display;
		this.listener = listener;
		//+++++++++++++++++++++++++++++++++++++++++++++
		//this.listS = listS;
		//++++++++++++++++++++++++++++++++++++++++++++
		//++++++++++++++++++++++++++++++++++++++++++++++
		Constant.dateiExsist.setCommandListener(this);
		//++++++++++++++++++++++++++++++++++++++++++++++
		System.out.println("Pfad: " + path);//+" "+javacall_fileconnection_get_photos_dir() );
		if(path!=null&&path.trim().length()>0)
			currDirName = path.trim();
			//currDirName=MEGA_ROOT;
		else
		        currDirName=MEGA_ROOT;
		        
		        //currDirName=System.getProperty("fileconn.dir.photos");
	        //endung abschneiden und aufheben, dann wieder anfügen wenn nicht selber eingegeben
	    if(Constant.FILENAME.indexOf('.')!=-1){
	    	//FILENEXTENSION = "."+Constant.ALLOWED_FILE_TYPES[Constant.SELECTED_FILE_TYPE];
	    	//FILENEXTENSION = Constant.FILENAME.substring(Constant.FILENAME.lastIndexOf('.'),Constant.FILENAME.lastIndexOf(' '));
	    	FILENEXTENSION = Constant.FILENAME.substring(0,Constant.FILENAME.lastIndexOf('.'));
	    	//System.out.println("FILENEXTENSION: "+FILENEXTENSION);
	    	if(FILENEXTENSION.indexOf('.')!=-1)
	    	 FILENEXTENSION = FILENEXTENSION.substring(FILENEXTENSION.lastIndexOf('.'),FILENEXTENSION.lastIndexOf(' '));
	    	//System.out.println("FILENEXTENSION: "+FILENEXTENSION);
	    }else
	    
	    
	    try{
	    currDirName=MEGA_ROOT;		
        //currDirName = path.trim();
	    FILENEXTENSION="";
       }catch(Exception e){
       	 //listS.append("Fehler: " + e.getMessage()+" "+e.toString(), null);
       	 //listS.append("curDirName: "+ currDirName,null);
       }
       ticker = new Ticker("Navigiere in den Telefonordner in dem Du speichern m\u00F6chtest und w\u00E4hle dann \"HIER SPEICHERN\" aus.");
       showCurDir();
	}
/*******************************************/
	public void run(){
		
		if(currentCommand != Constant.exitCommand && currentCommand != Constant.okCommand && currentCommand != Constant.cancelCommand && currentCommand != Constant.speichernCommand && currentCommand != Constant.alertOkCommand && currentCommand != Constant.alertCancelCommand){
		   currentCommand = Constant.okCommand;
		}
		if (currentCommand == Constant.exitCommand){
			listener.guiActionPerformed(new GuiAction(Constant.WELCOMESCREEN,null,0,currentCommand));
			
		}else if (currentCommand == Constant.okCommand || currentCommand ==  Constant.ok2Command || currentCommand == Constant.speichernCommand ){
			if(status==0){
				List curr = (List)currentDisplyable;
				String currFile = curr.getString(curr.getSelectedIndex());
				//System.out.println("currFile "+currFile);
				//System.out.println("currDirName "+currDirName);
				if (currFile.endsWith(SEP_STR)||
					currFile.equals(UP_DIRECTORY)){
					traverseDirectory(currFile);
					//askForFileName();
				}
				if(currFile.equals(SAVE_HERE)){
					//name wählen lassen, am besten suchbegriff vorschlagen
					askForFileName();				
				}
			}else{
				if(FileBrowser.validateFilename(fileName_new.getString())){
					TOSAVE = currDirName+fileName_new.getString();
					DIR=currDirName;
					if(!TOSAVE.endsWith(FILENEXTENSION)){
						TOSAVE=TOSAVE+FILENEXTENSION;
					}
					//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					FileConnection currDir = null;
					try {
			        currDir = (FileConnection)Connector.open("file:///"+TOSAVE,Connector.READ_WRITE);
			        }catch(Exception ioe){
    			         System.out.println("SaveScreen -> catch");
    			          ioe.printStackTrace();
    		        }
			        if(currDir.exists()) {
			        	//System.out.println("wirklich löschen überschreiben?");
				      display.setCurrent(Constant.dateiExsist);
				      Constant.FILENAME = fileName_new.getString();
				    try{   
     		          currDir.close();
     		        }catch(Exception ioe){
     		        	System.out.println("SaveScreen -> catch");
    			        ioe.printStackTrace();
     		        }	
     		        }else{
    		        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					listener.guiActionPerformed(new GuiAction(Constant.SAVESCREEN,null,Constant.index,currentCommand));
				    }
					//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				}else{
					reaskForFileName();				
				}
			}
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		}else if(currentCommand == Constant.alertOkCommand){
			//System.out.println("wirklich alert okCommand?");
			if(FileBrowser.validateFilename(fileName_new.getString())){
					TOSAVE = currDirName+fileName_new.getString();
					DIR=currDirName;
					if(!TOSAVE.endsWith(FILENEXTENSION)){TOSAVE=TOSAVE+FILENEXTENSION;}
				listener.guiActionPerformed(new GuiAction(Constant.SAVESCREEN,null,Constant.index,Constant.okCommand));
			}else{
				reaskForFileName();
			}				
		}else if(currentCommand == Constant.alertCancelCommand){
			 //System.out.println("wirklich alert cancelCommand?");
			 askForFileName();
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	 		
		}else if (currentCommand == Constant.cancelCommand){		
			listener.guiActionPerformed(new GuiAction(Constant.SAVESCREEN,null,0,currentCommand));
        	}
        	 synchronized(this){
		       	commandThread = null;
        	}
	}
/*******************************************/
//implements CommandListener
	public void commandAction(Command c, Displayable d){
		synchronized (this) {
			if (commandThread != null) {
                		// process only one command at a time
                		return;
		   	}
            		currentCommand = c;
            		currentDisplyable = d;
            		commandThread = new Thread(this);
            		commandThread.start();
            	}		
	}
/*******************************************/
	private void showCurDir(){	
		Enumeration e;
		FileConnection currDir = null;
		List browser =null;
		try {
			System.out.println("MEGA_ROOT  "+ MEGA_ROOT + " currDirName "+ currDirName );
			if (MEGA_ROOT.equals(currDirName)){
				System.out.println("if " + "currDirName :"+currDirName);
				if(!currDirName.endsWith("/"))currDirName=currDirName+"/";
				//System.out.println("ifif :");
				e = FileSystemRegistry.listRoots();
				String title = "";
				if(currDirName.equals(MEGA_ROOT)){
					title = "Speicherort w\u00E4hlen";
				}else{
					title = currDirName;
				}		
				 
				browser = new List(title, List.IMPLICIT);
				browser.setTicker(ticker);
			}else{
				//System.out.println("else");
				//currDir = (FileConnection)Connector.open(
				//"file://localhost/" + currDirName);
				//System.out.println("die Properties : "+System.getProperty("fileconn.dir.photos"));
				//System.out.println("Gibts da was "+ System.getProperty("microedition.io.file.FileConnection.version"));
				if(!currDirName.endsWith("/"))currDirName=currDirName+"/";
				System.out.println("nach if currDirName :" + currDirName);
				System.out.println("file:///"+ currDirName);
				//System.out.println(Connector.open("file:///" + currDirName,1));
				try{				
				//currDir = (FileConnection)Connector.open("file:///" + currDirName,1);
				currDir = (FileConnection)Connector.open("file:///" + currDirName, Connector.READ);
				//currDir = (FileConnection)Connector.open(currDirName, Connector.READ);
				//currDir = (FileConnection)Connector.open("file:///./Nokia/Images/",1);
				}catch(Exception se){
					System.out.println("Exception : " + currDir);
					System.out.println(se.toString());
					System.out.println(se.getMessage());
					se.printStackTrace();
				}
				System.out.println("nach Connector open");
				e = currDir.list("*",true);
				browser = new List(currDirName, List.IMPLICIT);
				browser.setTicker(ticker);
				browser.append(UP_DIRECTORY, null);				
			}
			boolean first=true;
			if(MEGA_ROOT.equals(currDirName))
				first=false;
			while (e.hasMoreElements()){
				String fileName = (String)e.nextElement();
				if (fileName.charAt(fileName.length()-1) == SEP) 
				{	//dir
					browser.append(fileName, null);
				} 
				else
				{	//file
					//erster File Sonderbehandlung
					if(first){
						browser.append(SAVE_HERE, null);
						first=false;
					}
					browser.append(fileName, null);
				}
			}
			if(first){
				browser.append(SAVE_HERE, null);
				first=false;
			}
			//browser.setSelectCommand(Constant.okCommand);
			//browser.addCommand(Constant.exitCommand);
			browser.addCommand(Constant.cancelCommand);
			browser.setCommandListener(this);
			if (currDir != null) 
			{
				currDir.close();
			}
			display.setCurrent(browser);
		}catch (IOException ioe){
			System.out.println("hier ");
			ioe.printStackTrace();
			browser.append("Fehler IO showCurDir : " + ioe.getMessage()+" "+ioe.toString(), null);
			display.setCurrent(browser);
		}catch(Exception ex){
			System.out.println("Exception : " + ex.getMessage());
			ex.printStackTrace();
			browser.append("Fehler showCurDir : " + ex.getMessage()+" "+ex.toString(), null);
			display.setCurrent(browser);
		    }
	}
/*******************************************/
	private void traverseDirectory(String fileName){
		if (currDirName.equals(MEGA_ROOT)){
			if (fileName.equals(UP_DIRECTORY)){
				// can not go up from MEGA_ROOT
				return;
			}
			currDirName = fileName;
		} else if (fileName.equals(UP_DIRECTORY)){
			// Go up one directory
			// TODO use setFileConnection when implemented
			int i = currDirName.lastIndexOf(SEP, currDirName.length()-2);
			if (i != -1){
				currDirName = currDirName.substring(0, i+1);
			}else{
				currDirName = MEGA_ROOT;
			}
		}else{
			currDirName = currDirName + fileName;
		}
		showCurDir();
	}
/*******************************************/
	private void askForFileName(){
		status = 1;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		String s = Constant.FILENAME;
		//System.out.println("name: "+ s +" " + Constant.ALLOWED_FILE_TYPES[Constant.SELECTED_FILE_TYPE]);
	//if(s.length() > 150){

		try{
		if(s.indexOf(FILENEXTENSION)> 0){	
		 s = s.substring(0, s.indexOf(FILENEXTENSION));
		 s= s.trim();
	    }
		if(s.length()> 146){
			s = s.substring(0, 100);
		}	
			s=s+FILENEXTENSION;
			//System.out.println("ask for filename FILENEXTENSION: "+FILENEXTENSION);	
		}catch(Exception e){
			e.printStackTrace();
		}
	//}		
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		System.out.println("askForFileName gestartet" + Constant.FILENAME + " "+ Constant.TOSEARCH+ " " + s);
		//if(FileBrowser.validateFilename(Constant.FILENAME)){
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if(FileBrowser.validateFilename(s)){
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	    
		        //fileName_new = new TextBox("BitJoe - Dateinamen eingeben", Constant.FILENAME, 200, 0);
		        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		        fileName_new = new TextBox("Dateinamen eingeben", s, 200, 0);
		        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		}else{
			//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		try{
			s=s.replace('-',' ');
		}catch(Exception e){
			System.out.println("- ist nicht vorhanden");
			e.printStackTrace();
		}
		try{
			s=s.replace('_',' ');
		}catch(Exception e){
			System.out.println("_ ist nicht vorhanden");
			e.printStackTrace();
		}
		try{
			s=s.replace('@',' ');
		}catch(Exception e){
			System.out.println("@ ist nicht vorhanden");
			e.printStackTrace();
		}
		try{
			s=s.replace('%',' ');
		}catch(Exception e){
			System.out.println("% ist nicht vorhanden");
			e.printStackTrace();
		}	
		    fileName_new = new TextBox("BitJoe - Dateinamen eingeben", s, 200, 0);
		    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
		}
		//fileName_new.addCommand(Constant.okCommand);
		fileName_new.addCommand(Constant.speichernCommand);
		fileName_new.addCommand(Constant.cancelCommand);
	    fileName_new.setCommandListener(this);
	    display.setCurrent(fileName_new);	      
	}
/*******************************************/
	private void reaskForFileName(){
		status = 1;
		System.out.println("reaskForFileName gestartet");
	        display.setCurrent(Constant.alert_h,fileName_new);	      
	}
/*******************************************/
}