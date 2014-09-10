//---------------------------------------
//New Multiplexer Engine
//24 sprite version
//
//Written by Fungus in 2005
//---------------------------------------

         .pc = $801
	:BasicUpstart($0810)

.var xofs     = $06          //x position
                        //offset
.var yofs     = $06          //x position
                        //offset
.var ysin     = $3800

.var sort     = $02          //index
.var ybuf     = $1a          //y position
.var xbuf     = $32          //x position
.var mbuf     = $0800        //msb of x
.var pbuf     = $4a          //image pointer
.var cbuf     = $52   //-$69  //color value

.var maxspr   = $18          //24 sprites

setup:
         sei
         cld
         lda #<irq0
         ldx #>irq0
         sta $fffe
         stx $ffff
dec $d020
         lda #<crap
         ldx #>crap
         sta $fffa
         sta $fffc
         stx $fffb
         stx $fffd

         lda #$01
         ldx #$fb
         sta $d01a
         stx $d012

         lda #$1b
         sta $d011

         lda #$7f
         sta $dc0d

         ldx #$17     //init index tab
isort:    txa
         sta sort,x
         dex
         bpl isort

         jsr move     //init first frame
         jsr super

         lda #$35
         sta $01

         bit $dc0d
         inc $d019


         cli

//this routine in realtime

main:
dec $d020

sw2:      lda #$00
         bne nomove

         jsr move       //move sprites
         jsr super
nomove:
         jmp main


super:    ldx #$00       //super swap
a0:       ldy sort+1,x   //remember sort
a1:       lda ybuf,y
         ldy sort,x
         cmp ybuf,y
         bcc swap
         inx
         cpx #maxspr-1
         bne a0
         beq send
swap:     lda sort+1,x
         sta sort,x
         sty sort+1,x
         dex
         bpl a1
         inx
         beq a1
send:     inc sw1+1      //ok to swap!
         rts


//this routine inside irq

irq0:
         pha
         txa
         pha
         tya
         pha

sw1:      lda #$00       //ok to swap?
         bne doit
         jmp skipit

doit:     dec sw1+1
         inc sw2+1      //tell main to
                        //wait

         ldx idx        //reset end of
                        //irq chain
         lda entab,x
         sta ren+1
         lda entab+1,x
         sta ren+2
         lda #$00
ren:      sta $1111

nrt:      ldy #$00       //mod irqs
         sty msb        //sprite values
                        //according to
                        //index table

         ldx sort+0
         lda ybuf,x
         sta y1+1
         pha
         clc
         adc #$15
         sta r8+1
         lda xbuf,x
         sta x1+1
         lda mbuf,x
         bne no1
         lda msb
         ora ortab,y
         bne ye1
no1:      lda msb
         and antab,y
ye1:      sta m1+1
         lda pbuf,x
         sta p1+1
         lda cbuf,x
         sta c1+1
         iny
         ldx sort+1
         lda ybuf,x
         sta y2+1
         pha
         clc
         adc #$15
         sta r9+1
         lda xbuf,x
         sta x2+1
         lda mbuf,x
         bne no2
         lda msb
         ora ortab,y
         bne ye2
no2:      lda msb
         and antab,y
ye2:      sta m2+1
         lda pbuf,x
         sta p2+1
         lda cbuf,x
         sta c2+1
         iny
         ldx sort+2
         lda ybuf,x
         sta y3+1
         pha
         clc
         adc #$15
         sta r10+1
         lda xbuf,x
         sta x3+1
         lda mbuf,x
         bne no3
         lda msb
         ora ortab,y
         bne ye3
no3:      lda msb
         and antab,y
ye3:      sta m3+1
         lda pbuf,x
         sta p3+1
         lda cbuf,x
         sta c3+1
         iny
         ldx sort+3
         lda ybuf,x
         sta y4+1
         pha
         clc
         adc #$15
         sta r11+1
         lda xbuf,x
         sta x4+1
         lda mbuf,x
         bne no4
         lda msb
         ora ortab,y
         bne ye4
no4:      lda msb
         and antab,y
