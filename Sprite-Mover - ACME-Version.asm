!to "projekte\codes\Sprite-Mover.prg",cbm	
!cpu 6502

*=$0801						; Basic-Start
!byte $0b,$08,$d8,$07,$9e		; Werte für den Sysbefehl in einer Basic-Zeile
!convtab pet					; CBM-Zeichen Konvertierung
!text "49152"					; Startadresse (49152 = $c000)

;Sprites einbinden
 	*=$2000 
	!binary "...\Sprites.prg",,2	; Hier Verzeichnis eintagen wo sich die Sprites befinden

;---------------------------------------
; sprite mover
;---------------------------------------
; (c) in go kusch
; simonstr.9
; 4700 hamm 3
;tel:02381/464619
;---------------------------------------
; bereich:-x- : 456-480
; -------(480-456) clr!!!!
;-y- : 40-240
;---------------------------------------
;abkuerzungen:
; 'sr' - sprite routine
; (move-programm)
; 'sd' - sprite darstellung
; (sichtbarmachen der beerechneten
;sprites mit first & next)
; zw.sp. - zwischen speicher
; s.o. - siehe oben
; s.u. - siehe unten
; clr- clear = loeschen
; spr- sprite
; adr- adresse
; tab- tabelle
; trk- track
; nr - nummer
;? - bedingungen/abfragen
;! - befehle/anweisungen
;---------------------------------------

;--- sprite tabellen

base		= $4000
inittb		= base
xpos		= base+30		;position x
ypos		= base+60		;position y
block		= base+90 		;block nr
control		= base+120		;on/msb/color
deltax		= base+150		;bewegung -x-
deltay		= base+180		;    "    -y-
delay		= base+210		;countdown
sinxhi		= base+240		;sinus -x-
sinxlo		= base+270
sinx1		= base+300
sinx2		= base+330
sinx3		= base+360
sinyhi		= base+390		;sinus -y-
sinylo		= base+420
siny1		= base+450
siny2		= base+480
siny3		= base+520
anitb		= base+570		;animation
anico		= base+600
anitco		= base+630
speclo		= base+660		;special-prgs
spechi		= base+690
trklo		= base+720		;track count
trkhi		= base+750
trkpo		= base+780
acctx		= base+810		;beschleunigung-x-
accty		= base+840		;       "      -y-
acct1		= base+870		; " -zeit -x-
acct2		= base+900		; "   "   -y-
zwisch		= base+930		;beeliebig
zwisch2		= base+960		;nutzbar
zwisch3		= base+990		; "
zwisch4		= base+1020	; "

xpos2		= base+1050 	;für 'sd'
ypos2		= base+1080 	;notwendige
control2		= base+1110	;zwischen tabs
block2		= base+1140

ytab		= base+$0500	;sortier tab 1
srtab		= ytab+100		;   "     "  2
srtab2		= ytab+130		; zw.sp. 'sd'
spfree		= ytab+160		;sortier tab 3

;--- zeropage adressen

adr			= $02
madr		= $04
mre			= $06

xwert		= $08
ywert		= $09
cntr		= $0a
ireg		= $0b
fspr		= $0c
spr			= $0d
spr2		= $0e
spr3		= $0f
zwr			= $10
zwr2		= $11
mzwr		= $12
mzwr2		= $13
by			= $14
my			= $15
sy			= $16
time		= $17 		;'uhr'

spr21		= $1a
spr31		= $1b


*= $c000 
		jmp init			;s.u.
;---------------------------------------
;* achtung ! die folgende routine wird
;von den irq-programmen first & next
;angesprungen ! sie steht hier vorn,
;damit sie einige taktzyklen schneller
;(branches nur in gleiche page usw...)
;---------------------------------------
set       dec spr21      	;bringt die
          bmi st3        	;sprs auf
          ldx spr21      	;den screen ...
          ldy srtab2,x
          lda control2,y 	;farbe
          bpl set        	;noch an ?!?!
          ldx spr
          sta $d027,x
          asl            	;msb holen
          asl
          lda $d010
          and tabb,x
          bcc st10       	;msb - setzen
          ora tabc,x
st10      sta $d010
          lda block2,y   	;block-nummer
st4       sta $07f8,x
          txa
          asl
          tax
          lda xpos2,y    	;x-position
          sta $d000,x
          lda ypos2,y    	;y-position
          sta $d001,x
          lda spr        	;next spr
          adc #$01
          and #$07
          sta spr
          rts
tabb      !byte $fe,$fd,$fb,$f7
          !byte $ef,$df,$bf,$7f
tabc      !byte $01,$02,$04,$08
          !byte $10,$20,$40,$80

st3       pla       		;keine sprs
          pla            	;mehr
          
          lda #<first
          sta $fffe
          lda #>first
          sta $ffff
          
          lda $d011      	; anfang
          and #$7f       	; raster
          sta $d011      	; refresh
          lda #10
          sta $d012
          lda spr31
          cmp #$08       	; zurück nach:
          bcs st31
          jmp f3         	; first ?!?
st31      jmp n3         	; oder next ??
;---------------------------------------
;* eigentlicher programm beginn
;---------------------------------------

init      sei
          lda #$05       	;rom aus         
          sta $01
          lda #$00
          sta $d020      	;background         
          sta $d021      	; colors         
          sta $dc0e      	;zeit irqs         
          sta $dc0d      	;sperren         
          
          tax
ii1       lda #$00
          sta base,x     	;register         
          sta base+$0100,x	;zurueck-         
          sta base+$0200,x	; setzen         
          sta base+$0300,x
          sta base+$0400,x
          sta base+$0500,x
          lda #$20
          sta $0400,x    	;bildschirm         
          sta $0500,x    	;clr !         
          sta $0600,x
          sta $0700,x
          dex
          bne ii1
          ldx #30        	;dito         
          lda #$00
ii2       sta $02,x      	;zeropage         
          dex
          bpl ii2
          
          lda #$ff       	;multicolor         
          sta $d01c      	;on         
          lda #$06       	;spr         
          sta $d025      	; farben         
          lda #$01       	;setzen         
          sta $d026

