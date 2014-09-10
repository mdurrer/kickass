/* $Id: Commodore64.java,v 1.46 2010/02/21 17:33:22 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GNU public license (http://www.gnu.org/copyleft/gpl.html)
 * Copyright (c) 2000-2006 Michael G. Binz
 */
package de.michab.apps.route64;

import de.michab.simulator.mos6502.Cpu6510;
import de.michab.simulator.mos6502.c64.*;

import de.michab.mack.*;
import de.michab.util.Localiser;

import java.awt.*;
import java.awt.event.*;
import java.awt.datatransfer.*;
import java.awt.dnd.*;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.ResourceBundle;
import java.util.MissingResourceException;
import javax.swing.*;



/**
 * Implementation of a graphical user interface on top of the emulator.
 *
 * @version $Revision: 1.46 $
 * @author Michael G. Binz
 */
public final class Commodore64
{
  /**
   * The minimum JDK version that is supported.
   */
  private static final String MINIMUM_JDK = "1.4";



  /**
   * The application's resources.  These are set from the <code>main()</code>
   * method.  If this is the coolest place has to be seen.
   */
  private static ResourceBundle _resources;



  /**
   * The key used to access the main window title in the resources.
   */
  private static final String TITLE = "APPLICATION_TITLE";



  /**
   * The key used to access the main window icon in the resources.
   */
  private static final String ICON = "APPLICATION_ICON";



  /**
   * The actual emulator instance tied to this UI.
   */
  private final C64Core _emulator;



  /**
   * The main application frame.
   */
  private final JFrame _main;



  /**
   * The message bar.
   */
  private final JLabel _messageBar = new JLabel();



  /**
   * The quick-load component on the toolbar.
   */
  private final LoadComponent _loadComponent;



  /**
   * This implements and glues together the GUI for the emulator.
   */
  private Commodore64()
  {
    // Make sure we are on the event dispatch thread.
    if ( ! SwingUtilities.isEventDispatchThread() )
    {
      throw new InternalError( "Commodore64.<init> not on EDT." );
    }

    _emulator = new C64Core();
    _emulator.addPropertyChangeListener(
      C64Core.IMAGE_NAME,
      _imageChangeListener );

    _main = new JFrame(
        Localiser.localise( _resources, TITLE, TITLE ) );
    _main.setIconImage(
        Localiser.localiseIcon( _resources, ICON ).getImage() );

    _loadComponent = new LoadComponent( _emulator, _main );

    // Set up toolbar.
    JToolBar toolBar = addActions();
    toolBar.setFloatable( false );

    // Set invisible text on message bar, so it gets displayed.
    _messageBar.setText( " " );

    _main.setJMenuBar( ActionManager.getMenuBar() );

    Component display = _emulator.getDisplay();
    // Connect the drag and drop machinery.
    new DropTarget( display, _dropTargetListener );
    // Add the stuff to the top level frame.
    _main.getContentPane().add( toolBar, BorderLayout.NORTH );
    _main.getContentPane().add( display, BorderLayout.CENTER );
    _main.getContentPane().add( _messageBar, BorderLayout.SOUTH );

    // Activate the keyboard.
    _activateKeyboardAction.actionPerformed( null );

    // Connect the emulator as a key event sink.
    _main.setEnabled( true );
    _main.addKeyListener( _emulator );

    _main.pack();
    _main.setVisible( true );
    _main.requestFocusInWindow();
  }



  /**
   * Creates the application's toolbar.
   */
  private JToolBar addActions()
  {
    // Actually add all the actions...
    ActionManager.addAction( _resetAction );
    ActionManager.addAction(
      new Monitor( (Cpu6510)_emulator.getCpu()) );
    ActionManager.addAction( createLoadAction( this, "ACT_LOAD" ) );
    ActionManager.addAction( _loadComponent );
    ActionManager.addAction( _activateJoystickOneAction );
    ActionManager.addAction( _activateJoystickTwoAction );
    ActionManager.addAction( _activateKeyboardAction );
    ActionManager.addAction( _restoreSizeAction );
    ActionManager.addAction( new SoundAction(  "ACT_SOUND", _emulator ) );
    ActionManager.addAction(
        new MemoryDisplay( _emulator.getMemory()) );
    de.michab.mack.actions.ActExitApplication exitAtion =
        new de.michab.mack.actions.ActExitApplication();
    _main.addWindowListener( exitAtion );
    ActionManager.addAction( exitAtion );

    JToolBar result = ActionManager.getToolbar();

    // ...and remove all the Keyboard bindings from toolbar and its children.
    // This has to be done to be able to get keys like SPACE and the cursor
    // keys in the emulator.  With the existing bindings the cursor keys were
    // consumed by the toolbar and the space key by the focused button on the
    // toolbar.
    removeActionMap( result );

    return result;
  }


