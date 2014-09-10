/* $Id: Joystick.java,v 1.12 2010/02/21 16:59:20 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under GPL (GNU public license)
 * Copyright (c) 2000-2003 Michael G. Binz
 */
package de.michab.simulator.mos6502.c64;

import de.michab.simulator.Processor;
import de.michab.simulator.mos6502.*;

import java.awt.event.KeyListener;
import java.awt.event.KeyEvent;
import java.util.logging.Level;
import java.util.logging.Logger;



/**
 * Implements a Joystick.  Cursor keys select the directions, space is the
 * joystick button.
 *
 * @version $Revision: 1.12 $
 * @author Michael G. Binz
 */
final class Joystick
  implements
    KeyListener
{
    private final static Logger _log =
        Logger.getLogger( Joystick.class.getName() );

    private final static Level _chipLogLevel =
        Level.FINE;

    private final boolean _doLogging =
        _log.isLoggable( _chipLogLevel );

    /**
     * The name of the CIA for logging purposes.
     */
    private final String _logPrefix;



  /**
   * This is the next one in the chain of responsibility of handling key
   * events, i.e. all key events that aren't handled by the Joystick are
   * passed on to that sublistener.
   */
  private final KeyListener _subKeyListener;



  /**
   * The raw registers of the CIA we are connected to.
   */
  private byte[] _ciaRegisters;



  /**
   * The index of the register of the CIA to be updated.
   */
  private int _registerIdx;



  /**
   * Create an instance using the passed listener as the target for key events
   * not consumed by the joystick.
   *
   * @param cia The CIA the joystick is attached to.
   * @param idx The register index in the CIA registers the joystick should
   *        update.
   * @param subListener A listener receiving all events that are not consumed
   *        by the new <code>Joystick</code> instance.
   */
  public Joystick( Cia cia, int idx, KeyListener subListener )
  {
    _subKeyListener = subListener;
    _ciaRegisters = cia.getRawRegisters();
    _registerIdx = idx;

    _logPrefix =
        cia +
        "[" +
        _registerIdx +
        "] ";
  }



  /**
   * This component's key listener.  Responsible for handling the cursor keys
   * without mouse interaction.
   *
   * @param k The key event.
   * @param isPressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   * @see java.awt.Component#processKeyEvent
   */
  private void handleKeyEvent( KeyEvent k, boolean isPressed )
  {
    // Check if this is one of the keys we handle...
    switch ( k.getKeyCode() )
    {
      case KeyEvent.VK_UP:
        handleUp( isPressed );
        break;

      case KeyEvent.VK_DOWN:
        handleDown( isPressed );
        break;

      case KeyEvent.VK_LEFT:
        handleLeft( isPressed );
        break;

      case KeyEvent.VK_RIGHT:
        handleRight( isPressed );
        break;

      case KeyEvent.VK_SPACE:
        handleButton( isPressed );
        break;

      // ...and forward the event to the next handler in the chain if nobody
      // feels responsible for it.
/*      default:
        if ( _subKeyListener != null )
        {
          if ( isPressed )
            _subKeyListener.keyPressed( k );
          else
            _subKeyListener.keyReleased( k );
        }
        break; */
    }
  }



  /**
   * Eventually handles joystick up signals.
   *
   * @param pressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   */
  private void handleUp( boolean pressed )
  {
      if ( _doLogging )
          _log.log( _chipLogLevel, pressed ? "Up pressed" : "Up released" );

    setRegisterBit( pressed, Processor.BIT_0 );
  }



  /**
   * Eventually handles joystick down signals.
   *
   * @param pressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   */
  private void handleDown( boolean pressed )
  {
      if ( _doLogging )
          _log.log( _chipLogLevel, pressed ? "Down pressed" : "Down released" );

    setRegisterBit( pressed, Processor.BIT_1 );
  }



  /**
   * Eventually handles joystick left signals.
   *
   * @param pressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   */
  private void handleLeft( boolean pressed )
  {
      if ( _doLogging )
          _log.log( _chipLogLevel, pressed ? "Left pressed" : "Left released" );

    setRegisterBit( pressed, Processor.BIT_2 );
  }



  /**
   * Eventually handles joystick right signals.
   *
   * @param pressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   */
  private void handleRight( boolean pressed )
  {
      if ( _doLogging )
          _log.log( _chipLogLevel, pressed ? "Right pressed" : "Right released" );

    setRegisterBit( pressed, Processor.BIT_3 );
  }



  /**
   * Eventually handles joystick button signals.
   *
   * @param pressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   */
  private void handleButton( boolean pressed )
  {
      if ( _doLogging )
          _log.log( _chipLogLevel, pressed ? "Button pressed" : "Button released" );

    setRegisterBit( pressed, Processor.BIT_4 );
  }



  /**
   * Finally set the register bit.
   *
   * @param pressed <code>true</code> if the key was pressed, otherwise
   *        the key was released.
   * @param theBit The bit to set.
   */
  private void setRegisterBit( boolean pressed, int theBit )
  {
    int value = _ciaRegisters[ _registerIdx ];

    _log.fine( _logPrefix + "== $" + Integer.toHexString( value ) );

    if ( pressed )
        value |= theBit;
    else
        value &= ~theBit;

    _log.fine( _logPrefix + ":= $" + Integer.toHexString( value ) );

    _ciaRegisters[ _registerIdx ] = (byte)value;
  }



  /*
   * java.awt.event.KeyListener#keyTyped
   */
  public void keyTyped( KeyEvent k )
  {
    // TODO forward only keys that we do not handle.
    // _subKeyListener.keyTyped(k);
  }



  /*
   * java.awt.event.KeyListener#keyPressed
   */
  public void keyPressed( KeyEvent k )
  {
    handleKeyEvent( k, true );
  }



  /*
   * java.awt.event.KeyListener#keyReleased
   */
  public void keyReleased( KeyEvent k )
  {
    handleKeyEvent( k, false );
  }
}