start     lda #<nmi      	;nmis         
          ldx #>nmi      	;auffangen         
          sta $fffa
          stx $fffb
                   
          lda #<first
          sta $fffe
          lda #>first
          sta $ffff
          
          lda $d011      	;  init...         
          and #$7f       	;raster msb         
          sta $d011      	;clr         
          lda #20        	;rasterzeile         
          sta $d012      	;setzen         
          lda #$81       	;rasterirq         
          sta $d01a      	; maskieren         
          cli            	;freigabewait     

wait      jsr minit      	;spr init            
          jsr timer      	;hier platz fuer         
          jmp wait       	;check-routinen                     
                         	;timer-routinen                      
                         	;usw. ausserhalb                      
                         	;des irq !

;---------------------------------------
;* stellt die ersten acht sprites dar
;---------------------------------------
first     sta a1+1       	;register         
          stx x1+1       	; retten         
          sty y1+1
          inc by         	;zeittakt         
          lda by
          and #$3f       	;circa jeden         
          bne i1         	; 64. screen         
          lda time       	; einmal         
          clc            	; time-counter         
          adc #1         	; erhoehen !         
          sta time
          bcc i1
          inc time+1
i1
          lda spr2       	;hier werden die         
          sta spr21      	;von der 'sr'         
          lda spr3       	;bearbeiteten         
          sta spr31      	;register in         
          ldx #30        	;die fuer 'sd'in2      
in2       lda xpos,x     	;notwendigen         
          sta xpos2,x    	;copiert.         
          lda ypos,x
          sta ypos2,x    	;dadurch kann         
          lda control,x  	;die berechnung         
          sta control2,x 	;'sr' (fuer den         
          lda block,x    	;naechsten         
          sta block2,x   	;durchlauf)         
          lda srtab,x    	;parallel mit         
          sta srtab2,x   	;'sd' ablaufen,         
          dex            	;ohne dass beide         
          bpl in2        	;sich stoeren !         
          lda #$00       	;spr ein!         
          sta spr
          ldx spr31
f5        cpx #$09       	;mehr als 8 ?         
          bcc f4
          ldx #$08       	;dann: alle an!f4       
f4        lda tabd,x     	;sonst: evtl.         
          sta $d015      	;  weniger!         
          jsr set        	;die obersten 8         
          jsr set        	;spr darstellen!         
          jsr set
          jsr set
          jsr set
          jsr set
          jsr set
          jsr set
          
          lda $d001      	;untere kante         
          adc #21        	;des naechsten         
          sta $d012      	;sprs neuer         
          
          lda #<next
          sta $fffe
          lda #>next
          sta $ffff

f3        asl $d019
          cli            	;irq frei         
          
          jsr move       	;'sr'         
          lda #$00
          sta $d020

a1        lda #$00       	;register
x1        ldx #$00       	; retten
y1        ldy #$00
nmi       rti

;---------------------------------------
;* stellt die weiteren sprites dar !
;---------------------------------------

next      sta a2+1       	;s.o.         
          stx x2+1
          sty y2+1

n2        jsr set        	;'sd'         
          asl            	;noch genug ras-         
          tax            	;ter zeit bis         
          lda $d001,x    	;zum naechsten         
          adc #21        	;spr, um noch         
          sta zwr        	;einen irq aus-         
          ldx $d012      	;zuloesen ???         
          inx
          cpx zwr
          bcs n2         	;nein : n2         
          
          sta $d012      	;ja !
n3        nop
a2        lda #$00       	;s.o.     
x2        ldx #$00
y2        ldy #$00
          
          asl $d019
          cli
          rti
;---------------------------------------
;* eigentliche sprite-routine 'sr'
;---------------------------------syntax
;zur bewegung & darstellung der sprites!
;    
;                         **************
;  xxxx xxxx              *control-byte*
;  ^^^^ ^----sprite farbe  **************
;  ^^^^------1st/2nd nibble (sinus)
;  ^^^-------explosion on/off
;  ^^--------msb
;  ^­---------sprite on/off
;---------------------------------------move      lda my         	;fuer x/y         
          eor #$80       	;bewegung :         
          sta my         	;up/down half                         
                         	;(s.u.)         
          ldx #30
mo2       lda control,x
          bpl yr5        	;spr an ?                         
                         	;ja !         
          lda #$00       	;zwischenwerte         
          sta xwert      	;losechen         
          sta ywert
an5       lda anitb,x    	;animation ?         
          bne an51
          jmp xs         	;nein : s.u.
an51      asl       		;ja:ausfuehren         
          dec anitco,x
          bpl an21       	;next step ?         
          tay            	;ja !         
          lda anitab+2,y 	;wartezeit         
          sta anitco,x   	; restaurieren         
          lda anitab,y   	;adr         
          sta adr        	;holen         
          lda anitab+1,y
          sta adr+1
          ldy anico,x    	;stepnummer
an3       lda (adr),y    	;block holen         
          bne an2        	;block ok ?         
          sta anico,x    	;nein:         
          tay            	;animation von         
          bcc an3        	;vorne ?         
          lda anitb,x    	;nicht nochmal!         
          and #$3f       	;explosion ?         
          beq an8        	;ja : clr
an41      inc inittb,x   	;nein:next init         
          lda #$00       	;anim. fertig         
          sta anitb,x
an4       lda control,x
          asl
          bpl an42       	;msb ?         
          lda xpos,x     	;ja :         
          cmp #160       	; spr clr ?         
          bcc an42       	; nein         
          cmp #200
          bcs an42       	; nein         
          bcc an8        	;ja!
an42      lda ypos,x     	; sortiert spr.         
          lsr            	; in ytab ein         
          lsr
          cmp #10        	;spr clr ?         
          bcc an8        	; ja         
          cmp #60
          bcs an8        	; ja         
          tay            	;nein
yr4       lda ytab,y
          beq yr3        	;platz besetzt?         
          iny            	; ja:next place         
          cpy #60
          bcc yr4        	; end of tab?         
          bcs yr5        	; ja: next spr
yr3       txa
          sta ytab,y     	; einsortieren         
          bne yr5
