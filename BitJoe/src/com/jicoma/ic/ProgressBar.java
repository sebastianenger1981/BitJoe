/*
 * %W% %E%
 *
 * Copyright (c) 2000-2004 Sun Microsystems, Inc. All rights reserved. 
 * PROPRIETARY/CONFIDENTIAL
 * Use is subject to license terms
 */
package com.jicoma.ic;

import javax.microedition.lcdui.*;
import de.hgnut.Misc.Constant;


/**
 * This class implements a interactive gague control
 * that moves automatically, between the min and max values.
 *
 * @version 2.0
 */
public class ProgressBar extends Gauge implements Runnable {

    private int maxValue = 10;

    /**
     * This member indicates the number of units to move per
     * iteration. It is set to -1 when we reach a 100 and 1
     * when we reach 0.
     */
    private int delta = 1000;

    private boolean done = false;
    
    /**
     * The constructor initializes the gauge.
     */
    public ProgressBar(String label, int maxValue, int initialValue) {
        super(label, false, maxValue, initialValue);
        this.maxValue = maxValue;
        new Thread(this).start();
    }

    /**
     * This method moves the gauge left and right.
     */
    public void run() {
        while (!Constant.pbDone) {
            // decide whether the gauge should start moving
            // backwards or forwards.
            //int newValue = getValue() + delta;
            int newValue = (int)Constant.time;
            this.maxValue=(int)Constant.holeTime;
            this.setMaxValue(maxValue);
            this.setLabel(Constant.label);
            //if (newValue == maxValue) {
               // done = true;
            //}
            //System.out.println("Value : "+newValue);
            setValue(newValue);
            try {
                Thread.currentThread().sleep(1000);
            } catch (InterruptedException err) {
            }
        }
    }
    
    void setDone() {
        done = true;
    }
}