.macro STABILIZE()
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
    // CYCLECOUNT: [7 -> 8] (7 cycles for the interrupt handler + [0 -> 1] cycle Jitter for the nop)

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
    beq *+2

    // Stable code    
 }
 
 
.pc = $1900
.var clrsprite = LoadBinary("clearsprite.prg")
clearsprite:
.fill clrsprite.getSize(), clrsprite.get(i)
.pc = $0801

:BasicUpstart2(start)
.pc = $1000
start:

sei
lda #$35
sta $01
lda #$7f
sta $dc0d
sta $dd0d
lda $dd0d
lda $dc0d
lda #<irq1
sta $fffe
lda #>irq1
sta $ffff
lda #$01
sta $d01a
asl $d019
lda $d011
and #$7f
sta $d011
lda #$50
sta $d012
lda #$04
sta $03

init_fadeout:
lda #$fa
sta $05
lda #$01
sta $06
	// Sprites in Lower and Upper Border
	lda #%111111111
	sta $d015
	lda #%11000000
	sta $d010
setsprycoord:
	lda #$fa
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f
setsprxcoord:
	clc
	lda #24
	sta $d000
	adc #48
	sta $d002
	adc #48
	sta $d004
	adc #48
	sta $d006
	adc #48
	sta $d008
	adc #30
	sta $d00a
	lda #$00
	sta $d00c
	adc #48
	sta $d00e
	ldx #$08
	
sprcolors:
	
	lda #$0e
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e
	lda #100
	ldx #$08
sprdata:
	lda #$ff
	sta $d01d
	sta $d017
	cli
jmp *
irq1:
    pha
    txa
    pha
    tya
    pha
    :STABILIZE()

    lda #<irq2
    sta $fffe
    lda #>irq2
    sta $ffff
    lda #$01
    sta $d019
	lda #$f8
	sta $d012
    pla
    tay
    pla
    tax
    pla
    rti
irq2:
    pha
    txa
    pha
    tya
    pha
    lda $d011
    and #%11110111
    sta $d011
    lda #$fc
    sta $d012
    lda #<irq3
    sta $fffe
    lda #>irq3
    sta $ffff
    asl $d019
    lda #$ff
    sta $3fff
    jsr fadeout
    pla
    tay
    pla
    tax
    pla
    rti

irq3:
    pha
    txa
    pha
    tya
    pha
    inc $d020
    nop
    nop
    nop
    dec $d020
	lda $d011
	ora #$08
	sta $d011
    lda #$50
    sta $d012
    lda #<irq1
    sta $fffe
    lda #>irq1
    sta $ffff
    inc $3fff
 
    asl $d019
	
    
    pla
    tay
    pla
    tax
    pla
    rti

fadeout:
lda $06
cmp #$01
bne down
up:
dec $05
lda $05
sta $d001
sta $d003
sta $d005
sta $d007
sta $d009
sta $d00b
sta $d00d
sta $d00f
cmp #$30
beq go_down
rts
go_down:
lda #$00
sta $06
down:
inc $05
lda $05
sta $d001
sta $d003
sta $d005
sta $d007
sta $d009
sta $d00b
sta $d00d
sta $d00f
cmp #$fa
beq go_up
rts
go_up:
lda #$01
sta $06
rts
