.var maxspr = $1f
.var sort = $02

ldx 3$00
loop: txa
sta sort,x
inx
cpx maxspr+1
bne loop

ypos = $c000
ybuf = $22
xpos = $42
ybuf = $c020
xmsb = $c040
mbuf = $62
sprc = $82
sprp = $c080
pbuf = $af

jsr  movspr
jsr anim
jsr colors

ldx #$00
loop1: ldy sort+1,x
loop2: lda ypos,y
lda sort,x
cmp ypos,x
bcc  swap
inx
cpx maxspr+1
bne loop1
beq end

swap
lda sort+1,x
sta sort,x
sty sort+1,x
tay
dex
bpl loop2
inx
beq loop1

jsr setirq

main:    lda timer     ;wait for signal, that the buffer swap is complete.
        sta mloop+1   
mloop:   lda +      
        beq mloop

        jsr movspr    ;move sprites 
        jsr anim      ;animate sprites
        jsr color     ;animate colors
cont:    jmp main      ;loop

setirq:
      sei            ;set interrupt disable
      lda #$1b
      sta $d011      ;raster irq to 1st half of screen.
      lda #$fb
      sta $d012      ;irq to happen at line #$fb
      lda #<irq0
      sta $fffe      ;hardware irq vector low byte
      lda #>irq0
      sta $ffff      ;hardware irq vector high byte
      lda #$1f
      sta $dc0d      ;turn off all types of cia irq/nmi.
      sta $dd0d
      lda #$01
      sta $d01a      ;turn on raster irq.
      lda #$35
      sta $01        ;no basic or kernal
      lda $dc0d      ;acknowledge any irq that has occured during setup.
      lda $dd0d
      inc $d019
      cli            ;clear interrupt disable
      rts            ;return from subroutine


irq0:
      pha            ;use stack instead of zp to prevent bugs.
      txa
      pha
      tya
      pha
      inc $d019      ;acknowledge irq
      ldx #$03       ;wait a few cycles
l1:    dex
      bpl
      inx
      stx $d015      ;sprites off = more raster time in top/bottom border

slop:  ldy sort+1,x   ;main index sort algo
slep:  lda ypos,y
      ldy sort,x     ;this sorter uses the previous frame as a prediction buffer.
      cmp ypos,y     ;as y position does not change much from frame to frame.
      bcc swap       ;otherwise, it is a simple swap sort.
      inx            ;our linked list (sort) is sorted in decending order, according
      cpx #maxspr-1  ;to sprite y positions.
      bne slop
      beq end
swap: 
      lda sort+1,x
      sta sort,x
      sty sort+1,x
      tay
      dex
      bpl slep
      inx
      beq slop
end:

      ldy sort      ;re arrange frame buffers, into the raster buffers.
      lda ypos,y    ;this is unrolled for speed.
      sta ybuf      ;this allows us to use only 1 index pointer for our sprite plotter.
      lda xpos,y    ;it is double buffered, to allow runtime code to calculate the sprite
      sta xbuf      ;positions.
      lda xmsb,y
      sta mbuf
      lda sprc,y
      sta cbuf
      lda sprp,y
      sta pbuf

      ldy sort+1
      lda ypos,y
      sta ybuf+1
      lda xpos,y
      sta xbuf+1
      lda xmsb,y
      sta mbuf+1
      lda sprc,y
      sta cbuf+1
      lda sprp,y
      sta pbuf+1

      ldx #$00     ;find # of used sprites (you can remove sprites by
      stx sptr     ;placing #$ff into the ypos buffer for the corresponding
maxc:  lda ybuf,x   ;sprite. It will not be displayed by the raster routine.
      cmp #$ff
      beq mxs
      inx
      cpx maxspr
      bne maxc
maxs:  stx cnt      ;max sprites this frame count.
      cpx #$07     ;check if were doing more than 8
      bcc maxm     ;if not, we want the plotter to stop after 1 irq.
      ldx #$07     