ye4:      sta m4+1
         lda pbuf,x
         sta p4+1
         lda cbuf,x
         sta c4+1
         iny
         ldx sort+4
         lda ybuf,x
         sta y5+1
         pha
         clc
         adc #$15
         sta r12+1
         lda xbuf,x
         sta x5+1
         lda mbuf,x
         bne no5
         lda msb
         ora ortab,y
         bne ye5
no5:      lda msb
         and antab,y
ye5:      sta m5+1
         lda pbuf,x
         sta p5+1
         lda cbuf,x
         sta c5+1
         iny
         ldx sort+5
         lda ybuf,x
         sta y6+1
         pha
         clc
         adc #$15
         sta r13+1
         lda xbuf,x
         sta x6+1
         lda mbuf,x
         bne no6
         lda msb
         ora ortab,y
         bne ye6
no6:      lda msb
         and antab,y
ye6:      sta m6+1
         lda pbuf,x
         sta p6+1
         lda cbuf,x
         sta c6+1
         iny
         ldx sort+6
         lda ybuf,x
         sta y7+1
         pha
         clc
         adc #$15
         sta r14+1
         lda xbuf,x
         sta x7+1
         lda mbuf,x
         bne no7
         lda msb
         ora ortab,y
         bne ye7
no7:      lda msb
         and antab,y
ye7:      sta m7+1
         lda pbuf,x
         sta p7+1
         lda cbuf,x
         sta c7+1
         iny
         ldx sort+7
         lda ybuf,x
         sta y8+1
         pha
         clc
         adc #$15
         sta r15+1
         lda xbuf,x
         sta x8+1
         lda mbuf,x
         bne no8
         lda msb
         ora ortab,y
         bne ye8
no8:      lda msb
         and antab,y
ye8:      sta m8+1
         lda pbuf,x
         sta p8+1
         lda cbuf,x
         sta c8+1
         ldy #$00
         ldx sort+8
         lda ybuf,x
         sta y9+1
         pha
         clc
         adc #$15
         sta r16+1
         lda xbuf,x
         sta x9+1
         lda mbuf,x
         bne no9
         lda msb
         ora ortab,y
         bne ye9
no9:      lda msb
         and antab,y
ye9:      sta m9+1
         lda pbuf,x
         sta p9+1
         lda cbuf,x
         sta c9+1
         iny
         ldx sort+10
         lda ybuf,x
         sta y10+1
         pha
         clc
         adc #$15
         sta r17+1
         lda xbuf,x
         sta x10+1
         lda mbuf,x
         bne no10
         lda msb
         ora ortab,y
         bne ye10
no10:     lda msb
         and antab,y
ye10:     sta m10+1
         lda pbuf,x
         sta p10+1
         lda cbuf,x
         sta c10+1
         iny
         ldx sort+10
         lda ybuf,x
         sta y11+1
         pha
         clc
         adc #$15
         sta r18+1
         lda xbuf,x
         sta x11+1
         lda mbuf,x
         bne no11
         lda msb
         ora ortab,y
         bne ye11
no11:     lda msb
         and antab,y
ye11:     sta m11+1
         lda pbuf,x
         sta p11+1
         lda cbuf,x
         sta c11+1
         iny
         ldx sort+11
         lda ybuf,x
         sta y12+1
         pha
         clc
         adc #$15
         sta r19+1
         lda xbuf,x
         sta x12+1
         lda mbuf,x
         bne no12
         lda msb
         ora ortab,y
         bne ye12
no12:     lda msb
         and antab,y
ye12:     sta m12+1
         lda pbuf,x
         sta p12+1
         lda cbuf,x
         sta c12+1
         iny
         ldx sort+12
         lda ybuf,x
         sta y13+1
         pha
         clc
         adc #$15
         sta r20+1
         lda xbuf,x
         sta x13+1
         lda mbuf,x
         bne no13
         lda msb
         ora ortab,y
         bne ye13
no13:     lda msb
         and antab,y
ye13:     sta m13+1
         lda pbuf,x
         sta p13+1
         lda cbuf,x
         sta c13+1
         iny
         ldx sort+13
         lda ybuf,x
         sta y14+1
         pha
         clc
         adc #$15
         sta r21+1
         lda xbuf,x
         sta x14+1
         lda mbuf,x
         bne no14
         lda msb
         ora ortab,y
         bne ye14
