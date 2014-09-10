/* $Id: Localiser.java,v 1.3 2004/01/29 20:26:18 michab66 Exp $
 *
 * Lichen CosExplorer / CosNaming
 *
 * Released under Gnu Public License
 * Copyright (c) 2002-2004 Michael G. Binz
 */
package de.michab.util;

import javax.swing.ImageIcon;
import java.util.ResourceBundle;
import java.util.MissingResourceException;



/**
 * A support class for localisation purposes.
 *
 * @version $Revision: 1.3 $
 */
public class Localiser
{
  /**
   * Forbid instantiation.
   */
  private Localiser()
  {
  }



  /**
   * Return an icon for the given key.
   *
   * @param b The resource bundle to use for resource lookup.
   * @param key The resource name to lookup.
   * @return A reference to the icon or null if the icon was not found.
   */
  static public ImageIcon localiseIcon( ResourceBundle b, String key )
  {
    String iconPath = localise( b, key );

    if ( iconPath == null )
      return null;

    java.net.URL url = Localiser.class.getClassLoader().
      getResource( iconPath );

    if ( url == null )
      return null;

    return new ImageIcon( url );
  }



  /**
   * Read the value for the passed key from the resource bundle.  If the key is
   * not found, <code>null</code> is returned.  Note that the passed key will
   * be extended with the action's key before it is tried to resolve.  E.g.
   * if the actions key is A_KEY and the parameter 'key''s value is 'name' then
   * it is tried to resolve 'A_KEY.name' in the resource bundle.
   *
   * @param b The resource bundle used to resolve the key.
   * @param key The key used for resource resolution.
   * @return The resolved resource value or <code>null</code> if the key could
   *         not be found.
   * @see Localiser#localise( ResourceBundle, String, String )
   */
  static public String localise( ResourceBundle b, String key )
  {
    return localise( b, key, null );
  }



  /**
   * Read the value for the passed key from the resource bundle.  If the key is
   * not found, the passed default value is returned.
   *
   * @param b The resource bundle used to resolve the key.
   * @param key The key used for resource resolution.
   * @param deflt The value to return in case the key could not be resolved.
   * @return The resolved resource value or the value of the <code>deflt</code>
   *         argument if the key could not be found.
   */
  static public String localise(
    ResourceBundle b,
    String key,
    String deflt )
  {
    try
    {
      return b.getString( key );
    }
    catch ( MissingResourceException e )
    {
      return deflt;
    }
  }
}
