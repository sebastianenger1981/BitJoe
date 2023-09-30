package com.jicoma.ic;

import phex.gui.tabs.search.cp.SearchControlPanel;
import java.net.*;
import java.io.*;
import javax.swing.*;
import phex.gui.tabs.search.SearchTab;
import java.util.ArrayList;
import phex.download.RemoteFile;
import phex.gui.tabs.search.cp.SearchActivityBox;
import phex.gui.tabs.search.SearchResultsDataModel;
import phex.gui.tabs.search.filterpanel.QuickFilterPanel;
import java.util.Hashtable;
import phex.gui.tabs.search.SearchListPanel;

public class PhexServerThread extends Thread{
        
 private ServerSocket service;
 //private KeywordSearchBox ksb;
 private SearchControlPanel scp;
 private SearchResultsDataModel srdm;
 private SearchListPanel slp;
 private SearchTab st;
 private ArrayList al;
 private RemoteFile rf;
 private StringBuffer sb;
 private Hashtable ht;
 private final String z = ";!$#%&";
 private PrintWriter sending;
 private String token ;
 private Socket client = null;
 //private boolean connected = true;
 
 	
 public PhexServerThread(SearchControlPanel scp, SearchListPanel slp, String token, Socket client, Hashtable ht){
 	this.scp=scp;
   	this.slp=slp;
   	this.token = token;
   	this.client = client;
   	this.ht = ht;
   	this.st= scp.getSearchTab(); 
 }		
 	