no14:     lda msb
         and antab,y
ye14:    sta m14+1
         lda pbuf,x
         sta p14+1
         lda cbuf,x
         sta c14+1
         iny
         ldx sort+14
         lda ybuf,x
         sta y15+1
         pha
         clc
         adc #$15
         sta r22+1
         lda xbuf,x
         sta x15+1
         lda mbuf,x
         bne no15
         lda msb
         ora ortab,y
         bne ye15
no15:     lda msb
         and antab,y
ye15:     sta m15+1
         lda pbuf,x
         sta p15+1
         lda cbuf,x
         sta c15+1
         iny
         ldx sort+15
         lda ybuf,x
         sta y16+1
         pha
         clc
         adc #$15
         sta r23+1
         lda xbuf,x
         sta x16+1
         lda mbuf,x
         bne no16
         lda msb
         ora ortab,y
         bne ye16
no16:     lda msb
         and antab,y
ye16:     sta m16+1
         lda pbuf,x
         sta p16+1
         lda cbuf,x
         sta c16+1
         ldy #$00
         ldx sort+16
         lda ybuf,x
         sta y17+1
         pha
         lda xbuf,x
         sta x17+1
         lda mbuf,x
         bne no17
         lda msb
         ora ortab,y
         bne ye17
no17:     lda msb
         and antab,y
ye17:     sta m17+1
         lda pbuf,x
         sta p17+1
         lda cbuf,x
         sta c17+1
         iny
         ldx sort+17
         lda ybuf,x
         sta y18+1
         pha
         lda xbuf,x
         sta x18+1
         lda mbuf,x
         bne no18
         lda msb
         ora ortab,y
         bne ye18
no18:     lda msb
         and antab,y
ye18:     sta m18+1
         lda pbuf,x
         sta p18+1
         lda cbuf,x
         sta c18+1
         iny
         ldx sort+18
         lda ybuf,x
         sta y19+1
         pha
         lda xbuf,x
         sta x19+1
         lda mbuf,x
         bne no19
         lda msb
         ora ortab,y
         bne ye19
no19:     lda msb
         and antab,y
ye19:     sta m19+1
         lda pbuf,x
         sta p19+1
         lda cbuf,x
         sta c19+1
         iny
         ldx sort+19
         lda ybuf,x
         sta y20+1
         pha
         lda xbuf,x
         sta x20+1
         lda mbuf,x
         bne no20
         lda msb
         ora ortab,y
         bne ye20
no20:     lda msb
         and antab,y
ye20:     sta m20+1
         lda pbuf,x
         sta p20+1
         lda cbuf,x
         sta c20+1
         iny
         ldx sort+20
         lda ybuf,x
         sta y21+1
         pha
         lda xbuf,x
         sta x21+1
         lda mbuf,x
         bne no21
         lda msb
         ora ortab,y
         bne ye21
no21:     lda msb
         and antab,y
ye21:     sta m21+1
         lda pbuf,x
         sta p21+1
         lda cbuf,x
         sta c21+1
         iny
         ldx sort+21
         lda ybuf,x
         sta y22+1
         pha
         lda xbuf,x
         sta x22+1
         lda mbuf,x
         bne no22
         lda msb
         ora ortab,y
         bne ye22
no22:     lda msb
         and antab,y
ye22:     sta m22+1
         lda pbuf,x
         sta p22+1
         lda cbuf,x
         sta c22+1
         iny
         ldx sort+22
         lda ybuf,x
         sta y23+1
         pha
         lda xbuf,x
         sta x23+1
         lda mbuf,x
         bne no23
         lda msb
         ora ortab,y
         bne ye23
no23:     lda msb
         and antab,y
ye23:     sta m23+1
         lda pbuf,x
         sta p23+1
         lda cbuf,x
         sta c23+1
         iny
         ldx sort+23
         lda ybuf,x
         sta y24+1
         pha
         lda xbuf,x
         sta x24+1
         lda mbuf,x
         bne no24
         lda msb
         ora ortab,y
         bne ye24
