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
 *  --- CVS Information ---
 *  $Id: ProxyPane.java 3633 2006-11-29 16:25:06Z gregork $
 */
package com.jicoma.ic;

import java.util.HashMap;

//import javax.swing.JCheckBox;
import javax.swing.JLabel;

import phex.gui.common.IntegerTextField;
//import phex.prefs.core.ConnectionPrefs;
import com.jicoma.ic.BitJoePrefs;
//mport phex.prefs.core.SubscriptionPrefs;
//import phex.utils.Localizer;

import com.jgoodies.forms.builder.PanelBuilder;
import com.jgoodies.forms.layout.CellConstraints;
import com.jgoodies.forms.layout.FormLayout;

import phex.gui.dialogs.options.OptionsSettingsPane;

public class SpecialPane extends OptionsSettingsPane
{
	private static final String DEL_TIME_OLD_ENTRIES = "deloldtime";
	private static final String DELAY_TIME = "delaytime";
	private static final String MAX_SEARCH = "maxsearch";
	
	private static final String TREFFER = "treffer";
	private static final String QUELLEN = "quellen";
	
	private static final String MAXKB = "maxkb";
	
	private static final String STOP_TIME = "stoptime";
	
	private static final String STOP_NUMBER = "stopnumber";
	private static final String STOP_NUMBER_DELAY ="stopnumberdelay";
	private static final String STOP_CHECK_STRIKE ="stopcheckstrike";
	
	private static final String SOCKET_DELAY ="socketdelay";
	
	private static final String PHEX_SERVER_PORT ="phexserverport";
	
	private static final String INCOMING_DELAY ="incomingdelay";
	

	
    //private static final String WORKER_PER_DOWNLOAD_KEY = "WorkerPerDownload";
    //public static int sp;
    
    private IntegerTextField delTimeTF;
    private IntegerTextField delayTimeTF;
    private IntegerTextField maxSearchTF;
    
    private IntegerTextField trefferTF;
    private IntegerTextField quellenTF;
    
    private IntegerTextField maxKbTF;
    
    private IntegerTextField stopTimeTF;
    
    private IntegerTextField stopNumberTF;
    private IntegerTextField stopNumberDelayTF;
    private IntegerTextField stopCheckStrikeTF;
    private IntegerTextField socketDelayTF;
    
    private IntegerTextField phexServerPortTF;
    
    private IntegerTextField incomingDelayTF;
    
    
    //private RadioDelayButtons rdb;

    public SpecialPane()
    {
        super( "Special Option" );
    }

