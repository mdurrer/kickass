/* $Id: Forwarder.java,v 1.8 2005/06/16 19:26:41 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under Gnu Public License
 * Copyright (c) 2000-2005 Michael G. Binz
 */
package de.michab.simulator;



/**
 * An entity that is responsible for receiving a read or write
 * operation and forwarding that to some target.  Used for example for
 * implementing chip registers, where the processor writes to the register
 * and that write eventually is forwarded to some chip internal machinery.
 *
 * @version $Revision: 1.8 $
 * @author Michael G. Binz
 */
public interface Forwarder
{
  /**
   * Read a byte from this <code>Forwarder</code>.
   *
   * @return The byte read.
   */
  byte read();



  /**
   * Write a byte to this <code>Forwarder</code>.
   *
   * @param value The byte to write.
   */
  void write( byte value );
}
