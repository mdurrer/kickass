.pc = $0801
:BasicUpstart(start)
.pc = $1000
start:

//lda #%00111000
sei
lda #$35
sta $01
lda #$00
sta $03
ldx #$00
loop:
sta $0400,x
sta $0500,x
sta $0600,x
sta $0700,x
dex
bne loop
ldx #00
loop2:
lda $0003
sta $d800,x
sta $d900,x
sta $da00,x
sta $db00,x
inc $03
dex
bne loop2


scrollarea:

clc
ldx #$00
scrollloop:
inc $03
lda $03
sta $d800,x
sta $d900,x
sta $da00,x
sta $db00,x
inc $0401
inx
bne scrollloop
jmp scrollarea
cli
jmp *
