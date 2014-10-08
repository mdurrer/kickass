.var from 	= $32
.var to   	= $fa
//---------------------------------------
.pc =  $c000
//---------------------------------------
init:	lda #0
      sta dir     // direction
      lda #$ff    // set garbage
      sta $3fff
      lda #from
      sta ofset   // set ofset
      sei         // disable interrupt
      lda #$7f    // disable timer interrupt
      sta $dc0d
      lda #1      // enable raster interrupt
      sta $d01a
      lda #<irq   // set irq vector
      sta $0314
      lda #>irq
      sta $0315
      lda #0      // to evoke our irq routine on 0th line
      sta $d012
      cli         // enable interrupt
      rts
//---------------------------------------
irq: 	
ldx ofset
l2:   
ldy $d012   // moving 1st bad line
l1:    
cpy $d012
      beq l1      // wait for begin of next line
      dey         // iy - bad line
      tya
      and #$07    // clear higher 5 bits
      ora #$10    // set text mode
      sta $d011
      dex
      bne l2
      inc $d019   // acknowledge the raster interrupt
      //jsr chofs
	 jsr fldcontrol



      jmp $ea31   // do standard irq routine
//---------------------------------------
ofset:
	.byte from
dir:
   .byte 0
//---------------------------------------
fldcontrol:

loop:
	lda $dc00
	cmp #$7d
	beq down
	
down:
	inc ofset
			// EDIT THIS JOYSTICK PART!
	
	jmp loop
	rts
	
chofs:
	 lda dir     // change ofset of screen
      bne up
      inc ofset   // down
      lda ofset
      cmp #to
      bne skip
      sta dir
skip:	rts
//---------------------------------------
up:    dec ofset   // up
      lda ofset
      cmp #from
      bne skip
      lda #0
      sta dir
      rts
