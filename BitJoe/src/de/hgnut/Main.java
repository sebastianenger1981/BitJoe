package de.hgnut;
/*****************************************************************/
import javax.microedition.lcdui.*;
import javax.microedition.midlet.*;
/*****************************************************************/
import de.hgnut.Misc.*;
import de.hgnut.Gui.*;
import de.hgnut.GnuUtil.*;
import de.hgnut.GnuUtil.Messages.*;
import com.jicoma.ic.Crypt;
import com.jicoma.ic.ConnectData;
//import com.nokia.mid.ui;
import java.io.InputStream;
import java.io.IOException;
import javax.microedition.rms.RecordStore;
/*
	1. Bugs, Bugs, Bugs --> unerlaubte Zeichen in Dateinamen, 2 Proxys
	2. HTTPS
	3. Konfig bis Downloadackk durchreichen und sonstwohin auch
	4. Gui Finetuning --> ?? Stunden Arbeitszeit
*/
/*****************************************************************/
public class Main extends MIDlet implements GuiActionListener{
/*****************************************************************/
	private Display display = null;
	private Command currentCommand;
	private boolean ini = false;
	private WelcomeScreen welcomeS;
	private StartScreen startS;
	private SearchScreen searchS;
	private ListScreen listS;
	private KonfigScreen konfigS;
	private SaveScreen saveS;
	private AnmeldeScreen anmeldeS;
	private CouponScreen couponS;
	private AufladeScreen aufladeS;
	private ConfirmScreen confirmS;
	private UserDatenScreen userS; 
	private PropManager propmanager;
	private ProxySearchConnection proxcon;
	//private StatusScreen statusS;
	//++++++++++++++++++++++++++++++++++++++++++++
	private Crypt cr;
	Alert splashScreenAlert;
    Image   splashScreen;
    private GnuConnection gnucon;
    private String AGBs ="";
    private ConnectData cd; 
	//+++++++++++++++++++++++++++++++++++++++++++
/*****************************************************************/
	//implements MIDlet
	protected void startApp() throws MIDletStateChangeException{
		if(!ini)init();
		Constant.FILENAME ="";
		Constant.ALLOWED_FILE_TYPES = Constant.VIDEO_FILE_TYPES;
		//Constant.SELECTED_FILE_TYPE = 0;
		//saveS = new SaveScreen(display, this, propmanager.getProperty("dir_last"));
	}

