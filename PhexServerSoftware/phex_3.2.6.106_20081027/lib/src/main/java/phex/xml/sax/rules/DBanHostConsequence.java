/*
 *  PHEX - The pure-java Gnutella-servent.
 *  Copyright (C) 2001 - 2006 Phex Development Group
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
 *  Created on 06.01.2006
 *  --- CVS Information ---
 *  $Id: DBanHostConsequence.java 3807 2007-05-19 17:06:46Z gregork $
 */
package phex.xml.sax.rules;

import org.xml.sax.SAXException;

import phex.rules.consequence.BanHostConsequence;
import phex.rules.consequence.Consequence;
import phex.xml.sax.PhexXmlSaxWriter;

public class DBanHostConsequence implements DConsequence
{
    public static final String ELEMENT_NAME = "banhost-consequence";
    
    public DBanHostConsequence()
    {
    }
    
    public void serialize( PhexXmlSaxWriter writer ) throws SAXException
    {
        writer.startElm( ELEMENT_NAME, null );
        writer.endElm( ELEMENT_NAME );
    }
    
    public Consequence createConsequence()
    {
        return BanHostConsequence.INSTANCE;
    }
}