    /**
     * Called when preparing this settings pane for display the first time. Can
     * be overriden to implement the look of the settings pane.
     */
    @Override
    protected void prepareComponent()
    {
        FormLayout layout = new FormLayout(
            "10dlu, right:d, 2dlu, d, 2dlu:grow", // columns
            "p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p, 3dlu, p"); // rows
        layout.setRowGroups( new int[][]{{3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25 }} );
        setLayout( layout );
        
        PanelBuilder builder = new PanelBuilder( layout, this );
        CellConstraints cc = new CellConstraints();
        
        builder.addSeparator("Special Settings:",
            cc.xywh( 1, 1, 5, 1 ) );
            
        JLabel label = builder.addLabel("Delay autom. L\u00F6schen Suche (ms)" 
            + ": ", cc.xy( 2, 3 ) );
        label.setToolTipText( "Die h\u00F6chst Zeit bis eine Suche gl\u00F6scht wird default Wert is 12000" );
        delTimeTF = new IntegerTextField(BitJoePrefs.OldTimeSetting.get().toString(), 6, 20 );
        delTimeTF.setToolTipText("hier die Zeitspanne eintragen bis ein Suchbegriff gel\u00F6scht wird");
        builder.add( delTimeTF, cc.xy( 4, 3 ) );
        
        JLabel label1 = builder.addLabel("Verz\u00F6gerung Anfragen Ultrapeers (ms)" 
            + ": ", cc.xy( 2, 5 ) );
        label1.setToolTipText( "Die Zeitspanne der verz\u00F6gerung der anfagen an die Ultrapeers defaullt is 0" );
        delayTimeTF = new IntegerTextField(BitJoePrefs.DelayTimeSetting.get().toString(), 6, 20 );
        delayTimeTF.setToolTipText("hier die Zeitspanne der verzögerung eingeben");
        builder.add( delayTimeTF, cc.xy( 4, 5 ) );
        
        JLabel label2 = builder.addLabel("max. parallele Suchen " 
            + ": ", cc.xy( 2, 7 ) );
        label2.setToolTipText( "Die h\u00F6chst m\u00F6gliche Anzahl gleichzeitig laufenden Suchen default ist 12" );
        maxSearchTF = new IntegerTextField(BitJoePrefs.MaxSearchSetting.get().toString(), 6, 20 );
        maxSearchTF.setToolTipText("Hier die Anzahl der max parallelen Suchen ");
        builder.add( maxSearchTF, cc.xy( 4, 7 ) );
        
        builder.addSeparator("",cc.xywh( 1, 9, 5, 1 ) );
        
        JLabel label9 = builder.addLabel("Stoppr\u00FCfung bei Treffer" 
            + ": ", cc.xy( 2, 11 ) );
        label9.setToolTipText( "Der so und so vielte Treffer f\u00FCr die Stoppr\u00FCfung default ist 10" );
        stopCheckStrikeTF = new IntegerTextField(BitJoePrefs.StopCheckStrikeSetting.get().toString(), 6, 20 );
        stopCheckStrikeTF.setToolTipText("Hier die Treffernummer eingeben");
        builder.add( stopCheckStrikeTF, cc.xy( 4, 11 ) );
        
        JLabel label7 = builder.addLabel("Anzahl Quellen bei Stop" 
            + ": ", cc.xy( 2, 13 ) );
        label7.setToolTipText( "Die Anzahl der Quellen der letzten treffer bis gestoppt wird mit 0 ist dieses Feature ausgeschaltet " );
        stopNumberTF = new IntegerTextField(BitJoePrefs.StopNumberSetting.get().toString(), 6, 20 );
        stopNumberTF.setToolTipText("Hier die Anzahl der Quellen des letzten treffers eingeben ");
        builder.add( stopNumberTF, cc.xy( 4, 13 ) );
        
        JLabel label8 = builder.addLabel("Intervall für Stoppr\u00FCfung" 
            + ": ", cc.xy( 2, 15 ) );
        label8.setToolTipText( "Der Zeitintervall die zwischen den pr\u00FCfungen der Anzahl der quellen des letzten treffers default is 10000" );
        stopNumberDelayTF = new IntegerTextField(BitJoePrefs.StopNumberDelaySetting.get().toString(), 6, 20 );
        stopNumberDelayTF.setToolTipText("Hier den Zeitintervall in ms eingeben ");
        builder.add( stopNumberDelayTF, cc.xy( 4, 15 ) );
         
        JLabel label6 = builder.addLabel("sp\u00E4tester Suchstop (ms)" 
            + ": ", cc.xy( 2, 17 ) );
        label6.setToolTipText( "Die Zeit in ms nach dem die Suche sp\u00E4tetstens gestoppt wird default ist 75000" );
        stopTimeTF = new IntegerTextField(BitJoePrefs.StopTimeSetting.get().toString(), 6, 20 );
        stopTimeTF.setToolTipText("Hier die stop Zeit in ms eingeben ");
        builder.add( stopTimeTF, cc.xy( 4, 17 ) );
        
        builder.addSeparator("",cc.xywh( 1, 19, 5, 1 ) );
        
        JLabel label3 = builder.addLabel("Anzahl Treffer bei Auslieferung" 
            + ": ", cc.xy( 2, 21 ) );
        label3.setToolTipText( "Die Anzahl der maximalen treffer default ist 15" );
        trefferTF = new IntegerTextField(BitJoePrefs.TrefferSetting.get().toString(), 6, 20 );
        trefferTF.setToolTipText("Hier die Anzahl der max Treffer eingeben ");
        builder.add( trefferTF, cc.xy( 4, 21 ) );
        
        
        JLabel label4 = builder.addLabel("Anzahl Quellen bei Auslieferung" 
            + ": ", cc.xy( 2, 23 ) );
        label4.setToolTipText( "Die Anzahl quellen pro Treffer default ist 30" );
        quellenTF = new IntegerTextField(BitJoePrefs.QuellenSetting.get().toString(), 6, 20 );
        quellenTF.setToolTipText("Hier die Anzahl der max Quellen pro Treffer eingeben ");
        builder.add( quellenTF, cc.xy( 4, 23 ) );
        
        JLabel label5 = builder.addLabel("Max kb bei Auslieferung" 
            + ": ", cc.xy( 2, 25 ) );
        label5.setToolTipText( "Die maximale anzahl an kb die der phex als resultate sendet default ist 500" );
        maxKbTF = new IntegerTextField(BitJoePrefs.MaxKbSetting.get().toString(), 6, 20 );
        maxKbTF.setToolTipText("Hier die Anzahl der max kb pro result eingeben ");
        builder.add( maxKbTF, cc.xy( 4, 25 ) );
        
        builder.addSeparator("",cc.xywh( 1, 27, 5, 1 ) );
        
        JLabel label10 = builder.addLabel("Socket delay in ms" 
            + ": ", cc.xy( 2, 29 ) );
        label10.setToolTipText( "Die minimum Zeit in ms bis ein neuer PhexServerThread gestartet wird" );
        socketDelayTF = new IntegerTextField(BitJoePrefs.SocketDelaySetting.get().toString(), 6, 20 );
        socketDelayTF.setToolTipText("Hier die minimale wartezeit eingeben");
        builder.add( socketDelayTF, cc.xy( 4, 29 ) );
        
        JLabel label11 = builder.addLabel("Phex Server Port" 
            + ": ", cc.xy( 2, 31 ) );
        label11.setToolTipText( "Hier kann der Phex server Port ge\u00E4ndert werden neustart erforderlich" );
        phexServerPortTF = new IntegerTextField(BitJoePrefs.PhexServerPortSetting.get().toString(), 6, 20 );
        phexServerPortTF.setToolTipText("Hir den Phex Server Port eingeben und den Phex neu starten");
        builder.add( phexServerPortTF, cc.xy( 4, 31 ) );
        
        JLabel label16 = builder.addLabel("incoming Delay" 
            + ": ", cc.xy( 2, 33 ) );
        label16.setToolTipText( "Hier das incoming delay eingeben dh die Zeit die gewartet wird bis zur freigabe" );
        incomingDelayTF = new IntegerTextField(BitJoePrefs.IncomingDelaySetting.get().toString(), 6, 20 );
        incomingDelayTF.setToolTipText("Hir den delay eingeben in ms 50 ms ist default");
        builder.add( incomingDelayTF, cc.xy( 4, 33 ) );
        
        initConfigValues();
        refreshEnableState();    
    }