	private void init(){	
		Constant.init();
		//System.out.println("File Type 48: "+ Constant.SELECTED_FILE_TYPE);
		propmanager = new PropManager("BitJoeRS");
		display = Display.getDisplay(this);
		welcomeS = new WelcomeScreen(this);
		konfigS = new KonfigScreen(this);
		startS = new StartScreen(this);
		searchS = new SearchScreen(this);
		listS = new ListScreen(this);
		anmeldeS = new AnmeldeScreen(this);
		couponS = new CouponScreen(this);
		aufladeS = new AufladeScreen(this, this);
		confirmS = new ConfirmScreen(this);
		userS = new UserDatenScreen(this);
		cd = new ConnectData(Constant.connectData);
		Constant.PROXY_IP = cd.getIp();
		Constant.PROXY_PORT = cd.getPort();
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		try {
         splashScreen = Image.createImage("/images/logo_klein_64.png");
         //Image source = Image.createImage("/images/logo_klein_64.png");	
         //splashScreen = Image.createImage(source.getWidth(), source.getHeight());
         //splashScreen = Image.createImage(source,0,0,source.getWidth,source.getHeight(),Sprite.TRANS_NONE);
         //g = splashScreen.getGraphics();    
         //g.drawImage(splashScreen, 0, 0, Graphics.TOP|Graphics.LEFT); 
        } catch (java.io.IOException ex) {
        	System.out.println("Bild nicht geladen");
        }

        splashScreenAlert = new Alert("BitJoe", "BitJoe "+Constant.VERSION+" www.bitjoe.de", splashScreen, AlertType.INFO);
        splashScreenAlert.setTimeout(2000);
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
		if(checkUP()){
			display.setCurrent(splashScreenAlert ,welcomeS);
		}else{
			display.setCurrent(splashScreenAlert ,anmeldeS);
		}
         
		//display.setCurrent(splashScreenAlert ,AGBS);
		//display.setCurrent(splashScreenAlert ,tc);	
		ini = true;
		//++++++++++++++++++++++++++++++++++++++++++++
		cr = new Crypt(LizenzKey.getKey());
		couponS.setCrypt(cr);
		aufladeS.setCrypt(cr);
		userS.setCrypt(cr);
		
		//++++++++++++++++++++++++++++++++++++++++++++
	}
/*****************************************************************/
	public void destroyApp(boolean unconditional){
		//System.out.println("Hellox :"+ propmanager.toString());
		if(proxcon != null){
		  proxcon.status =true;
	    }
		propmanager.save();
	}
/*****************************************************************/
	public void pauseApp(){}
/*****************************************************************/
        public void guiActionPerformed(GuiAction ga){
        	
		currentCommand = ga.COMMAND;
		if(ga.SOURCE.equals(Constant.COUPONSCREEN)){
			if(ga.MESSAGE != null){
			Constant.alert_k.setString(ga.MESSAGE);
			display.setCurrent(Constant.alert_k);	
			}else{
			  if(ga.STATUS < 1){
			  	Constant.alert_k.setString(Constant.coupon);
			  	anmeldeS.setText();
			    display.setCurrent(Constant.alert_k, anmeldeS);
			    Constant.coupon="";
			  }else{			
			    Constant.alert_k.setString(Constant.coupon);
			    display.setCurrent(Constant.alert_k, welcomeS);
			    Constant.coupon="";
			  }  
			} 
		}	
		else if(ga.SOURCE.equals(Constant.ANMELDESCREEN)){
			if(ga.STATUS < 1){
			display.setCurrent(welcomeS);
		    }else{
		    confirmS.setText();	
			display.setCurrent(confirmS);
		    }
		}else if(ga.SOURCE.equals(Constant.CONFIRMSCREEN)){
			if(ga.COMMAND.equals(Constant.jaCommand))
				anmeldeS.setRecord();
				display.setCurrent(welcomeS);
							
		
		}else if(ga.SOURCE.equals(Constant.AUFLADESCREEN)){
			if(ga.MESSAGE.equals("-1")){
			 anmeldeS.setText();
			 display.setCurrent(anmeldeS);
			}else{
				//System.out.println("zurück geklickt"); 
			 //kontoS.setPrice(false);
			} 
		}
		else if(ga.SOURCE.equals(Constant.USERDATENSCREEN)){
			if(currentCommand == Constant.jaCommand){
			  anmeldeS.setText();
			  display.setCurrent(anmeldeS);	
			}else if(currentCommand == Constant.neinCommand){
				if(ga.STATUS > 0){
					if(!Constant.USER.equals("")){
					 System.out.println("Zeile 239");
					}else{
						display.setCurrent(Constant.alert_m, welcomeS);
					}		
				}else{
					if(!Constant.USER.equals("")){
					 display.setCurrent(couponS);
					}else{
						display.setCurrent(Constant.alert_m, welcomeS);
					}	 	
				}		
			}			
		}		
		else if(ga.SOURCE.equals(Constant.WELCOMESCREEN)){
			System.out.println("Welkomscreen");
				
			if (currentCommand == Constant.exitCommand){
	        		System.out.println("WELCOMESCREEN SAGT -> EXIT");
	        		Constant.pbDone = true;
				    destroyApp(false);
	 	           	notifyDestroyed();
	 	        }else if (currentCommand == Constant.okCommand){
	 	        	switch(ga.STATUS){
	 	        		case 0:/*Versuche Videos*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[0]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
	 	        				Constant.SELECTED_FILE_FAMILY = Constant.VIDEO_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.VIDEO_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","0");
				 	        	Constant.firstWaitTimer = 30000;
							//display.setCurrent(startS);
							display.setCurrent(searchS);
	 	        			}
	 	        			break;
	 	        		case 1:/*Versuche Bilder*/
						if(!Constant.ALLOWED_FILE_FAMILYS[1]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
	 	        				Constant.SELECTED_FILE_FAMILY = Constant.PICTURE_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.PICTURE_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	//System.out.println("File Type 112: "+ Constant.SELECTED_FILE_TYPE);
				 	        	propmanager.setProperty("file_family_last_index","1");
				 	        	Constant.firstWaitTimer = 30000;
							//display.setCurrent(startS);
							display.setCurrent(searchS);
	 	        			}
	 	        			break;
	 	        		case 2:/*Versuche Klingeltöne*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[2]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.KLINGEL_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.KLINGEL_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","2");
				 	        	Constant.firstWaitTimer = 30000;
							//display.setCurrent(startS);
							display.setCurrent(searchS);
	 	        			}
	 	        			break;
	 	        		case 3:/*Versuche MP3*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[3]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.MUSIK_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.MUSIK_FILE_TYPES;							
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","3");
				 	        	Constant.firstWaitTimer = 20000;
							//display.setCurrent(startS);
							display.setCurrent(searchS);
	 	        			}
	 	        			break;
	 	        		case 4:/*Versuche Java*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[4]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.JAVA_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.JAVA_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","4");
				 	        	Constant.firstWaitTimer = 40000;
							//display.setCurrent(startS);
							display.setCurrent(searchS);
	 	        			}
	 	        			break;
	 	        		case 5:/*Versuche Dokumente*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[5]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.DOK_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.DOK_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());				 	        	
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","5");
				 	        	Constant.firstWaitTimer = 40000;
							//display.setCurrent(startS);
							display.setCurrent(searchS);
	 	        			}
	 	        			break;
	 	        		case 6:
	 	        		    //getAGBs();
	 	        		    display.setCurrent(startS);
	 	        		    break;	
	 	        		case 7:
	 	        		   //System.out.println("Gutschein einlösen");
	 	        		   if(!Constant.USER.equals("")){
	 	        		   display.setCurrent(couponS);
	 	        		   }else{
	 	        		   	 userS.setStatus(0);
	 	        		     display.setCurrent(userS);
	 	        		   } 
	 	        		   break;
	 	        		case 8:
	 	        		    anmeldeS.setText();
	 	        		    display.setCurrent(anmeldeS);
	 	        		    break;        
	 	        		    	
	 	        	}
	 	        }
	//STARTSCREEN
		}else if(ga.SOURCE.equals(Constant.STARTSCREEN)){
			System.out.println("Startscreen");
			if (currentCommand == Constant.cancelCommand){
	        		System.out.println("SEACHSCREEN SAGT -> BACK");
				display.setCurrent(welcomeS);
	        	}else if (currentCommand == Constant.okCommand){
	        		switch(ga.STATUS){
	 	        		case 0:/*Versuche Videos*/
	 	        		 //System.out.println("Hiuer dafgsakldgjkadfjg fdagagf ggdsafg");
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[0]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
	 	        				Constant.SELECTED_FILE_FAMILY = Constant.VIDEO_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.VIDEO_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","0");
							//display.setCurrent(startS);
							display.setCurrent(konfigS);
	 	        			}
	 	        			break;
	 	        		case 1:/*Versuche Bilder*/
						if(!Constant.ALLOWED_FILE_FAMILYS[1]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
	 	        				Constant.SELECTED_FILE_FAMILY = Constant.PICTURE_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.PICTURE_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	//System.out.println("File Type 112: "+ Constant.SELECTED_FILE_TYPE);
				 	        	propmanager.setProperty("file_family_last_index","1");
							//display.setCurrent(startS);
							display.setCurrent(konfigS);
	 	        			}
	 	        			break;
	 	        		case 2:/*Versuche Klingeltöne*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[2]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.KLINGEL_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.KLINGEL_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","2");
							//display.setCurrent(startS);
							display.setCurrent(konfigS);
	 	        			}
	 	        			break;
	 	        		case 3:/*Versuche MP3*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[3]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.MUSIK_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.MUSIK_FILE_TYPES;							
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","3");
							//display.setCurrent(startS);
							display.setCurrent(konfigS);
	 	        			}
	 	        			break;
	 	        		case 4:/*Versuche Java*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[4]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.JAVA_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.JAVA_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","4");
							//display.setCurrent(startS);
							display.setCurrent(konfigS);
	 	        			}
	 	        			break;
	 	        		case 5:/*Versuche Dokumente*/
	 	        			if(!Constant.ALLOWED_FILE_FAMILYS[5]){
	 	        				display.setCurrent(Constant.alert_j,welcomeS);
	 	        			}else{
		 	        			Constant.SELECTED_FILE_FAMILY = Constant.DOK_FAMILY;
							Constant.ALLOWED_FILE_TYPES = Constant.DOK_FILE_TYPES;
				 	        	konfigS.init(getAFFFIProp());				 	        	
				 	        	Constant.SELECTED_FILE_TYPES=getAFFFIProp();
				 	        	propmanager.setProperty("file_family_last_index","5");
							//display.setCurrent(startS);
							display.setCurrent(konfigS);
	 	        			}
	 	        			break;
	 	        	 }	
	        		//System.out.print("STARTSCREEN SAGT -> : OK ");
	        		//System.out.println(ga.MESSAGE);
	        		//if(ga.MESSAGE.equals(Constant.SEARCHSCREEN)){
	        			//if(Constant.SELECTED_FILE_TYPE==-1){
	        				//zwinge ihn zur konfig
	        				//Constant.SELECTED_FILE_TYPE=0;
	        				//display.setCurrent(Constant.alert_i,konfigS);
	        			//}*/
	        				//display.setCurrent(searchS);
	        			
	        		//}else if(ga.MESSAGE.equals(Constant.KONFIGSCREEN)){	        			
					//display.setCurrent(konfigS);
	        		//}
	        	}
	//SEARCHSCREEN
		}else if(ga.SOURCE.equals(Constant.SEARCHSCREEN)){
			//searchS.insert(" vor new Status screen "+ Constant.TOSEARCH, searchS.getCaretPosition()+1);
			//statusS = new StatusScreen(this, "Suche teen");
			//searchS.insert(" nach new status screen "+ Constant.TOSEARCH, searchS.getCaretPosition()+1);
			System.out.println("Searchscreen");
	        	if (currentCommand == Constant.cancelCommand){
	        		System.out.println("SEACHSCREEN SAGT -> CANCEL");
				//display.setCurrent(startS);
				display.setCurrent(welcomeS);
	        	}else if (currentCommand == Constant.okCommand || currentCommand ==  Constant.ok2Command){
				Constant.TOSEARCH = ga.MESSAGE;
				//searchS.insert(" in search Screen run "+ Constant.TOSEARCH, searchS.getCaretPosition()+1);
//	        		System.out.println("SEACHSCREEN SAGT -> SUCHE: "+Constant.TOSEARCH);
				if(Constant.TOSEARCH!=null&&Constant.TOSEARCH.trim().length()>0){
					//searchS.insert(" hierdrin ", searchS.getCaretPosition()+1);
					//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					//display.setCurrent(statusS);
					//statusS = new StatusScreen(this,"Suche "+Constant.TOSEARCH);
					Constant.pbDone = false;
					Constant.holeTime = Constant.firstWaitTimer;
	                Constant.label= "Versuch 1:  0 %     ";

	                StatusScreen statusS = new StatusScreen(this,Constant.TOSEARCH, false, "BitJoe sucht"); 
					//display.setCurrent();
					display.setCurrent(statusS);
					//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					     //searchS.insert(" nach new StatusScreen ", searchS.getCaretPosition()+1);
		        		//search();
		        		search(statusS);
		        		if(Constant.hits!=null&&Constant.hits.size()>0){
		        			listS.setHits(Constant.hits);
		        			display.setCurrent(listS);
		        		}else{
		        			if(Constant.clearRecord){
		        				//Constant.alert_k.setString(Constant.error);
		        				//anmeldeS.setText();
						    	//display.setCurrent(Constant.alert_k, anmeldeS);
						    	System.out.println("neue suche mit neuer ip !!!!");
						    	display.setCurrent(statusS);
						    	search(statusS);
						    	//Constant.error="";
						    	Constant.clearRecord = false;
						     
						    }else{
						       if(Constant.error.equals("")){
						       	 display.setCurrent(Constant.alert_a,searchS);
						       	 //display.setCurrent(Constant.alert_a,kontoS);
						       }else{ 
						         Constant.alert_k.setString(Constant.error);
						         //display.setCurrent(Constant.alert_k,searchS);
						         System.out.println("Zeile 526");
						         Constant.error="";
						       }   
						    }
		        		}
		        	}else{
		        		display.setCurrent(Constant.alert_f,searchS);
		        	}
	        	}
	//LISTSCREEN
	        }else if(ga.SOURCE.equals(Constant.LISTSCREEN)){
	        	System.out.println("Listscreen");
	        	if (currentCommand == Constant.cancelCommand){
	        		System.out.println("LISTSCREEN SAGT -> CANCEL");
	        		//AUFRÄUMEN ALTE SUCHE UND ALLE TREFFER WEGWERFEN
	        	  Constant.TOSEARCH = null;
				  Constant.hits = null;
				//startS = new StartScreen(display, this);
				display.setCurrent(welcomeS);
	        	}else if (currentCommand == Constant.okCommand){
	        		System.out.println("LISTSCREEN SAGT -> OK");
//	        		Hier muss der SAVEAS Dialog aufgerufen werden
                    
                    if(ga.STATUS == 1000){
                      System.out.println("Zeile 550");
				    }else{ 
	        		 saveS = new SaveScreen(display, this, propmanager.getProperty("dir_last"));
	        		} 
	        	}
	//KONFIGSCREEN
		}else if(ga.SOURCE.equals(Constant.KONFIGSCREEN)){
			System.out.println("Konfigscreen");
			if(currentCommand== Constant.cancelCommand){
				display.setCurrent(startS);
			}else if (currentCommand== Constant.okCommand){
				//Constant.SELECTED_FILE_TYPE = konfigS.SELECTEDINDEX;
				//System.out.println("Selected File Types "+Constant.SELECTED_FILE_TYPES);
				setAFFFIProp(Constant.SELECTED_FILE_TYPES);
				display.setCurrent(startS);
			}
	//STATUSSCREEN
	        }else if(ga.SOURCE.equals(Constant.STATUSSCREEN)){//1
	        	System.out.println("Statusscreen");		
	        if (currentCommand == Constant.exitCommand){//2
	        	if(ga.MESSAGE.equals("download")){//3
	        	   gnucon.stopDownload();
	        	   	Constant.pbDone = true;
				    destroyApp(false);
	 	           	notifyDestroyed();
	        		//System.out.println("Hier angekommen download download");
	        	  }else if(ga.MESSAGE.equals("status")){//end 3 3
	                proxcon.status= true;
	        		Constant.pbDone = true;
	        		destroyApp(false);
	 	           	notifyDestroyed();
	        	  }//end 3
	        		
				
	 	        }else if(currentCommand == Constant.cancelCommand){// end 2 2
	 	        	if(ga.MESSAGE.equals("download")){//3
	        		  //System.out.println("Hier angekommen download download");
	        		  gnucon.stopDownload();
	        		  display.setCurrent(Constant.alert_c);
	        		  
	        	    }else if(ga.MESSAGE.equals("status")){	//end 3 3
	        		  proxcon.status= true;
	        		  //Constant.pbDone = false;
					  //Constant.holeTime = Constant.firstWaitTimer;
	                  //Constant.label= "Versuch 1:  0 %     ";
	                  //Constant.time = 0;
	        	      //display.setCurrent(searchS);
	        	    }//end 3
	        	}//end 2       
	        	
	        	
	//SAVESCREEN
	        }else if(ga.SOURCE.equals(Constant.SAVESCREEN)){//end 1
	        	//System.out.println("Savescreen");
	        	if (currentCommand == Constant.cancelCommand){
	        		System.out.println("SAVESCREEN SAGT -> CANCEL");	        			        			        	
	        		display.setCurrent(Constant.alert_c,listS);
	        		//display.setCurrent(Constant.alert_c,startS);
	        	}else if (currentCommand == Constant.okCommand || currentCommand ==  Constant.ok2Command || currentCommand ==  Constant.speichernCommand ){
					System.out.println("SAVESCREEN SAGT -> OK");
					
					//System.out.println("Savescreen ga Status: "+ ga.STATUS );
						
					Constant.FILENAME = (String)((Object[])((ProxySearchReply)Constant.hits.elementAt(ga.STATUS)).getSource(0))[3];
					System.out.println("Filename: "+Constant.FILENAME);
					//Constant.FILENAME = (String)((Object[])((ProxySearchReply)Constant.hits.elementAt(ga.STATUS)).getSource(ga.STATUS))[3];
					
					//System.out.println("Filename Main: "+ Constant.FILENAME);
					//System.out.println("saveS.TOSAVE Main: "+ saveS.TOSAVE);
					//System.out.println("Constant hits.element Main: "+ Constant.hits.elementAt(ga.STATUS));
					Constant.pbDone = false;
					Constant.label ="Versuch:         ";
					String fname = Constant.FILENAME;
					if(fname.length() > 30)
					  fname= fname.substring(0,29)+ "...";
	        		display.setCurrent(new StatusScreen(this, fname, true, "BitJoe l\u00E4d"));
	        		gnucon = new GnuConnection((ProxySearchReply)Constant.hits.elementAt(ga.STATUS),saveS.TOSAVE, cr);
	    			gnucon.start();
	    			while(!gnucon.finished){
	    				try{
					   Thread.currentThread().sleep(1000);
					   }catch (InterruptedException ie){
						 System.out.println("Main.run while();");
						 ie.printStackTrace();
					   }
	    			}	    			
	    			if(!gnucon.statusdownload){
	    				display.setCurrent(Constant.alert_b,listS);
	    			}else if(!gnucon.statussave){
	    				display.setCurrent(Constant.alert_c,listS);
	    			}else{
	    				display.setCurrent(Constant.alert_d,listS);
	    			}
		        	propmanager.setProperty("dir_last",saveS.DIR);
		        	//System.out.println(" Prop Save: "+propmanager.getProperty("dir_last") );
					//AUFRÄUMEN ALTE SUCHE UND ALLE TREFFER WEGWERFEN
		        	//Constant.FILENAME = null;
		        	saveS.TOSAVE = null;
	        	}
	        }
       	}