an8       lda #$00       	; spr clr!         
          sta control,x
yr5       dex       		; next spr         
          beq yr51       	; all ready ?         
          jmp mo2        	; no
yr51      jmp sort       	; all ready !!
an2       sta block,x    	; new block         
          inc anico,x    	; step forward     
          bcc xs         	; explosion ?         
an21      ldy #$00         	; vielleicht         
          lda anitb,x
          and #$3f
          bne xs         	; explosion ?         
          jmp setxy      	; ja!
xs        lda control,x  	; weiter :         
          eor #$10       	; first/sec.         
          sta control,x  	; halfbyte         
          asl
          asl
          asl
          sta sy         	; sichern         
          lda sinxhi,x   	; sinus in         
          beq ys         	; x-richtung ?         
          sta adr+1      	; ja:adr         
          lda sinxlo,x   	; holen         
          sta adr
          ldy sinx1,x
          lda (adr),y    	; wert holen         
          bit sy         	; 1st/2nd         
          bmi xs2        	; halfbyte ?         
          lsr            	; first         
          lsr
          lsr
          lsr
xs2       and #$0f       	; second         
          tay
          lda deltb,y    	; aus tab holen         
          sta xwert      	; ablegen         
          bit sy         	; bereits next         
          bpl ys         	;  byte ???         
          lda sinx1,x    	; ja!         
          clc            	; step forward         
          adc #1
          cmp sinx2,x
          bcc xs1        	;ende erreicht?         
          lda sinx3,x    	; ja:restart
xs1       sta sinx1,x    	; nein:store
ys        lda sinyhi,x   	; sinus in         
          beq del        	; y-richtung ?         
          sta adr+1      	; ja :adr         
          lda sinylo,x   	; holen         
          sta adr
          ldy siny1,x
          lda (adr),y    	; dito         
          bit sy         	; alles analog         
          bmi ys2        	; zu -xs-         
          lsr
          lsr
          lsr
          lsr
ys2       and #$0f
          tay
          lda deltb,y
          sta ywert
          bit sy
          bpl del
          lda siny1,x
          clc
          adc #1
          cmp siny2,x
          bcc ys1
          lda siny3,x
ys1       sta siny1,x
del       lda delay,x    	; countdown ?         
          beq acx
          dec delay,x    	; ja:ausfuehren         
          bne acx        	; null ?         
          inc inittb,x   	; ja:next init
acx       lda acctx,x    	;beschleunigung x?         
          beq dx
          dec acct1,x    	;ja:wert schon         
          bpl ac1        	;  aendern ?         
          lda acctx,x    	;ja: zeit         
          sta acct1,x    	; restaurieren         
          lda deltax,x   	;tab-wert holen         
          and #$f0
          sta zwr2       	;ziel retten         
          lsr
          lsr
          lsr
          lsr
          sta zwr        	;ziel wert         
          lda deltax,x
          and #$0f       	;moment wert         
          cmp zwr        	;ziel         
          bne ac5        	; erreicht?         
          lda #$00       	; ja : acc-         
          sta acctx,x    	; ende !         
          beq acy
ac5       bcc ac3        	;ziel annaehren         
          sbc #1
          bpl ac4
ac3       adc #1
ac4       ora zwr2       	;tab wert         
          sta deltax,x   	; zurueck !         
          bne dx1
ac1       lda deltax,x   	;bewegung aus-         
          bne dx1        	;  fuehren !
dx        lda deltax,x   	; x -         
          beq dy         	;  bewegung ??         
          bit my         	; ja         
          bpl dx1        	; 1st/2nd half?         
          lsr            	;1st         
          lsr
          lsr
          lsr
dx1       and #$0f       	;2nd         
          tay
          lda deltb,y    	; s.o.         
          clc
          adc xwert      	;ablegen         
          sta xwert
acy       lda accty,x    	;beschleunigung y?         
          beq dy
          dec acct2,x    	;ja: weiter         
          bpl ac11       	;analog -acx-         
          lda accty,x
          sta acct2,x
          lda deltay,x
          and #$f0
          sta zwr2
          lsr
          lsr
          lsr
          lsr
          sta zwr
          lda deltay,x
          and #$0f
          cmp zwr
          bne ac6
          lda #$00
          sta accty,x
          beq spc
ac6       bcc ac7
          sbc #1
          bpl ac8
ac7       adc #1
ac8       ora zwr2
          sta deltay,x
          bne dy1
ac11      lda deltay,x
          bne dy1
dy        lda deltay,x   	; y bewegung ?         
          beq spc
          bit my         	; analog -dx- !         
          bpl dy1
          lsr
          lsr
          lsr
          lsr
dy1       and #$0f
          tay
          lda deltb,y
          clc
          adc ywert
          sta ywert
spc       lda spechi,x   	;special prg ?!         
          beq setxy
          sta sp1+2      	;ja! adr         
          lda speclo,x   	; holen         
          sta sp1+1
          stx sp1+4      	;spr-nr retten      
sp1       jsr $ffff      	;ins zusatz-prg         
          ldx #$00         	;spr-nr retten

setxy     lda xwert      	;neue spr-pos.         
          beq sx5        	;berechnen !         
          clc
          adc xpos,x     	;x-pos         
          sta xpos,x
          bit xwert
          bpl sx3        	;xwert neg?         
          bcc sx3+2      	;add.ueberlauf?         
          bcs sx5        	;ja/nein?
sx3       bcc sx5
          lda control,x  	;mit msb !         
          eor #$40
          sta control,x
sx5       lda ywert
          beq sx4
          clc
          adc ypos,x     	;y-pos         
          sta ypos,x     	; und fertig!
sx4       jmp an4        	;einsortieren !;---------------------------------------
;* abschliessender sortier - algorithmus
;---------------------------------------
sort      ldy #0
          ldx #60
an7       lda ytab,x     	;tab search                
          beq an6        	;spr gefunden?
          sta srtab,y    	;ja:einsortieren!
          lda #0
          sta ytab,x     	;wert clr!                
          iny            	;next             
