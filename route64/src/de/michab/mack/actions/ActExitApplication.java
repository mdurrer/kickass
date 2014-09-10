/* $Id: ActExitApplication.java,v 1.3 2003/12/21 12:09:57 michab66 Exp $
 *
 * Lichen CosExplorer / CosNaming
 *
 * Released under Gnu Public License
 * Copyright (c) 2002, 2003 Michael G. Binz
 */
package de.michab.mack.actions;

import java.awt.Component;
import java.awt.event.*;
import java.util.ResourceBundle;
import javax.swing.*;
import de.michab.mack.ConfigurableAction;



/**
 * <p>The application exit action.  Linked to an application's main window via
 * the offered window listener interface.</p>
 * <p>The action reads the key <code>ACT_APP_EXIT.really.leave</code> from the
 * resource bundle.  If this is set to a non-empty string value, then this is
 * shown in a confirmation dialog, ensuring that the user really wants to leave
 * the app.  If this is empty or the key doesn't exist the application is
 * terminated without confirmation.</p>
 *
 * @author Michael Binz
 */
public final class ActExitApplication
  extends
    ConfigurableAction
  implements
    WindowListener
{
  /**
   * This <code>Action</code>'s key.  Can be accessed via getKey().
   */
  private static final String ACTION_KEY = "ACT_APP_EXIT";



  /**
   * This will get localised in the setAttributes() method.  The initial value
   * is used as the default setting that is not overriden if the key isn't
   * found.
   */
  private String msgReallyLeave = null;



  /**
   * The frame we are listening to.
   */
  private JFrame appFrame = null;



  /**
   */
  public ActExitApplication()
  {
    super( ACTION_KEY, true );
  }



  /**
   * This actually finds out whether the application should shut down by
   * presenting the user a dialog showing the message in
   * <code>msgReallyLeave</code>.  If this is not set, then this method
   * will always return <code>true</code>.
   *
   * @param root The root to use for the dialog that pops up.
   * @return <code>True</code> if the user *really* wants to leave.
   */
  private boolean askReallyLeave( Component root )
  {
    if ( msgReallyLeave == null || msgReallyLeave.length() == 0 )
      return true;

    // Bring up the dialog...
    int dialogResult = JOptionPane.showConfirmDialog(
      root,
      msgReallyLeave,
      (String)getValue( NAME ),
      JOptionPane.OK_CANCEL_OPTION );

    // ...and act accordingly.
    return dialogResult == JOptionPane.OK_OPTION;
  }



  /**
   * Performs local localisation.
   *
   * @param r The resource bundle to use for localisation.
   */
  public void configureFrom( ResourceBundle r )
  {
    // Read our additional settings.
    msgReallyLeave = localize( r,
                               "really.leave",
                               null );
  }



  /**
   * Asks the user if he really wants to leave the application and terminates
   * in case of a positive answer.
   *
   * @param e The action event.
   * @see java.awt.event.ActionListener#actionPerformed(ActionEvent)
   */
  public void actionPerformed( ActionEvent e )
  {
    windowClosing( new WindowEvent( appFrame, WindowEvent.WINDOW_CLOSING ) );
  }



  /**
   * Shuts down the application, never returns.  Was cool to meet it. After
   * this method the shutdown handlers execute.
   *
   * @param we The window event.
   * @see ActExitApplication#windowClosing(WindowEvent)
   */
  public void windowClosed( WindowEvent we )
  {
    System.exit( 0 );
  }



  /**
   * <p>First step in application shutdown.  Somebody tried to close the main
   * frame.  Method decides whether the application should be shut down and
   * disposes() the frame, which results in a call to
   * </code>windowClosed()</code>.</p>
   * <p>Note that the action will switch the <code>defaultCloseOperation</code>
   *  property of its frame to <code>DO_NOTHING_ON_CLOSE</code>.</p>
   *
   * @param we The window event.
   * @see ActExitApplication#windowClosed(WindowEvent)
   */
  public void windowClosing( WindowEvent we )
  {
    JFrame frame = (JFrame)we.getSource();

    if ( askReallyLeave( frame.getContentPane() ) )
    {
      frame.setVisible( false );
      // The dispose() here triggers the windowClosed().
      frame.dispose();
    }
  }



  /**
   * Initialises the internal application frame reference.
   *
   * @param we The window event.
   */
  public void windowOpened( WindowEvent we )
  {
    appFrame = (JFrame)we.getSource();

    // If the frame we are listening to has a default close operation that is
    // not 'do nothing...'...
    if ( appFrame.getDefaultCloseOperation() != JFrame.DO_NOTHING_ON_CLOSE )
      // ...we set a close operation of 'do nothing...'.  The reason is that
      // *we* are in charge of handling close operations and we do not need any
      // default behaviour.
      appFrame.setDefaultCloseOperation( JFrame.DO_NOTHING_ON_CLOSE );
  }



  /**
   * Empty implementation.
   *
   * @param we The window event.
   */
  public void windowActivated( WindowEvent we )
  {
  }



  /**
   * Empty implementation.
   *
   * @param we The window event.
   */
  public void windowDeactivated( WindowEvent we )
  {
  }



  /**
   * Empty implementation.
   *
   * @param we The window event.
   */
  public void windowIconified( WindowEvent we )
  {
  }



  /**
   * Empty implementation.
   *
   * @param we The window event.
   */
  public void windowDeiconified( WindowEvent we )
  {
  }
}
