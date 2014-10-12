.macro Stabilize()
{

//«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»
// Raster Stabilizing Code
//«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»
    // A Raster Compare IRQ is triggered on cycle 0 on the current $d012 line
    // The MPU needs to finish it's current OP code before starting the Interrupt Handler,
    // meaning a 0 -> 7 cycles delay depending on OP code.
    // Then a 7 cycle delay is spendt invoking the Interrupt Handler (Push SR/PC to stack++)
    // Then 13 cycles for storing registers (pha, txa, pha, tya, pha)

    // CYCLECOUNT: [20 -> 27] cycles after Raster IRQ occurred.
	lda $03
	sta $d02
	inc $03
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

    // Restore previous Stack Pointer (ignore the last Stack Manipulation by the IRQ)
    txs

    // PAL-63  // NTSC-64    // NTSC-65
    //---------//------------//-----------
    ldx #$08   // ldx #$08   // ldx #$09
    dex        // dex        // dex
    bne *-1    // bne *-1    // bne *-1
    bit $00    // nop
               // nop

    // Check if $d012 is incremented and rectify with an aditional cycle if neccessary
    lda $d012
    cmp $d012  // <- critical instruction (ZERO-Flag will indicate if Jitter = 0 or 1)
    
    // CYCLECOUNT: [61 -> 62] <- Will not work if this timing is wrong

    // cmp $d012 is originally a 5 cycle instruction but due to piplining tech. the
    // 5th cycle responsible for calculating the result is executed simultaniously
    // with the next OP fetch cycle (first cycle of beq *+2).

    // Add one cycle if $d012 wasn't incremented (Jitter / ZERO-Flag = 0)
    beq stable

    // Stable code    
    stable:
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
lda $d011
and #$7f
sta $d011


lda #$0
sta $03
ldx #$ff
mainloop:
lda $03
sta $0400,x
inc $03
dex
bne mainloop
cli 
jmp *

fld:
pha
txa
pha
tya
pha
:Stabilize()
inc $03
lda #$01 
nop
nop
nop
nop
nop

lda #$06
sta $d021
inc $d020
lda $03
sta $0700
inc $03 
lda #$80
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
lda #1
sta $d020
asl $d019
lda #<fld
ldx #>fld
sta $fffe
stx $ffff
lda #$80
sta $d012
lda $d011
and #$7f
sta $d011

pla
tay
pla
tax
pla
rti