 	public void run(){
 		scp.setBlock(true);

        BufferedReader receiving;
        String searchString ="";
        
        //while(connected){
        	try{
        	
        	 	
        	 System.out.println("neue connection");
        	 sending = new PrintWriter(client.getOutputStream(), true);
        	 receiving = new BufferedReader(new InputStreamReader(client.getInputStream()));
        	 //sending = client.getOutputStream();
        	 //receiving = client.getInputStream();	
        	 
        	 
        	 String inputLine = "";
        	 //String outputLine= "";
        	 sending.println("");
        	 sending.flush();
        	 
        	 
        	 while((inputLine = receiving.readLine()) != null) {
        	 	System.out.println("in: '"+inputLine+ "'");
        	 	//inputLine = "find 1 0 9999999 Any abc paris .jpg";
        	 	//System.out.println("Input 2: "+ inputLine);	
        	  
        	 String[] input = inputLine.split(" "); 	
            
             if (input[0].equals("find")){
             	//if(BitJoePrefs.MaxSearchSetting.get() < ht.size()+1){
             		//sending.println("busy\\n");
             		//sending.close();
             		//connected = false;
             		//scp.setBlock(false); 
             	//}else{	
             	//System.out.println("in find");
             	input[5]= "token="+input[5];
             	if(input[5].equals(token)){
             	
             		
             	  searchString= "";
             	for(int i = 6; i < input.length; i++){
             	  searchString = searchString + input[i]+" ";
                }
                if(!ht.containsKey(input[1])){
                  if(!searchString.equals("")){
                  	 String suffix = searchString.substring(searchString.lastIndexOf("-filetype")+10, searchString.length());
                  	 searchString = searchString.substring(0 , searchString.lastIndexOf("-filetype"));
                  	 searchString = searchString.trim();
                  	 //System.out.println("suffix: "+suffix);
                  	 suffix = suffix.trim();
                  	 //System.out.println("suffix: "+suffix);
                  	 //System.out.println("searchString: "+ searchString);
                  	 //System.out.println("block true");
                  
                  	 scp.setSuffix(suffix);
                	if(scp.startKeywordSearch(searchString, ht, input[1])){
                		find(input);
                		//scp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
             	        //slp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
                		System.out.println("searching for : "+ searchString);
                		//sending.println("searching for : "+ searchString);
                		sending.close();
                		//slp.repaint();
                		//connected = false;
                		//scp.setBlock(false);
                		//System.out.println("connection closed");
                		//sending.flush();
                	}else{
                		SearchActivityBox.klick();
                		if(scp.startKeywordSearch(searchString)){ 
                		    find(input);
                		    //sending.println("searching for : "+ searchString);
                		    sending.close();
                		    //slp.repaint();
                		    //connected = false;
                		    //scp.setBlock(false); 
                		//System.out.println("connection closed");
                	    }else{
                	    	//sending.println("searching not for: "+ searchString);
                	    	sending.close();
                	    	//slp.repaint();
                	    	//connected = false;
                		    //scp.setBlock(false); 
                		    //System.out.println("connection closed");
                	    }
                	}
                	//System.out.println("block false");
                	//connected = false;
                	//scp.setBlock(false);    	
                }else{
                	//sending.println("usage: find id Minsize Maxsize Dateityp Tokenid Suchbegriff");
                	sending.close();
                	//connected = false;
                	//scp.setBlock(false); 
                	//System.out.println("connection closed");
                	//sending.flush();
                }
              }else{
              	//sending.println("id "+input[1]+" already exsists");
              	sending.close();
              	//connected = false;
              	//scp.setBlock(false); 
                //System.out.println("connection closed");
              	//sending.flush();
              }
            }else{
            	//sending.println("wrong token conection canceled");
            	//sending.flush();
                sending.close();
                //connected = false;
                //scp.setBlock(false); 
                //System.out.println("connection closed");
               //} 		
            }
            
              /*}else if(input[0].equals("stop")){
              	input[2]= "token="+input[2];
              	if(input[2].equals(token)){
             	if(!input[1].equals("")){
             		if(!ht.containsKey(input[1])){
             			sending.println("id: "+input[1]+" does not exsist");
             			sending.close();
             			//connected = false;
             			//scp.setBlock(false); 
             			//sending.flush();
             		}else{
             	    scp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
             	    slp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
             	    scp.stopSearching();
             	    sending.println("searching for id "+ input[1] +" is stoped");
             	    sending.close();
             	    //connected = false;
             	    //scp.setBlock(false); 
                    //System.out.println("connection closed");
             	    //sending.flush();
             	  }
             	}else{
             		sending.println("usage: stop id Tokenid");
             		sending.close();
             		//connected = false;
             		//scp.setBlock(false); 
                    //System.out.println("connection closed");
             		//sending.flush();
             	}
             }else{
             	sending.println("wrong token conection canceled");
             	//sending.flush();
            	sending.close();
            	//connected = false;
            	//scp.setBlock(false); 
            	//System.out.println("connection closed");
             }
             	
             }else if(input[0].equals("del")){
             	input[2]= "token="+input[2];
              	if(input[2].equals(token)){
              	 if(!input[1].equals("")){
              	 	if(!ht.containsKey(input[1])){
             			sending.println("id: "+input[1]+" does not exsist");
             			sending.close();
             			//connected = false;
             			//scp.setBlock(false); 
             		}else{
             	  //System.out.println("blocked true");
              	    scp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
              	    slp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
             	    scp.stopSearching();
             	    //srdm = scp.getSearchResultsDataModel();
             	    //srdm.clearSearchResults();
             	    //((SearchResultsDataModel)ht.get(input[1])).clearSearchResults();
             	    //System.out.println(st);
             	    try{
             	     st.closeSearch(((SearchResultsDataModel)ht.get(input[1])).getSearch());
             	    }catch(Exception e){
             	    }	
             	    //SearchActivityBox.closeSearch();
             	    ht.remove(input[1]);
             	    sending.println(input[1]+" had ceased to exsist");
             	    sending.close();
                    //System.out.println("connection closed");
             	    //sending.flush();
             	    //sending.close();
             	    //System.out.println("blocked false");
             	    //connected = false;
             	    //scp.setBlock(false);
             	  }
              }else{
             		sending.println("usage: del id");
             		sending.close();
             		//connected = false;
             		//scp.setBlock(false); 
                    //System.out.println("connection closed");
             		//sending.flush();
             	}
             	}else{
             		sending.println("wrong token conection canceled");
             		//sending.flush();
            	    sending.close();
            	    //connected = false;
            	    //scp.setBlock(false); 
            	     //System.out.println("connection closed");
             	}
 	         
             }else if(input[0].equals("exit")){
             	input[1]= "token="+input[1];
              	if(input[1].equals(token)){
             	   sending.println("Bye");
             	   sending.close();
             	   //connected = false;
             	   //scp.setBlock(false); 
                    //System.out.println("connection closed");
             	   //sending.flush();
                   System.exit(-1);
                }else{
                	sending.println("wrong token conection canceled");
                	//sending.flush();
            	    sending.close();
            	    //connected = false;
            	    //scp.setBlock(false); 
                    //System.out.println("connection closed");
                }*/	      				  	
             }else if(input[0].equals("result")){
             	input[2]= "token="+input[2];
              	if(input[2].equals(token)){
             	if(!input[1].equals("")){
             		if(!ht.containsKey(input[1])){
             			//sending.println("id: "+input[1]+" does not exsist");
             			sending.close();
             			//connected = false;
             			//scp.setBlock(false); 
                        //System.out.println("connection closed");
             			//sending.flush();
             		}else{
             	  //System.out.println("blocked true");
             	  //scp.setBlock(true);	
             	   scp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
             	   slp.setDisplayedSearch((SearchResultsDataModel)ht.get(input[1]));
                   srdm = scp.getSearchResultsDataModel();
                   srdm.setSortBy(5, false);	
                   al=srdm.getAllRemoteFiles();
                   if(al != null){
                   	 sb = new StringBuffer();
                   	 String s = "";
                   	 String sha1 ="";
                   	 int treffer = 0;
                   	 int quellen = 0;
                   	 int maxTreffer = BitJoePrefs.TrefferSetting.get();
                   	 int maxQuellen = BitJoePrefs.QuellenSetting.get();
                   	 int maxKb = BitJoePrefs.MaxKbSetting.get();
                   	 //System.out.println("maxTreffer: "+maxTreffer+" maxQuellen: " + maxQuellen);
                   	 boolean add = true;
                   	 for(int i = 0; i<al.size(); i++){
                   	 	sha1 = ((RemoteFile)al.get(i)).getSHA1();
                   	 	if(s.equals(sha1)){
                   	 		quellen++;
                   	 		//System.out.println("    Quellen: " + quellen + " " + sha1);
                   	 		if(quellen > maxQuellen){
                   	 		  add = false;
                   	 		    //System.out.println("     add: " + add + " " + sha1);	
                   	 		}	 
                   	 	}else{
                   	 		treffer++;
                   	 		quellen = 0;
                   	 		//System.out.println("treffer "+ treffer + " quellen "+ quellen + " " + sha1);
                   	 		add = true;
                   	 		if(treffer > maxTreffer){
                   	 			//System.out.println("treffer: " + treffer + " " + sha1);
                   	 			break;
                   	 		}	
                   	 	}	
                   	 	s = sha1;
                   	 	if(add){
                   	 		StringBuffer sbTemp = new StringBuffer();	
                   	 	    sbTemp.append(((RemoteFile)al.get(i)).getSpeed());
                   	 	    sbTemp.append(z);
                   	 	    sbTemp.append(sha1);
                   	 	    sbTemp.append(z);
                   	 	    sbTemp.append(((RemoteFile)al.get(i)).getFileSize());
                   	 	    sbTemp.append(z);
                   	 	    sbTemp.append(((RemoteFile)al.get(i)).getFileIndex());
                   	 	    sbTemp.append(z);
                   	 	    sbTemp.append(((RemoteFile)al.get(i)).getHostAddress());
                   	 	    sbTemp.append(z);
                   	 	    sbTemp.append(((RemoteFile)al.get(i)).getFilename());
                   	 	    sbTemp.append("\\n");
                   	 	    if(sb.length()+ sbTemp.length() < maxKb * 1024){
                   	 	    	//System.out.println("append: " + + (sb.length()+ sbTemp.length())+ " "+ maxKb * 1024);
                   	 	    	sb.append(sbTemp);
                   	 	    }else{
                   	 	    	//System.out.println("to much: " + (sb.length()+ sbTemp.length()));
                   	 	    	sbTemp = null;
                   	 	    	break;
                   	 	    }		
                   	    }
                   	 }
                   	 //System.out.println("output: "+sb.toString());
                   	 sending.println(sb.toString());
                   	 scp.stopSearching();
                   	 try{
             	     st.closeSearch(((SearchResultsDataModel)ht.get(input[1])).getSearch());
             	     }catch(Exception e){
             	     	e.printStackTrace();
             	     }
             	     ht.remove(input[1]);
                   	 sending.close();
                     //System.out.println("connection closed");
                   	 sb = null;
                   	 //System.out.println("Block false");
                   	 //connected = false;
                   	 //scp.setBlock(false);
                   	 }else{
             		//sending.println("usage: result id Tokenid");
             		sending.close();
             		//connected = false;
             		//scp.setBlock(false); 
                    //System.out.println("connection closed");
             		//sending.flush();
             		sb = null;
             	    }
                   	}  	    	      	 	
                   }else{
                   	 //sending.println("found nothing for: "+ searchString);
                   	 sending.close();
                   	 //connected = false;
                   	 //scp.setBlock(false); 
                    //System.out.println("connection closed");
                   	 //sending.flush();
                   }
                   }else{
                   	//sending.println("wrong token conection canceled");
                   	//sending.flush();
            	    sending.close();
            	    //connected = false;
            	    //scp.setBlock(false); 
                    //System.out.println("connection closed");
                   }
                  
                   			 		         	
             
             }else if(input[0].equals("status")){
             	input[1]= "token="+input[1];
              	if(input[1].equals(token)){
                  sending.println("running\\n");
                  sending.close();
                  //connected = false;
                  //scp.setBlock(false);
                }else{
                	//sending.println("wrong token conection canceled\\n");
                	sending.close();
                	//connected = false;
                	//scp.setBlock(false);
                }	  
                  
             }else{
             	//sending.println("usage: find id Minsize Maxsize Dateityp Tokenid Suchbegriff or result id Tokenid or del id Tokenid");
             	sending.close();
             	//connected = false;
             	//scp.setBlock(false); 
                //System.out.println("connection closed");
             	//sending.flush();
             }
             }
            	
            }catch(IOException ioe){
            	sending.close();
            	//connected = false;
            	//scp.setBlock(false);
            	//System.out.println("ServerThread IOException"+ ioe.toString());
            	//sending.println(ioe.toString());
            	//sending.println("usage: find id Minsize Maxsize Dateityp Tokenid Suchbegriff or result id Tokenid or del id Tokenid");
            }catch(Exception e){
            	sending.close();
            	//connected = false;
            	//scp.setBlock(false);           	
            	scp.updateKeywordSearch();
            	System.out.println("Exception "+ e.toString());
            	e.printStackTrace();
            	System.out.println("Exception "+ e.getCause());
            	//sending.println(e.toString());
                //sending.println("usage: find id Minsize Maxsize Dateityp Tokenid Suchbegriff or result id Tokenid or del id Tokenid");
            }	
        //}
        try{
          sleep(BitJoePrefs.IncomingDelaySetting.get());
        }catch(InterruptedException ie){
        	ie.printStackTrace();
        }	
        scp.setBlock(false);	
    }
   
    private void find(String[] input){
      QuickFilterPanel.setMinFile(input[2]);
      QuickFilterPanel.setMaxFile(input[3]);
      input[4]= input[4].toUpperCase();
      if(input[4].equals("ANY")){
        QuickFilterPanel.setMediaType(0);
      }else if(input[4].equals("AUDIO")){
        QuickFilterPanel.setMediaType(1);
      }else if(input[4].equals("VIDEO")){
        QuickFilterPanel.setMediaType(2);
      }else if(input[4].equals("PROGRAMS")){
        QuickFilterPanel.setMediaType(3);
      }else if(input[4].equals("IMAGES")){
        QuickFilterPanel.setMediaType(4);
      }else if(input[4].equals("DOCUMENTS")){
        QuickFilterPanel.setMediaType(5);
      }else if(input[4].equals("ROMS")){
        QuickFilterPanel.setMediaType(6);
      }else if(input[4].equals("OPEN")){
        QuickFilterPanel.setMediaType(7);
      }else if(input[4].equals("META")){
        QuickFilterPanel.setMediaType(8);
      }
      ht.put(input[1], scp.getSearchResultsDataModel()); 
    }	
 
 }
    
	