/* $Id: P00Adapter.java,v 1.6 2010/02/21 16:59:20 michab66 Exp $
 *
 * Project: Route64
 *
 * Released under Gnu Public License
 * Copyright (c) 2000-2003 Michael G. Binz
 */
package de.michab.simulator.mos6502.c64;



/**
 * Loader for the .p00 image format.
 *
 * @author Michael G. Binz
 */
class P00Adapter
  extends
    ImageFileFactory
{
  private static final int DE_NAME_START = 8;
  private static final int DE_NAME_LEN = 16;
  private static final int DE_CONTENT_START = 26;



  /**
   * Creates an ImageFileFactory for the .p00 format.
   */
  public P00Adapter()
  {
    super( "Tape image", "p00", 1 );
  }



  /**
   * @see ImageFileFactory#loadEntry(byte[], byte[])
   */
  public byte[] loadEntry( byte[] name, byte[] image )
  {
    byte[] result = null;

    byte[][] dir = getDirectory( image );

    if ( namesEqual( dir[0], name ) )
    {
      result = new byte[ image.length - DE_CONTENT_START ];
      System.arraycopy( image, DE_CONTENT_START, result, 0, result.length );
      return result;
    }

    return result;
  }



  /**
   * @see ImageFileFactory#getDirectory(byte[])
   */
  public byte[][] getDirectory( byte[] image )
  {
    byte[][] result =
      new byte[][]{ stripBytes( image,
                                DE_NAME_START,
                                DE_NAME_START + DE_NAME_LEN,
                                (byte)0 ) };

    return result;
  }
}
