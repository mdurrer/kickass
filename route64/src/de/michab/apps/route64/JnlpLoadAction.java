/* $Id: JnlpLoadAction.java,v 1.9 2005/09/17 12:30:08 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GNU public license (www.gnu.org/copyleft/gpl.html)
 * Copyright (c) 2000-2003 Michael G. Binz
 */
package de.michab.apps.route64;

import java.awt.event.ActionEvent;
import java.io.IOException;
import java.util.logging.Logger;

import javax.jnlp.*;
import de.michab.mack.ConfigurableAction;
import de.michab.simulator.mos6502.c64.*;



/**
 * Implement an Action responsible for loading an image file into the emulator.
 * This action controls the needed file chooser, either the one that Swing
 * delivers or the one provided by WebStart for reading files in a restricted
 * environment.
 */
class JnlpLoadAction
  extends
    ConfigurableAction
{
  // The logger for this class.
  private static Logger log = 
    Logger.getLogger( ConfigurableAction.class.getName() );



  /**
   * A reference to the emulator implementation.
   */
  private final Commodore64 _c64;



  /**
   * A reference to a WebStart file chooser that also works in the limited
   * sandbox.
   */
  private FileOpenService _jnlpChooser;



  /**
   * Creates a webstart load action.
   *
   * @param c64 The emulator instance that the load action is tied to.
   * @param key The action's key.
   */
  JnlpLoadAction( Commodore64 c64, String key )
  {
    super( key, true );

    _c64 = c64;

    try
    {
      _jnlpChooser = (FileOpenService)
        ServiceManager.lookup("javax.jnlp.FileOpenService");
    }
    catch ( UnavailableServiceException e )
    {
      _jnlpChooser = null;
    }

    // If we weren't able to find some file chooser we disable ourselfes.
    if ( _jnlpChooser == null )
      setEnabled( false );
  }



  /**
   * Implements the handling of an actual action trigger.
   *
   * @param ae The event that triggered the action.
   */
  public void actionPerformed( ActionEvent ae )
  {
    if ( ! isEnabled() )
      return;

    FileContents fc = null;

    try
    {
      fc = _jnlpChooser.openFileDialog( null, null );
    }
    catch ( Exception e )
    {
      e.printStackTrace();
      fc = null;
    }

    if ( fc != null )
    {
      try
      {
        SystemFile wrapped = new SystemFile( 
          fc.getName(),
          fc.getInputStream(),
          (int)fc.getLength() );
        _c64.getEmulatorEngine().setImageFile( wrapped );

        log.finest("open: " + wrapped.getName());
      }
      catch ( IOException e )
      {
        e.printStackTrace();
        setEnabled( false );
      }
    }

    // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
    _c64.getMainWindow().requestFocus();
  }
}
