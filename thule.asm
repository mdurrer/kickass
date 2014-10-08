.var from 	= $32
.var to   	= $fa
.var key	= $03
//---------------------------------------
      .pc = $1000
//---------------------------------------
init:
	sei
      lda #$00
      sta dir     // direction
      lda #$ff    // set garbage
      sta $3fff
      lda #from
      sta ofset   // set ofset
      lda #$7f    // disable timer interrupt
      sta $dc0d
      lda #1      // enable raster interrupt
      sta $d01a
      lda #<irq   // set irq vector
      sta $fffe
      lda #>irq
      sta $ffff
      lda #0      // to evoke our irq routine on 0th line
      sta $d012


//jsr 	hires_on

mainloop:
//jsr	checkspace
//jsr 	hires_off
	inc $d021
	inc $d021
	nop
	dec $d021
        cli         // enable interrupt
//---------------------------------------
checkspace:
	inc $d021
	lda $dc01
	cmp #$ef
	beq finish
	
finish:
	sta $03
	rts
hires_on:
lda $d018
ora #$08
sta $d018
lda #$d011
ora #$20
sta $d011
rts

hires_off:
lda $d018
and #$08
sta $d018
lda $d011
and #$20
sta $d011
rts

irq: 	 
pla
tay
pla
tax
pla
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
      jsr chofs
      jmp $ea31   // do standard irq routine 

2a	
//---------------------------------------
ofset:
	.byte from
dir:
   .byte 0
//---------------------------------------
chofs: 
		lda dir     // change ofset of screen
		lda $dc01
		and #$7f
		sta $dc01
		// CHANGE THIS!
		
      bne up
      inc ofset   // down
      lda ofset
      cmp #to
      bne skip
      sta dir
skip:
	rts
//---------------------------------------
up:
     dec ofset   // up
      lda ofset
      cmp #from
      bne skip
      lda #0
      sta dir
      lda #$2
      rts
