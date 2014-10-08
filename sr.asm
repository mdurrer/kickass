
.macro StabilizeIRQ ()
{
//«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»
// Raster Stabilizing Code
//«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»
	// PHA TAX usw. kommt hierhinne, vor dem Makro und danach das Gegenteil, klar nech?
    // CYCLECOUNT: [20 -> 27] cycles after Raster IRQ occurred.

    // Set up Wedge IRQ vector
    lda #<WedgeIRQ
    sta $fffe
    lda #>WedgeIRQ
    sta $ffff

    // Set the Raster IRQ to trigger on the next Raster line
    inc $d012

    // Acknowlege current Raster IRQ
    lda #$01
    sta $d019

    // Store current Stack Pointer (will be messed up when the next IRQ occurs)
    tsx

    // Allow IRQ to happen (Remeber the Interupt flag is set by the Interrupt Handler).
    cli

    // Execute NOPs untill the raster line changes and the Raster IRQ triggers
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    // Add one extra nop for 65 cycle NTSC machines

    // CYCLECOUNT: [64 -> 71]

WedgeIRQ:
    // At this point the next Raster Compare IRQ has triggered and the jitter is max 1 cycle.
    // CYCLECOUNT: [7 -> 8] (7 cycles for the interrupt handler + [0 -> 1] cycle Jitter for the NOP)

    txs

    // PAL-63  // NTSC-64    // NTSC-65
    //---------//------------//-----------
    ldx #$08   // ldx #$08   // ldx #$09
    dex        // dex        // dex
    bne *-1    // bne *-1    // bne *-1
    bit $00    // nop

    lda $d012
    cmp $d012  // <- critical instruction (ZERO-Flag will indicate if Jitter = 0 or 1)
    beq *+2
    
}

.pc = $1000
:BasicUpstart2(start)
start:
sei
lda #$35
sta $01

lda #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d
lda #$1b
sta $d011
sta $d020
lda #$40
sta $d012
lda #$01
sta $d019
lda #$01
sta $d01a
lda #<irq2
ldx #>irq2
sta $fffe
stx $ffff
cli
jmp *

.pc = $1500
irq2:
pha
txa
pha
tya
pha
:StabilizeIRQ()

inc $d021
nop
nop
nop
nop

dec $d021 
ldx #$4
d021loop:
lda $d021,x
sta $d021
dex
bne d021loop
lda #<irq2
sta $fffe
lda #>irq2
sta $ffff
lda #$66
sta $d012
lsr $d019
pla
tay
pla
tax
pla
rti

rastertable:
//.byte $06,$04,$0b,$0a,$06,$04,$05,$04,$08,$03,$0d,$01,$06,$04,$0c,$04,$06,$04,$05
.byte $01,$2,$3,$1,$3