  private void removeActionMap( Container root )
  {
    int numKids = root.getComponentCount();
    for ( int i = 0 ; i < numKids ; i++ )
    {
      Component c = root.getComponent( i );
      if ( c instanceof Container )
        removeActionMap( (Container)c  );
      if ( c instanceof JComponent )
        ((JComponent)c).setActionMap( null );
    }

    if ( root instanceof JComponent )
      ((JComponent)root).setActionMap( null );
  }



  /**
   * Creates the action that is responsible for image loading depending on the
   * execution environment.  In a WebStart environment the load action is soft
   * and sandbox compliant.  In a local VM it is rude and demanding.
   *
   * @param c64 The simulator the action is tied to.
   * @param name The action's key.
   */
  private static ConfigurableAction createLoadAction(
    Commodore64 c64,
    String name )
  {
    String webstartVersion = System.getProperty( "javawebstart.version" );

    if ( null == webstartVersion )
      return new LoadAction( c64, name );

    return new JnlpLoadAction( c64, name );
  }



  /**
   * Start the thing -- will this ever fly??
   */
  public static void main( final String[] argv )
  {
    // Check the JDK version.
    String javaVersion = System.getProperty( "java.version" );
    if ( javaVersion == null || MINIMUM_JDK.compareTo( javaVersion ) > 0 )
    {
      JOptionPane.showMessageDialog( null,
        "Requires jdk/jre " + MINIMUM_JDK + " or better." );
      System.exit( 1 );
    }

    try
    {
      UIManager.setLookAndFeel(
        UIManager.getSystemLookAndFeelClassName() );
    }
    catch ( Exception e )
    {
      System.err.println( "Couldn't set system l&f." );
    }

    // Since our main window holds a heavyweight component, we do not want the
    // menu items to be lightweight, appearing behind the windows content.
    JPopupMenu.setDefaultLightWeightPopupEnabled( false );
    // The same goes with the tool tips.
    ToolTipManager.sharedInstance().setLightWeightPopupEnabled( false );
    // Switch off Swing focus handling.  Starting with jdk 1.4 this is
    // deprecated.  Nevertheless it is important.
    FocusManager.disableSwingFocusManager();
    try
    {
      _resources = ResourceBundle.getBundle(
        "de.michab.apps.route64.resources.Route64" );
    }
    catch ( MissingResourceException e )
    {
      JOptionPane.showMessageDialog( null,
        "Fatal: Resource bundle not found." );
      System.exit( 1 );
    }

    // Initialize menu and tool bar from resources.
    ActionManager.initMenuSetup( _resources );

    SystemFile sysFilePrepare = null;
    if ( argv.length > 0 ) try
    {
      sysFilePrepare = new SystemFile( new File( argv[0] ) );
    }
    catch ( IOException e )
    {
      JOptionPane.showMessageDialog(
        null,
        "Fatal: Could not read file: '" +
        argv[0] +
        "'" );
      System.exit( 1 );
    }
    final SystemFile sysFile = sysFilePrepare;

    // Start the GUI on the event dispatch thread.
    SwingUtilities.invokeLater( new Runnable()
    {
      public void run()
      {
        Commodore64 c64 = new Commodore64();

        c64._emulator.start();

        if ( argv.length > 0 )
        {
          c64._emulator.setImageFile( sysFile );
        }

        if ( argv.length > 1 )
          c64._emulator.load( argv[1].getBytes() );
      }
    } );
  }



  /**
   * Resets the emulation.
   */
  private ConfigurableAction _resetAction =
    new ConfigurableAction( "ACT_RESET", true )
  {
    public void actionPerformed( ActionEvent ae )
    {
      if ( _emulator != null )
        _emulator.reset( true );

      // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
      _main.requestFocusInWindow();
    }
  };



  /**
   * Get a reference to the internal emulator engine.
   */
  C64Core getEmulatorEngine()
  {
    return _emulator;
  }



  /**
   * Get a reference to the application's main frame.
   */
  JFrame getMainWindow()
  {
    return _main;
  }



  /**
   * Activates joystick one.
   */
  private ConfigurableAction _activateJoystickOneAction =
    new ConfigurableAction( "ACT_JOYSTICK_ONE" )
  {
    public void actionPerformed( ActionEvent ae )
    {
      _activateJoystickOneAction.setEnabled( false );
      _activateJoystickTwoAction.setEnabled( true );
      _activateKeyboardAction.setEnabled( true );

      _emulator.setInputDevice( C64Core.D_JOYSTICK_0 );

      // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
      _main.requestFocusInWindow();
    }
  };



