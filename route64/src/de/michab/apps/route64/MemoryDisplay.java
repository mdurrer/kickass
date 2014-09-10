/* $Id: MemoryDisplay.java,v 1.1 2006/05/19 06:13:33 michab66 Exp $
*
* Project: Route64
*
* Released under GNU public license (www.gnu.org/copyleft/gpl.html)
* Copyright (c) 2006 Michael G. Binz
*/
package de.michab.apps.route64;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.util.ResourceBundle;

import javax.swing.DefaultCellEditor;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.WindowConstants;
import javax.swing.border.LineBorder;
import javax.swing.table.DefaultTableCellRenderer;

import de.michab.mack.ConfigurableAction;
import de.michab.simulator.Memory;



/**
 * Displays an editable memory view that can be used for debugging.
 * 
 * @author Michael G.Binz
 */
public class MemoryDisplay
  extends 
    ConfigurableAction
{
  /**
   * A table model that wraps the memory to be displayed.
   */
  private final MemoryTableModel _memoryModel;



  /**
   * A fixed width font.  Used for processor data and the like.  See the static
   * initialiser for more info.
   */
  private static final java.awt.Font _fixedWidthFont;

  static
  {
    // Get the default font size from a vanilla textfield...
    int defaultFontSize = new JTextField().getFont().getSize();
    // ...and use that to initialise our fixed width font.
    _fixedWidthFont = new Font( "Monospaced", Font.PLAIN, defaultFontSize );
  }



  /**
   * Create an instance.
   *
   * @param memory The memory that is to be displayed.
   */
  public MemoryDisplay( Memory memory )
  {
    super( "ACT_EDIT_MEMORY", true );

    _memoryModel = new MemoryTableModel( memory );
  }



  /*
   * Inherit Javadoc.
   */
  public void actionPerformed( ActionEvent e )
  {
    JTable view = new JTable(
        _memoryModel );

    view.getTableHeader().setReorderingAllowed( false );

    view.setFont(
        _fixedWidthFont );
    view.setDefaultRenderer( 
        Byte.class, 
        new ByteRenderer());
    view.setDefaultRenderer( 
        Integer.class, 
        new IntegerRenderer());
    view.setDefaultEditor( 
        Byte.class, 
        new ByteEditor());
 
    JFrame f = new JFrame( 
        _frameTitle );
    f.setDefaultCloseOperation( 
        WindowConstants.DISPOSE_ON_CLOSE );
    f.getContentPane().add( 
        new JScrollPane( view ), BorderLayout.CENTER);
    f.pack();
    f.setVisible(true);
  }



  /**
   * The frame title that is read from the resources.
   */
  private String _frameTitle;



  /*
   * Inherit Javadoc.
   */
  public void configureFrom( ResourceBundle b )
  {
    _frameTitle =
        localize( b, "FRAME_TITLE" );
    // TODO set frame icon.
  }



  /**
   * Adds leading zero characters ('0') to the passed string until
   * a certain length is reached.
   *
   * @param s The string to extend.
   * @param len The expected length.
   * @return The extended string.
   */
  private static String nullExtend( String s, int len )
  {
    StringBuffer sb = new StringBuffer( s );
    while ( sb.length() < len )
      sb.insert( 0, '0' );
    
    return sb.toString();
  }



  /**
   * Makes a string for display purposes from an integer number.
   *
   * @param b The number value for display.
   * @param bitWidth The width in bits used to create the resulting number.
   * @param radix The radix for display. Common values are 16, 10 or 2.
   * @param len The length of the result string.  If the result string would
   *        be shorter, it is extended with leading zero characters.
   * @return The displayable number.
   */
  static private String makeNumberDisplay( 
      int b,
      int bitWidth,
      int radix, 
      int len )
  {
    int ivalue = b;
    int mask = (int)Math.pow( 2, bitWidth ) -1;
    ivalue &= mask;

    return
      nullExtend( Integer.toString( ivalue, radix ), len );
  }

  // TODO can be made much cooler.  Let's unify the renderers and
  // editors.  Later  JDK 1.5.
  static class ByteRenderer extends DefaultTableCellRenderer
  {  
    public ByteRenderer()
    {
    }

    public void setValue(Object value)
    {
      assert( value instanceof Byte );

      setText(
        makeNumberDisplay( ((Byte)value).intValue(), 8, 16, 2  ) );
      setToolTipText(
        makeNumberDisplay( ((Byte)value).intValue(), 8, 2, 8 ) );
    }
  }


  // TODO can be made much cooler.  Let's unify the renderers and
  // editors.  Later JDK 1.5.
  static class IntegerRenderer extends DefaultTableCellRenderer
  {  
    public IntegerRenderer()
    {
    }

    public void setValue(Object value)
    {
      assert( value instanceof Integer );

      setText(
        makeNumberDisplay( 
            ((Integer)value).intValue(),
            16,
            16,
            4  ) );
      setToolTipText(
          value.toString() );
    }
  }



  /**
   * A simple editor that allows to edit bytes in hex.
   */
  static class ByteEditor extends DefaultCellEditor
  {
    /**
     * The value that is currently edited.
     */
    private Byte _value;



    /**
     * Create an instance.
     */
    public ByteEditor()
    {
      super( new JTextField() );
      setClickCountToStart( 0 );
    }



    /*
     * Inherit Javadoc.
     */
    public boolean stopCellEditing()
    {
      String s = (String) super.getCellEditorValue();

      try
      {
        _value = new Byte( (byte)Integer.parseInt( s, 16 ) );
      }
      catch (Exception e)
      {
        ((JComponent) getComponent()).setBorder(
            new LineBorder( Color.red ) );
        return false;
      }
      return super.stopCellEditing();
    }



    /*
     * Inherit Javadoc.
     */
    public Component getTableCellEditorComponent(
        JTable table, 
        Object value,
        boolean isSelected, 
        int row, 
        int column )
    {
      assert ( value instanceof Byte );

      _value = (Byte)value;

      JTextField tf = (JTextField)
        super.getTableCellEditorComponent(
            table, 
            value, 
            isSelected,
            row,
            column );
      
      tf.setText(
          makeNumberDisplay( _value.intValue(), 8, 16, 2  ) );
      tf.setBorder(
          new LineBorder( Color.black ) );
      tf.selectAll();
      
      return tf;
    }



    /*
     * Inherit Javadoc.
     */
    public Object getCellEditorValue()
    {
      return _value;
    }
  }
}