an6       dex            	;ganzen bereich                
          cpx #10        	;durchsuchen!                
          bcs an7
          lda #$ff       	;ende der tab                
          sta srtab,y    	;markieren                
          sty spr2       	;spr-anzahl                
          sty spr3       	;retten
fs7       dey       		;ueberprueft                
          beq try        	;nochmals die                
          ldx srtab,y    	;reihenfolge                
          lda ypos,x     	;der sprites                
          ldx srtab-1,y  	;mittels der                
          cmp ypos,x     	;jeweiligen                
          bcc fs7        	;(echten) ypos                
          lda srtab,y    	;& sortiert um                
          sta srtab-1,y  	;(falls noetig)                
          txa
          sta srtab,y
          bne fs7
try       ldy #0         	;fertigt eine                
          ldx #30        	;tabelle der
fs2       lda control,x  	;freien spr                
          bmi fs1        	;an ...                
          lda inittb,x
          beq fs3        	;wird von                
          bpl fs1        	;getspr genutzt                
          cmp #$ff
          bne fs1
          lda #$00
          sta inittb,x
          beq fs1
fs3       txa
          sta spfree,y
          iny
fs1       dex
          bne fs2
          dey
          sty fspr       	;ende des move                
          rts            	;programms
;---------------------------------------
;* initialisiert alle sprites mittels
;  track-tabelle !
;---------------------------------------

minit     ldx #30
mi17      lda inittb,x
          beq mi1        	;init ?         
          cmp #$ff       	;vielleicht ?         
          beq mi1
          bmi mi16       	;ja:explosion         
          ldy control,x  	;ja:normal         
          sty cntr
          bmi mi2        	;spr on?         
          asl            	;nein         
          tay
          lda trktab,y   	;track adr         
          sta trklo,x    	; holen         
          sta madr
          lda trktab+1,y
          sta trkhi,x
          sta madr+1
          jsr clr        	;alte wert clr         
          ldy #0
          lda (madr),y   	;position         
          beq mi15       	;  gegeben ?         
          asl            	;ja !         
          sta xpos,x     	; x-pos &         
          ror
          lsr
          and #$40
          sta cntr       	; msb holen!         
          iny
          lda (madr),y
          sta ypos,x     	; y-pos holen!
mi15      ldy #2
          bne mi32       	; weiter
mi16      jsr expl2      	;expl.-init
mi13      lda cntr
          sta control,x  	;spr ein/aus     
mi14      lda #0
          sta inittb,x   	;init fertig!
mi1       dex
          bne mi17       	;next spr?         
          rts            	;minit ende !!!                         
                         	;spr war ein !
mi2       tya       		;control-reg!         
          asl
          asl
          bmi mi14       	;expl ?
mi12      lda trklo,x    	;no: alte         
          sta madr       	; adr holen         
          lda trkhi,x
          beq mi14
          sta madr+1
          ldy trkpo,x    	;pointer
mi32      lda (madr),y
          beq mi14       	;track ende ?         
          cmp #$ff       	;no:         
          beq mijmp      	;jump/einschub?         
          jsr mi3        	;no: norm-init!         
          iny
          tya            	;neuen         
          sta trkpo,x    	;pointer retten         
          jmp mi13       	;next spr !
mijmp     iny
          lda (madr),y   	;testen !         
          cmp #$ff
          beq mij1       	;jump ?         
          cmp #$fe
          beq mijs       	;einschub ?         
          dey
          jmp mi13       	;weder noch !
mij1      iny       		;jump!         
          lda (madr),y   	; holt neue         
          sta trklo,x    	; track adr         
          iny            	; & uebergibt!         
          lda (madr),y   	; achtung :         
          sta trkhi,x    	;----------         
          lda #0         	;muss auf         
          sta trkpo,x    	;status byte         
          beq mi12       	;weisen !!!                         
                         	;einschub !
mijs      iny       		; holt         
          lda (madr),y   	; einsprung         
          sta mijs2+1    	; der init-seq         
          iny
          lda (madr),y   	;achtung:         
          sta madr+1     	;--------
mijs2     lda #$00       	;muss auf         
          sta madr       	;status byte         
          iny            	;weisen !         
          tya
          sta trkpo,x
          ldy #0
          lda (madr),y   	; fuehrt sie         
          jsr mi3        	; aus & kehrt         
          jmp mi13       	; zurueck

mi3       lsr       		;holt alle         
          sta ireg       	; daten aus dem         
          bcc mi4        	; track !         
          iny
          lda (madr),y   	;special init?         
          sta mi4-6      	;wenn ja:         
          iny            	; holt einsrung         
          lda (madr),y
          sta mi4-5
          sty mi4-1      	;rettet x,y         
          stx mi4-3
          jsr $ffff      	;springt ein!         
          ldx #$00         	; x,y retten         
          ldy #$00

mi4       lsr ireg       	;basic         
          bcc mi5        	; refresh ?         
          iny            	;ja:         
          lda (madr),y   	;ja: holt:         
          beq mi41
          sta block,x    	; block &     
mi41      lda cntr
          and #$40
          iny
          ora (madr),y   	; farbe !         
          ora #$80       	;& spr on !         
          sta cntr
mi5       lsr ireg       	;bewegung x/y?         
          bcc mi6
          iny            	;ja: holt:         
          lda (madr),y   	; deltax         
          sta deltax,x
          iny
          lda (madr),y   	; deltay         
          sta deltay,x
mi6       lsr ireg       	;count down?         
          bcc mi7
          iny            	;ja:         
          lda (madr),y   	; holt delay         
          sta delay,x
mi7       lsr ireg       	;beschleunigung         
          bcc mi8        	; x/y ?         
          iny            	;ja!         
          sty mi71+1     	;y retten         
          lda (madr),y   	;holt zeiger         
          asl            	; auf acctb         
          asl            	; *4         
          tay            	;holt aus         
          lda acctb+1,y  	; acctb :         
          sta acctx,x    	; time x         
          lda acctb,y    	;ziel/start -x-         
          sta deltax,x
          lda acctb+3,y  	; time y         
          sta accty,x
          lda acctb+2,y  	;ziel/start -y-         
          sta deltay,x
          lda #$00       	; alte counter         
          sta acct1,x    	; clr         
          sta acct2,x
