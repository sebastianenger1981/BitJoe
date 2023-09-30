package de.hgnut.GnuUtil.Messages;

import java.util.*;
import de.hgnut.Misc.Constant;

public class ProxySearchReply{
	private Vector sources;
	public int FILESIZE;
	public int FILESCORE;
	public String SHA1;
	public String FILEFLAG;
	public String IMEI;
	public String LIZENZKEY;
	public String CLIENTVERSION;
	public String to_search;
	public String RESULTID;
	public boolean finished=false;

	public ProxySearchReply(){sources = new Vector();}
	public void setFileSize(int size){this.FILESIZE=size;}
	public int getFileSize(){return FILESIZE;}
	public void setFileScore(int score){this.FILESCORE=score;}
	public int getFileScore(){return FILESCORE;}
	public void setSHA1(String sha1){this.SHA1=sha1;}
	public String getSHA1(){return SHA1;}
	public void addSource(String ip, int port, int fileindex, String name){
		Object[] source = new Object[4];
		source[0]=ip;
		source[1]=new Integer(port);
		source[2]= new Integer(fileindex);
		source[3]=name;
		sources.addElement(source);	
	}
	public int getSourcesCount(){
		if(sources!=null) return sources.size();
		else return 0;
	}
	public Object[] getSource(int index){
		if(sources!=null&&sources.size()>index) return ((Object[])sources.elementAt(index));
		else return null;
	}
	public String toString(){
		String ret = FILESCORE+" "+FILESIZE+" "+SHA1+"\r\n";
		for(int i=0;i<sources.size();i++){
			ret=ret+"   "+((Object[])sources.elementAt(i))[0]+" "+((Object[])sources.elementAt(i))[1]+" "+((Object[])sources.elementAt(i))[2]+" "+((Object[])sources.elementAt(i))[3]+"\r\n";
		}
		return ret;
	}
	
	public String toGUIString(){
		String ret = ((Object[])sources.elementAt(0))[3]+""; //FILESIZE;
		if(ret.length() > 54){
			String suffix = ret.substring(ret.lastIndexOf('.'));
			ret = ret.substring(0,50);
			ret = ret + suffix;
		}
		float size = FILESIZE;
		String bez = "B";
		if(size > 1024){
		 size = size/1024;
		 bez = "KB";
		 if(size > 1024){
		 	size = size/1024;
		    bez = "MB";
		 }	
		}
		String s = Float.toString(size);
		try{
			s = s.substring(0, s.indexOf('.')+2);
		}catch(Exception e){
		}		
		ret = ret +" "+s+" "+bez; 
		//ret = ret+" "+FILESIZE;	
		return ret;
	}
}
