
.pc = $0fc0
.fill 64,255
.var MINSPRY = 30
.var MAXSPRY = 250
.var MAXSPR = 24
.var NUMSPR = 24
.var IRQ1LINE = $10
.var temp1 = $02
.var temp2 = $03
.var temp3 = $04
.var sprupdateflag = $05
.var sortsprstart = $06
.var sortsprend = $07
.var sprorder = $40+MAXSPR+1
.var DEBUG = true

.var SCREENRAM = $0400
.pc = $c000
sprxl:
.fill MAXSPR,0
sprxh:
.fill MAXSPR,0

sprf:
.fill MAXSPR,0
sprc:
.fill MAXSPR,1
.var spry = $40
.var screen1 = $0400
sortsprx:
.fill MAXSPR*2,0
sortspry:
.fill MAXSPR*2,0
sortsprc:
.fill MAXSPR*2,0
sortsprf:
.fill MAXSPR*2,0
sortsprd010:
.fill MAXSPR*2,0
sprirqline:
.fill MAXSPR*2,0
sprirqadvtbl:
.byte -4,-5,-6,-7,-7,-8,-9,-10

d015tbl:
.byte $00,$01,$03,$07,$0f,$1f,$3f,$7f,$ff
sprortbl:    
		.byte $01,$02,$04,$08,$10,$20,$40,$80 // OR table for $d010 manipulation DblBuf
                .byte $01,$02,$04,$08,$10,$20,$40,$80
                .byte $01,$02,$04,$08,$10,$20,$40,$80
                .byte $01,$02,$04,$08,$10,$20,$40,$80
                .byte $01,$02,$04,$08,$10,$20,$40,$80
                
sprandtbl:      
		.byte $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f  //AND table likewise repeated for 2x max sprites
		.byte $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f
                .byte $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f
                .byte $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f
                .byte $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f
                .byte $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f

sprirqjumptbllo:
		.byte <irq2_spr0                 //Jump table for starting the IRQ at sprite
                .byte <irq2_spr1
                .byte <irq2_spr2
                .byte <irq2_spr3
                .byte <irq2_spr4
                .byte <irq2_spr5
                .byte <irq2_spr6
                .byte <irq2_spr7

sprirqjumptblhi:
		.byte >irq2_spr0
                .byte >irq2_spr1
                .byte >irq2_spr2
                .byte >irq2_spr3
                .byte >irq2_spr4
                .byte >irq2_spr5
                .byte >irq2_spr6
                .byte >irq2_spr7
.pc = $1000

jsr initsprites
jsr initraster

ldx #NUMSPR-1
initloop:
sta $e000,x
sta sprxl,xrts
lda $e018,x
and #$01
sta sprxh,x
lda $e030,x
lda #$3f
sta sprf,x
txa
and #$0f
cmp #$06
bne colorok

lda #$05
colorok:
sta sprc,x
dex
bpl initloop

// Main Loop!

mainloop:
ldx #NUMSPR-1
moveloop:
lda #$e048,x
and #$03
sec
adc sprxl,x
sta sprxl,x
lda sprxh,x
adc #$00
sta sprxh,x
beq moveloop_xnotover
lda sprxl,x
bpl moveloop_xnotover
sec
sbc #$80
sta sprxl,x
dec sprxh,x

moveloop_xnotover
lda $e060,x
and #$01
sec
adc spry,x
sta spry,x
dex 
bpl moveloop
jsr sortsprites
jmp mainloop

initraster:
cld
sei
//lda #$35
//sta $01
lda  #$7f
sta $dc0d
sta $dd0d
lda $dc0d
lda $dd0d
lda #$01
sta $d01a
lda #$10
sta $d011
lda #$1b
sta $d011
lda #<irq1
sta $0314
lda #>irq1
sta $0315
cli
rts

initsprites:

// RTS nicht vergessen!

lda #$00
sta sprupdateflag
sta sortsprstart
ldx #MAXSPR
is_orderlist:
	txa
	sta sprorder,x
	lda #$ff
	sta spry,x
	dex
	bpl is_orderlist
	rts
sortsprites:
bne sortsprites

.if (DEBUG)
{
inc $d020
}

lda sortsprstart
eor #MAXSPR
sta sortsprstart
ldx #$00
sta temp3

rts
sspr_loop1:
ldy sprorder,x
cmp spry,y
beq sspr_noswap2
bcc sspr_noswap1
stx temp1
sty temp2
lda spry,y
ldy  sprorder-1,x
sty sprorder,x
dex
beq sspr_swapdone1

