package de.hgnut.Misc;

import java.util.*;

public class Lizenzen{

	public static Hashtable hash = new Hashtable();
	public static String[] fileTypes = {"jpg","jpeg","bmp","tif"};

	public static void init(){
		hash.put("jpg","1");
		hash.put("jpeg","2");
		hash.put("bmp","3");
		hash.put("tif","4");
	}

}