/* $Id: Addressable.java,v 1.7 2005/06/16 19:26:41 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under Gnu Public License
 * Copyright (c) 2000-2005 Michael G. Binz
 */
package de.michab.simulator;



/**
 * Base interface for addressable components.
 *
 * @version $Revision: 1.7 $
 * @author Michael G. Binz
 */
public interface Addressable
{
  /**
   * Read a byte from the given address.
   *
   * @param address The source address.
   * @return The byte read.
   */
  byte read( int address );



  /**
   * Write a byte into the given address.
   *
   * @param address The target address.
   * @param value The value to be written.
   */
  void write( int address, byte value );
}