no24:     lda msb
         and antab,y
ye24:     sta m24+1
         lda pbuf,x
         sta p24+1
         lda cbuf,x
         sta c24+1

         ldx #$18     //find count
cnt1:     dex
         bmi none
         pla
         beq cnt1
         txa
         sta $fb      //sprite count

rest:     pla
         dex
         bpl rest
none:
         lda $fb      //set end of chain
         asl          //*2
         tax
         stx idx      //save for next
         lda entab,x  //frame
         sta sen+1
         lda entab+1,x
         sta sen+2
         lda #$01
sen:      sta $1111    //self modded

         dec sw2+1    //ok to move
                      //again

skipit:
         lda #$2d
         sta $d012
         lda #<irq1
         sta $fffe
         lda #>irq1
         sta $ffff
         inc $d019
         pla
         tay
         pla
         tax
         pla
         rti
irq1:

         pha
         inc $d019

         lda #$ff
         sta $d015

y1:       lda #$00
         sta $d001
x1:       lda #$00
         sta $d000
m1:       lda #$00
         sta $d010
p1:       lda #$00
         sta $63f8
         sta $67f8
c1:       lda #$00
         sta $d027
e1:       lda #$00
         beq s1
         jmp end
s1:
y2:       lda #$00
         sta $d003
x2:       lda #$00
         sta $d002
m2:       lda #$00
         sta $d010
p2:       lda #$00
         sta $63f9
         sta $67f9
c2:       lda #$00
         sta $d028
e2:       lda #$00
         beq s2
         jmp end
s2:
y3:       lda #$00
         sta $d005
x3:       lda #$00
         sta $d004
m3:       lda #$00
         sta $d010
p3:       lda #$00
         sta $63fa
         sta $67fa
c3:       lda #$00
         sta $d029
e3:       lda #$00
         beq s3
         jmp end
s3:
y4:       lda #$00
         sta $d007
x4:       lda #$00
         sta $d006
m4:       lda #$00
         sta $d010
p4:       lda #$00
         sta $63fb
         sta $67fb
c4:       lda #$00
         sta $d02a
e4:       lda #$00
         beq s4
         jmp end
s4:
y5:       lda #$00
         sta $d009
x5:       lda #$00
         sta $d008
m5:       lda #$00
         sta $d010
p5:       lda #$00
         sta $63fc
         sta $67fc
c5:       lda #$00
         sta $d02b
e5:       lda #$00
         beq s5
         jmp end
s5:
y6:       lda #$00
         sta $d00b
x6:       lda #$00
         sta $d00a
m6:       lda #$00
         sta $d010
p6:       lda #$00
         sta $63fd
         sta $67fd
c6:       lda #$00
         sta $d02c
e6:       lda #$00
         beq s6
         jmp end
s6:
y7:       lda #$00
         sta $d00d
x7:       lda #$00
         sta $d00c
m7:       lda #$00
         sta $d010
p7:       lda #$00
         sta $63fe
         sta $67fe
c7:       lda #$00
         sta $d02d
e7:       lda #$00
         beq s7
         jmp end
s7:
y8:       lda #$00
         sta $d00f
x8:       lda #$00
         sta $d00e
m8:       lda #$00
         sta $d010
p8:       lda #$00
         sta $63ff
         sta $67ff
c8:       lda #$00
         sta $d02e
e8:       lda #$00
         beq s8
         jmp end
s8:
         lda #$00
         bne y9
r8:       lda #$00
         sta $d012
         lda #<irq2
         sta $fffe
         lda #>irq2
         sta $ffff
         pla
         rti
irq2:
         pha
         inc $d019

y9:       lda #$00
         sta $d001
x9:       lda #$00
         sta $d000
m9:       lda #$00
         sta $d010
p9:       lda #$00
         sta $63f8
         sta $67f8
c9:      lda #$00
         sta $d027
e9:       lda #$00
         beq s9
         jmp end
s9:

         lda #$00
         bne y10
r9:       lda #$00
         sta $d012
         lda #<irq3
         sta $fffe
         lda #>irq3
         sta $ffff
         pla
         rti
