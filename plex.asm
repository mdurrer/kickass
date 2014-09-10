
.pc = $1000


sprx: .fill $20,0
spry: .fill $20,0
sprc: .fill $20,0
sprf: .fill $20,0
MAXSPR: 
	.byte $20
sortsprx: .fill $20,0
sortspry: .fill $20,0
sortsprc: .fill $20,0
sortsprf: .fill $20,0
sortorder: .fill $20,0
setup:
         sei
         cld
         lda #<irq0
         ldx #>irq0
         sta $fffe
         stx $ffff
        
         lda #$01
         ldx #$fb
         sta $d01a
         stx $d012
         lda #$1b
         sta $d011
         lda #$7f
         sta $dc0d
	

spritesortloop:

        ldx #$00
        txa
sortloop:       ldy sortorder,x
        cmp spry,y
        beq noswap2
        bcc noswap1
        stx temp1
        sty temp2
        lda spry,y
        ldy sortorder-1,x
        sty sortorder,x
        dex
        beq swapdone
swaploop:       
	ldy sortorder-1,x
        sty sortorder,x
        cmp spry,y
        bcs swapdone
        dex
        bne swaploop
swapdone:       ldy temp2
        sty sortorder,x
        ldx temp1
        ldy sortorder,x
noswap1:        lda spry,y
noswap2:        inx
        cpx #MAX_SPR
        bne spritesortloop
