.pc = $1000
init: sei         //irq sperren          
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
      ldx #<irq //irq-vektoren auf     
      ldy #>irq // eigene routine      
      stx $0314   // verbiegen           
      sty $0315   //                     
      lda #$00    //letzte vic-adr. auf  
      sta $3fff   // 0 setzen            
      lda #$0e    //rahmen- u. hinter-   
      sta $d020   // grundfarben auf     
      lda #$06    // hellblau/blau       
      sta $d021   // setzen              
      ldy #$3f    //sprite-block 13      
      lda #$ff    // ($0340) mit $ff     
loop2: sta $0340,y // füllen              
      dey                               
      bpl loop2                         
      lda #$01    //sprite 0             
      sta $d015   // einschalten         
      sta $d027   // farbe="weiß"        
      lda #$0d    //spritezeiger auf     
      sta $07f8   // block 13 setzen     
      lda #$64    //x- und y-pos.        
      sta $d000   // auf 100/100         
      sta $d001   // setzen              
      cli         //irqs freigeben       
      rts         //ende                 
irq:   lda $d011   //bildschirm           
      and #$f7    // auf 24 zeilen       
      sta $d011   // umschalten          
      dec $d019   //vic-icr löschen      
      ldx #$c0    //verzögerungs-        
loop1:	inx
      bne loop1                         
      lda $d011   //bildschirm           
      ora #$08    // auf 25 zeilen       
      sta $d011   // zurückschalten      
      inc $d001
      jmp $ea31