irq3:
         pha
         inc $d019

y10:      lda #$00
         sta $d003
x10:      lda #$00
         sta $d002
m10:      lda #$00
         sta $d010
p10:      lda #$00
         sta $63f9
         sta $67f9
c10:      lda #$00
         sta $d028
e10:      lda #$00
         beq s10
         jmp end
s10:
         lda #$00
         bne y11
r10:      lda #$00
         sta $d012
         lda #<irq4
         sta $fffe
         lda #>irq4
         sta $ffff
         pla
         rti
irq4:
         pha
         inc $d019

y11:      lda #$00
         sta $d005
x11:      lda #$00
         sta $d004
m11:      lda #$00
         sta $d010
p11:      lda #$00
         sta $63fa
         sta $67fa
c11:      lda #$00
         sta $d029
e11:      lda #$00
         beq s11
         jmp end
s11:
         lda #$00
         bne y12
r11:      lda #$00
         sta $d012
         lda #<irq5
         sta $fffe
         lda #>irq5
         sta $ffff
         pla
         rti
irq5:
         pha
         inc $d019

y12:      lda #$00
         sta $d007
x12:      lda #$00
         sta $d006
m12:      lda #$00
         sta $d010
p12:      lda #$00
         sta $63fb
         sta $67fb
c12:      lda #$00
         sta $d02a
e12:      lda #$00
         beq s12
         jmp end
s12:
         lda #$00
         bne y14
r12:      lda #$00
         sta $d012
         lda #<irq6
         sta $fffe
         lda #>irq6
         sta $ffff
         pla
         rti
irq6:
         pha
         inc $d019

y13:      lda #$00
         sta $d009
x13:      lda #$00
         sta $d008
m13:      lda #$00
         sta $d010
p13:      lda #$00
         sta $63fc
         sta $67fc
c13:      lda #$00
         sta $d02b
e13:      lda #$00
         beq s13
         jmp end
s13:
         lda #$00
         bne y15
r13:      lda #$00
         sta $d012
         lda #<irq7
         sta $fffe
         lda #>irq7
         sta $ffff
         pla
         rti
irq7:
         pha
         inc $d019

y14:      lda #$00
         sta $d00b
x14:      lda #$00
         sta $d00a
m14:      lda #$00
         sta $d010
p14:      lda #$00
         sta $63fd
         sta $67fd
c14:      lda #$00
         sta $d02c
e14:      lda #$00
         beq s14
         jmp end
s14:
         lda #$00
         bne y16
r14:      lda #$00
         sta $d012
         lda #<irq8
         sta $fffe
         lda #>irq8
         sta $ffff
         pla
         rti
irq8:
         pha
         inc $d019

y15:      lda #$00
         sta $d00d
x15:      lda #$00
         sta $d00c
m15:      lda #$00
         sta $d010
p15:      lda #$00
         sta $63fe
         sta $67fe
c15:      lda #$00
         sta $d02d
e15:      lda #$00
         beq s15
         jmp end
s15:
         lda #$00
         bne y17
r15:     lda #$00
         sta $d012
         lda #<irq9
         sta $fffe
         lda #>irq9
         sta $ffff
         pla
         rti
irq9:
         pha
         inc $d019

y16:      lda #$00
         sta $d00f
x16:      lda #$00
         sta $d00e
m16:      lda #$00
         sta $d010
p16:      lda #$00
         sta $63ff
         sta $67ff
c16:      lda #$00
         sta $d02e
e16:      lda #$00
         beq s16
         jmp end
s16:
         lda #$00
         bne y17
r16:      lda #$00
         sta $d012
         lda #<irqa
         sta $fffe
         lda #>irqa
         sta $ffff
         pla
         rti

irqa:
         pha
         inc $d019

y17:      lda #$00
         sta $d001
x17:      lda #$00
         sta $d000
m17:      lda #$00
         sta $d010
p17:      lda #$00
         sta $63f8
         sta $67f8
c17:      lda #$00
         sta $d027
e17:      lda #$00
         beq s17
         jmp end
s17:

         lda #$00
         bne y18