sspr_swap1:
ldy sprorder -1,x
sty sprorder,x
cmp spry,y
bcs sspr_swapdone1
dex
bne sspr_swap1
sspr_swapdone1:
ldy temp2
sty sprorder,x
ldx temp1
ldy sprorder,x

sspr_noswap1:   

lda spry,y

sspr_noswap2:   

inx
cpx #MAXSPR
bne sspr_loop1               ldx #$00
sspr_findfirst: 
		ldy sprorder,x                  //Find upmost visible sprite
                lda spry,y
                cmp #MINSPRY
                bcs sspr_firstfound
                inx
                bne sspr_findfirst
sspr_firstfound:
		txa
                adc #<sprorder                  //Add 1m C=1 becomes 0
                sbc sortsprstart                //subtract one  to cancel out
                sta sspr_copyloop1+1
                ldy sortsprstart
                tya
                adc #8-1                        //C=1
                sta sspr_copyloop1end+1         //Set endpoint for first copyloop
                bpl sspr_copyloop1

sspr_copyloop1skip:                             //Copyloop for the first 8 sprites
                inc sspr_copyloop1+1
sspr_copyloop1: 
		ldx sprorder,y
                lda spry,x                      //If reach the maximum Y-coord, all done
                cmp #MAXSPRY
                bcs sspr_copyloop1done
                sta sortspry,y
                lda sprc,x                      //Copy sprite's properties to sorted table
                sta sortsprc,y
                lda sprf,x
                sta sortsprf,y
                lda 	sprxl,x
                sta sortsprx,y
                lda sprxh,x                     //Handle sprite X coordinate MSB
                beq sspr_copyloop1msblow
                lda temp3
                ora sprortbl,y
                sta temp3
sspr_copyloop1msblow:
                iny
sspr_copyloop1end:
                cpy #$00
                bcc sspr_copyloop1
                lda temp3
                sta sortsprd010-1,y
                lda sortsprc-1,y                //Make first irq endmark
                ora #$80
                sta sortsprc-1,y
                lda sspr_copyloop1+1            //Copy sortindex from first copyloop
                sta sspr_copyloop2+1            //To second
                bcs sspr_copyloop2

sspr_copyloop1done:
                lda temp3
                sta sortsprd010-1,y
                sty temp1                       //Store sorted sprite end index
                cpy sortsprstart                //Any sprites at all?
                beq sspr_nosprites
                lda sortsprc-1,y                //Make first (and final) IRQ endmark
                ora #$80                        //(stored in the color table)
                sta sortsprc-1,y
                jmp sspr_finalendmark
sspr_nosprites:
		jmp sspr_alldone

sspr_copyloop2skip:                             //Copyloop for subsequent sprites,
                inc sspr_copyloop2+1            //with "9th sprite" (physical overlap) prevention
sspr_copyloop2: 
		ldx sprorder,y
                lda spry,x
                cmp #MAXSPRY
                bcs sspr_copyloop2done
                sta sortspry,y
                sbc #21-1
                cmp sortspry-8,y                //Check for physical sprite overlap
                bcc sspr_copyloop2skip
                lda sprc,x
                sta sortsprc,y
                lda sprf,x
                sta sortsprf,y
                lda sprxl,x
                sta sortsprx,y
                lda sprxh,x
                beq sspr_copyloop2msblow
                lda sortsprd010-1,y
                ora sprortbl,y
                bne sspr_copyloop2msbdone
sspr_copyloop2msblow:
                lda sortsprd010-1,y
                and sprandtbl,y
sspr_copyloop2msbdone:
                sta sortsprd010,y
                iny
                bne sspr_copyloop2

sspr_copyloop2done:
                sty temp1                       //Store sorted sprite end index
                ldy sspr_copyloop1end+1         //Go back to the second IRQ start
                cpy temp1
                beq sspr_finalendmark
sspr_irqloop:   
		sty temp2                       //Store IRQ startindex
                lda sortspry,y                  //C=0 here
                sbc #21+12-1                    //First sprite of IRQ: store the y-coord
                sta sspr_irqycmp1+1             //compare values
                adc #21+12+6-1
                sta sspr_irqycmp2+1
sspr_irqsprloop:
		iny
                cpy temp1
                bcs sspr_irqdone
                lda sortspry-8,y                //Add next sprite to this IRQ?
sspr_irqycmp1:  
		cmp #$00                        //(try to add as many as possible while
                bcc sspr_irqsprloop             //avoiding glitches)
                lda sortspry,y
