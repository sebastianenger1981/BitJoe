package de.hgnut.Misc;
/**************************************************/
import javax.microedition.lcdui.*;
import java.util.*;
import java.util.Random;
/**************************************************/
public class Constant{
/**************************************************/
	//public static int SELECTED_FILE_TYPE = -1;
	public static String SELECTED_FILE_TYPES = "-1";
	public static String SELECTED_FILE_FAMILY;
	public static String[] ALLOWED_FILE_TYPES;
	public static String myipaddress;
	public static int myport;
	public static String FILENAME;
	public static String TOSEARCH;
	public static Vector hits;
	public static String STANDART_UP_MD5 = "cc917b8dfffc08995b6cd2699caf0fd6";
	public static String UP_MD5 = STANDART_UP_MD5;
	public static String SEC_MD5 = "c0d410d040ed471a80696f06409f801d";
	public static String USER = "";
	public static String ID = "";
	public static boolean clearRecord = false; 
	public static String error = "";
	public static String coupon = "";
	public static String mail = "";
	public static String mes ="";
	
//++++++++++++++++++++++++++++++++	
	public static int index;
	private static Random random;
//++++++++++++++++++++++++++++++++	
	/**************************************************/
	//Was darf ich
	public final static boolean[] ALLOWED_FILE_FAMILYS = {true,true,true,true,true,true};

	public final static String VIDEO_FAMILY ="v";
	public final static String[] VIDEO_FILE_TYPES ={"3gp","mpg","avi","wmv","mp4","rm","mpeg","mov","wmm","wmf","ram","ogm","vivo","asx","flv","fla","swf","f4v"};
	
	public final static String PICTURE_FAMILY ="b";
	public final static String[] PICTURE_FILE_TYPES ={"jpg","jpeg","png","gif","bmp","tiff","svg","jpa","tif","thm"};

	public final static String KLINGEL_FAMILY ="k";
	public final static String[] KLINGEL_FILE_TYPES ={"midi","mid","wav","aac","amr","wave","flac","smaf","mld","ogg","mmf","aiff","rma","ape","mpc"};

	public final static String MUSIK_FAMILY ="m";
	public final static String[] MUSIK_FILE_TYPES ={"mp3","wma","mp2","midi","mid","wav","aac","amr","wave","flac","smaf","mld","ogg","mmf","aiff","rma","ape","mpc", "3gp"};
	
	public final static String JAVA_FAMILY ="j";
	public final static String[] JAVA_FILE_TYPES ={"jar","class","jad","sis","sisx"};
	
	public final static String DOK_FAMILY ="d";
	public final static String[] DOK_FILE_TYPES ={"txt","pdf","rtf","xls","xlsx","doc","docx","ppt","pptx","xml","html","htm","xhtml","odt","sxw","ods","sxc","odp","sxi"};		
	
