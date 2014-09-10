/* $Id: AdaptPrg.java,v 1.3 2010/02/21 16:59:20 michab66 Exp $
*
* Project: Route64
*
* Released under Gnu Public License
* Copyright (c) 2004 Michael G. Binz
*/
package de.michab.simulator.mos6502.c64;

/**
 * Loader for the .prg image format.
 *
 * @version $Revision: 1.3 $
 * @author Michael G. Binz
 */
class AdaptPrg extends ImageFileFactory
{

  /**
   * Create an instance.
   */
  protected AdaptPrg()
  {
    super( "Raw file", "prg", 1 );
  }



  /**
   * The directory of a prg file always contains a single entry with the name
   * of the file itself.
   *
   * @see de.michab.simulator.mos6502.c64.ImageFileFactory#getDirectory(byte[])
   */
  public byte[][] getDirectory( String filename, byte[] imageFile )
  {
    String name = filename.toUpperCase().substring(
        0, 
        filename.length() - getFilenameSuffix().length() -1 );
    
    return new byte[][]{ name.getBytes() };
  }



  /*
   * Inherit javadoc.
   */
  public byte[] loadEntry( byte[] name, byte[] imageFile )
  {
    return imageFile;
  }
}
