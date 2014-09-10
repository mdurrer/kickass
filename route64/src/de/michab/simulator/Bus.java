/* $Id: Bus.java,v 1.6 2005/06/16 19:26:41 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under Gnu Public License
 * Copyright (c) 2000-2005 Michael G. Binz
 */
package de.michab.simulator;



/**
 * Models a bus, i.e. a connection between two system components.  Currently
 * only 8 bit busses are supported.  Operations on the <code>Bus</code> are 
 * forwarded to the attached listener.  The <code>Bus</code> has no internal 
 * state, i.e. the written values are not saved, only passed through.
 *
 * @version $Revision: 1.6 $
 * @author Michael G. Binz
 */
public interface Bus extends Forwarder
{
  /**
   * Set the single bus listener.  To remove the listener set it to
   * <code>null</code>.
   *
   * @param listener The listener to set on this <code>Bus</code>.
   */
  void setListener( Forwarder listener );
}