	public final static String[] DYN_DNS ={"00001.dontexist.net","00002.dontexist.net","00003.dontexist.net","00001.mine.nu","00002.mine.nu","00001.servebeer.com","00002.servebeer.com","00001.zapto.org","00002.zapto.org","00003.zapto.org"};
	//public final static String[] DYN_MESSAGE ={"Mit einer BitJoe.de Flatrate kannst du unbegrenzt downloaden.", "Eine Flatrate kannst Du unter \"Konto aufladen\" bestellen.", "Die BitJoe.de Flatrate f\u00FCr 3 Tage kostet nur 2,99 Euro.", "Mit einer Flatrate für 3 Tage kannst du 3 Tage unbegrenzt downloaden.","Wir empfehlen Dir die BitJoe.de Flatrate.", "Du willst eine Flatrate?Bestelle Sie unter \"Konto aufladen\"!", "Mit der BitJoe.de Flatrate bestimmst du, was du haben willst.","Erz\u00E4hl deinen Freunden von www.bitjoe.de !"};
	public final static String LIZENZ_KEY = "MILLIONAIRE";
	public final static String VERSION = "1.7.5";
	public final static String CRLF = "\r\n";
	//public final static String CRLF = "##";
	public final static String PUBLICKEY = "0123456789abcdef0123456789abcdef";
	//public final static String PROXY_IP = "81.169.137.179";
	//public final static String PROXY_IP ="87.106.63.182";
	//public static String PROXY_IP ="77.247.178.21";
    public static String PROXY_IP ="87.106.134.107";
    public static String connectData ="v=1000;81.169.137.179:23072:5;87.106.134.107:23071:5;77.247.178.21:9923:5;";
	//public final static String PROXY_IP ="85.214.39.76";
	//public final static String PROXY_IP = "00001.dontexist.net";
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//public final static int PROXY_PORT = 3381;
	//public final static int PROXY_PORT = 9865;
	//public final static int PROXY_PORT = 3383;
	//normal
	//public final static int PROXY_PORT = 3385;
	//distributet
	//public final static int PROXY_PORT = 7773;
	//public final static int PROXY_PORT = 8080;
	public static int PROXY_PORT = 23071;
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public final static String SEARCHSCREEN ="SEARCHSCREEN";
	public final static String LISTSCREEN ="LISTSCREEN";
	public final static String KONFIGSCREEN ="KONFIGSCREEN";
	public final static String STATUSSCREEN ="STATUSSCREEN";
	public final static String SAVESCREEN ="SAVESCREEN";
	public final static String STARTSCREEN ="STARTSCREEN";
	public final static String WELCOMESCREEN ="WELCOMESCREEN";
	public final static String AGBSCREEN = "AGBSCREEN";
	public final static String AGB2SCREEN = "AGB2SCREEN";
	public final static String AGBMAILSCREEN = "AGBMAILSCREEN";
	public final static String ANMELDESCREEN ="ANMELDESCREEN";
	public final static String COUPONSCREEN ="COUPONSCREEN";
	public final static String AUFLADESCREEN="AUFLADESCREEN";
	public final static String CONFIRMSCREEN ="CONFIRMSCREEN";
	public final static String USERDATENSCREEN ="USERDATESCREEN";
	//public final static Command okCommand = new Command("OK", Command.OK, 0);// Sony Ericson
	
