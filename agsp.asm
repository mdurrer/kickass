// AGSP-Beispiel
.pc = $1000
init: 
	sei         //irq sperren          
      lda #$7f    //timer-irq            
      sta $dc0d   // abschalten          
      lda $dc0d // icr löschen

      lda #$f8    //rasterzeile $f8 als  
      sta $d012   // interrupt-auslöser  
      lda $d011   // festlegen (incl. dem
      and #$7f    // löschen des hi-bits)
      sta $d011                         
      lda #$01    //raster als irq-      
      sta $d01a   // quelle wählen       
      ldx #<agsp //irq-vektoren auf     
      ldy #>agsp // eigene routine      
      stx $fffe   // verbiegen           
      sty $ffff   //
	                     

