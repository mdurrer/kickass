/* $Id: C64Core.java,v 1.44 2010/02/21 16:59:20 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GNU public license
 * Copyright (c) 2000-2004 Michael G. Binz
 */
package de.michab.simulator.mos6502.c64;

import de.michab.simulator.*;
import de.michab.simulator.mos6502.*;

import java.awt.*;
import java.awt.event.*;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;



/**
 * <p>A facade to a single instance of a Commodore 64.  Years ago that cost
 * $1000, today only a constructor is needed.  The <code>KeyListener</code>
 * implemented by this class has to be connected to the component receiving the
 * emulation's keyboard input.</p>
 *
 * <p>The display property provides a component that represents the Commodore
 * 64's video screen.  This has to be displayed in a GUI environment.</p>
 *
 * <p>As soon as the minimum setup -- connect of the KeyListener and display of
 * the display component -- has been done a call to the <code>start()</code>
 * method starts the emulation.</p>
 *
 * @version $Revision: 1.44 $
 * @author Michael G. Binz
 */
public class C64Core
  implements
    KeyListener
{
  public final static String IMAGE_NAME = "imageNameProperty";



  /**
   * @see de.michab.simulator.mos6502.c64.C64Core#setInputDevice(int)
   */
  public final static int D_KEYBOARD = 'K';



  /**
   * @see de.michab.simulator.mos6502.c64.C64Core#setInputDevice
   */
  public final static int D_JOYSTICK_0 = 'G';



  /**
   * @see de.michab.simulator.mos6502.c64.C64Core#setInputDevice
   */
  public final static int D_JOYSTICK_1 = 'M';



  /**
   * Used for implementing bound properties.
   */
  private PropertyChangeSupport _pcs = new PropertyChangeSupport( this );



  /**
   * Position of the color ram.  This is non-moveable.
   */
  public static final int ADR_COLOR_RAM_NEW = 0xd800;



  private final Clock _systemClock =
    new Clock( C64Core.PAL_TICKS_PER_SEC ); // 5 );



  /**
   * Main memory.
   */
  private final C64Memory _memory;



  /**
   * System cpu.
   */
  private final Cpu6510 _processor;
  private static final int PROCESSOR_BASE = 0x0000;



  /**
   * Keyboard
   */
  private final Keyboard _keyboard;



  /**
   * Joystick 1
   */
  private final Joystick _joystick0;



  /**
   * Joystick 2
   */
  private final Joystick _joystick1;



  /**
   * Video chip.
   */
  private final Vic _vic;
  private static final int VIC_BASE = 0xd000;



  /**
   * This C64's CIA 1.
   */
  private final Cia _cia1;
  private static final int CIA1_BASE = 0xdc00;



  /**
   * This C64's CIA 2.
   */
  private final Cia _cia2;
  private static final int CIA2_BASE = 0xdd00;



  /**
   * Sound chip.
   */
  private final Sid _sid;
  private static final int SID_BASE = 0xd400;



  /**
   * @see LoadDevice
   */
  private LoadDevice _ld;



  /**
   * @see SystemInput
   */
  private SystemInput _systemInput;



  /**
   *
   */
  private KeyListener _currentKeyListener = null;



  /**
   *
   */
  public static final int PAL_TICKS_PER_SEC = 980000;



  /**
   *
   */
  public static final int NTSC_TICKS_PER_SEC = 1000000;



  /**
   * Creates an instance of a Commodore 64.  Note that the thread priority
   * of the calling thread is used as a reference priority.  This means that
   * other threads that are created to control the contained chips are
   * placed on priority levels relative to the one of the calling thread.
   */
  public C64Core()
  {
    // Create the 64's memory.
    _memory = new C64Memory();

    // Create a processor.
    _processor = new Cpu6510( _memory, _systemClock );
    _memory.mapInto( _processor, PROCESSOR_BASE );
    // Connect the memory to the processor's port 1.
    _processor.setPortListener( 1, _memory.getAddress1Listener() );

    // Create the SID.
    _sid = new Sid();
    _memory.mapInto( _sid, SID_BASE );

    // Create the VIC.
    // The VIC registers are repeated each 64 bytes in the area $d000-$d3ff,
    // i.e. register 0 appears on addresses $d000, $d040, $d080 etc.
    _vic = new C64Vic( _processor, _memory, ADR_COLOR_RAM_NEW, _systemClock );
    for ( int i = VIC_BASE ; i < 0xd3ff ; i += 0x40 )
      _memory.mapInto( _vic, i );

    // Create the CIAs;
    _cia1 = new Cia( _processor, _systemClock );
    _memory.mapInto( _cia1, CIA1_BASE );
    _memory.mapInto( _cia1, CIA1_BASE + 0x10 );

    _cia2 = new Cia( _processor, _systemClock );
    _memory.mapInto( _cia2, CIA2_BASE );
    // Connect the two least significant bits of cia2's port a to the video
    // chip base address.  Bits are low active.
    _cia2.connectPortA( new Forwarder(){
      public void write( byte value )
      {
        _vic.setPageAddress( ~value );
      }
      public byte read()
      {
        return 0;
      }
    } );

    // Create and connect the Keyboard...
    _keyboard = new Keyboard( _processor );
    // ...to CIA 1 Port A which is the hardware input...
    _cia1.connectPortA( _keyboard );
    // ...and to CIA 1 Port B which is the hardware output.
    _keyboard.setListener( _cia1.getInputPortB() );


    // Create and connect the joysticks.
    _joystick0 = new Joystick( _cia1, 0, _keyboard );
//    _joystick0.setRegisters( _cia1, 0 );
    _joystick1 = new Joystick( _cia1, 1,_keyboard );
//    _joystick1.setRegisters( _cia1, 1 );

    // Finally add extensions
    addExtensions();

    _currentKeyListener = _keyboard;
  }



  /**
   * Check if the passed file is a valid image file.
   *
   * @param file The file to check.
   */
  public boolean isImageFileValid( SystemFile file )
  {
    return _ld.isValid( file );
  }



  /**
   * Attaches a file to the emulator.  This is the bound property
   * <code>IMAGE_NAME</code>.
   *
   * @param file The file to attach.
   */
  public void setImageFile( SystemFile file )
  {
    SystemFile oldFile = _ld.getFile();

    // If the old file name differs from the new one...
    if ( oldFile == null || !oldFile.equals( file ) )
    {
      // ...set the new one...
      if ( _ld.setFile( file ) )
        // ...and fire a change event in case of success.
        _pcs.firePropertyChange( IMAGE_NAME, oldFile, file );
    }
  }



  /**
   * Get the currently attached image file.  Bound property IMAGE_NAME.
   *
   * @return The currently attached image file.  Returns <code>null</code> if
   *         no image file is attached.
   */
  public SystemFile getImageFile()
  {
    return _ld.getFile();
  }



  /**
   * Returns the directory of the currently loaded image file.  If none is
   * loaded null is returned.  Note that this is the directory structure
   * *inside* the image file, not the directory that holds the image file
   * itself.  The array entries contain the valid input for the load() method.
   *
   * @see C64Core#load
   */
  public byte[][] getImageFileDirectory()
  {
    return _ld.getDirectory();
  }



  /**
   * Load and start a program.  Note that an image file has to be already been
   * loaded.  Calling this method is equivalent to entering
   * <pre><code>
   *   LOAD "fileName",8,1<br>
   *   RUN <br>
   * </code></pre>
   * on the 64's command line.  Note that the ",8" part is autodetected so
   * don't worry about that.
   *
   * @param fileName The name of the file to load in CBM ASCII.  This file has
   *        to be contained in the currently set image file.  The name passed
   *        in here should also be part of the directory list of the image
   *        file.  If the file can't be found a C64 error message is printed.
   * @see C64Core#setImageFile(SystemFile)
   * @see C64Core#getImageFileDirectory()
   */
  public void load( byte[] fileName )
  {
    // Build the basic command as a string...
    StringBuffer buffer = new StringBuffer();
    buffer.append( "LOAD\"" );
    buffer.append( new String( fileName ) );
    buffer.append( "\"," );
    buffer.append( _ld.getDeviceNumber() );
    buffer.append( ",1\rRUN\r" );

    // ...and write that into the 64's keyboard input buffer.
    _systemInput.writeInput( buffer.toString().getBytes() );
  }



  /**
   * Add all the extensions into the simulation.  This means all the patches
   * that replace a standard piece of functionality.  An example is the file
   * loader extension.  This completely replaces the original load logic.
   */
  private void addExtensions()
  {
    // Add image loading extensions.
    _ld = new LoadDevice( _processor, _memory );
    _memory.mapInto( _ld, _ld.getBaseAddress() );

    // Add the external write port into the 64's key buffer.
    _systemInput = new SystemInput( _memory );
    _memory.mapInto( _systemInput, _systemInput.getBaseAddress() );
  }



  /**
   * Reset the emulation.
   *
   * @param hard A module is detected if the memory location 0x8004 and
   *             following hold the string 'CBM80' in Commodore ASCII.  If this
   *             is the case a reset results in a JMP($8000) which was used by
   *             many games to get reset save.  Passing <code>true</code> here
   *             results in a reset even in case a module marker exists.
   */
  public /*synchronized*/ void reset( boolean hard )
  {
    // The following line prevents module autostart if a hard reset was
    // requested.
    if ( hard )
      _memory.write( 0x8004, (byte)0 );

    _memory.reset();

    // ...and perform the reset for all chips.
    _cia1.reset();
//    _cia2.reset();
//    _vic.reset();
//    _sid.reset();

    _processor.reset();

  }



  /**
   * Performs a soft reset.
   *
   * @see #reset(boolean)
   */
  public void reset()
  {
    reset( false );
  }



  /**
   * Shutdown the emulator and release all resources held.  It is not possible
   * to restart after <code>shutdown()</code> was called.
   */
  public void shutdown()
  {
    _vic.terminate();
  }



  /**
   * Starts execution of the system.
   */
  public void start()
  {
    _systemClock.start();
  }



  /**
   * Returns a reference to the emulation's video interface chip (aka VIC).
   */
  public Chip getVic()
  {
    return _vic;
  }



  /**
   * Returns a reference to the emulation's sound interface device (aka SID).
   */
  public Chip getSid()
  {
    return _sid;
  }



  /**
   * Returns a reference to the emulation's pair of CIA chips.
   */
  public Chip[] getCia()
  {
    return new Chip[]{ _cia1, _cia2 };
  }



  /**
   * Returns a reference to the emulation's CPU.
   */
  public Processor getCpu()
  {
    return _processor;
  }



  /**
   * Get a reference to the emulation's memory.
   */
  public Memory getMemory()
  {
    return _memory;
  }



  /**
   * Returns a reference on the component that the display is drawn into.
   *
   * @return The hot component containing the emulation's raster screen.
   */
  public Component getDisplay()
  {
    return _vic.getComponent();
  }



  /**
   * Returns the frame color as set in the C64's VIC chip.  The returned
   * color can be used for advanced embedding of the display component in a
   * user interface.
   *
   * @return The current frame colour.
   */
  public Color getFrameColor()
  {
    if ( _vic != null )
    {
      return _vic.getExteriorColor();
    }
    return Color.black;
  }



  /**
   * Returns the currently selected input device.
   *
   * @return One of the constants D_JOYSTICK_0, D_JOYSTICK_1 or D_KEYBOARD.
   */
  public int getInputDevice()
  {
    if ( _currentKeyListener == _keyboard )
      return D_KEYBOARD;
    else if ( _currentKeyListener == _joystick0 )
      return D_JOYSTICK_0;
    else if ( _currentKeyListener == _joystick1 )
      return D_JOYSTICK_1;
    else
      throw new InternalError();
  }



  /**
   * Selects an input device: joystick 1, joystick 2, or keyboard.
   *
   * @param which One of the constants D_JOYSTICK_0, D_JOYSTICK_1 or
   *              D_KEYBOARD.
   */
  public void setInputDevice( int which )
  {
    switch ( which )
    {
      case D_JOYSTICK_0:
        _currentKeyListener = _joystick0;
        break;

      case D_JOYSTICK_1:
        _currentKeyListener = _joystick1;
        break;

      case D_KEYBOARD:
        _currentKeyListener = _keyboard;
        break;

      default:
        throw new IllegalArgumentException();
    }
  }



  /**
   * Check whether sound is enabled.
   *
   * @return <code>true</code> if sound is enabled, <code>false</code>
   *         otherwise.
   */
  public boolean isSoundOn()
  {
    return _sid.isSoundOn();
  }


  /**
   * Switch sound on or off.
   *
   * @param what <code>true</code> to switch sound on, <code>false</code>
   *        otherwise.
   */
  public void setSoundOn( boolean what )
  {
    _sid.setSoundOn( what );
  }



  /**
   * Adds a property change listener to this bean.
   */
  public void addPropertyChangeListener(
    String name,
    PropertyChangeListener pcl )
  {
    _pcs.addPropertyChangeListener( name, pcl );
  }



  /**
   * Remove a property change listener from this bean.
   */
  public void removePropertyChangeListener(
    String name,
    PropertyChangeListener pcl )
  {
    _pcs.removePropertyChangeListener( name,  pcl );
  }



  /*
   * Inherit javadoc.
   */
  public void keyTyped(KeyEvent e)
  {
    _currentKeyListener.keyTyped( e );
  }



  /*
   * Inherit javadoc.
   */
  public void keyPressed(KeyEvent e)
  {
    _currentKeyListener.keyPressed( e );
  }



  /*
   * Inherit javadoc.
   */
  public void keyReleased(KeyEvent e)
  {
    _currentKeyListener.keyReleased( e );
  }
}
