/*
 *  PHEX - The pure-java Gnutella-servent.
 *  Copyright (C) 2001 - 2007 Phex Development Group
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
 *  --- SVN Information ---
 *  $Id: SystemProperties.java 4231 2008-07-15 16:01:10Z gregork $
 */
package phex.utils;

import java.io.File;
import java.io.IOException;
import java.security.Security;

import org.apache.commons.lang.SystemUtils;

import phex.common.Environment;
import phex.common.log.NLogger;
import phex.prefs.core.ProxyPrefs;

public class SystemProperties
{
    public static final String PHEX_CONFIG_PATH_SYSPROP = "phex.config.path";
    private static String userPath;
        
    /**
     * For a HTTPURLConnection java uses configured proxy settings.
     */
    public static void updateProxyProperties()
    {
        System.setProperty( "http.agent", Environment.getPhexVendor() );
        if ( ProxyPrefs.UseHttp.get().booleanValue() )
        {
            System.setProperty( "http.proxyHost", ProxyPrefs.HttpHost.get() );
            System.setProperty( "http.proxyPort", ProxyPrefs.HttpPort.get().toString() );
        }
        else
        {
            System.setProperty( "http.proxyHost", "" );
            System.setProperty( "http.proxyPort", "" );
        }
        
        // cache DNS name lookups for only 30 minutes
        System.setProperty( "networkaddress.cache.ttl", "1800" );
        Security.setProperty( "networkaddress.cache.ttl", "1800" );
    }
    
    /**
     * Sets the directory into which Phex adds its configuration files. When
     * configRoot is null the directory is set to:<br>
     * {user.home}/phex on windows systems and<br>
     * {user.home}/.phex on unix and mac systems.
     * @param configRoot the directory into which Phex adds its configuration files
     *        or null.
     * 
     * @deprecated since Phex 3.0, drop support once 2.x is not in use anymore
     */
    @Deprecated
    private static File getOldPhexConfigRoot( )
    {        
        StringBuffer path = new StringBuffer(20);
        path.append( System.getProperty("user.home") );
        path.append( File.separator );

        //phex config files are hidden on all UNIX systems (also MacOSX. Since
        //there are many UNIX like operation systems with Java support out there,
        //we can not recognize the OS through it's name. Thus we check if the
        //root of the filesystem starts with "/" since only UNIX uses such
        //filesystem conventions
        if ( File.separatorChar == '/' )
        {
            path.append ('.');
        }
        path.append ("phex");
        File configRoot = new File( path.toString() );
        return configRoot;
    }
    
    /**
     * @deprecated since Phex 3.0, drop support once 2.x is not in use anymore
     */
    @Deprecated
    public static void migratePhexConfigRoot()
    {
        File oldRoot = getOldPhexConfigRoot();
        if ( oldRoot.exists()  )
        {
            File newRoot = new File( getPhexConfigRoot() );
            if ( !oldRoot.equals( newRoot ) )
            {
                try
                {
                    FileUtils.copyDirectory( oldRoot, newRoot, true );
                    FileUtils.deleteDirectory( oldRoot );
                }
                catch ( IOException exp )
                {
                    NLogger.error( SystemProperties.class, exp, exp );
                }
            }
        }
    }
    
    /**
     * Returns the full path to the Phex directory of the user's home. This
     * directory is plattform dependent.
     * - Unix: ~/.phex/
     * - OSX: ~/Library/Application Support/Phex/
     * - Windows: ..../Documents and Settings/username/Application Data/Phex/
     */
    public static String getPhexConfigRoot() 
    {
        if ( userPath != null )
        {
            return userPath;
        }
        
        // to prevent problems wait with assigning userPath...
        String tmpUserPath = System.getProperty( PHEX_CONFIG_PATH_SYSPROP );
        if ( StringUtils.isEmpty( tmpUserPath ) )
        {
            if ( SystemUtils.IS_OS_WINDOWS )
            {
                String appDataEnv = System.getenv( "APPDATA" );
                if ( StringUtils.isEmpty( appDataEnv ) )
                {
                    tmpUserPath = System.getProperty( "user.home" ) + File.separator + "Application Data";
                }
                tmpUserPath = appDataEnv + File.separator
                    + "Phex" + File.separator;
            }
            else if ( SystemUtils.IS_OS_MAC_OSX )
            {
                tmpUserPath = System.getProperty( "user.home" ) + File.separator
                    + "Library" + File.separator + "Application Support";
                tmpUserPath = tmpUserPath + File.separator + "Phex" + File.separator;
            }
            else
            {
                tmpUserPath = System.getProperty( "user.home" ) + File.separator 
                    + ".phex" + File.separator;
            }
        }
        else
        {
            if ( !tmpUserPath.endsWith( File.separator ) )
            {
                tmpUserPath = tmpUserPath + File.separator;
            }
        }
        
        File dir = new File( tmpUserPath );
        if (!dir.exists()) 
        {
            dir.mkdirs();
        }
        userPath = tmpUserPath;
        return userPath;
    }        
}