/*****************************************************************/
	private synchronized void search(StatusScreen statusS ){
	//private synchronized void search(){
		//ProxySearchConnection proxcon = new ProxySearchConnection(Constant.PROXY_IP,Constant.PROXY_PORT,Constant.TOSEARCH);
		//System.out.println("Random: "+Math.abs(random.nextInt())%Constant.DYN_DNS.length);
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		proxcon = new ProxySearchConnection(Constant.PROXY_IP,Constant.PROXY_PORT,Constant.TOSEARCH, cr, statusS, display, cd, searchS );
		//System.out.println("cd "+ cd);
		//proxcon = new ProxySearchConnection(cd.getIp(),cd.getPort(),Constant.TOSEARCH, cr, statusS, display, cd);
		//ProxySearchConnection proxcon = new ProxySearchConnection(Constant.PROXY_IP,Constant.PROXY_PORT,Constant.TOSEARCH, cr, statusS);
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       		proxcon.start();
       
		 //do{}while(!proxcon.status);
	     do{ 
		  try{
			wait(1000);
		    }catch(InterruptedException ire){
		    }		
		}while(!proxcon.status);
		 
	    
		if(proxcon.results!=null&&proxcon.results.size()>0){
			/*for(int z=0;z<proxcon.results.size();z++){
				System.out.println("-----------------");
				System.out.println(((ProxySearchReply)proxcon.results.elementAt(z)).toString());
				System.out.println("-----------------");
			}*/
			Constant.hits = proxcon.results;
		}else{
			System.out.println("Keine SearchReplyMessage bekommen");
			proxcon.status=true;
			//proxcon=null;
			Constant.hits = null;
		}
	}