r17:      lda #$00
         sta $d012
         lda #<irqb
         sta $fffe
         lda #>irqb
         sta $ffff
         pla
         rti
irqb:
         pha
         inc $d019

y18:      lda #$00
         sta $d003
x18:      lda #$00
         sta $d002
m18:      lda #$00
         sta $d010
p18:      lda #$00
         sta $63f9
         sta $67f9
c18:      lda #$00
         sta $d028
e18:      lda #$00
         beq s18
         jmp end
s18:
         lda #$00
         bne y19
r18:      lda #$00
         sta $d012
         lda #<irqc
         sta $fffe
         lda #>irqc
         sta $ffff
         pla
         rti
irqc:
         pha
         inc $d019

y19:      lda #$00
         sta $d005
x19:      lda #$00
         sta $d004
m19:      lda #$00
         sta $d010
p19:      lda #$00
         sta $63fa
         sta $67fa
c19:      lda #$00
         sta $d029
e19:      lda #$00
         beq s19
         jmp end
s19:
         lda #$00
         bne y20
r19:      lda #$00
         sta $d012
         lda #<irqd
         sta $fffe
         lda #>irqd
         sta $ffff
         pla
         rti
irqd:
         pha
         inc $d019

y20:      lda #$00
         sta $d007
x20:      lda #$00
         sta $d006
m20:      lda #$00
         sta $d010
p20:      lda #$00
         sta $63fb
         sta $67fb
c20:      lda #$00
         sta $d02a
e20:      lda #$00
         beq s20
         jmp end
s20:
         lda #$00
         bne y21
r20:      lda #$00
         sta $d012
         lda #<irqe
         sta $fffe
         lda #>irqe
         sta $ffff
         pla
         rti
irqe:
         pha
         inc $d019

y21:      lda #$00
         sta $d009
x21:      lda #$00
         sta $d008
m21:      lda #$00
         sta $d010
p21:      lda #$00
         sta $63fc
         sta $67fc
c21:      lda #$00
         sta $d02b
e21:      lda #$00
         beq s21
         jmp end
s21:
         lda #$00
         bne y22
r21:      lda #$00
         sta $d012
         lda #<irqf
         sta $fffe
         lda #>irqf
         sta $ffff
         pla
         rti
irqf:
         pha
         inc $d019

y22:      lda #$00
         sta $d00b
x22:      lda #$00
         sta $d00a
m22:      lda #$00
         sta $d010
p22:      lda #$00
         sta $63fd
         sta $67fd
c22:      lda #$00
         sta $d02c
e22:      lda #$00
         beq s22
         jmp end
s22: 
         lda #$00
         bne y23
r22:      lda #$00
         sta $d012
         lda #<irqg
         sta $fffe
         lda #>irqg
         sta $ffff
         pla
         rti
irqg:
         pha
         inc $d019

y23:      lda #$00
         sta $d00d
x23:      lda #$00
         sta $d00c
m23:      lda #$00
         sta $d010
p23:      lda #$00
         sta $63fe
         sta $67fe
c23:      lda #$00
         sta $d02d
e23:      lda #$00
         beq s23
         jmp end
s23:
         lda #$00
         bne y24
r23:      lda #$00
         sta $d012
         lda #<irqh
         sta $fffe
         lda #>irqh
         sta $ffff
         pla
         rti
irqh:
         pha
         inc $d019

y24:      lda #$00
         sta $d00f
x24:      lda #$00
         sta $d00e
m24:      lda #$00
         sta $d010
p24:      lda #$00
         sta $63ff
         sta $67ff
c24:      lda #$00
         sta $d02e
                      //end here
e24:      lda #$00
end:      lda #$00
         sta $d012
         lda #<irq0
         sta $fffe
         lda #>irq0
         sta $ffff
         pla
crap:     rti

idx:      .byte $ff
msb:      .byte $ff

ortab:
         .byte %10000000
         .byte %01000000
         .byte %00100000
         .byte %00010000
         .byte %00001000
         .byte %00000100
         .byte %00000010
         .byte %00000001
