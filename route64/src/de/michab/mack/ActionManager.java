/* $Id: ActionManager.java,v 1.8 2005/07/21 20:06:23 michab66 Exp $
 *
 * Michael's Application Construction Kit (MACK)
 *
 * Released under Gnu Public License
 * Copyright (c) 2003-2005 Michael G. Binz
 */
package de.michab.mack;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.awt.Component;

import javax.swing.*;



/**
 * <p>Manages an application's set of actions.  The current main responsibility
 * is to keep references to all existing application actions and to compute a
 * popup menu and a menu bar.</p>
 *
 * @see de.michab.mack.ConfigurableAction
 */
public class ActionManager
{
  // The logger for this class.
  private static Logger log = 
    Logger.getLogger( ActionManager.class.getName() );



  /**
   * A default root component for action controlled dialogs.
   *
   * @see ActionManager#setDefaultActionRoot(Component)
   * @see ActionManager#getDefaultActionRoot()
   */
  private static java.awt.Component _defaultActionRoot = null;



  /**
   * Sets a default root component for action controlled dialogs.
   *
   * @param ar The default root component for action controlled dialogs.
   */
  public static void setDefaultActionRoot( Component ar )
  {
    _defaultActionRoot = ar;
  }



  /**
   * Returns the default root component for action driven dialogs.  The default
   * root has to be set by <code>setDefaultActionRoot()</code>.  This is
   * also somewhere available in Swing, but I cannot find it again.
   *
   * @return The default root component for action driven dialogs.
   */
  public static Component getDefaultActionRoot()
  {
    return _defaultActionRoot;
  }



  /**
   * The set of all actions controlled by the <code>ActionManager</code>.
   */
  private static final Vector _actions = new Vector();



  /**
   * Holds the actions that are to be displayed in a popup menu.
   */
  private static final Vector _popupActions = new Vector();



  /**
   * The commonly used popup menu.  Note that this must only be used from the
   * event dispatch thread.
   *
   * @see ActionManager#doPopup(java.awt.event.MouseEvent)
   */
  private final static JPopupMenu _popupMenu = new JPopupMenu();



  /**
   * The managed toolbar.
   */
  private static final JToolBar _toolbar = new JToolBar();



  /**
   *  The managed menu bar.
   */
  private static final JMenuBar _menuBar = new JMenuBar();



  /**
   * Add an action to the <code>ActionManager</code>'s set of managed
   * actions.
   *
   * @param ca The action to add.
   */
  public static void addAction( ConfigurableAction ca )
  {
    // TODO check for duplicate actions.
    ca.configureBasicAttributesFrom( _resourceBundle );

    _actions.add( ca );

    if ( ca.getValue( "POPUP" ) != null )
      _popupActions.add( ca );

    if ( ca.getValue( "TOOLBAR" ) != null )
    {
      JComponent c = ca.getToolbarComponent();
        _toolbar.add( c );
    }

    String value = (String)ca.getValue( "MENU" );
    if ( value != null )
    {
      JMenu menu = (JMenu)_menuBar.getClientProperty( value );
      if ( menu == null )
        log.log( Level.WARNING, "Menu misconfiguration, key: ", value );
      else
        menu.add( ca );
    }
  }



  /**
   * Returns a reference to the menu bar holding the configured actions.
   *
   * @return A reference to the menu bar holding the configured actions.
   */
  public static JMenuBar getMenuBar()
  {
    return _menuBar;
  }



  /**
   * Returns a reference to the tool bar holding the configured actions.
   *
   * @return A reference to the tool bar holding the configured actions.
   */
  public static JToolBar getToolbar()
  {
    return _toolbar;
  }



  /**
   * The resources used to configure the added actions.
   */
  private static ResourceBundle _resourceBundle = null;



  /**
   * Initiates initialisation of the ActionManager from the passed resources.
   *
   * @param rb The resources to be used for initialisation.
   */
  public static void initMenuSetup( ResourceBundle rb )
  {
    _resourceBundle = rb;

    // Create the menu structure from the property file.
    try
    {
      String menuHeaders = rb.getString( "MACK_MENU" );

      Enumeration menuHeadersIterator = new StringTokenizer( menuHeaders );

      while ( menuHeadersIterator.hasMoreElements() )
      {
        String currentKey = (String)menuHeadersIterator.nextElement();

        // Create a localised menu.
        JMenu menu = new JMenu( rb.getString( currentKey ) );
        _menuBar.add( menu );
        _menuBar.putClientProperty( currentKey, menu );
      }
    }
    catch ( java.util.MissingResourceException e )
    {
      log.log( 
          Level.SEVERE, 
          "Menu setup inconsistent. Key: " + e.getKey(), 
          e );
      System.exit( 1 );
    }

    // Read the menu actions from the properties file.  The following variable
    // is kept out of the try to be also available in the catch clause.
    String currentAction = "";
    try
    {
      String actions = rb.getString( "APPLICATION_ACTIONS" );

      Enumeration actionsIterator = new StringTokenizer( actions );

      while ( actionsIterator.hasMoreElements() )
      {
        currentAction = (String)actionsIterator.nextElement();

        // Create an action instance...
        Class actionClass = Class.forName( currentAction );
        ConfigurableAction ca = (ConfigurableAction)actionClass.newInstance();
        // ...and register it with the manager.
        addAction( ca );
      }
    }
    catch ( Exception e )
    {
      log.log( 
          Level.SEVERE, 
          "Bad action definition: " + currentAction,
          e );
      System.exit( 1 );
    }
  }



  /**
   * Pops up a context menu on the component specified by the passed event.
   *
   * @param me The mouse event that was identified as a popup trigger.
   * @throws InternalError If not called on the event dispatch thread.
   */
  public static void doPopup( java.awt.event.MouseEvent me )
  {
    if ( ! javax.swing.SwingUtilities.isEventDispatchThread() )
      throw new InternalError( "Must be used on the event dispatch thread." );

    // Now include all enabled actions into our context menu.  Since the
    // disabled ones cannot be selected anyway we keep those out.
    _popupMenu.removeAll();
    for ( int i = 0 ; i < _popupActions.size() ; i++ )
    {
      Action currentAction =
        (Action)_popupActions.elementAt( i );
      if ( currentAction.isEnabled() )
        _popupMenu.add( currentAction );
    }

    // And finally, if there is at least one entry in the menu we pop it up.
    if ( _popupMenu.getComponentCount() > 0 )
      _popupMenu.show(
        (Component)me.getSource(),
         me.getX(),
         me.getY() );
  }
}
