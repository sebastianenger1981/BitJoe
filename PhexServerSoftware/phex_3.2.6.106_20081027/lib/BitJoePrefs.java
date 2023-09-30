/*
 *  PHEX - The pure-java Gnutella-servent.
 *  Copyright (C) 2001 - 2005 Phex Development Group
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 *  Created on 17.08.2006
 *  --- CVS Information ---
 *  $Id$
 */
package com.jicoma.ic;

import phex.prefs.api.PreferencesFactory;
import phex.prefs.api.Setting;
import phex.prefs.core.PhexCorePrefs;

public class BitJoePrefs extends PhexCorePrefs
{
    //public static Setting OLD_TIME_SETTING = PreferencesFactory.createIntSetting( "deloldtime",20, instance );
    public static final Setting<Integer> OldTimeSetting;
    public static final Setting<Integer> DelayTimeSetting;
    public static final Setting<Integer> MaxSearchSetting;
    
    public static final Setting<Integer> TrefferSetting;
    public static final Setting<Integer> QuellenSetting;
    
    public static final Setting<Integer> MaxKbSetting;
    
    public static final Setting<Integer> StopTimeSetting;
    
    public static final Setting<Integer> StopNumberSetting;
    public static final Setting<Integer> StopNumberDelaySetting;
    
    public static final Setting<Integer> StopCheckStrikeSetting;
    
    public static final Setting<Integer> SocketDelaySetting;
    
    public static final Setting<Integer> PhexServerPortSetting;
    
    public static final Setting<Integer> IncomingDelaySetting;
    
    static{
    	OldTimeSetting = PreferencesFactory.createIntSetting( "BitJoe.OldTimeSetting",60000, instance );
    	DelayTimeSetting = PreferencesFactory.createIntSetting( "BitJoe.DelayTimeSetting",300, instance );
    	MaxSearchSetting = PreferencesFactory.createIntSetting( "BitJoe.MaxSearchSetting",15, instance );
    	//DelayButtonsSetting = PreferencesFactory.createStringSetting( "BitJoe.DelayButtonsSetting","Static", instance );
    	
    	TrefferSetting = PreferencesFactory.createIntSetting( "BitJoe.TrefferSetting",20, instance );
    	QuellenSetting = PreferencesFactory.createIntSetting( "BitJoe.QuellenSetting",40, instance );
    	
    	MaxKbSetting = PreferencesFactory.createIntSetting( "BitJoe.MaxKbSetting",500, instance );
    	StopTimeSetting = PreferencesFactory.createIntSetting( "BitJoe.StopTimeSetting",45000, instance );
    	
    	StopNumberSetting = PreferencesFactory.createIntSetting( "BitJoe.StopNumberSetting", 0, instance );
    	StopNumberDelaySetting = PreferencesFactory.createIntSetting( "BitJoe.StopNumberDelaySetting", 10000, instance );
    	StopCheckStrikeSetting = PreferencesFactory.createIntSetting( "BitJoe.StopCheckStrikeSetting", 10, instance );
    	
    	SocketDelaySetting = PreferencesFactory.createIntSetting( "BitJoe.SocketDelaySetting", 170, instance );
    	
    	PhexServerPortSetting = PreferencesFactory.createIntSetting( "BitJoe.PhexServerPortSetting", 3383, instance );
    	
    	IncomingDelaySetting = PreferencesFactory.createIntSetting( "BitJoe.IncomingDelaySetting", 50, instance );
    }	
    
}
