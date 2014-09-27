 
.pc=$1000
sei
lda #<irq
sta $0314
lda #>irq
sta $0315
cli
ever:
jmp ever  //(Can be replaced with rts)
//rts ever
irq:
ldx #$00
lda #$3b
start:
cmp $d012
bne start
nop
nop
nop
nop
nop
nop
loop:
ldy timer,x
lda color,x // (can be replaced with lda $0400,x
sta $d020 // so that you can edit the colors direct
sta $d021 // on the top of the screen)
delay:
dey
bne delay
inx
cpx #$18
bne loop
jmp $ea31

timer:
.byte $08,$08,$08,$08,$08,$08
.byte $08,$01
.byte $08,$08,$08,$08,$08,$08
.byte $08,$01
.byte $08,$08,$08,$08,$08,$08
.byte $08,$01
.byte $08,$08,$08,$08,$08,$08
.byte $08,$01

color:
.byte $01,$00,$01,$00,$01,$00
.byte $01,$00
.byte $01,$00,$01,$00,$01,$00
.byte $01,$00
.byte $01,$00,$01,$00,$01,$00
.byte $01,$00
.byte $01,$00,$01,$00,$01,$00
.byte $01,$00