  /**
   * Activates joystick two.
   */
  private ConfigurableAction _activateJoystickTwoAction =
      new ConfigurableAction( "ACT_JOYSTICK_TWO" )
  {
    public void actionPerformed( ActionEvent ae )
    {
      _activateJoystickOneAction.setEnabled( true );
      _activateJoystickTwoAction.setEnabled( false );
      _activateKeyboardAction.setEnabled( true );

      _emulator.setInputDevice( C64Core.D_JOYSTICK_1 );

      // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
      _main.requestFocusInWindow();
    }
  };


  /**
   * Activates the keyboard.
   */
  private ConfigurableAction _activateKeyboardAction =
    new ConfigurableAction( "ACT_KEYBOARD", true )
  {
    public void actionPerformed( ActionEvent ae )
    {
      _activateJoystickOneAction.setEnabled( true );
      _activateJoystickTwoAction.setEnabled( true );
      _activateKeyboardAction.setEnabled( false );

      _emulator.setInputDevice( C64Core.D_KEYBOARD );

      // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
      _main.requestFocusInWindow();
    }
  };



  /**
   * Resets window size to original.
   */
  private ConfigurableAction _restoreSizeAction =
    new ConfigurableAction( "ACT_ZOOMBACK", true )
  {
    public void actionPerformed( ActionEvent ae )
    {
      _main.pack();
      // Workaround for focus handling bug in jdk1.4.  BugParade 4478706.
      _main.requestFocusInWindow();
    }
  };



  /**
   * Listens to changes of the image file.  The image file title is displayed
   * in the message bar.
   */
  private java.beans.PropertyChangeListener _imageChangeListener =
    new java.beans.PropertyChangeListener()
  {
    public void propertyChange( java.beans.PropertyChangeEvent pc )
    {
      if ( pc.getPropertyName() == C64Core.IMAGE_NAME )
      {
        SystemFile newImage = (SystemFile)pc.getNewValue();

        _messageBar.setText( newImage.getName() );
        _loadComponent.setDirectoryEntries( _emulator.getImageFileDirectory() );
      }
    }
  };



  /**
   * The display component is a drop target for image files.  This is the
   * listener responsible for implementing drag and drop behavior.
   */
  private DropTargetListener _dropTargetListener = new DropTargetListener()
  {
     // Beginning with jdk 1.5 DropTargetDragEvent carries the method
     // getTransferrable that can be used to check whether we know the file
     // type and to reject the drop if not.
    /*
     * Inherit javadoc.
     */
    public void dragEnter( DropTargetDragEvent dtde )
    {
      if ( dtde.isDataFlavorSupported( DataFlavor.javaFileListFlavor ) )
        dtde.acceptDrag( DnDConstants.ACTION_COPY_OR_MOVE );
      else
        dtde.rejectDrag();
    }



    /*
     * Inherit javadoc.
     */
    public void dragOver( DropTargetDragEvent dtde )
    {
    }



    /*
     * Inherit javadoc.
     */
    public void dragExit( DropTargetEvent dte )
    {
    }



    /*
     * Inherit javadoc.
     */
    public void drop( DropTargetDropEvent dtde )
    {
      // Used on dnd protocol completion in 'finally' below.
      boolean status = false;

      try
      {
        if ( dtde.isDataFlavorSupported( DataFlavor.javaFileListFlavor ) )
        {
          // First we accept the drop to get the dnd protocol into the needed
          // state for getting the data.
          dtde.acceptDrop( DnDConstants.ACTION_COPY_OR_MOVE );

          // Now get the transferred data and be as defensive as possible.  We
          // expect a java.util.List of java.io.Files.
          Transferable x = dtde.getTransferable();
          List data = (List)x.getTransferData( DataFlavor.javaFileListFlavor );

          // If we received an image file set this onto the simulator.
          if ( data.size() > 0 )
          {
            File file = (File)data.get( 0 );
            SystemFile wrapped = new SystemFile( file );
            _emulator.setImageFile( wrapped );
          }

          // Everything went fine.
          status = true;
        }
        else
          dtde.rejectDrop();
      }
      // Catch potential IO exceptions and keep dnd protocol in sync.
      catch ( Exception e )
      {
        e.printStackTrace();
        dtde.rejectDrop();
      }
      // And again:  Last step in dnd protocol.  After that we are ready to
      // accept the next drop.
      finally
      {
        dtde.dropComplete( status );
      }
    }



    /*
     * Inherit javadoc.
     */
    public void dropActionChanged( DropTargetDragEvent dtde )
    {
      //System.err.println( "dropActionChanged" );
    }
  };
}
