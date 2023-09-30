package com.jicoma.ic;

import phex.query.Search;
import phex.gui.tabs.search.SearchTab;
import java.util.Hashtable;

public class SearchDeleteTimer extends Thread{
	
	private Search search;
	private SearchTab searchTab;
	private Hashtable ht = null;
	private String input = null;
	
	public SearchDeleteTimer(Search search, SearchTab searchTab){
		this.search = search;
		this.searchTab = searchTab;
		//System.out.println("Hier komnt der wert: " +SpecialPane.sp);
		
	}
	public SearchDeleteTimer(Search search, SearchTab searchTab, Hashtable ht, String input){
		this.search = search;
		this.searchTab = searchTab;
		this.ht = ht;
		this.input = input;
		//System.out.println("Hier komnt der wert: " +SpecialPane.sp);
	}
	public void run(){
		//System.out.println("SearchDelete Timer run");
		try{
			//System.out.println(BitJoePrefs.OldTimeSetting.get());
			this.sleep(BitJoePrefs.OldTimeSetting.get());
		}catch(InterruptedException ie){
			System.out.println("Interrupted Exception: " + ie);
		}
		searchTab.closeSearch(search);
		//System.out.println(ht +" "+ input);
		if(ht != null && input != null){
			//System.out.println("remove input");
			ht.remove(input);
		}					
	}		
}	