/* $Id: LoadComponent.java,v 1.17 2006/03/19 09:48:10 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GNU public license (www.gnu.org/copyleft/gpl.html)
 * Copyright (c) 2000-2006 Michael G. Binz
 */
package de.michab.apps.route64;

import de.michab.simulator.mos6502.c64.C64Core;
import java.awt.event.ActionEvent;
import java.util.ResourceBundle;

import javax.swing.*;
import de.michab.mack.ConfigurableAction;



/**
 * Implements a component that allows for loading of a file from an image
 * file's directory.
 * 
 * @version $Revision: 1.17 $
 */
final class LoadComponent
  extends
    ConfigurableAction
{
  /**
   * The component that is ultimately placed on the toolbar.
   */
  private final JComponent _box = 
    new Box( BoxLayout.X_AXIS );



  /**
   * Reference to the emulator.
   */
  private final C64Core _core;



  /**
   * The load button.  Triggers loading of the image that is the currently
   * active in the combo box.
   * 
   * @see #setDirectoryEntries(byte[][])
   */
  private final JButton _loadSelected = new JButton();



  /**
   * A combo box holding a list of image references.
   */
  private final JComboBox _comboBox = new JComboBox();



  /**
   * The list of image names.  Represents the combo box entries.
   */
  private byte[][] _currentEntries = null;



  private JFrame _main;

  /**
   * A component that simplifies loading of entries contained in image files.
   * Consists of a combo box that displays all the entries that are contained
   * in a single image file and a selection button that triggers loading one
   * out of this set.
   */
  public LoadComponent( C64Core core, JFrame m )
  {
    super( "ACT_LOAD_COMPONENT", true );
    _main = m;
    _core = core;
    
    _loadSelected.setFocusable( false );
    _loadSelected.setRequestFocusEnabled( false );
    _comboBox.setFocusable( false );
    _comboBox.setRequestFocusEnabled( false );
  }



  /**
   * Performs the action's custom localisation. 
   *
   * @param b The resource bundle to use.
   */
  public void configureFrom( ResourceBundle b )
  {
    // We access the default icon of the configurable action.
    Icon loadSelectedIcon = (Icon)getValue( SMALL_ICON );
     
//    _loadSelected = new JButtonNoFocus( loadSelectedIcon );
    _loadSelected.setIcon( loadSelectedIcon );
    // Add the listeners
    _loadSelected.addActionListener( this );
    /* TODO it would be cool if the selection button would be the same height
     * as the combo box.  It would also be cool if it could be more narrow in
     * x direction.  The code below is not really cool. */
    _loadSelected.setPreferredSize(
      new java.awt.Dimension(
        loadSelectedIcon.getIconWidth()+6,
        0 /*(int)_comboBox.getPreferredSize().getHeight()*/ ) );

    _box.add( _comboBox );
    _box.add( _loadSelected );

    _comboBox.setLightWeightPopupEnabled( false );

    setEnabled( false );
  }



  /**
   * Set the list of directory entries that have to be displayed by the
   * component.  If the passed array of entries is empty or null, then the
   * component is disabled.
   * 
   * @param entries The list of directory entries.
   */
  public void setDirectoryEntries( byte[][] entries )
  {
    if ( entries != null && entries.length > 0 )
    {
      // Remember the entries set.
      _currentEntries = entries;

      String[] values = new String[ entries.length ];

      for ( int i = 0 ; i < values.length ; i++ )
        values[i] = new String( entries[i] ).trim();

      // Create a new model for the passed entries...
      DefaultComboBoxModel comboBoxModel = new DefaultComboBoxModel( values );
      // ...and add that to the combo box.
      _comboBox.setModel( comboBoxModel );
    }
    else
    {
      _currentEntries = null;
      _comboBox.setModel( new DefaultComboBoxModel() );
    }

    setEnabled( _currentEntries != null );
  }



  /**
   * Returns the component that is to be placed on the toolbar.
   *
   * @return The component that is to be placed on the toolbar.
   */
  public JComponent getToolbarComponent()
  {
    return _box;
  }



  /*
   * Inherit Javadoc.
   */
  public void setEnabled( boolean enabled )
  {
    super.setEnabled( enabled );

    // The null conditions are possible since this gets called from the
    // baseclass ctor.
    if ( _loadSelected != null )
      _loadSelected.setEnabled( enabled );
    if ( _comboBox != null )
      _comboBox.setEnabled( enabled );
  }



  /**
   * Handles the button press.
   * 
   * @param actionEvent The associated event.
   */
  public void actionPerformed( ActionEvent actionEvent )
  {
    if ( _currentEntries == null || _core == null )
      return;

    _core.load( _currentEntries[ _comboBox.getSelectedIndex() ] );

    _main.requestFocus();
    // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
    // TODO retest if needed on jdk1.4 -> defect is marked as fixed.
    //Window w = (Window)
      //SwingUtilities.getWindowAncestor( (JComponent)actionEvent.getSource() );
    //if ( w != null )
      //w.requestFocus();
  }
}
