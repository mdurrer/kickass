/* $Id: SoundAction.java,v 1.4 2006/03/19 09:48:10 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GPL (GNU public license)
 * Copyright (c) 2004-2006 Michael G. Binz
 */
package de.michab.apps.route64;

import java.awt.event.ActionEvent;
import java.util.ResourceBundle;

import javax.swing.JComponent;
import javax.swing.JToggleButton;

import de.michab.mack.ConfigurableAction;
import de.michab.simulator.mos6502.c64.C64Core;



/**
 * A toolbar action that allows to switch on or off sound support.
 * 
 * @version $Revision: 1.4 $
 */
final class SoundAction extends ConfigurableAction
{
  /**
   * The initial value for sound.  <code>False</code> means 'sound off'.
   */
  private static final boolean INITIAL_SOUND_STATE = false;



  /**
   * The component to be placed on the toolbar.
   */
  private final JToggleButton _button;



  /**
   * A reference to the emulator.
   */
  private final C64Core _emulator;



  /**
   * Create an instance of this action.
   *
   * @param key The <code>Action</code>'s key used for resource access.
   */
  public SoundAction( String key, C64Core emulator )
  {
    super( key, true );
    _button = new JToggleButton( this );
    _button.setFocusable( false );
    _button.setBorder(null);
    _button.addActionListener( this );
    _button.setSelected( INITIAL_SOUND_STATE );
    _emulator = emulator;
    _emulator.setSoundOn( INITIAL_SOUND_STATE );
  }



  /*
   * Inherit javadoc. 
   */
  public JComponent getToolbarComponent()
  {
    return _button;
  }



  /* 
   * Inherit javadoc.
   */
  public void actionPerformed(ActionEvent e)
  {
    _emulator.setSoundOn( _button.isSelected() );
  }



  /*
   * Inherit Javadoc.
   */
  public void configureFrom( ResourceBundle b )
  {
    _button.setText( null );
    _button.setSelectedIcon(
        localizeIcon( b, "SELECTED_ICON" ) );
  }
}