mi71      ldy #$00       	;y zurueck
mi8       lsr ireg       	;animation ?         
          bcc mi9
          iny            	;ja         
          lda (madr),y   	;animations-nr.         
          asl            	;*2         
          sta anitb,x    	;uebergeben         
          lda #0
          sta anitco,x   	; clr         
          sta anico,x
mi9       lsr ireg       	;special-prg         
          bcc mi10
          iny            	;ja !         
          lda (madr),y
          sta speclo,x   	;holt adr !         
          iny
          lda (madr),y   	;&uebergibt !         
          sta spechi,x
mi10      lsr ireg       	;sinus ?         
          bcc mi11
          iny            	; ja!         
          lda (madr),y   	;holt nr fuer         
          jmp sininit    	;sintab2 & init
mi11      rts
;--------------------------------------------------
expl2     lda #$c0       	;explosion                
          sta cntr       	; kennzeichnen        
expl      jsr clr        	; clr                
          lda #$40       	;0. animation                
          asl            	;einmal aus-                
          sta anitb,x    	; fuehren !                
          lda #0
          sta anico,x    	;clr                
          sta anitco,x
          lda control,x
          and #$c0
          ora #$27       	;farbe gelb                
          sta control,x
          rts
;--------------------------------------------------
sininit   sty si2+1      	;holt die werte                
          asl            	;aus sintab2 &                
          asl            	;sintab ...                
          tay            	;uebergibt                                         
                         	;diese an die                                        
                         	;spr tabs !!                
          lda sintab2+1,y	;start pointer                
          sta sinx1,x    	; sinus x                
          lda sintab2+2,y	;nummer sinus y                
          asl
          asl            	;*4 &                
          sta si1+1      	;retten                
          lda sintab2+3,y	;start pointer                
          sta siny1,x    	; sinus y                
          lda sintab2,y  	;nummer sinus x                
          asl
          asl            	;*4                
          tay            	;aus sintab:                
          lda sintab+2,y 	;end-pointer                
          sta sinx2,x
          lda sintab+3,y 	;anfangs-                
          sta sinx3,x    	; pointer                
          lda sintab,y   	;adr !                
          sta sinxlo,x
          lda sintab+1,y
          sta sinxhi,x
si1       ldy #$00       	;analog fuer                
          lda sintab+2,y 	; sinus y                
          sta siny2,x    	;end-pointer                
          lda sintab+3,y 	;anfangs-                
          sta siny3,x    	; pointer                
          lda sintab,y   	;adr !                
          sta sinylo,x
          lda sintab+1,y
          sta sinyhi,x
si2       ldy #$00       	;y-retten                
          rts            	;ende
;--------------------------------------------------
clr       lda #$00       	;clr der alten                
          sta deltax,x   	;werte                
          sta deltay,x
          sta delay,x
          sta sinxhi,x
          sta sinyhi,x
          sta siny1,x
          sta control,x
          sta anitb,x
          sta spechi,x
          sta zwisch2,x
          sta acctx,x
          sta accty,x
          rts
;--------------------------------------------------
getspr    ldy fspr       	;holt nummer                
          bmi gs1        	;eines freien                
          lda spfree,y   	;sprites aus                
          dec fspr       	;spfree und                
          tay            	;gibt dessen                
          lda #$ff       	;nr nach y !!                
          sta inittb,y
          clc
 		 rts
gs1    	 sec
          rts
;--------------------------------------------------
getpos    lda xpos,x     	;holt position                
          sta xpos,y     	;des                
          lda ypos,x     	;aufrufenden                
          sta ypos,y     	;sprites !                
          lda control,x
          and #$40
          sta control,y
          rts

;---------------------------------------
;*- zusatz init programme
;---------------------------------------

more      lda xpos,x     	;initialisiert
          sta mrx+1      	;beliebig viele
          lda cntr       	;zusatz spr
          and #$40       	;analog
          sta mrx+6      	;more-tabelle
          lda ypos,x     	;hierbei kann
          sta mry+1      	;sowohl die
          stx mrs+1      	;position
          stx mrss+1     	;relativ zum
                         	;aufrufenden
                         	; sprite
          iny            	;als auch die
          lda (madr),y   	;track-nr des
          asl            	;neuen spr.
          iny            	;ueberrgeben
          sty mi4-1      	;werden.
          tay
          lda moretb,y   	;beim neu
          sta mre        	;initial. spr
          lda moretb+1,y 	;wird zusaetz-
          sta mre+1      	;lich im
                         	;'zwisch3'-reg
          ldy #$00       	;die nr des
mr1       sty mr7+1      	;ausgangs-spr
          jsr getspr     	;und im
          bcs mrs        	;'zwisch'-reg
          tya            	;die nr des
          tax            	;zuvor init.
                         	;spr mitueber-
mr7       ldy #$00       	;geben !!!
          lda (mre),y    	;dies ist
          cmp #$ff       	;wichtig bei
          beq mrs        	;der progm. von
          sta inittb,x   	;zusammen-
          iny            	; gesetzten
          lda (mre),y    	;sprites...
mr6       sta mzwr
          clc
mrx       adc #$00
          sta xpos,x
          lda #$00
          bit mzwr
          bpl mr2
          bcc mr2+2
          bcs mr2+4
mr2       bcc mr2+4
          eor #$40
          sta control,x
          iny
          lda (mre),y
          clc
mry       adc #$00
          sta ypos,x
mrss      lda #$00
          sta zwisch,x
          stx mrss+1
          lda mrs+1
          sta zwisch3,x
mr5       iny
          bne mr1
mrs       ldx #$00
          rts
;---------------------------syntax: more
;;.word more,<tab-pointer>
;---------------------------------------
;tab-pointer weisst auf moretb, es gilt:
;moretb	;.word 0		;0
;		;.word <name>	;<pointer>
;---------------------------------------
;wobei :
;<name>	!byte <trknr1>,<dx1>,<dy1>
;		!byte <trknr2>,<dx2>,<dy2>
;		....
;		!byte $ff 			;ende !
;---------------------------------------
;hierbei:	<dx>	positionsaenderung(!) des
;				neuen spr relativ (!) zum
;				alten spr !!!!
;wobei: 		<dx> sowohl >0 als auch <0
;				sein darf !!!
; analog das ganze fuer <dy> !
;---------------------------------------
; note : siehe demo !!!
;---------------------------------------

