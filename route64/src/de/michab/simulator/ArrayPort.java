/* $Id: ArrayPort.java,v 1.6 2010/02/21 17:26:38 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under Gnu Public License
 * Copyright (c) 2003-2008 Michael G. Binz
 */
package de.michab.simulator;



/**
 * This is a special <code>Forwarder</code> used for direct array forwarding.
 *
 * @version $Revision: 1.6 $
 * @author Michael Binz
 */
public class ArrayPort
  implements
    Forwarder
{
// TODO note that the synchronised handling in this class has to be rethought.
//  For now synchroniation is disabled.

  /**
   * The array we are pointing to.
   */
  byte[] _array;



  /**
   * The array slot we are pointing to.
   */
  private int _slot = 0;



  /**
   * Creates an instance.
   *
   * @param array The array we are forwarding accesses to.
   * @param slot The slot in the array we are forwarding to.
   */
  private ArrayPort( byte[] array, int slot )
  {
    _array = array;
    _slot = slot;
  }



  /**
   * Creates an array of <code>Forwarder</code>s for the passed array.
   *
   * @param a The array to create <code>Forwarder</code>s for.
   * @return An array of <code>Forwarder</code>s.
   */
  static public Forwarder[] createForwarders( byte[] a )
  {
    Forwarder[] result = new Forwarder[ a.length ];

    for ( int i = result.length -1 ; i >= 0 ; i-- )
      result[ i ] = new ArrayPort( a, i );

    return result;
  }



  /*
   * Forwarder#write
   */
   public /*synchronized*/ void write( byte value )
   {
      _array[ _slot ] = value;
   }



   /*
    * Forwarder#read
    */
   public /*synchronized*/ byte read()
   {
      return _array[ _slot ];
   }
}
