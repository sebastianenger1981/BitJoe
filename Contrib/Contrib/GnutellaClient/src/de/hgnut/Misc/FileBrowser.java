package de.hgnut.Misc;

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
			currDir = (FileConnection)Connector.open("file://"+FileOrDir,Connector.READ_WRITE);
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
			currDir = (FileConnection)Connector.open("file:///root1/"+file,Connector.READ_WRITE);
			 if(!currDir.exists()) {
         			currDir.create();
     			}
			OutputStream outstream = currDir.openOutputStream();
			outstream.write(content);
			return true;
    		}catch(Exception ioe){
    			System.out.println("FileBrowser.writeFile() -> catch");
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
/*************************************************************************/
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
			Wirklich rekursive Lösung ist verdammt schwer und möglicherweie
			auch zu speicherlastig.
		*/
		return null;
	}
/*************************************************************************/
}