more2     iny       			;holt ein spr
          lda (madr),y   		;zusaetzlich
          iny            		;auf die selbe
          sty mi4-1      		;position wie
          sta mor2+1     		;das aufrufende
mor4      jsr getspr     		;sprite !!!
          bcs mors
          jsr getpos
mor2      lda #$00
          sta inittb,y
mors      rts
;--------------------------syntax: more2
;;.word more2,<trk-nr>
;---------------------------------------
more3     iny       			;initialisiert
          lda (madr),y   		;beliebig viele
          sta zwisch,x   		;gleiche tracks
          sta zwisch3,x  		;unter berueck-
          iny            		;sichtigung
          lda (madr),y   		;einer pause...
          sta zwisch2,x
          iny            		;nach erfolgter
          lda (madr),y   		;init. schaltet
          sta zwisch4,x  		;es sich selbst
          sty mi4-1      		;wieder ab ...
          lda #<mrp3
          sta speclo,x
          lda #>mrp3
          sta spechi,x
          rts
;--------------------------------------------------
mrp3      dec zwisch,x
          bpl mp1
          lda zwisch3,x
          sta zwisch,x
          dec zwisch2,x
          bmi mp2
          jsr getspr
          bcs mp1
          jsr getpos
          lda zwisch4,x
          sta inittb,y
mp1       rts
;--------------------------------------------------
mp2       lda #$00
          sta spechi,x
          inc inittb,x
          rts
;--------------------------syntax: more3
;;.word more3
;!byte <time>,<anzahl>,<trk-nr>
;---------------------------------------

;---------------------------------------
;*- weitere ergaenzungsprogramme
;---------------------------------------

shoot2    lda #$ef       ;holt ein freies
          bne s3         ;spr
                         ;(jeden 16 scr)
shoot     lda #$67       ;und init. es
s3        sta sht+7      ;als ein schuss!
          lda by
          and #$0f
          bne s1
          jsr getspr
          bcs s1
          jsr getpos
s2        lda #$02
          sta inittb,y
s1        rts
;--------------------------------------------------
throw     dec zwisch,x   		;holt ein freies
          bpl t1         		;spr
          lda #$05       		;(jeden 6 scr)
          sta zwisch,x   		;und init. es
                         		;als kugel, die
          lda xwert      		;tangential zur
          jsr t2         		;kreisbewegung
          sta thr+5      		;des aufrufenden
          lda ywert      		;sprs wegfliegt!
          jsr t2
          sta thr+6
          jsr getspr
          bcs t1
          jsr getpos
          lda #$11
          sta inittb,y
t1        rts
;--------------------------------------------------
t2        bmi t3_a
          ldy #$07
t21       cmp deltb,y
          bcs t22
          dey
          bne t21
t22       tya
          sty t23+1
          asl
          asl
          asl
          asl
t23       ora #$00
t32       rts
;--------------------------------------------------
t3_a      ldy #$0f
t31       cmp deltb,y
          bcc t22
          dey
          cpy #$08
          bne t31
          jmp t22

ss1       !byte 0,0
sttb      !byte 1,5,13,18,2,23,4,8,9
          !byte 20,16,3,14,6,0,17,21
          !byte 7,11,15,10,19,22,12

starscr   lda by         		;sternflug
          and #$01       		; routine !!
          bne t32
          lda #$01
          sta time+1
          jsr getspr
          bcs t32
          jsr getpos
          ldx ss1
          lda sttb,x
          tax
          lda sin3,x
          sta star1+5
          and #$0f
          tax
          lda deltb,x
          sta ss71+1
          lda #$02
          sta ss1+1
ss7       lda xpos,y
          clc
ss71      adc #$00
          sta xpos,y
          lda control,y
          bit ss71+1
          bpl ss72
          bcc ss72+2
          bcs ss73
ss72      bcc ss73
          eor #$40
ss73      sta control,y
ss6       dec ss1+1
          bpl ss7
          asl
          asl
          lda xpos,y
          ror
          sta star1
          ldx ss1
          lda sttb,x
          clc
          adc #$08
          cmp #$18
          bcc ss4
          sbc #$18
ss4       tax
          lda #$02
          sta ss1+1
          lda sin3,x
          sta star1+6
          and #$0f
          tax
          lda ypos,y
ss8       clc
          adc deltb,x
          sta star1+1
          dec ss1+1
          bpl ss8
          lda #$15
          sta inittb,y
          lda ss1
          clc
          adc #$0c
          cmp #$18
          bcc ss3
          sbc #23
ss3       sta ss1
ss2       rts

; --- sonstiges ---

tabd	!byte $00,$01,$03,$07,$0f
 		!byte $1f,$3f,$7f,$ff

deltb	!byte $00,$01,$02,$03,$04,$06
		!byte $08,$0a,$00,$ff,$fe,$fd
 		!byte $fc,$fa,$f8,$f6

;---------------------------------------
;* track - tabelle
;---------------------------------syntax
;		;.word <name> 		;<pointer>
;---------------------------------------

trktab	!word 0 			;max 128!
		!word trk1 		;1
		!word sht			;2
		!word trk2			;3
		!word tr22			;4
		!word trk3			;5
		!word tr33			;6
		!word trk4			;7
		!word tk41			;8
		!word tk42			;9
		!word tk43			;a
		!word tk44			;b
		!word trk5			;c
		!word tk51			;d
		!word trk6			;e	
		!word tk61			;f
		!word tk62			;10
		!word thr			;11
		!word trk7			;12
		!word tr71			;13
		!word star			;14
		!word star1		;15

