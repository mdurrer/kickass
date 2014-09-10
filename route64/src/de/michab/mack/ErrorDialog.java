/* $Id: ErrorDialog.java,v 1.3 2005/09/17 12:30:08 michab66 Exp $
 *
 * Michael's Application Construction Kit (MACK)
 *
 * Released under Gnu Public License
 * Copyright (c) 2002 Michael G. Binz
 */
package de.michab.mack;

import java.awt.Component;
import javax.swing.*;

import java.util.*;
import java.util.logging.Logger;
import java.text.MessageFormat;



/**
 * Represents a singular error dialog that can be loaded with a resource
 * file.
 *
 * @version $Revision: 1.3 $
 * @author michab
 */
public class ErrorDialog
{
  // TODO We have to add a possibility to pass an exception and display its
  //       stack backtrace (and if only I need it for debugging.)
  /**
   * The logger for this class.
   */
  private final static Logger _log = 
    Logger.getLogger( ErrorDialog.class.getName() );



  /**
   * The resource bundle to use for localising the dialog.
   *
   * @see ErrorDialog#set(ResourceBundle)
   */
  private static ResourceBundle _errorResources = null;



  /**
   * Forbid creation.
   */
  private ErrorDialog()
  {
  }



  /**
   * Brings up an error dialog on the passed parent component.  Dialog text is
   * created from the passed resource string and with the formatted arguments.
   *
   * @param parent The parent component for the dialog.  Pass
   *               <code>null</code> if there's no parent component.
   * @param key The resource key.
   * @param arg0 Parameter to be formatted into the error message.
   * @param arg1 Parameter to be formatted into the error message.
   * @param arg2 Parameter to be formatted into the error message.
   */
  static public void show( Component parent,
                           String key,
                           String arg0,
                           String arg1,
                           String arg2 )
  {
    String theMessage = key;

    try
    {
      theMessage =
        _errorResources.getString( key );
      theMessage =
        MessageFormat.format( theMessage, new Object[]{ arg0, arg1, arg2 } );
    }
    catch ( MissingResourceException e )
    {
      // Nothing to do.  theMessage is initialised to the key by default.
      _log.warning( e.getMessage() );
    }

    JOptionPane.showMessageDialog(
      parent,
      theMessage,
      ERROR_DIALOG_TITLE,
      JOptionPane.ERROR_MESSAGE );
  }



  /**
   * Brings up an error dialog on the passed parent component.  Dialog text is
   * created from the passed resource string and with the formatted arguments.
   *
   * @param parent The parent component for the dialog.  Pass
   *               <code>null</code> if there's no parent componant.
   * @param key The resource key.
   * @param arg0 Paramater to be formatted into the error message.
   * @param arg1 Paramater to be formatted into the error message.
   */
  static public void show( Component parent,
                           String key,
                           String arg0,
                           String arg1 )
  {
    show( parent, key, arg0, arg1, null );
  }



  /**
   * Brings up an error dialog on the passed parent component.  Dialog text is
   * created from the passed resource string and with the formatted arguments.
   *
   * @param parent The parent component for the dialog.  Pass
   *               <code>null</code> if there's no parent componant.
   * @param key The resource key.
   * @param arg0 Paramater to be formatted into the error message.
   */
  static public void show( Component parent,
                           String key,
                           String arg0 )
  {
    show( parent, key, arg0, null, null );
  }



  /**
   * Brings up an error dialog on the passed parent component.  Dialog text is
   * created from the passed resource string and with the formatted arguments.
   *
   * @param parent The parent component for the dialog.  Pass
   *               <code>null</code> if there's no parent componant.
   * @param key The resource key.
   */
  static public void show( Component parent,
                           String key )
  {
    show( parent, key, null, null, null );
  }



  /**
   * Sets the resource bundle to be used for resource key resolution.  The
   * passed bundle can contain a resource key 'ERROR_DIALOG_BUNDLE' that is
   * used as title of the dialog.
   *
   * @param rb The resource bundle to be used for resource key resolution.
   */
  static public void set( ResourceBundle rb )
  {
    _errorResources = rb;

    try
    {
      ERROR_DIALOG_TITLE = _errorResources.getString( ERROR_DIALOG_TITLE );
    }
    catch ( MissingResourceException e )
    {
      // Fall through.
    }
  }



  /**
   * Creates a message from the passed exception.
   *
   * @param e The exception to create the message for.
   * @return The message.
   */
  static private Object createMessage( Exception e )
  {
    // Then transform the exception stack backtrace into a string...
    java.io.StringWriter sw = new java.io.StringWriter();
    java.io.PrintWriter pw = new java.io.PrintWriter( sw );
    e.printStackTrace( pw );
    pw.flush();
    sw.flush();
    
    return sw.toString();
  }



  /**
   * Title to be used for the dialog.  Initial value is the resource key used
   * to resolve the title.  Successful resolution replaces the initial value.
   */
  private static String ERROR_DIALOG_TITLE = "ERROR_DIALOG_TITLE";


  /**
   *
   */
  private static String _errorTabTitle = "Error";
  private static String _detailTabTitle = "Details";
}