    /**
     * Override this method if you like to verify inputs before storing them.
     * A input dictionary is given to the pane. It can be used to store values
     * like error flags or prepared values for saving. The dictionary is given
     * to every settings pane checkInput(), displayErrorMessage() and
     * saveAndApplyChanges() method.
     * When the input has been flaged as invalid with the method setInputValid()
     * the method displayErrorMessage() is called directly after return of
     * checkInput() and the focus is given to settings pane.
     * After checking all settings pane without any error the method
     * saveAndApplyChanges() is called for all settings panes to save the
     * changes.
     */
    public void checkInput( HashMap inputDic )
    {
        
       try
        {
            //String totalWorkersStr = totalWorkersTF.getText();
            //Integer totalWorkers = new Integer( totalWorkersStr );
            inputDic.put(DEL_TIME_OLD_ENTRIES , new Integer(delTimeTF.getText()) );
            inputDic.put(DELAY_TIME , new Integer(delayTimeTF.getText()) );
            inputDic.put(MAX_SEARCH , new Integer(maxSearchTF.getText()) );
            
            inputDic.put(TREFFER , new Integer(trefferTF.getText()) );
            inputDic.put(QUELLEN , new Integer(quellenTF.getText()) );
            
            inputDic.put(MAXKB , new Integer(maxKbTF.getText()) );
            
            inputDic.put(STOP_TIME , new Integer(stopTimeTF.getText()) );
            
            inputDic.put(STOP_NUMBER , new Integer(stopNumberTF.getText()) );
            inputDic.put(STOP_NUMBER_DELAY , new Integer(stopNumberDelayTF.getText()) );
            inputDic.put(STOP_CHECK_STRIKE , new Integer(stopCheckStrikeTF.getText()) );
            inputDic.put(SOCKET_DELAY , new Integer(socketDelayTF.getText()) );
            
            inputDic.put(PHEX_SERVER_PORT , new Integer(phexServerPortTF.getText()) );
            
            inputDic.put(INCOMING_DELAY , new Integer(incomingDelayTF.getText()) );
        }
        catch ( NumberFormatException exp )
        {
            inputDic.put( DEL_TIME_OLD_ENTRIES, delayTimeTF );
            inputDic.put( DELAY_TIME, delTimeTF );
            inputDic.put( MAX_SEARCH, maxSearchTF );
            
            inputDic.put( TREFFER, trefferTF );
            inputDic.put( QUELLEN, quellenTF );
            
            inputDic.put( MAXKB, maxKbTF );
            
            inputDic.put( STOP_TIME, stopTimeTF );
            
            inputDic.put( STOP_NUMBER, stopNumberTF );
            inputDic.put( STOP_NUMBER_DELAY, stopNumberDelayTF );
            inputDic.put( STOP_CHECK_STRIKE, stopCheckStrikeTF );
            inputDic.put( SOCKET_DELAY, socketDelayTF );
            
            inputDic.put( PHEX_SERVER_PORT, phexServerPortTF );
            
            inputDic.put( INCOMING_DELAY, incomingDelayTF );
            
            setInputValid( inputDic, false );
            return;
        }

        setInputValid( inputDic, true );
    }

