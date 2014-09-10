/* $Id: MemoryTableModel.java,v 1.1 2006/05/19 06:13:33 michab66 Exp $
*
* Project: Route64
*
* Released under GNU public license (http://www.gnu.org/copyleft/gpl.html)
* Copyright (c) 2006 Michael G. Binz
*/
package de.michab.apps.route64;

import javax.swing.table.AbstractTableModel;

import de.michab.simulator.Memory;



/**
 * A table model used to edit and display raw memory content.  The first column
 * represents the memory address, the following columns the memory content.
 *
 * @version $Revision: 1.1 $
 * @author Michael G. Binz
 */
class MemoryTableModel
    extends
      AbstractTableModel
{
  private static final int NUM_EDIT_COLS = 16;
  
  private final Memory _memory;



  /*
   * Create an instance.
   *
   * @param memory The memory that is to be displayed.
   * @throws NullPointerException If the passed memory is null.
   */
  public MemoryTableModel( Memory memory )
  {
    if ( memory == null )
      throw new NullPointerException();

    _memory = memory;
  }



  /*
   * Inherit Javadoc.
   */
  public int getColumnCount()
  {
    return NUM_EDIT_COLS +1;
  }



  /*
   * Inherit Javadoc.
   */
  public int getRowCount()
  {
    assert( 0 == (_memory.getSize() % NUM_EDIT_COLS) );

    return _memory.getSize() / NUM_EDIT_COLS;
  }



  /*
   * Inherit Javadoc.
   */
  public boolean isCellEditable( int rowIndex, int columnIndex )
  {
    return columnIndex > 0;
  }



  /*
   * Inherit Javadoc.
   */
  public Class getColumnClass( int columnIndex )
  {
    if ( columnIndex == 0 )
      return Integer.class;

    return Byte.class;
  }



  /*
   * Inherit Javadoc.
   */
  public Object getValueAt( int rowIndex, int columnIndex )
  {
    if (columnIndex == 0)
    {
      return new Integer( rowIndex * NUM_EDIT_COLS );
    }
    
    columnIndex--;

    return new Byte(
        _memory.read( 
            columnIndex + (rowIndex * NUM_EDIT_COLS) ) );
  }



  /*
   * Inherit Javadoc.
   */
  public void setValueAt( Object aValue, int rowIndex, int columnIndex )
  {
    assert( aValue instanceof Byte );

    _memory.write(
        (columnIndex-1) + (rowIndex*NUM_EDIT_COLS),
        ((Byte)aValue).byteValue() );
  }


  /*
   * Inherit Javadoc.
   */
  public String getColumnName( int column )
  {
    if ( column == 0 )
      return "";
    
    column--;
    
    return Integer.toHexString( column );
  }
}
