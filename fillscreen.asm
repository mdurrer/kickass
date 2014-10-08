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
cli
jmp *