maxm:  stx mnt

      lda #$ff    ;reset sprites to off screen.
      sta $d001   ;prevents bugs.
      sta $d003
      sta $d005
      sta $d007
      sta $d009
      sta $d00b
      sta $d00d
      sta $d00f

      inc lsbtod   ;buffers are swapped, so we can do the next frame now.

      lda #<irq1   ;irq chain for raster code. prolly want a routine before
      sta $fffe    ;this one, to turn the sprites back on ;)
      lda #>irq1   ;i.e. lda #$ff sta $d015
      sta $ffff
      lda #$28
      sta $d012
      jmp eirq
irq1:
      pha           ;save registers
      txa
      pha
      tya
      pha
      inc $d019     ;acknowledge irq
      ldx sptr      ;get current sprite index
hlop1: lda ybuf,x    ;get sprite y position
      sta $d001     ;store sprite y postion.
      lda xbuf,x    ;get sprite x position.
      sta $d000     ;sta sprite x position.
      lda mbuf,x    ;get sprite x position msb
      bne no1       ;set msb register
      lda $d010
      ora #%00000001
      bne yes1
no1:   lda $d010
      and #%11111110
yes1:  sta $d010
      lda pbuf,x    ;get sprite image pointer
      sta $63f8     ;store it, double buffered screen.
      sta $67f8
      lda cbuf,x    ;get sprite color
      sta $d027     ;store sprite color
      inx           ;next sprite index
      cpx mnt       ;lets go to next plot, if < then 8 yet.
      bcc hlop2
      cpx cnt       ;no more sprites?
      bne ok1
      jmp done      ;no more sprites.

ok1:   stx sptr      ;save sprite index
      lda $d003     ;get last position of next sprite
      clc
      adc #$15      ;add 21 lines
      cmp $d012     ;we there yet?
      bcc hlop2     ;yeah, so plot next sprite
      adc #$02      ;no, so calculate next irq position (+3)
      sta $d012     ;set it
      lda #<irq2    ;irq for next sprite.
      sta $fffe
      lda #>irq2
      sta $ffff
      jmp eirq

irq2:
      pha           ;and so on
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop2: lda ybuf,x
      sta $d003
      lda xbuf,x
      sta $d002
      lda mbuf,x
      bne no2
      lda $d010
      ora #%00000010
      bne yes2
no2:   lda $d010
      and #%11111101
yes2:  sta $d010
      lda pbuf,x
      sta $63f9
      sta $67f9
      lda cbuf,x
      sta $d028
      inx
      cpx mnt
      bcc hlop3
      cpx cnt
      bne ok2
      jmp done

ok2:   stx sptr
      lda $d005
      clc
      adc #$15
      cmp $d012
      bcc hlop3
      adc #$02
      sta $d012
      lda #<irq3
      sta $fffe
      lda #>irq3
      sta $ffff
      jmp eirq

irq3:
      pha
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop3: lda ybuf,x
      sta $d005
      lda xbuf,x
      sta $d004
      lda mbuf,x
      bne no3
      lda $d010
      ora #%00000100
      bne yes3
no3:   lda $d010
      and #%11111011
yes3:  sta $d010
      lda pbuf,x
      sta $63fa
      sta $67fa
      lda cbuf,x
      sta $d029
      inx
      cpx mnt
      bcc hlop4
      cpx cnt
      bne ok3
      jmp done

ok3:   stx sptr
      lda $d007
      clc
      adc #$15
      cmp $d012
      bcc hlop4
      adc #$02
      sta $d012
      lda #<irq4
      sta $fffe
      lda #>irq4
      sta $ffff
      jmp eirq

irq4:  
      pha
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop4: lda ybuf,x
      sta $d007
      lda xbuf,x
      sta $d006
      lda mbuf,x
      bne no4
      lda $d010
      ora #%00001000
      bne yes4
no4:   lda $d010
      and #%11110111
