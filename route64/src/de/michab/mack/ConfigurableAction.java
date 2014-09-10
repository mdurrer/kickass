/* $Id: ConfigurableAction.java,v 1.8 2004/07/26 19:56:20 michab66 Exp $
 *
 * Michael's Application Construction Kit (MACK)
 *
 * Released under Gnu Public License
 * Copyright (c) 2002-2004 Michael G. Binz
 */
package de.michab.mack;

import java.awt.Component;
import java.util.*;
import javax.swing.*;
import de.michab.util.Localiser;



/**
 * <p>A base class that supports configuration and localisation of actions.  It
 * adds the concept of a unique key to the action used to read the
 * localised attributes from the resource bundle passed to the
 * <code>setAttributes()</code> method.  The table below lists the configurable
 * attributes supported by this class:</p>
 *
 * <TABLE BORDER="2" 
 *        CELLPADDING="2" 
 *        CELLSPACING="0" 
 *        SUMMARY="Resource keys evaluated by ConfigurableAction">
 *    <TR>
 *          <TH>Key</TH>
 *          <TH>Comment</TH>
 *    </TR>
 *    <TR>
 *      <TD><code>NAME</code></TD>
 *      <TD>The <code>Action</code>'s display name.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>TOOLTIP</code></TD>
 *      <TD>Text to be displayed on the <code>Action</code>'s tooltip.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>DESCRIPTION</code></TD>
 *      <TD>A textual description of the <code>Action</code>.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>POPUP</code></TD>
 *      <TD>Flag indicating whether the <code>Action</code> should show up in a
 *      popup menu.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>MENU</code></TD>
 *      <TD>Flag indicating whether the <code>Action</code> is part of the
 *      menu.  The value of the flag is the menu group, see ActionManager.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>TOOLBAR</code></TD>
 *      <TD>Flag indicating whether the <code>Action</code> is part of the
 *      application's toolbar.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>KEYSTROKE</code></TD>
 *      <TD>A keystroke that results in an
 *      <code>Action</code> invocation.  Displayed also in the application
 *      and context sensitive popup menu.</TD>
 *    </TR>
 *    <TR>
 *      <TD><code>ICON</code></TD>
 *      <TD>The icon to be used to represent the <code>Action</code> in menus
 *      and on the toolbar.  Note that the value for the ICON key is the path
 *      name of an image file, e.g.
 *      <code>de/michab/apps/lichen/cosexplorer/res/Lumumba.gif</code></TD>
 *    </TR>
 * </TABLE>
 * <p>An <code>ActionManager</code> is used to create menus and toolbars from
 * the <code>COnfigurableAction</code>s that are available in an
 * application.</p>
 *
 * @see ActionManager
 * @version $Revision: 1.8 $
 * @author Michael Binz
 */