;---------------------------------syntax
; zur initialisierung (im track) !
; 
; xxxx xxxx betreffendes bit
;  ^
;  ^--------bezeichnung
;          * wird als syntax erwartet !
;                  länge x-bytes(xby)
;
;                          *************
; xxxx xxxx                *status-byte*
; ^^^^ ^^^^                ************* 
; ^^^^ ^^^^--special init
; ^^^^ ^^^  * (lo/hi) adresse & sonst.(mind.2by)
; ^^^^ ^^^---basic refresh
; ^^^^ ^^   * block/control		(2by)
; ^^^^ ^^----bewegung nach x/y
; ^^^^ ^    * deltax/deltay		(2by)
; ^^^^ ^-----count down (f. neues init)
; ^^^^      * wartezeit			(1by)
; ^^^^-------beschleunging x/y
; ^^^       * zeiger auf acctab	(1by)
; ^^^--------animation
; ^^        * zeiger auf anitb	(1by)
; ^^---------special-routinen
; ^         * (lo/hi) adresse		(2by)
; ^----------sinus
;           * zeiger auf sintab2	(1by)
;---------------------------------------

trk1      !byte 10,180,%00011010
          !byte $80,$0e,$20,$00
          !byte %00011000,$12,$01
          !byte %10101000,$30,$41,$01
          !byte %10000000,$00
          !byte %10011000,$18,$02,$00
          !byte %10110000,$03,$42,$02
          !byte %10001000,$02,$00
          !byte %11101000,$c0,$07
          !word shoot
          !byte $03,%00001000,$f0
          !byte %00000001
          !word expl
;----
sht       !byte 0,0,%00000111
          !word sht2
          !byte $94,$05,$67,$00

sht2      lda sht+7
          eor #$32
          sta sht+7
          rts
;----

trk2	!byte 170,50,%00100011
		!word more3
		!byte $10,$07,$04			;f. more3
		!byte $00,$0c,$04
		!byte %10011000,$20,$02,$04
		!byte %00011000,$40,$03
		!byte %00010000,$04,$00,$00

tr22 	!byte 0,0,%10111010
		!byte $00,$0c,$20,$02,$04,$04
		!byte %00011000,$40,$03
		!byte %00010000,$04,$00,$00
;----

trk3	!byte 170,220,%00100011
		!word more3
		!byte $08,$0e,$06			;f. more3
		!byte $00,$05,$04
		!byte %10011000,$20,$02,$05
		!byte %00011000,$40,$03
		!byte %00010000,$04,$00,$00

tr33 	!byte 0,0,%10111010
		!byte $00,$05,$20,$02,$04,$05
		!byte %00011000,$40,$03
		!byte %00010000,$04,$00,$00
;----

trk4 	!byte 170,120,%00111011
 		!word more,$01
		!byte $00,$0e,$30,$02,$03
		!byte %00011000,$20,$03
		!byte %00011000,$20,$05
		!byte %00011000,$40,$01
		!byte %00010000,$02

tki1 	= *+2
tk41 	!byte 0,0,%00111010
		!byte $00,$0e,$30,$02,$03
		!byte %00011000,$20,$03
		!byte %01001001
 		!word more2,$09
		!byte $20
		!word shoot2
tke1 	!byte %00011000,$50,$01
		!byte %00010000,$05

tk42 	!byte 0,0,%00111010
		!byte $00,$0e,$25,$06,$03
		!byte %01011000,$50,$07
		!word shoot2
		!byte %01010000,$05,0,0

tk43 	!byte 0,0
 		!word $feff,tki1
		!byte %00011000,$20,$03
		!byte %01001001
 		!word more2,$0b
		!byte $20
		!word shoot2
 		!word $ffff,tke1	
 
tk44 	!byte 0,0,%00111010
		!byte $00,$0e,$25,$08,$03
		!byte %01011000,$50,$09
		!word shoot2
		!byte %01010000,$05,0,0
;----

trk5 	!byte 10,60,%10011010
		!byte $ac,$0e,$60,$0a,$06
		!byte %10000101
		!word more3
		!byte $04,$12,$0d
		!byte $00,$00,$00
		!byte %10001000,$c0,$06
 		!word $ffff,tk5m		
 
tk51 	!byte 0,0,%10001010
 		!byte $ac,$0e,$c0,$06
tk5m 	!byte %00001100,$a9,$00,$30
 		!byte %00001100,$11,$00,$90
 		!byte %00001100,$a9,$00,$90
		!byte %00000100,$11,$00
;----

trk6 	!byte 170,220,%10101111
		!word more,$02
		!byte $00,$0a,$09,$00,$60,$05,$05
		!byte %01000100,$99,$00
 		!word throw,$00

tk61 	!byte 0,0,%10101110
		!byte $00,$0a,$09,0,$60,$05,$05
		!byte %00000100,$99,$00

tk62 	!byte 0,0,%10101110
		!byte $00,$0e,$09,0,$60,$04,$05
		!byte %00000100,$99,$00

thr		!byte 0,0,%00000110
		!byte $bc,$05,$00,$00
		!byte $00,$00
;----

trk7 	!byte 170,60,%11100111
		!word more2,$13
		!byte $00,$0e,$99,$00,$04
		!word throw
		!byte $04

tr71 	!byte 10,230,%11100110
		!byte $00,$0e,$11,$00,$04
		!word throw
		!byte $01
;----

star 	!byte 86,120,%01000010
		!byte $bf,$0e
		!word starscr,$00,$00

star1	!byte 0,0,%00001110
		!byte $bd,$06,$00,$00,$04
 		!byte %00001010,$bd,$0e,$06
 		!byte %00001010,$bd,$03,$09
		!byte %00000010,$be,$01
		!word $00,$00

;---------------------------------------
;* more - tabelle
;---------------------------------syntax
;		;.word <name> 		;<pointer>
;---------------------------------------

moretb 	!word $00			;0
		!word tk4			;1
		!word tk6			;2
;---------------------------------syntax
;<name>	!byte <trknr>,<dx>,<dy>
;		!byte $ff
;---------------------------------------

tk4		!byte $08,20,$ec
 		!byte $0a,20,20
		!byte $ff

tk6		!byte $0f,20,0
		!byte $10,10,$f6
		!byte $10,10,$0a
		!byte $ff

