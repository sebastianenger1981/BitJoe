import java.util.*;
import java.io.*;
import javax.microedition.io.*;
import javax.microedition.io.file.*;
import javax.microedition.midlet.*;
import javax.microedition.lcdui.*;
/*************************************************************************/
/*
	Universelle Datei-Funktions-KLasse
	Liest&Schreibt Verzeichnisse&Dateien
	
	!!Momentan noch keine Ausreichenden Schutzvorkehrungen!!
	!!bsp.: writeFile(file,content,overwrite)wird noch nicht berücksichtigt
*/


/*

Bin der Meinung, dass wir nicht mit den statischen Variabeln a la UP_DIRECTORY
arbeiten sollten, sondern auf die Funktion getRootCompleteDirectoryStructure() zurückgreifen!°!

Der Name getRootCompleteDirectoryStructure() is auch nicht so prall von mir gewählt ^^

*/


public class FileBrowser{
/*************************************************************************/
	private static String UP_DIRECTORY = "..";
	private static String MEGA_ROOT = "/";
	private static String SEP_STR = "/";
	private static char   SEP = '/';
/*************************************************************************/
	//Kein wirkliches Objekt, sollte ich die Methoden maybe zu Funktionen wandlen, static...
	//werde wohl keine Pool Klasse anlegen können, zu speicherintensiv!
	public FileBrowser(){}
/*************************************************************************/
	public static Enumeration listDir(String dir){
    		FileConnection currDir = null;
		try {
			if (MEGA_ROOT.equals(dir)){
				return FileSystemRegistry.listRoots();
			}else{
				currDir = (FileConnection)Connector.open("file://" + dir,Connector.READ_WRITE);
				return currDir.list();
			}
    		}catch(IOException ioe){
    			System.out.println(ioe);
    			ioe.printStackTrace();
    			return null;
    		}
	}
/*************************************************************************/
	//Grundlage, aber wird die wirklich benötigt? Was löschen wir denn? Nix, ausser RS
	public static boolean delFileOrDir(String FileOrDir){
		FileConnection currDir = null;
		try {
			currDir = (FileConnection)Connector.open("file://" +FileOrDir,Connector.READ_WRITE);
			currDir.delete();
			return true;
    		}catch(IOException ioe){
    			System.out.println(ioe);
    			ioe.printStackTrace();
    			return false;
    		}
	}
/*************************************************************************/
	public static boolean writeFile(String file, byte[] content, boolean overwrite){
		FileConnection currDir = null;
		try {
			currDir = (FileConnection)Connector.open("file://" +file,Connector.READ_WRITE);
			OutputStream outstream = currDir.openOutputStream();
			outstream.write(content);
			return true;
    		}catch(IOException ioe){
    			System.out.println(ioe);
    			ioe.printStackTrace();
    			return false;
    		}
	}
/*************************************************************************/
	public static boolean writeFile(String file, InputStream content, boolean overwrite){
		FileConnection currDir = null;
		try{
			currDir = (FileConnection)Connector.open("file://" +file,Connector.READ_WRITE);
			OutputStream outstream = currDir.openOutputStream();
			int ch = -1;
			while ((ch = content.read()) != -1) {
				outstream.write(ch);
			}
			return true;
		}catch(Exception e){
			e.printStackTrace();
			return false;
		}
		
	}
/*************************************************************************/
//Sollte ich ncht besser nen Stream zurückgeben, ist vielleicht performanter bei 512kb im RAM pro Bild?!?!?!
	public static InputStream readFile(String file){
		FileConnection currDir = null;
		try {
			currDir = (FileConnection)Connector.open("file://" +file,Connector.READ_WRITE);
			InputStream instream = currDir.openInputStream();
			return instream;
    		}catch(IOException ioe){
    			System.out.println(ioe);
    			ioe.printStackTrace();
    			return null;
    		}
	}



/**********************************************************/ 

	//Liefert bis zu 5 Vorschläge, wo Musik=0/Videos=1/Bilder=2 abgelegt werden sollten

