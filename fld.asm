.var from = $32
.var to = $fa

.pc = $c000
lda #0
sta dir
lda #$ff
sta $3fff
lda #from
sta offset
sei
lda #$7f
sta $dc0d
lda $dc0d
lda #$01
sta $d01a
lda #<irq
ldx #>irq
sta $0314
stx $0315
lda #$01
sta $d019
lda #$1b
sta $d011 
lda #$00
sta $d012
cli

ghost: 
rol $3fff
jmp ghost
//rts
dir:
.byte 0
offset:
.byte from
irq:
ldx offset
l2: 
ldy $d012
l1:
cpy $d012
beq l1
dey
tya
and #$07
ora #$10
 sta $d011
dex
bne l2
inc $d019
jsr chofs
jmp $ea31

chofs:
lda dir
bne up
inc offset
lda offset
cmp #to
bne skip
sta dir
skip: 
rts
up:
dec offset
lda offset
cmp #from
bne skip
lda #$00
sta dir

mainloop:
//jsr joystickcheck
ldx #$00
licht:
inc $d021

dec $d021
dex
bne licht
jmp mainloop


joystickcheck:
lda $dc00
and #$5f // $5F = %0101111, Bit 0-4 = Joystick controls, high = not activated, low = activated (fire). Left / Right, Up / Down, Fire (in reverse order for the first lowest bits)
sta $dc00

lda  $dc00
and #%01111111 
sta $dc00
cmp  #127
beq nobuttons
rts
nobuttons:
inc $d020
jmp *
rts