sspr_irqycmp2:  
		cmp #$00
                bcc sspr_irqsprloop
sspr_irqdone:  
		tya
                sbc temp2
                tax
                lda sprirqadvtbl-1,x
                ldx temp2
                adc sortspry,x
                sta sprirqline-1,x              //Store IRQ start line (with advance)
                lda sortsprc-1,y                //Make endmark
                ora #$80
                sta sortsprc-1,y
                cpy temp1                       //Sprites left?
                bcc sspr_irqloop
sspr_finalendmark:
                lda #$00                        //Make final endmark
                sta sprirqline-1,y
sspr_alldone:   sty sortsprend                  //Index of last sorted sprite +1
                inc sprupdateflag               
                .if (DEBUG)
		{
                dec $d020
                }
                rts

//rts
irq1:
inc $d019
.if (DEBUG == true)
{
inc $d021
}

// Actual IRQ Code MAIN INTERRUPT //
.if (DEBUG == true)
{
dec $d021
}
jmp $ea31

irq2_spr0:
lda sortspry,x
sta $d001
ldy sortsprd010,x
sta $d000
sty $d010
sta sortsprf,x
sta SCREENRAM+$037f8
lda sortsprc,x
sta $d027
bmi irq2_sprirqdone2
inx

irq2_spr1:
lda sortspry,x
sta $d003
ldy sortsprd010,x
sta $d002
sty $d010
sta sortsprf,x
sta SCREENRAM+$037f9
lda sortsprc,x
sta $d028
bmi irq2_sprirqdone2
inx

irq2_spr2:
lda sortspry,x
sta $d005
ldy sortsprd010,x
sta $d004
sty $d010
sta sortsprf,x
sta SCREENRAM+$037fa
lda sortsprc,x
sta $d029
bmi irq2_sprirqdone2
inx

irq2_spr3:
lda sortspry,x
sta $d007
ldy sortsprd010,x
sta $d006
sty $d010
sta sortsprf,x
sta SCREENRAM+$037fb
lda sortsprc,x
sta $d02a
bpl irq2_tospr4
inx

irq2_sprirqdone2:
	jmp irq2_sprirqdone
irq2_tospr4:
	inx
irq2_spr4:      
		lda sortspry,x
                sta $d009
                lda sortsprx,x
                ldy sortsprd010,x
                sta $d008
                sty $d010
                lda sortsprf,x
irq2_spr4frame: 
		sta SCREENRAM+$03fc
                lda sortsprc,x
                sta $d02c
                bmi irq2_sprirqdone
                inx	
irq2_spr5:      
		lda sortspry,x
                sta $d00b
                lda sortsprx,x
                ldy sortsprd010,x
                sta $d00a
                sty $d010
                lda sortsprf,x
irq2_spr5frame: 
		sta SCREENRAM+$03fd
                lda sortsprc,x
                sta $d02c
                bmi irq2_sprirqdone
                inx	

irq2_spr6:      
		lda sortspry,x
                sta $d00d
                lda sortsprx,x
                ldy sortsprd010,x
                sta $d00c
                sty $d010
                lda sortsprf,x
irq2_spr6frame: 
		sta SCREENRAM+$03fe
                lda sortsprc,x
                sta $d02d
                bmi irq2_sprirqdone
                inx	
irq2_spr7:      
		lda sortspry,x
                sta $d00f
                lda sortsprx,x
                ldy sortsprd010,x
                sta $d00e
                sty $d010
                lda sortsprf,x
irq2_spr7frame: 
		sta SCREENRAM+$03ff
                lda sortsprc,x
                sta $d02f
                bmi irq2_sprirqdone
                inx	
irq2_sprirqdone:
.if (DEBUG)
{
dec $d020
}
		ldy sprirqline,x
		beq irq2_alldone
		inx
		stx irq2_sprindex+1
		txa
		and #$07
		tax
		lda sprirqjumptbllo,x
		sta irq2_sprjump+1
		lda sprirqjumptblhi,x
		sta irq2_sprjump+2
		tya
		sta $d012
		sec
		sbc #$3
		cmp $d012
		bcc irq2_direct
		inc $d019
		jmp $ea81
		
irq2:
irq2_direct:	.if(DEBUG)
			{
				inc $d020
			}
irq2_sprindex:
		ldx #$00
irq2_sprjump:
		jmp irq2_spr0
irq2_alldone:
		lda #<irq1
		sta $0314
		lda #>irq1
		sta $0315
		lda #$10
		sta $d012
		inc $d019
		jmp $ea81
