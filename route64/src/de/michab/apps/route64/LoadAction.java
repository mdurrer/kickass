/* $Id: LoadAction.java,v 1.10 2006/03/19 09:48:10 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GNU public license (www.gnu.org/copyleft/gpl.html)
 * Copyright (c) 2000-2004 Michael G. Binz
 */
package de.michab.apps.route64;

import java.awt.event.ActionEvent;
import java.io.File;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.*;
import de.michab.mack.ConfigurableAction;
import de.michab.simulator.mos6502.c64.*;



/**
 * An <code>Action</code> responsible for loading an image file into the 
 * emulator.  It controls the needed file chooser, either the one that Swing
 * delivers or the one provided by WebStart for reading files in a restricted
 * environment.
 *
 * @version $Revision: 1.10 $
 * @author Michael G. Binz
 */
class LoadAction
  extends
    ConfigurableAction
{
  // The logger for this class.
  private final static Logger log = 
    Logger.getLogger( LoadAction.class.getName() );



  /**
   * A reference to the emulator implementation.
   */
  private final Commodore64 _c64;



  /**
   * A reference to the file chooser to use.
   */
  private JFileChooser _chooser;



  /**
   * A filter for the file chooser.
   */
  private javax.swing.filechooser.FileFilter _fileFilter =
    new javax.swing.filechooser.FileFilter()
  {
    public String getDescription()
    {
      return "C64 image files";
    }

    public boolean accept( File f )
    {
      if ( f.isDirectory() )
        return true;

      SystemFile wrapped;
      try
      {
        wrapped = new SystemFile( f );
      }
      catch ( IOException e )
      {
        return false;
      }

      return _c64.getEmulatorEngine().isImageFileValid( wrapped );
    }
  };



  /**
   * Create an instance.
   *
   * @param c64 The emulator the action is tied to.
   * @param key The action key.
   */
  LoadAction( Commodore64 c64, String key )
  {
    super( key, true );

    _c64 = c64;

    _chooser = new JFileChooser();
    _chooser.addChoosableFileFilter( _fileFilter );

    // If we weren't able to find some file chooser we disable ourselfes.
    if ( _chooser == null )
      this.setEnabled( false );
  }



  /**
   * Implements the handling of an actual action trigger.
   *
   * @param ae The event that triggered the action.
   */
  public void actionPerformed( ActionEvent ae )
  {
    int returnVal = _chooser.showOpenDialog( _c64.getMainWindow() );

    if ( returnVal == JFileChooser.APPROVE_OPTION )
    {
      try
      {
        SystemFile wrapped = new SystemFile( _chooser.getSelectedFile() );
        _c64.getEmulatorEngine().setImageFile( wrapped );

        log.fine( "open: " + wrapped.getName() );
      }
      catch ( IOException e )
      {
        log.log( Level.WARNING, "actionPerformed", e );
        setEnabled( false );
      }
    }

    // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
    _c64.getMainWindow().requestFocusInWindow();
  }
}