antab:
         .byte %01111111
         .byte %10111111
         .byte %11011111
         .byte %11101111
         .byte %11110111
         .byte %11111011
         .byte %11111101
         .byte %11111110

.var en01 =  e1+1
.var en02 = e2+1
.var en03  =   e3+1
.var en04  =     e4+1
.var en05  =     e5+1
.var en06  =     e6+1
.var en07  =     e7+1
.var en08  =     e8+1
.var en09 =      e9+1
.var en10 =      e10+1
.var en11 =      e11+1
.var en12 =      e12+1
.var en13 =      e13+1
.var en14 =      e14+1
.var en15 =      e15+1
.var en16 =      e16+1
.var en17 =      e17+1
.var en18 =      e18+1
.var en19 =      e19+1
.var en20 =      e20+1
.var en21 =      e21+1
.var en22 =      e22+1
.var en23 =      e23+1
.var en24 =      e24+1

entab:
         .byte <en01,>en01
         .byte <en02,>en02
         .byte <en03,>en03
         .byte <en04,>en04
         .byte <en05,>en05
         .byte <en06,>en06
         .byte <en07,>en07
         .byte <en08,>en08
         .byte <en09,>en09
         .byte <en10,>en10
         .byte <en11,>en11
         .byte <en12,>en12
         .byte <en13,>en13
         .byte <en14,>en14
         .byte <en15,>en15
         .byte <en16,>en16
         .byte <en17,>en17
         .byte <en18,>en18
         .byte <en19,>en19
         .byte <en20,>en20
         .byte <en21,>en21
         .byte <en22,>en22
         .byte <en23,>en23
         .byte <en24,>en24


//---------------------------------------
//sprite movement

move:

//plot y

j1:       lda ysin
         sta ybuf
j2:       lda ysin+yofs
         sta ybuf+1
j3:       lda ysin+[yofs*2]
         sta ybuf+2
j4:       lda ysin+[yofs*3]
         sta ybuf+3
j5:       lda ysin+[yofs*4]
         sta ybuf+4
j6:       lda ysin+[yofs*5]
         sta ybuf+5
j7:       lda ysin+[yofs*6]
         sta ybuf+6
j8:       lda ysin+[yofs*7]
         sta ybuf+7
j9:       lda ysin+[yofs*8]
         sta ybuf+8
j10:      lda ysin+[yofs*9]
         sta ybuf+9
j11:      lda ysin+[yofs*10]
         sta ybuf+10
j12:      lda ysin+[yofs*11]
         sta ybuf+11
j13:      lda ysin+[yofs*12]
         sta ybuf+12
j14:      lda ysin+[yofs*13]
         sta ybuf+13
j15:      lda ysin+[yofs*14]
         sta ybuf+14
j16:      lda ysin+[yofs*15]
         sta ybuf+15
j17:      lda ysin+[yofs*16]
         sta ybuf+16
j18:      lda ysin+[yofs*17]
         sta ybuf+17
j19:      lda ysin+ [yofs*18]
         sta ybuf+18
j20:      lda ysin+[yofs*19]
         sta ybuf+19
j21:      lda ysin+[yofs*20]
         sta ybuf+20
j22:      lda ysin+[yofs*21]
         sta ybuf+21
j23:      lda ysin+[yofs*22]
         sta ybuf+22
j24:      lda ysin+[yofs*23]
         sta ybuf+23
//plot x

k1:       lda #$00
         sta xbuf
k2:       lda #$00+xofs
         sta xbuf+1
k3:       lda #$00+[xofs*2]
         sta xbuf+2
k4:       lda #$00+[xofs*3]
         sta xbuf+3
k5:       lda #$00+[xofs*4]
         sta xbuf+4
k6:       lda #$00+[xofs*5]
         sta xbuf+5
k7:       lda #$00+[xofs*6]
         sta xbuf+6
k8:       lda #$00+[xofs*7]
         sta xbuf+7
k9:       lda #$00+[xofs*8]
         sta xbuf+8
k10:      lda #$00+[xofs*9]
         sta xbuf+9
k11:      lda #$00+[xofs*10]
         sta xbuf+10
k12:      lda #$00+[xofs*11]
         sta xbuf+11