    /**
     * When isInputValid() returns a false this method is called.
     * The input dictionary should contain the settings pane specific information
     * of the error.
     * The settings pane should override this method to display a error
     * message. Before calling the method the focus is given to the
     * settings pane.
     */
    public void displayErrorMessage( HashMap inputDic )
    {
    	
    	if ( inputDic.containsKey( NUMBER_FORMAT_ERROR_KEY ) )
        {
            displayNumberFormatError( inputDic );
        }
        
        
    }

    /**
     * Override this method if you like to apply and save changes made on
     * settings pane. To trigger saving of the configuration if any value was
     * changed call triggerConfigSave().
     */
    @Override
    public void saveAndApplyChanges( HashMap inputDic )
    {
    	Integer totalDelTimeInt = (Integer) inputDic.get(DEL_TIME_OLD_ENTRIES);
        BitJoePrefs.OldTimeSetting.set( totalDelTimeInt );
        
        Integer delayTimeInt = (Integer) inputDic.get(DELAY_TIME);
        BitJoePrefs.DelayTimeSetting.set( delayTimeInt );
        
        Integer maxSearchInt = (Integer) inputDic.get(MAX_SEARCH);
        BitJoePrefs.MaxSearchSetting.set( maxSearchInt );
        
        
        Integer trefferInt = (Integer) inputDic.get(TREFFER);
        BitJoePrefs.TrefferSetting.set( trefferInt );
        
        Integer quellenInt = (Integer) inputDic.get(QUELLEN);
        BitJoePrefs.QuellenSetting.set( quellenInt );
        
        Integer maxKbInt = (Integer) inputDic.get(MAXKB);
        BitJoePrefs.MaxKbSetting.set( maxKbInt );
        
        Integer stopTimeInt = (Integer) inputDic.get(STOP_TIME);
        BitJoePrefs.StopTimeSetting.set( stopTimeInt );
        
        Integer stopNumberInt = (Integer) inputDic.get(STOP_NUMBER);
        BitJoePrefs.StopNumberSetting.set( stopNumberInt );
        
        Integer stopNumberDelayInt = (Integer) inputDic.get(STOP_NUMBER_DELAY);
        BitJoePrefs.StopNumberDelaySetting.set( stopNumberDelayInt );
        
        Integer stopCheckStrikeInt = (Integer) inputDic.get(STOP_CHECK_STRIKE);
        BitJoePrefs.StopCheckStrikeSetting.set( stopCheckStrikeInt );
        
        Integer socketDelayInt = (Integer) inputDic.get(SOCKET_DELAY);
        BitJoePrefs.SocketDelaySetting.set( socketDelayInt );
        
        Integer phexServerPortInt = (Integer) inputDic.get(PHEX_SERVER_PORT);
        BitJoePrefs.PhexServerPortSetting.set( phexServerPortInt );
        
        Integer incomingDelayInt = (Integer) inputDic.get(INCOMING_DELAY);
        BitJoePrefs.IncomingDelaySetting.set( incomingDelayInt );
        
        //label7.setText("Anzahl Quellen des letzten Treffers ( Treffer Nr: "+BitJoePrefs.TrefferSetting.get().toString()+" ) bis gestoppt wird :" );
    }
    private void initConfigValues()
    {
    }

    private void refreshEnableState()
    {
       
    }

    
}