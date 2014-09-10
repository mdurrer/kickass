// Start code
.pc =$0801
:BasicUpstart(setup_irq)
.pc = $0810
start:
.import source "stdlib.a"
// Setting up IRQ, deactivating CIA IRQs, setting up Multiplexer 
setup_multiplex:
.var Multiplex_spriteHeightTweak = 21+2
setup_irq:

sei
lda #$7f
sta CIA1SerialShift
sta CIA1InterruptControl
lda CIA1SerialShift
lda CIA1InterruptControl

lda #$01
sta $d01a
lda #60
sta VIC2Raster

lda #$1b
sta VIC2ScreenControlV

// Deactivate BASIC
lda #$35
sta ZPProcessorPort
// Setting Pointer (IRQ)	
lda #<irq
ldx #>irq
sta $fffe
stx $ffff


cli

jmp *


irq:
pha
txa
pha
tya

lda #$ff
sta VIC2InterruptControl

pla
tay
pla
tax
pla

rti

