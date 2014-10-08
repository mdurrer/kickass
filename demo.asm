 .pc = $1000
.var areg = $5
.var xreg = $6
.var yreg = $07
.var reseta1 = $03
.var resetx1 = $04
.var resety1 = $05

.var nextline = 0
wodvar:
.word $0001

init:
:SetBorderColor(4)
cld

sei
lda #$35
sta $01
lda  #$7f
sta $dc0d
sta $dd0d
lda $dd00
and #%00000000
ora #$11111100
sta $dd00
lda $dc0d
lda $dd0d
lda #$01
sta $d01a
sta $d019
tsx
lda #$1b
sta $d011
lda #<irq1
sta $fffe
lda #>irq1
sta $ffff
inc $d012 
lda #$00  // REMOVE SPRITES!!!
sta $d015
lda #$34
sta $d012
//' Multicolour mode and active bitmap mode
lda $d011
ora #%00111000
sta $d011
//'Active bitmap
lda $d016
and #%00111000
ora #%00001000
ora #%00010000
sta $d016
lda #$35
sta $01

cli

nop
nop
nop
nop
nop
nop
nop
nop


newloop:

ldx #$00
lda #$05    
bloop:
sta $03
inc $03
lda $03
sta $d800,x
sta $d900,x
sta $da00,x
sta $db00,x
dex
bne bloop

jmp newloop



irq1:
sta areg
stx xreg
sty yreg

lda #<irq2
ldx #>irq2
sta $fffe
stx $ffff
inc $d012
asl $d019
tsx


nop
nop
nop
nop

nop
nop
nop
nop

nop
nop
nop
nop

nop
nop

cli
irq2:
txs
ldx #$08
dex
bne *-1
bit $ea
nop
lda #65
jsr $ffd2
lda #$35
cmp $d012

beq start

start:
nop
nop
nop
    // Add one extra nop for 65 cycle NTSC machines

    // CYCLECOUNT: [64 -> 71]

WedgeIRQ:
    // At this point the next Raster Compare IRQ has triggered and the jitter is max 1 cycle.
    // CYCLECOUNT: [7 -> 8] (7 cycles for the interrupt handler + [0 -> 1] cycle Jitter for the NOP)

    // Restore previous Stack Pointer (ignore the last Stack Manipulation by the IRQ)
    txs

    // PAL-63  // NTSC-64    // NTSC-65
    //---------//------------//-----------
     ldx #$08   // lc
               // nop 
	lda $d012
    cmp $d012  // <- critical instruction (ZERO-Flag will indicate if Jitter = 0 or 1)

    // CYCLECOUNT: [61 -> 62] <- Will not work if this timing is wrong

    // cmp $d012 is originally a 5 cycle instruction but due to piplining tech. the
    // 5th cycle responsible for calculating the result is executed simultaniously
    // with the next OP fetch cycle (first cycle of beq *+2).

    // Add one cycle if $d012 wasn't incremented (Jitter / ZERO-Flag = 0)
  beq *+2

    // Stable code    
    

lda #$06
ldx #$0e
sta $d021
stx $d021
lda #<irq3
ldx #>irq3
ldy #$68
sta $fffe
stx $ffff

sty $d012
asl $d019
lda #$01
sta $d01a
lda #$00


rti

irq3:
sta reseta2
stx resetx2
sty resety2

ldx #$0a
dex
bne *-1
nop

lda #$0e
ldx #$06
sta $d021
stx $d021
ldy #$13
dey
bne *-1
reseta2:
	 .byte 07
 resetx2:
 .byte $08
resety2:
 .byte $09
rti


.macro ClearScreen(screen,clearByte)
{
	lda #clearByte
bne sloloop
ldx #0
loop:
	sta screen,x
	sta screen+$100,x
	sta screen+$200,x
	sta screen+$300,x
	inx
	bne loop
}
.macro SetBorderColor (color)
{
	lda #color
	sta $d020
}
.macro SetBackgroundColor (color)
{
	lda #color
	sta $d021
}
