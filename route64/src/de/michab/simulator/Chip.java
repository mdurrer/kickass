/* $Id: Chip.java,v 1.10 2005/06/16 19:26:41 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under Gnu Public License
 * Copyright (c) 2000-2005 Michael G. Binz
 */
package de.michab.simulator;



/**
 * The interface all chips in a system have to implement.
 *
 * @see de.michab.simulator.Port
 * @author Michael G. Binz
 */
public interface Chip
  extends
    Addressable
{
  /**
   * Reset the chip to a defined state.
   */
  void reset();



  /**
   * Get an array of the chip's ports.  May return <code>null</code> if this
   * chip does not support ports.
   * 
   * @return An array of the chip's ports.
   */
  Port[] getPorts();
}