	public static Enumeration getDirsFor(int modus){
		/*
			Vorgehen:
			1. Root auflisten
			2. Alle Dirs merken
			3. Für jedes Dir suche nach Musik/Video/Bild-Dateien. 
			   Wenn gefunden stecke Dir in Musik/Video/Bild-Liste 
			   und merke Anzahl der entsprechenden Dateien.
			4. Aus der Liste die 5 Dirs mit maximaler Anzahl raussuchen
			   und mit absolutem Pfad zurückliefern
			
			Problem: Muss durchsuchbare Verzeichnisebene beschränken (maximal 3 Ebenen von root aus).
			Wirklich rekursive Lösung ist verdammt schwer und möglicherweie -- @micha: ^^ , siehe unten ^^
			auch zu speicherlastig.
		*/

		return null;
	}
/**************************************************************/ 


/*
	########################################################################
	##########	Neu: von Basti alles unter nachfolgendem Kommentar #########
	########################################################################

	Info: ich habe den Code noch nicht kompiliert!!!
	Info: Musik=0 Video=1 Bilder=2 Java=3 HandyProgramme=4 Sonstiges=5

*/

	// hole alle Rootverzeichnisse
	private getRootCompleteDirectoryStructure() {
		
		Enumeration drives = FileSystemRegistry.listRoots();
		Vector rDirs = new Vector();

		while(drives.hasMoreElements()) {
			String rootDir = (String)drives.nextElement();
			rDirs.addElement(rootDir);
		}

		return rDirs;

	} /* private void getRootCompleteDirectoryStructure() {} */


	// bestimme den Filetype
	private getTheFileType( String filename ){
		
		try
		{
			String FileType = (String)filename.getFileType();
			FileType		= FileType.toLowerCase();		// ich will den FileType als lowercase haben!!!
		}
		catch (Exception ex)
		{
			System.out.println("java.io.IOException: "+ex);
			return false;
		}
		
		return FileType;

	}; /* public getTheFileType( String filename ){} */


	// klassifiziere eine Datei anhand ihrer Endung und gib entsprechenden Statuswert zurück
	private classifyContent( String filetype ) {

		// alles zum thema Musik 
		if ( filetype.equals("mp3") ){
			return 0;
		}else if ( filetype.equals("wav") ){
			return 0;
		} else if ( filetype.equals("wave") ){
			return 0;
		} else if ( filetype.equals("flac") ){
			return 0;
		} else if ( filetype.equals("aac") ){
			return 0;
		} else if ( filetype.equals("smaf") ){
			return 0;
		}else if ( filetype.equals("mld") ){
			return 0;
		} else if ( filetype.equals("ogg") ){
			return 0;
		} else if ( filetype.equals("mmf") ){
			return 0;
		} else if ( filetype.equals("aiff") ){
			return 0;
		} else if ( filetype.equals("mp2") ){
			return 0;
		} else if ( filetype.equals("mid") ){
			return 0;
		} else if ( filetype.equals("midi") ){
			return 0;
		} else if ( filetype.equals("wma") ){
			return 0;
		} else if ( filetype.equals("rma") ){
			return 0;
		} else if ( filetype.equals("au") ){
			return 0;
		} else if ( filetype.equals("ape") ){
			return 0;
		} else if ( filetype.equals("mpc") ){
			return 0;

		// alles zum thema videos
		} else if ( filetype.equals("mp4") ){
			return 1;
		} else if ( filetype.equals("rm") ){
			return 1;
		} else if ( filetype.equals("avi") ){
			return 1;
		} else if ( filetype.equals("mpg") ){
			return 1;
		} else if ( filetype.equals("mpeg") ){
			return 1;
		} else if ( filetype.equals("mov") ){
			return 1;
		} else if ( filetype.equals("wmm") ){
			return 1;
		} else if ( filetype.equals("wmf") ){
			return 1;
		} else if ( filetype.equals("wmv") ){
			return 1;
		} else if ( filetype.equals("divix") ){
			return 1;
		} else if ( filetype.equals("3gp") ){
			return 1;
		} else if ( filetype.equals("mpeg4") ){
			return 1;
		} else if ( filetype.equals("3g") ){
			return 1;
		} else if ( filetype.equals("ram") ){
			return 1;
		} else if ( filetype.equals("vob") ){
			return 1;
		} else if ( filetype.equals("ogm") ){
			return 1;
		} else if ( filetype.equals("vivo") ){
			return 1;
		
		// alles zum thema Bilder
		} else if ( filetype.equals("jpg") ){
			return 2;
		} else if ( filetype.equals("jpeg") ){
			return 2;
		} else if ( filetype.equals("jpa") ){
			return 2;
		} else if ( filetype.equals("png") ){
			return 2;
		} else if ( filetype.equals("gif") ){
			return 2;
		} else if ( filetype.equals("bmp") ){
			return 2;
		} else if ( filetype.equals("tif") ){
			return 2;
		} else if ( filetype.equals("tiff") ){
			return 2;
		} else if ( filetype.equals("svg") ){
			return 2;

		// alles zum Thema Java
		} else if ( filetype.equals("jad") ){
			return 3;
		} else if ( filetype.equals("jar") ){
			return 3;

		// alles zum Thema HandyProgramme
		} else if ( filetype.equals("sis") ){
			return 4;
	
		// alles weiter ist Sonstiges
		} else {
			return 5;
		}

	}; /* private classifyContent( String filename, String filetype, String directory ) {} */