yes4:  sta $d010
      lda pbuf,x
      sta $63fb
      sta $67fb
      lda cbuf,x
      sta $d02a
      inx
      cpx mnt
      bcc hlop5
      cpx cnt
      bne ok4
      jmp done

ok4:   stx sptr
      lda $d009
      clc
      adc #$15
      cmp $d012
      bcc hlop5
      adc #$02
      sta $d012
      lda #<irq5
      sta $fffe
      lda #>irq5
      sta $ffff
      jmp eirq

irq5:
      pha
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop5: lda ypos,x
      sta $d009
      lda xpos,x
      sta $d008
      lda mbuf,x
      bne no5
      lda $d010
      ora #%00010000
      bne yes5
no5:   lda $d010
      and #%11101111
yes5:  sta $d010
      lda pbuf,x
      sta $63fc
      sta $67fc
      lda cbuf,x
      sta $d02b
      inx
      cpx mnt
      bcc hlop6
      cpx cnt
      bne ok5
      jmp done

ok5:   stx sptr
      lda $d00b
      clc
      adc #$15
      cmp $d012
      bcc hlop6
      adc #$02
      sta $d012
      lda #<irq6
      sta $fffe
      lda #>irq6
      sta $ffff
      jmp eirq

irq6:
      pha
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop6: lda ybuf,x
      sta $d00b
      lda xbuf,x
      sta $d00a
      lda mbuf,x
      bne no6
      lda $d010
      ora #%00100000
      bne yes6
no6:   lda $d010
      and #%11011111
yes6:  sta $d010
      lda pbuf,x
      sta $63fd
      sta $67fd
      lda cbuf,x
      sta $d02c
      inx
      cpx mnt
      bcc hlop7
      cpx cnt
      bne ok6
      jmp done

ok6:   stx sptr
      lda $d00d
      clc
      adc #$15
      cmp $d012
      bcc hlop7
      adc #$02
      sta $d012
      lda #<irq7
      sta $fffe
      lda #>irq7
      sta $ffff
      jmp eirq

irq7:
      pha
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop7: lda ybuf,x
      sta $d00d
      lda xbuf,x
      sta $d00c
      lda mbuf,x
      bne no7
      lda $d010
      ora #%01000000
      bne yes7
no7:   lda $d010
      and #%10111111
yes7:  sta $d010
      lda pbuf,x
      sta $63fe
      sta $67fe
      lda cbuf,x
      sta $d02d
      inx
      cpx mnt
      bcc hlop8
      cpx cnt
      bne ok7
      jmp done

ok7:   stx sptr
      lda $d00f
      clc
      adc #$15
      cmp $d012
      bcc hlop8
      adc #$02
      sta $d012
      lda #<irq8
      sta $fffe
      lda #>irq8
      sta $ffff
      jmp eirq

irq8: 
      pha
      txa
      pha
      tya
      pha
      inc $d019
      ldx sptr
hlop8: lda ybuf,x
      sta $d00f
      lda xbuf,x
      sta $d00e
      lda mbuf,x
      bne no8
      lda $d010
      ora #%10000000
      bne yes8
no8:   lda $d010
      and #%01111111
yes8:  sta $d010
      lda pbuf,x
      sta $63ff
      sta $67ff
      lda cbuf,x
      sta $d02e
      inx
      cpx mnt
      bcc hlop9
      cpx cnt
      bne ok8
      jmp done

ok8:   stx sptr
      lda $d001
      clc
      adc #$15
      cmp $d012
      bcc hlop9
      adc #$02
      sta $d012
      lda #<irq1
      sta $fffe
      lda #>irq1
      sta $ffff
      jmp eirq
hlop9: jmp hlop1

done:  lda #<irq0
      sta $fffe
      lda #>irq0
      sta $ffff
      lda #$fb
      sta $d012
eirq:
      pla
      tay
      pla
      tax
      pla
      rti


