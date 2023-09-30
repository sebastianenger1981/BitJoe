package de.hgnut.Misc;

import java.util.*;
import java.io.*;
import javax.microedition.io.*;
import javax.microedition.io.file.*;
/*************************************************************************/
/*
	Universelle Datei-Funktions-KLasse
	Liest&Schreibt Verzeichnisse&Dateien
	!!Momentan noch keine Ausreichenden Schutzvorkehrungen!!
	!!bsp.: writeFile(file,content,overwrite)wird noch nicht berücksichtigt
*/

public class FileBrowser{
/*************************************************************************/
//	private static String UP_DIRECTORY = "..";
	private static String MEGA_ROOT = "/";
//	private static String SEP_STR = "/";
//	private static char   SEP = '/';
/*************************************************************************/
	public static Enumeration listDir(String dir){
    		FileConnection currDir = null;
		try {
			if (MEGA_ROOT.equals(dir)){
				return FileSystemRegistry.listRoots();
			}else{
				currDir = (FileConnection)Connector.open("file:///" + dir,Connector.READ_WRITE);
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
			currDir = (FileConnection)Connector.open("file:///"+FileOrDir,Connector.READ_WRITE);
			currDir.delete();
			return true;
    		}catch(IOException ioe){
    			System.out.println(ioe);
    			ioe.printStackTrace();
    			return false;
    		}
	}
/*************************************************************************/
	public static boolean writeFile(String file, byte[] content){
		System.out.println("versuche writeFile "+file);
		FileConnection currDir = null;
		try {
			currDir = (FileConnection)Connector.open("file:///"+file,Connector.READ_WRITE);
			 if(!currDir.exists()) {
				 currDir.create();
     		}
			// 1. output unkontroliert
			/*OutputStream outstream = currDir.openOutputStream();
			outstream.write(content);*/
			// 2. dataoutput kontroliert
			 DataOutputStream outstream = currDir.openDataOutputStream();
			outstream.write(content,0,content.length);
			
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
			currDir = (FileConnection)Connector.open("file:///" +file,Connector.READ_WRITE);
			OutputStream outstream = currDir.openOutputStream();
			int ch = -1;
			while ((ch = content.read()) != -1) {
				outstream.write(ch);
			}
//zu machen
			currDir.close();
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
			currDir = (FileConnection)Connector.open("file:///" +file,Connector.READ_WRITE);
			InputStream instream = currDir.openInputStream();
			return instream;
    		}catch(IOException ioe){
    			System.out.println(ioe);
    			ioe.printStackTrace();
    			return null;
    		}
	}
/*************************************************************************/
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	private static FileConnection OpenedFile = null;
	private static OutputStream staticoutstream  = null;
	private static boolean opend_status = true;
	public static boolean openFileForWrite(String file){
		try{
			OpenedFile = (FileConnection)Connector.open("file:///" +file,Connector.READ_WRITE);
			if(!OpenedFile.exists()) {
				 OpenedFile.create();
     		}
			staticoutstream = OpenedFile.openOutputStream();
			opend_status = true;
			return true;
		}catch(Exception e){
			OpenedFile = null;
			staticoutstream  = null;
			System.out.println("Fehler in open: "+ e.toString());	
			e.printStackTrace();
			opend_status = false;
			return false;
		}
	}
	public static boolean appendToOpendFile(int b){
		if(OpenedFile!=null&&staticoutstream!=null&&opend_status){
		try{
			staticoutstream.write(b);
			return true;
		}catch(Exception e){
			System.out.println("Fehler in append: "+ e.toString());	
			opend_status = false;
			return false;
		}
		}else{
			return false;
		}
	}
	public static boolean closeOpendFile(){
		try{
			staticoutstream.close();
			OpenedFile.close();
			staticoutstream = null;
			OpenedFile = null;
			return opend_status;
		}catch(Exception e){
			opend_status = false;
			return false;
		}
	}

	public static boolean deleteOpendFile(){
		try{
			if(OpenedFile!=null){
				OpenedFile.delete();
				return true;			
			}else{
				return true;
			}
		}catch(Exception e){
			return false;			
		}

	}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
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
	//private static char[] notAllowed = {' ','-','_','@','%'};
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	private static char[] notAllowed = {'-','_','@','%'};
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static boolean validateFilename(String fileName){
		for(int i=0;i<notAllowed.length;i++){
			if(fileName.indexOf(notAllowed[i])!=-1){
				return false;
			}
		}
		//datei schon vorhanden?
		
		return true;		
	}
/*************************************************************************/
}