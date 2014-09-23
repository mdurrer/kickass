.var FROM 	= $32
.var TO   	= $FA
//---------------------------------------
      *= $C000
//---------------------------------------
INIT:	LDA #0
      STA DIR     // Direction
      LDA #$FF    // Set garbage
      STA $3FFF
      LDA #FROM
      STA OFSET   // Set ofset
      SEI         // Disable interrupt
      LDA #$7F    // Disable timer interrupt
      STA $DC0D
      LDA #1      // Enable raster interrupt
      STA $D01A
      LDA #<IRQ   // Set irq vector
      STA $0314
      LDA #>IRQ
      STA $0315
      LDA #0      // To evoke our irq routine on 0th line
      STA $D012
      CLI         // Enable interrupt
      RTS
//---------------------------------------
IRQ: 	LDX OFSET
L2:   LDY $D012   // Moving 1st bad line
L1:    CPY $D012
      BEQ L1      // Wait for begin of next line
      DEY         // IY - bad line
      TYA
      AND #$07    // Clear higher 5 bits
      ORA #$10    // Set text mode
      STA $D011
      DEX
      BNE L2
      INC $D019   // Acknowledge the raster interrupt
      JSR CHOFS
      JMP $EA31   // Do standard irq routine
//---------------------------------------
OFSET:
	.BYTE FROM
DIR:
   .BYTE 0
//---------------------------------------
CHOFS LDA DIR     // Change OFSET of screen
      BNE UP
      INC OFSET   // Down
      LDA OFSET
      CMP #TO
      BNE SKIP
      STA DIR
SKIP	RTS
//---------------------------------------
UP    DEC OFSET   // Up
      LDA OFSET
      CMP #FROM
      BNE SKIP
      LDA #0
      STA DIR
      RTS