k13:      lda #$00+[xofs*12]
         sta xbuf+12
k14:      lda #$00+[xofs*13]
         sta xbuf+13
k15:      lda #$00+[xofs*14]
         sta xbuf+14
k16:      lda #$00+[xofs*15]
         sta xbuf+15
k17:      lda #$00+[xofs*16]
         sta xbuf+16
k18:      lda #$00+[xofs*17]
         sta xbuf+17
k19:      lda #$00+[xofs*18]
         sta xbuf+18
k20:      lda #$00+[xofs*19]
         sta xbuf+19
k21:      lda #$00+[xofs*20]
         sta xbuf+20
k22:      lda #$00+[xofs*21]
         sta xbuf+21
k23:      lda #$00+[xofs*22]
         sta xbuf+22
k24:      lda #$00+[xofs*23]
         sta xbuf+23
k25:	 lda #$00+[xofs*24]
	sta xbuf +24

        //jmp cx
//move y
         inc j1+1
         inc j2+1
         inc j3+1
         inc j4+1
         inc j5+1
         inc j6+1
         inc j7+1
         inc j8+1
         inc j9+1
         inc j10+1
         inc j11+1
         inc j12+1
         inc j13+1
         inc j14+1
         inc j15+1
         inc j16+1
         inc j17+1
         inc j18+1
         inc j19+1
         inc j20+1
         inc j21+1
         inc j22+1
         inc j23+1
         inc j24+1
//move x
cx:
         dec k1+1
         dec k2+1
         dec k3+1
         dec k4+1
         dec k5+1
         dec k6+1
         dec k7+1
         dec k8+1
         dec k9+1
         dec k10+1
         dec k11+1
         dec k12+1
         dec k13+1
         dec k14+1
         dec k15+1
         dec k16+1
         dec k17+1
         dec k18+1
         dec k19+1
         dec k20+1
         dec k21+1
         dec k22+1
         dec k23+1
         dec k24+1

//scroll wrap

         ldx #$b0
         lda k1+1
         cmp #$ff
         bne n1
         stx k1+1
n1:       lda k2+1
         cmp #$ff
         bne n2
         stx k2+1
n2:       lda k3+1
         cmp #$ff
         bne n3
         stx k3+1
n3:       lda k4+1
         cmp #$ff
         bne n4
         stx k4+1
n4:       lda k5+1
         cmp #$ff
         bne n5
         stx k5+1
n5:       lda k6+1
         cmp #$ff
         bne n6
         stx k6+1
n6:       lda k7+1
         cmp #$ff
         bne n7
         stx k7+1
n7:       lda k8+1
         cmp #$ff
         bne n8
         stx k8+1
n8:       lda k9+1
         cmp #$ff
         bne n9
         stx k9+1
n9:       lda k10+1
         cmp #$ff
         bne n10
         stx k10+1
n10:      lda k11+1
         cmp #$ff
         bne n11
         stx k11+1
n11:      lda k12+1
         cmp #$ff
         bne n12
         stx k12+1
n12:      lda k13+1
         cmp #$ff
         bne n13
         stx k13+1
n13:      lda k14+1
         cmp #$ff
         bne n14
         stx k14+1
n14:      lda k15+1
         cmp #$ff
         bne n15
         stx k15+1
n15:      lda k16+1
         cmp #$ff
         bne n16
         stx k16+1
n16:      lda k17+1
         cmp #$ff
         bne n17
         stx k17+1
n17:      lda k18+1
         cmp #$ff
         bne n18
         stx k18+1
n18:      lda k19+1
         cmp #$ff
         bne n19
         stx k19+1
n19:      lda k20+1
         cmp #$ff
         bne n20
         stx k20+1
n20:      lda k21+1
         cmp #$ff
         bne n21
         stx k21+1
n21:      lda k22+1
         cmp #$ff
         bne n22
         stx k22+1
n22:      lda k23+1
         cmp #$ff
         bne n23
         stx k23+1
n23:      lda k24+1
         cmp #$ff
         bne n24
         stx k24+1
n24:      lda k25+1
         cmp #$ff
         bne n25
         stx k25+1
n25:
         rts