/*****************************************************************/
	private void setAFFFIProp(String index){
		//System.out.println("setAFFFIPRO: "+ index);
		propmanager.setProperty(Constant.SELECTED_FILE_FAMILY,index);
	}
/*****************************************************************/
	private String getAFFFIProp(){
		//System.out.println("befor propmanager "+ Constant.SELECTED_FILE_FAMILY);
		String tmp = propmanager.getProperty(Constant.SELECTED_FILE_FAMILY);
		//System.out.println("getAFFFIPRO: "+ tmp);
		if(tmp!=null){
			try{
				return tmp;
			}catch(Exception e){
				return "-1";
			}
		}else{
			if(Constant.SELECTED_FILE_FAMILY.equals("v")){
				//"3gp","mpg","avi","wmv","mp4","rm","mpeg","mov","wmm","wmf","ram","ogm","vivo","asx","flv","fla","swf","f4v"
				return "111000100000000000";
			}else if(Constant.SELECTED_FILE_FAMILY.equals("m")){
			   	//"mp3","wma","mp2","midi","mid","wav","aac","amr","wave","flac","smaf","mld","ogg","mmf","aiff","rma","ape","mpc"
			   	return "100100000000000000";
			}else if(Constant.SELECTED_FILE_FAMILY.equals("b")){
			   	//"jpg","jpeg","png","gif","bmp","tiff","svg","jpa","tif","thm"
			   	return "1100000000";   	
			}else if(Constant.SELECTED_FILE_FAMILY.equals("j")){
			   	//"jar","class","jad","sis","sisx"
			   	return "10000"; 
			}else if(Constant.SELECTED_FILE_FAMILY.equals("d")){
			   	//"txt","pdf","rtf","xls","xlsx","doc","docx","ppt","pptx","xml","html","htm","xhtml","odt","sxw","ods","sxc","odp","sxi"
			   	return "1111111111111111111";    	  	
			}else{	
			 return "-1";
		    }
		}
	}
	private boolean checkUP(){
	   try{	
		RecordStore rs = RecordStore.openRecordStore("UP" , false);
		String UPs = new String(rs.getRecord(1));
		String Sec = new String(rs.getRecord(2));
		
		Constant.UP_MD5 = UPs;
		Constant.SEC_MD5 = Sec;
		
		String UPsS = new String(rs.getRecord(3));
		String UserS =  new String(rs.getRecord(4));
		//System.out.println("UP_MD5: "+ UPs +" SEC_MD5: "+ Sec);
		Constant.USER = UPsS;
		Constant.ID = UserS; 
		rs.closeRecordStore();
		return true;
	   }catch(Exception e){
	    	//System.out.println("Das war wohl nixx: " + e);
	    	e.printStackTrace();
	   	return false;
	   }		
	}
	
  /*private boolean checkFileAccess(){
  	try {
 	   javax.microedition.io.file.FileConnection currDir = (javax.microedition.io.file.FileConnection)javax.microedition.io.Connector.open("file:////" ,javax.microedition.io.Connector.READ_WRITE);
 	   System.out.println("currDir. " + currDir);
 	   return true;
 	}catch(Exception e){
        System.out.println(e);
        return false;
    }
  }	*/			
/*****************************************************************/
}//Class