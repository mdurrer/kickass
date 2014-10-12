

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
    beq *+3
    
}
.pc = $0801
:BasicUpstart(start)
.pc = $1000
start:

sei
lda #$35
sta $01
lda #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d
lda #$50
sta $d012
lda #$01
sta $d01a
lda #<fld
ldx #>fld
sta $fffe
stx $ffff
cli 

mainloop:
lda $d011
and #$7f
sta $d011
jmp mainloop

fld:
pha
txa
pha
tya
pha
//:StabilizeIRQ()
inc $d021
inc $d021
dec $d021
dec $d021

lda $d011
and #$7f
sta $d011
lda #$13
sta $d011
inc $d021
lda #$01
sta $0400
sta $0401
//lda #<bord
//ldx #>bord
//sta $fffe
//stx $ffff
lda #<fld
ldx #>fld
sta $fffe
stx $ffff
lda #$50
sta $d012
pla
tay
pla
tax
pla
rti

bord:
pha
txa
pha
tya
pha
asl $d019
lda #<fld
ldx #>fld
sta $fffe
stx $ffff
lda #$30
sta $d012
lda $d011
and #$7f
sta $d011
inc $d021
nop
nop
nop
dec $d021
pla
tay
pla
tax
pla
rti
