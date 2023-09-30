package com.jicoma.ic;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;


public class RadioDelayButtons extends JPanel
                             implements ActionListener {
    static String staticString = "Static";
    static String linearString = "Linear";
    static String quadratString = "Quadrat";
    static String wurzelString = "Wurzel";
  

    JLabel picture;

    public RadioDelayButtons() {
        super(new BorderLayout());

        //Create the radio buttons.
        JRadioButton staticButton = new JRadioButton(staticString);
        staticButton.setActionCommand(staticString);
        staticButton.setSelected(true);

        JRadioButton linearButton = new JRadioButton(linearString);
        linearButton.setActionCommand(linearString);

        JRadioButton quadratButton = new JRadioButton(quadratString);
        quadratButton.setActionCommand(quadratString);

        JRadioButton wurzelButton = new JRadioButton(wurzelString);
        wurzelButton.setActionCommand(wurzelString);


        //Group the radio buttons.
        ButtonGroup group = new ButtonGroup();
        group.add(staticButton);
        group.add(linearButton);
        group.add(quadratButton);
        group.add(wurzelButton);
       

        //Register a listener for the radio buttons.
        staticButton.addActionListener(this);
        linearButton.addActionListener(this);
        quadratButton.addActionListener(this);
        wurzelButton.addActionListener(this);

        //Set up the picture label.
        //picture = new JLabel(createImageIcon("images/"
          //                                   + staticString
            //                                 + ".gif"));

        //The preferred size is hard-coded to be the width of the
        //widest image and the height of the tallest image.
        //A real program would compute this.
        //picture.setPreferredSize(new Dimension(177, 122));


        //Put the radio buttons in a column in a panel.
        JPanel radioPanel = new JPanel(new GridLayout(0, 4));
        radioPanel.add(staticButton);
        radioPanel.add(linearButton);
        radioPanel.add(quadratButton);
        radioPanel.add(wurzelButton);
      

        add(radioPanel, BorderLayout.LINE_START);
        //add(picture, BorderLayout.CENTER);
        //setBorder(BorderFactory.createEmptyBorder(20,20,20,20));
    }

    /** Listens to the radio buttons. */
    public void actionPerformed(ActionEvent e) {
       System.out.println("command: "+e.getActionCommand());
    }

    /** Returns an ImageIcon, or null if the path was invalid. */
    

    /**
     * Create the GUI and show it.  For thread safety,
     * this method should be invoked from the
     * event-dispatching thread.
     */
    private static void createAndShowGUI() {
        //Create and set up the window.
        JFrame frame = new JFrame("RadioButton");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        //Create and set up the content pane.
        JComponent newContentPane = new RadioDelayButtons();
        newContentPane.setOpaque(true); //content panes must be opaque
        frame.setContentPane(newContentPane);

        //Display the window.
        frame.pack();
        frame.setVisible(true);
    }

    public static void main(String[] args) {
        //Schedule a job for the event-dispatching thread:
        //creating and showing this application's GUI.
        javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                createAndShowGUI();
            }
        });
    }
}
