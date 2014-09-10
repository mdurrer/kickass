/* $Id: ActAbout.java,v 1.6 2006/01/06 13:01:15 michab66 Exp $
 *
 * MACK
 *
 * Released under Gnu Public License
 * Copyright (c) 2003-2006 Michael G. Binz
 */
package de.michab.mack.actions;

import java.awt.Dimension;
import java.awt.event.*;
import java.util.Date;
import java.util.ResourceBundle;
import java.text.MessageFormat;
import javax.swing.*;
import de.michab.mack.ConfigurableAction;



/**
 * <p>An about box.  The action id is <code>ACT_ABOUT</code>. Allows to
 * display a message and an application logo.  For debug support it also
 * supports a display of the Java system properties.</p>
 * <p>The following table describes the properties the action evaluates:</p>
 *
 * <TABLE BORDER="2"
 *        CELLPADDING="2"
 *        CELLSPACING="0"
 *        SUMMARY="Keys evaluated by ActAbout">
 *    <TR>
 *          <TH>Key</TH>
 *          <TH>Comment</TH>
 *    </TR>
 *    <TR>
 *      <TD><code>message</code></TD>
 *      <TD>The <code>Action</code>'s display name.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>logo</code></TD>
 *      <TD>Text to be displayed on the <code>Action</code>'s tooltip.</TD>
 *    </TR>
 * </TABLE>
 *
 * @see de.michab.mack.ConfigurableAction
 * @version $Revision: 1.6 $
 * @author Michael G. Binz
 */
public final class ActAbout
  extends
    ConfigurableAction
{
  /**
   * The <code>Action</code>'s key.
   */
  private static final String ACTION_KEY = "ACT_ABOUT";



  /**
   * The text shown in the about box.  Can contain placeholders {0} to {2} for
   * the CVS build number, java vendor, and java version information
   * respectively.  Referred to by the resource key "message".
   * The initial value is the default text that will be replaced by text from
   * the resource bundle.
   */
  private String _aboutText = "Build {0}\nVM {1}\nVersion {2}";



  /**
   *
   */
  private Icon _applicationLogo = null;



  /**
   * Create an about action.
   */
  public ActAbout()
  {
    super( ACTION_KEY, true );
  }



  /**
   * Brings up the actual about dialog.
   *
   * @param ae The event that triggered execution of this action.
   */
  public void actionPerformed( ActionEvent ae )
  {
    // Create the actual about box text.
    JComponent optionPaneComponent = new JLabel( _aboutText );
    
    if ( accessToSystemPropertiesAllowed() )
    {
      // Second tab, displaying the system properties table.
      JComponent tabTwo = new JScrollPane(
        new JTable( new SystemPropertiesTable() ) );

      Dimension tableSize = new JTable( 16, 2 ).getPreferredSize();

      tabTwo.setPreferredSize( tableSize );

      JTabbedPane tabbedPane = new JTabbedPane();
      tabbedPane.addTab( "About", optionPaneComponent );
      tabbedPane.addTab( "Info", tabTwo );
      
      optionPaneComponent = tabbedPane;
    }

    // Finally show the actual dialog.  Parent is now in the best case our
    // basic JFrame, in the worst case its null and we will center in the
    // middle of the screen.
    JOptionPane.showMessageDialog(
      getDialogRoot( ae ),
      optionPaneComponent,
      getValue( AbstractAction.NAME ).toString(),
      JOptionPane.INFORMATION_MESSAGE,
      _applicationLogo );
  }



  /**
   * Performs local localisation.  Additionally checks for the resource key
   * <code>ACT_ABOUT.message</code> that contains text for the about box.
   *
   * @param r The resource bundle to be used for configuration.
   */
  public void configureFrom( ResourceBundle r )
  {
    _aboutText = localize( 
        r,
        "message",
        _aboutText );

    _aboutText = MessageFormat.format( 
        _aboutText,
        new Object[]{
            "$Name:  $",
            new Date()
        } );

    _applicationLogo = localizeIcon( 
        r,
        "logo" );
  }



  /**
   * Checks whether we are allowed to access the system properties.
   *
   * @return <code>true</code> if system properties access is allowed,
   *         <code>false</code> otherwise.
   */
  private boolean accessToSystemPropertiesAllowed()
  {
    SecurityManager sm = System.getSecurityManager();

    try
    {
      if ( sm != null )
        sm.checkPropertiesAccess();
    }
    catch ( SecurityException e )
    {
      return false;
    }
    return true;
  }
}