	public final static Command okCommand = new Command("W\u00E4hlen", Command.CANCEL, 0);//Nokia
	public final static Command absendenCommand = new Command("Absenden", Command.ITEM, 2);
	public final static Command speichernCommand = new Command("Speichern", Command.CANCEL, 0);
	public final static Command anrufenCommand = new Command("Anrufen", Command.CANCEL, 0);
	//public final static Command herunterladenCommand = new Command("Herunterladen", Command.CANCEL, 0);
	public final static Command ok2Command = new Command("OK", Command.ITEM, 2);
	public final static Command cancelCommand = new Command("Zur\u00FCck", Command.CANCEL, 2);
	public final static Command exitCommand  = new Command("Schliessen", Command.ITEM, 2);
	public final static Command sendenCommand  = new Command("Senden", Command.CANCEL, 2);
	public final static Command jaCommand  = new Command("Ja", Command.CANCEL, 0);
	public final static Command neinCommand  = new Command("Nein", Command.CANCEL, 2);
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public final static Command alertOkCommand = new Command("OK", Command.CANCEL, 2);
	public final static Command alertCancelCommand = new Command("Zur\u00FCck", Command.ITEM, 2);
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static int firstWaitTimer = 30000;
	
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static long time = 0L;
	public static long holeTime = 0L; 
	public static String label= "  0 % fertig         ";
	public static boolean pbDone = false;
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public final static Alert alert_a = new Alert("BitJoe Alarm","Leider keine Treffer",null,AlertType.INFO);
	public final static Alert alert_b = new Alert("BitJoe Alarm","Download leider nicht erfolgreich",null,AlertType.ERROR);
	public final static Alert alert_c = new Alert("BitJoe Alarm","Speichervorgang abgebrochen",null,AlertType.CONFIRMATION);
	public final static Alert alert_d = new Alert("BitJoe Alarm","Speichervorgang abgeschlossen",null,AlertType.INFO);
	public final static Alert alert_e = new Alert("BitJoe Alarm","FEHLER beim Speichervorgang",null,AlertType.ERROR);
	public final static Alert alert_f = new Alert("BitJoe Alarm","Kein Suchbegriff eingegeben",null,AlertType.ERROR);
	public final static Alert alert_g = new Alert("BitJoe Alarm","Vorgang abgebrochen",null,AlertType.CONFIRMATION);
	public final static Alert alert_h = new Alert("BitJoe Alarm","Unerlaubte Sonderzeichen, bitte anderen Namen vergeben!",null,AlertType.ERROR);
	public final static Alert alert_i = new Alert("BitJoe Alarm","Bitte zuerst einen Dateityp auswählen!",null,AlertType.ERROR);
	public final static Alert alert_j = new Alert("BitJoe Alarm","Diese Option steht Ihnen nicht zur Verfügung",null,AlertType.ERROR);
	public final static Alert alert_k = new Alert("BitJoe Info","",null,AlertType.INFO);
	public final static Alert alert_L = new Alert("BitJoe Info","",null,AlertType.INFO);
	public final static Alert alert_m = new Alert("BitJoe Alarm","Nutzer konnte nicht erstellt werden bitte sp\u00E4ter nocheinmal versuchen",null,AlertType.ERROR);
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public final static Alert dateiExsist = new Alert("BitJoe Alarm","Die Datei exsistiert bereits, \u00DCberschreiben? ",null,AlertType.ERROR);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public final static String proxy_errora = "FC 105 A";
	public final static String proxy_errorb = "FC 105 B";
	public final static String proxy_errorc = "FC 105 C";
	public final static String no_valid1_lizenz = "FC 205";
	public final static String no_valid2_lizenz = "FC 305";
	public final static String no_valid3_lizenz = "FC 405";
	public final static String no_port_left = "FC 909";
	public final static String ip_banned = "FC 908";
	public final static String PROXYNOTREADY = "FC 808";
/*
FC 105 A - Protokollfehler ( tritt auf, wenn der client weder sucht, results abholt, logs sendet )
FC 105 B - Lizenzfehler - tritt auf, wenn in der Lizenzemanagemant ein Fehler auftritt - zb der SQL Socket nicht geöffnet werden konnte
FC 105 C - Cachingfehler - tritt auf, wenn der Client einen ungültigen suchbegriff abholen wollte und das Senden eines zugehörigen Caches ebenfalls fehlgeschlagen ist
FC 205 - Die Lizenz ist ungültig
FC 305 - Client Version passt nicht zur Lizenz
FC 405 - Der Handy Client hat eine Dateiendung angefragt, die er laut Lizenz nicht darf
FC 808 - der Proxy hat noch keine Ergebnisse , Handy bitte noch warten
FC 908 - die IP des Handysclient ist geblockt vom Proxy
FC 909 - Server ist busy und kann keine Anfragen mehr annehmen
*/
	/**************************************************/
	public static void init(){
		holeTime = firstWaitTimer;
		alert_a.setTimeout(Alert.FOREVER);
		alert_b.setTimeout(Alert.FOREVER);
		alert_c.setTimeout(Alert.FOREVER);
		alert_d.setTimeout(Alert.FOREVER);
		alert_e.setTimeout(Alert.FOREVER);
		alert_f.setTimeout(Alert.FOREVER);
		alert_g.setTimeout(Alert.FOREVER);
		alert_h.setTimeout(Alert.FOREVER);
		alert_i.setTimeout(Alert.FOREVER);
		alert_j.setTimeout(Alert.FOREVER);
		alert_k.setTimeout(Alert.FOREVER);
		alert_L.setTimeout(Alert.FOREVER);
		alert_m.setTimeout(Alert.FOREVER);
	//++++++++++++++++++++++++++++++++++++++++++++++++
	   dateiExsist.setTimeout(Alert.FOREVER);
	   dateiExsist.addCommand(alertOkCommand);
	   dateiExsist.addCommand(alertCancelCommand);
	   //random = new Random();
	   //PROXY_IP = Constant.DYN_DNS[Math.abs(random.nextInt())%Constant.DYN_DNS.length];
	//++++++++++++++++++++++++++++++++++++++++++++++++	
	}
	/**************************************************/
	public static String toOutString(){
		String ret= "SELECTED_FILE_TYPES "+SELECTED_FILE_TYPES+CRLF
		+"SELECTED_FILE_FAMILY "+SELECTED_FILE_FAMILY+CRLF;
		for(int i=0;i<ALLOWED_FILE_TYPES.length;i++)
			ret = ret + "ALLOWED_FILE_TYPES "+i+" "+ALLOWED_FILE_TYPES[i]+CRLF
		+"PICTURE_FAMILY "+PICTURE_FAMILY+CRLF
		+"LIZENZ_KEY "+LIZENZ_KEY+CRLF
		+"VERSION "+VERSION;
		return ret;
	}
/**************************************************/
}