	// klassifiziere den inhalt von verzeichnissen
	private void classifyFolderTypes( Vector rDirs ){

		// enthält zum schluss die gesammte Verzeichnisstruktur des Handys -> für weitere bearbeitung notwenig
		Vector CompleteDirectoryStructure  = new Vector();

		// Info: Musik=0 Video=1 Bilder=2 Java=3 HandyProgramme=4 Sonstiges=5
		
		HashSet MusicFolders	= new HashSet();
		HashSet MovieFolders	= new HashSet();
		HashSet PictureFolders	= new HashSet();
		HashSet JavaFolders		= new HashSet();
		HashSet ProgrammFolders	= new HashSet();
		HashSet MiscFolders		= new HashSet();

		// für alle Vector Einträge aus dem übergebenen Parameter rDir - sprich für rootverzeichnisse aus dem Vector rDir tu etwas
		for ( int i=0; i<rDirs.size(); i++ ){
			
			// rDirs.elementAt(i)) enthält jeweils ein root directory 
			String rootDirectory = rDirs.elementAt(i); // unnötig hier einen string anzulegen??
		
			try {
				
				// öffne "directory" und hole mittels glob("*") alle einträge
				FileConnection fc = (FileConnection)Connector.open("file:///"+rootDirectory);
				Enumeration filelist = fc.list("*", true);

				// lese alle einträge aus dem "directory" aus
				while (filelist.hasMoreElements()) {
					
					String fileName  = (String)filelist.nextElement();
					File fileNameDir =  new File(fileName);

					// wir haben es mit einem existierenden verzeichnis zu tun !
					if ( ( fileNameDir.isDirectory() == true ) && ( fileNameDir.exists() == true) ){
								
						String completeFileName = new String();
						
						// benutzen Handys Windows oder Linux style Pfadnamen? - momentan auf Windows Pfad umgemünzt
						completeFileName.append(rootDirectory).append("\\").append(fileName);	
						// completeFileName soll nun so aussehen "rootDirectory\fileName"
						
						// rufe die Funktion entsprechend auf
						recursiveDirectoryListening( completeFileName, "" );

					}
				} /* while (filelist.hasMoreElements()) {} */

				fc.close();

			/* hier muss eine anweisung rein, speicher wieder freizugeben !!! */

			} catch (IOException ex) {
				System.out.println(ex);
				return false;
			}

		} /* for ( int i=0; i<rDirs.size(); i++ ){} */


		static void recursiveDirectoryListening(String dir, String indent) {

			// Schreibe den Eintrag String dir in den Vector CompleteDirectoryStructure -> dir enthält Verzeichnisstruktur
			CompleteDirectoryStructure.addElement( dir );

			try {

				// wandere rekursiv durch die verzeichnisse
				FileConnection rfc = (FileConnection)Connector.open("file:///"+dir);
				Enumeration recFileList = rfc.list("*", true);
			
				indent += " ";	// wozu ist das eigentlich nötig?
				
				while (recFileList.hasMoreElements()) {
				
					String recFileName  = (String)recFileList.nextElement();
					File recFileNameDir =  new File(recFileName);

					// wir haben es mit einem existierenden verzeichnis zu tun !
					if ( ( recFileNameDir.isDirectory() == true ) && ( recFileNameDir.exists() == true) ){
											
						String recCompleteFileName = new String();
						
						recCompleteFileName.append(dir).append("\\").append(recFileName);	
						// recCompleteFileName soll nun so aussehen "dir\recFileName"
						
						// rekrusiver aufruf von unserer eigenen funktion
						recursiveDirectoryListening( recCompleteFileName, indent );

					}
				} /* while (recFileList.hasMoreElements()) {} */
			
				rfc.close();
			
			/* hier muss eine anweisung rein, speicher wieder freizugeben !!! */

			} catch (IOException ex) {
				System.out.println(ex);
				return false;
			}

		} /* static void recursiveDirectoryListening(String dir, String indent) {} */

		// in dem Vector CompleteDirectoryStructure stehen nun die vorhanden Verzeichnissstruktur des handys
		// grase nun diesen Vector ab und schaue, was für dateieinträge darin vorhanden sind

		for ( int i=0; i<CompleteDirectoryStructure.size(); i++ ){

			String DirectoryStructure = CompleteDirectoryStructure.elementAt(i);
			FileConnection fh = (FileConnection)Connector.open("file:///"+DirectoryStructure);
			Enumeration FileListStructure = fh.list("*", true);
			
			while (FileListStructure.hasMoreElements()) {
				
				String StringFileName	= (String)FileListStructure.nextElement();
				File FileFileName		=  new File(StringFileName);

				// wir haben es mit einer existierenden datei zu tun !
				if ( ( FileFileName.isFile() == true ) && ( FileFileName.exists() == true) ){
				
					// prüfe was StringFileName für eine Datei ist - benutze dafür private getTheFileType( String filename ){}
					String FileType = getTheFileType(StringFileName);
			
					// ordne nun dem Filetyp eine Kategorie zu, gib integer Wert zurück 
					int classifiedFolderType = classifyContent(FileType);

					// Info: Musik=0 Video=1 Bilder=2 Java=3 HandyProgramme=4 Sonstiges=5
					
					// schreibe das aktuelle verzeichnis in einen Vector für je musik, bilder, movies, java, progs, miscs
					if ( classifiedFolderType.equals(0) ){
						if ( MusicFolders.add(DirectoryStructure) ){ };	
					} else if ( classifiedFolderType.equals(1) ) ){ };	
						if ( MovieFolders.add(DirectoryStructure);
					} else if ( classifiedFolderType.equals(2) ) ){ };	
						if ( PictureFolders.add(DirectoryStructure);
					} else if ( classifiedFolderType.equals(3) ) ){ };	
						if ( JavaFolders.add(DirectoryStructure);
					} else if ( classifiedFolderType.equals(4) ) ){ };	
						if ( ProgrammFolders.add(DirectoryStructure);
					} else if ( classifiedFolderType.equals(5) ){
						if ( MiscFolders.add(DirectoryStructure) ){
							//Eintrag war noch nicht vorhanden
						} else {
							//Eintrag bereits vorhanden
						}
					} else {
						// never reached
						if ( MiscFolders.add(DirectoryStructure) ){ };
					};
					
				};

			}; /* while (FileListStructure.hasMoreElements()) { */
			
			fh.close();

		/* hier muss eine anweisung rein, speicher wieder freizugeben !!! */

		}; /* for ( int i=0; i<CompleteDirectoryStructure.size(); i++ ){} */


		/*
			In den HashSet :
				
				MusicFolders
				MovieFolders
				PictureFolders
				JavaFolders
				ProgrammFolders
				MiscFolders

			stehen nun alle Verzeichnisse drinne in denen ein bestimmter filetyp liegt

			@micha: Ich habe speicherlastig programmiert und immer alles im speicher gehalten -> eventuell alles mit records stores speichern?
			
		*/
		
	}; /* private void classifyFolderTypes( Vector rDirs ){} */


} /* public class FileBrowser{} */