public abstract class ConfigurableAction
  extends
    AbstractAction
{
  // TODO we also should read from a class private resource bundle.  The
  // configurations contained there should be the default action settings that
  // can be optionally overridden by the setAttributes op.



  /**
   * This <code>Action</code>'s unique key.
   */
  private final String _key;



  /**
   * Create a new action for the given key with the passed enabled setting.
   *
   * @param key The new action's key.
   * @param enabled The initial setting for the enabled poperty.
   */
  public ConfigurableAction( String key, boolean enabled )
  {
    super( key );
    _key = key;
    setEnabled( enabled );
  }



  /**
   * Create an instance for the given key.  The new action is disabled by
   * default.
   *
   * @param key The new action's key.
   */
  public ConfigurableAction( String key )
  {
    this( key, false );
  }



  /**
   * Computes the default parent component for a dialog displayed by this
   * action.  The returned result can always directly passed into dialog
   * creation, even in case it is <code>null</code>.
   *
   * @param event The event that triggered the action.
   * @return Either a reference to a component or <code>null</code> in case no
   *         root component could be found.
   */
  protected final static Component getDialogRoot( java.util.EventObject event )
  {
    Component result;

    try
    {
      result = SwingUtilities.getRoot( (Component)event.getSource() );
    }
    catch ( ClassCastException e )
    {
      // We end up here in case the source was no Component.
      result = null;
    }

    // Note that getRoot() above can return null without throwing an exception.
    // As a consequence we need this special condition.
    if ( result == null )
       result = ActionManager.getDefaultActionRoot();

    // We did our best.
    return result;
  }



  /**
   * Creates a <code>JComponent</code> that is to be placed on a toolbar.  This
   * default implementation returns a <code>JButton</code> instance.  Override
   * if other components need to be placed on the toolbar.  Restrict yourself
   * to <i>simple</i> components, since the real estate on a toolbar is rare.
   *
   * @return A component to be placed on the toolbar.
   */
  public JComponent getToolbarComponent()
  {
    
    if ( _toolbarButton == null )
    {
      _toolbarButton = new JButton( this );
      // Vaporise the button's text.  We do not want text displayed on the
      // button.
      _toolbarButton.setText( null );
//      _toolbarButton.setRolloverEnabled( true );
//      _toolbarButton.setBorderPainted( false );
    }

    return _toolbarButton;
  }



  /**
   * Get the <code>Action</code>'s key.
   *
   * @return The <code>Action</code>s key.
   */
  public String getKey()
  {
    return _key;
  }



  /**
   * A template method to be overridden if an action requires addititional
   * information from the resource file.  It is called after the basic
   * attributes have been initialised.  This default implementation is
   * guaranteed to be empty and needs not to be called from the overriding
   * method.
   *
   * @param b The resource bundle to read the configuration from.
   */
  public void configureFrom( ResourceBundle b )
  {
  }



  /**
   * Sets the <code>Action</code>'s attributes from the resource bundle.
   * The key names that are read consist of the Action's key name with
   * an additional identifier appended, e.g. <code>ACT_COPY.ICON</code>.  See
   * the class comment for a complete list.
   *
   * @param b The resource bundle to read from.
   */
  final void configureBasicAttributesFrom( ResourceBundle b )
  {
    // TODO add a table for the properties to javadoc above.
    Object value;

    value = localize( b, "NAME" );
    if ( value != null )
      putValue( NAME, value );

    value = localize( b, "TOOLTIP" );
    if ( value != null )
      putValue( SHORT_DESCRIPTION, value );

    value = localize( b, "DESCRIPTION" );
    if ( value != null )
      putValue( LONG_DESCRIPTION, value );

    value = localize( b, "POPUP" );
    if ( value != null )
      putValue( "POPUP", Boolean.TRUE );

    value = localize( b, "MENU" );
    if ( value != null )
      putValue( "MENU", value );

    value = localize( b, "TOOLBAR" );
    if ( value != null )
      putValue( "TOOLBAR", value );

    // The key stroke that triggers the action.
    value = localize( b, "KEY_STROKE" );
    // If a key stroke string was defined...
    if ( value != null )
      // ...try to create a keystroke object from it.  See the javadocs for
      // KeyStroke.getKeyStroke for the syntax.
      value = KeyStroke.getKeyStroke( (String)value );
    if ( value != null )
      // Specified a valid key stroke.
      putValue( ACCELERATOR_KEY, value );

    value = localizeIcon( b, "ICON" );
    if ( value != null )
      putValue( SMALL_ICON, value );
    else
      // In case no icon is set, we set a dummy icon to properly align the menu
      // entries.  See BugParade 4199382.
      putValue( SMALL_ICON,
                new Icon(){
                  public void paintIcon( Component c, java.awt.Graphics g, int i1, int i2 )
                  {
                  }
                  public int getIconWidth()
                  {
                    return 16;
                  }
                  public int getIconHeight()
                  {
                    return 16;
                  }
                } );


    // Finally call the template method for additional class specific init.
    configureFrom( b );
  }



  /**
   * Return an icon for the given key.
   *
   * @param b The resource bundle to use for resource lookup.
   * @param key The resource name to lookup.
   * @return A reference to the icon or null if the icon was not found.
   */
  protected final Icon localizeIcon( ResourceBundle b, String key )
  {
    return Localiser.localiseIcon( b, createResourceKey( key ) );
  }



  /**
   * Read the value for the passed key from the resource bundle.  If the key is
   * not found, <code>null</code> is returned.  Note that the passed key will
   * be extended with the action's key before resolution is tried.  E.g. if the
   * actions key is <code>A_KEY</code> and the parameter key's value is
   * <code>name</code> then it is tried to resolve <code>A_KEY.name</code> in
   * the resource bundle.
   *
   * @param b The resource bundle used to resolve the key.
   * @param key The key used for resource resolution.
   * @return The resolved resource value or <code>null</code> if the key could
   *         not be found.
   * @see Localiser#localise( ResourceBundle, String, String )
   */
  protected final String localize( ResourceBundle b, String key )
  {
    return localize( b, key, null );
  }



  /**
   * Read the value for the passed key from the resource bundle.  If the key is
   * not found, the passed default value is returned.
   *
   * @param b The resource bundle used to resolve the key.
   * @param key The key used for resource resolution.
   * @param deflt The valuje to return in case the key could not be resolved.
   * @return The resolved resource value or <code>null</code> if the key could
   *         not be found.
   */
  protected final String localize(
    ResourceBundle b,
    String key,
    String deflt )
  {
    return Localiser.localise( b, createResourceKey( key ), deflt );
  }



  /**
   * Creates a unique resource key name for this action.
   *
   * @param simpleKey A key name valid for this action.
   * @return The unique resource key.
   */
  private String createResourceKey( String simpleKey )
  {
    return _key + "." + simpleKey;
  }



  /**
   * The lazily initialised toolbar button.
   */
  private JButton _toolbarButton = null;
}
