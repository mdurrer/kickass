.pc = $1000
cld

sei
lda #$35
sta $01
lda  #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d
lda #$01
sta $d01a
lda #$1b
sta $d011
lda #$1b
sta $d011
lda #<irq1
sta $fffe
lda #>irq1
sta $ffff 
lda #$50
sta $d012

lda #$35
sta $01
cli


jmp *


irq1:
lsr $d019
inc $d021
dec $d021
rti