;---------------------------------------
;* beschleunigungs - tabelle
;---------------------------------syntax
;		!byte<ax>,<tx>,<ay>,<ty>
;---------------------------------------
;wobei:	ax = $uv	->	u - ziel
; 				  	v - beginn
; 		tx 		-> 	wartezeit
;---------------------------------------

acctb	!byte $50,$02,$10,$03		;max 64!
 		!byte $05,$04,$00,$00		;1
 		!byte $c9,$04,$00,$00		;2
 		!byte $8c,$04,$00,$00		;3
 		!byte $a8,$04,$00,$00		;4
		!byte $50,$04,$00,$00		;5
		!byte $30,$04,$20,$02		;6
 		!byte $03,$04,$02,$02		;7
		!byte $30,$04,$a8,$02		;8
 		!byte $03,$04,$8a,$02		;9
		!byte $20,$04,$00,$00		;a

;---------------------------------------
;* sinus - tabellen
;------------------------syntax: sintab2
;		!byte <sx>,<x1>,<sy>,<y1>
;---------------------------------------
sintab2	!byte $00,$00,$00,$00		;max 64!
		!byte $02,$00,$02,$0c		;1
 		!byte $01,$18,$02,$24		;2
		!byte $00,$00,$02,$0c		;3
 		!byte $02,$18,$02,$24		;4
 		!byte $02,$18,$02,$0c		;5
		!byte $02,$00,$02,$24		;6

;-------------------------syntax: sintab
;		;.word <name>,$(beg/end)
;wobei:			(lo=end/hi=beg) !
;---------------------------------------

sintab	!word $00,$00				;max 64!
 		!word sin1,$30				;1
 		!word sin2,$30 				;2

sin1 	!byte $44,$43,$33,$22,$22,$11
 		!byte $11,$11,$11,$00,$00,$00
 		!byte $00,$00,$00,$99,$99,$99
 		!byte $99,$aa,$aa,$bb,$bc,$cc
 		!byte $cc,$cb,$bb,$aa,$aa,$99
 		!byte $99,$99,$99,$00,$00,$00
 		!byte $00,$00,$00,$11,$11,$11
 		!byte $11,$22,$22,$33,$34,$44

sin2 	!byte $55,$55,$44,$44,$43,$33
 		!byte $33,$22,$22,$21,$11,$11
 		!byte $99,$99,$9a,$aa,$aa,$bb
 		!byte $bb,$bc,$cc,$cc,$dd,$dd
 		!byte $dd,$dd,$cc,$cc,$cb,$bb
 		!byte $bb,$aa,$aa,$a9,$99,$99
 		!byte $11,$11,$12,$22,$22,$33
 		!byte $33,$34,$44,$44,$55,$55

sin3 	!byte $54,$44,$43,$33,$22,$11
 		!byte $99,$aa,$bb,$bc,$cc,$cd
 		!byte $cd,$cc,$bc,$bb,$aa,$99
 		!byte $11,$22,$33,$34,$44,$54

;---------------------------------------
;* animations - tabelle
;---------------------------------syntax
;		;.word <name>,<ani-speed>
;---------------------------------------

anitab 	!word exp,$04
 		!word turn1,$04 		;1
 		!word turn2,$04			;2
 		!word dreh1,$04			;3
		!word dreh2,$08			;4
 		!word dreh3,$08			;5
 		!word rolle1,$09		;6
 		!word rolle2,$09		;7

exp		!byte $b3,$b4,$b5,$b6,$b7,$b8
		!byte $b9,$ba,$bb,$00

turn1	!byte $80,$81,$82,$83,$84,$85
 		!byte $86,$87,$88,$89,$8a,$00

turn2	!byte $8a,$8b,$8c,$8d,$8e,$8f
		!byte $90,$91,$92,$93,$80,$00

dreh1	!byte $a0,$a1,$a2,$a3,$a4,$a5
		!byte $00

dreh2	!byte $a6,$a7,$a8,$a9,$aa,$ab
		!byte $00

dreh3	!byte $ac,$ad,$ae,$af,$b0,$b1
		!byte $b2,$00

rolle1	!byte $86,$87,$88,$89,$8a,$8a
 		!byte $8a,$8a,$89,$88,$87,$86
		!byte $00

rolle2	!byte $90,$91,$92,$93,$80,$80
		!byte $80,$80,$93,$92,$91,$90
		!byte $00

;---------------------------------------
;* steuert die init. der sprites!
;---------------------------------------

timer	lda time+1
		bne tiend
		ldy time				;zaehler
		cpy time+2				;schon einmal
		beq ti0				;init?
		sty time+2				;nein!
ti1		lda timetb,y			;only 1 blk!
		beq ti0 				;neuer init?
 		sta ti2+1 				;ja!
		jsr getspr				;sprite holen
		bcs ti0				;spr frei?
ti2		lda #$00 				;ja: init!
		sta inittb,y
ti0		rts

tiend	lda #$00
		bne ti0
 		inc tiend+1
		ldx #$00
te1		lda text,x
		beq te2
		and #$3f
		sta $06f8,x
		lda #$0c
 		sta $daf8,x
		inx
		bne te1
te2		rts

text	!text "sprite-routine   "
		!text "               30.7.92 "
 		!text "vielen dank fuer "
		!text "ihr interesse ....     "
		!text "for further inform "
		!text "ation please dial : "
		!text " ingo kusch / simon"
		!text "str. 9 / 4700 hamm 3 "
		!text " tel : (02381)464619"

;---------------------------------------
;* tabelle zur steuerung der inits!
;---------------------------------------

timetb	!byte $00,$01,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$03
		!byte $00,$00,$00,$00,$05,$00
		!byte $00,$00,$00,$00,$07,$00
		!byte $00,$00,$00,$0c,$00,$00
		!byte $00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$0e,$00,$00
		!byte $00,$00,$00,$00,$00,$00
		!byte $0c,$01,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$07,$00,$05
		!byte $00,$00,$00,$12,$00,$00
		!byte $00,$00,$00,$14,$00,$00
		!byte $00,$00,$00,$00,$00,$00
;---------------------------------------
; --- ende ---
;---------------------------------------