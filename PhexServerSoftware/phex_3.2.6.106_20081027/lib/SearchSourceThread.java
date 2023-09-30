package com.jicoma.ic;

import phex.gui.common.treetable.JTreeTable;
import phex.gui.models.SearchTreeTableModel;
import phex.gui.tabs.search.SearchResultsDataModel;
import phex.gui.tabs.search.cp.SearchControlPanel;
import phex.gui.tabs.search.SearchListPanel;
import phex.query.Search;

import com.jicoma.ic.BitJoePrefs;

public class SearchSourceThread extends Thread{
	
	private JTreeTable jtt;
	private SearchResultsDataModel srdm;
	private SearchControlPanel scp;
	private SearchListPanel slp;
	private SearchTreeTableModel sttm;
	private Search search;
	public boolean searching = true;
	
	public SearchSourceThread(JTreeTable jtt, SearchResultsDataModel srdm,SearchListPanel slp ,Search search ,SearchControlPanel scp){
		this.jtt = jtt;
		this.srdm = srdm;
		this.scp = scp;
		this.slp=slp;
		this.search = search;
		this.sttm = srdm.getSearchTreeTableModel();
		this.setPriority(Thread.MIN_PRIORITY );
		
	}
	
	
	public void run(){
		//System.out.println("SearchDelete Timer run");
		while(searching){
		try{
			//System.out.println(BitJoePrefs.OldTimeSetting.get());
			this.sleep(BitJoePrefs.StopNumberDelaySetting.get());
		}catch(InterruptedException ie){
			System.out.println("Interrupted Exception: " + ie);
		}
		if(!scp.getBlock()){
		 scp.setBlock(true);	
		 update();
		 try{
          sleep(BitJoePrefs.IncomingDelaySetting.get());
        }catch(InterruptedException ie){
        	System.out.println("SearchSourceTread");
        	ie.printStackTrace();
        }
		 scp.setBlock(false);
		}else{
		} 
	  }
		//System.out.println(ht +" "+ input);
						
	}
	private void update(){
		//System.out.println("stoppr\u00FCfung");
		searching = search.isSearching();
		if(searching){
		   scp.setDisplayedSearch(srdm);
		   slp.setDisplayedSearch(srdm);
		   srdm.setSortBy(5, false);
		   if(sttm.getChildCount(jtt.getNodeOfRow(BitJoePrefs.StopCheckStrikeSetting.get()-1)) > BitJoePrefs.StopNumberSetting.get()){
		   //System.out.println(sttm.getChildCount(jtt.getNodeOfRow(BitJoePrefs.TrefferSetting.get())));
		   //System.out.println(BitJoePrefs.TrefferSetting.get());
		   //System.out.println(BitJoePrefs.StopNumberSetting.get());
		     search.stopSearching();
		   }
		   
	   }

	}
			
}	