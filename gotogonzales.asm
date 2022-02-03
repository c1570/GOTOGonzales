	.word $c000
	* = $c000

	linnum = $14  ; line number to search
	lowtr = $5f   ; offset found

	cachelen = 32

;find cache entry with largest smaller or equal line number
;if line number exact match, return
;look from basic start ($A613 FNDLIN) if no cache entry found, else look from found entry offset ($A617)
;if have entry with same line number high
;    if cache entry has higher line number low then replace that entry
;else
;    replace oldest entry

enable:	jmp patch
clear:	jmp clrall
fndlnc:	ldy #$ff
	sty cndlnr
	sty cndlnr+1
	iny
	; jsr debug
cmpe:	lda linnum
	cmp cache,y
	lda linnum+1
	sbc cache+1,y
	bcs fndc  ; linnum>=cache entry, found a candidate
nexte:	iny
	iny
	iny
	iny
nextf:	cpy #cachelen
	bne cmpe
ends:	ldy cndlnr
	iny
	bne dosrch  ; have a candidate, start search from there
	; start search from beginning
	jsr $a613
	bcs stor
	rts
dosrch:	ldy #$01
	jsr $a61d
	bcs stor
	rts

fndc:	; found a candidate, is it better than the last candidate
	lda #$ff
	cmp cndlnr+1
	beq stoc    ; just take this if we have no candidate yet
	lda cache,y
	cmp cndlnr
	lda cache+1,y
	sbc cndlnr+1
	bcc nexte ; have a better candidate already, skip
	; cache line nr>=candidate, just found a better candidate
stoc:	lda cache,y
	sta cndlnr
	lda cache+1,y
	sta cndlnr+1
	lda cache+2,y
	sta lowtr
	lda cache+3,y
	sta lowtr+1
	lda linnum
	cmp cndlnr
	bne nexte
	lda linnum+1
	cmp cndlnr+1
	bne nexte
	; exact match, just return
	sec
	rts

;if have entry with same line number high
;    if cache entry has higher line number low then replace that entry
;else
;    replace oldest entry

stor:	; store new cache entry
	ldy #$00
stloop:	lda cache+1,y
	cmp linnum+1
	beq sthm
stls:	iny
	iny
	iny
	iny
	cpy #cachelen
	bcc stloop
	; no high match found, replace oldest entry
stlast:	ldx #$00
	lda linnum
	sta cache,x
	lda linnum+1
	sta cache+1,x
	lda lowtr
	sta cache+2,x
	lda lowtr+1
	sta cache+3,x
	inx
	inx
	inx
	inx
	stx stlast+1
	cpx #cachelen
	bne stend
	ldx #$00
	stx stlast+1
stend:	sec
	rts
sthm:	; high match found
	lda cache,y
	cmp #$ff
	beq stls  ; unused entry, skip
	cmp linnum
	; beq stls  ; should not happen, have tested exact match before
	bcc stend  ; cache line is lower than new candidate, ignore candidate
	lda linnum
	sta cache,y
	lda lowtr
	sta cache+2,y
	lda lowtr+1
	sta cache+3,y
	jmp stend

cndlnr:	brk
	brk

clrall:	ldy #cachelen
	lda #$ff
clloop:	dey
	sta cache,y
	bne clloop
	sty stlast+1
	jmp $ffe7

cache:	.dsb cachelen, 0

debug:	lda linnum
	jsr dbg
	lda linnum+1
dbg:	sta $e000
	inc dbg+1
	bne dbgrts
	inc dbg+2
	bne dbgrts
	lda #$e0
	sta dbg+2
dbgrts:	rts


patch:	ldy #$00
	lda #$a0
	sta $23
	sty $22
ploop:	lda ($22),y
	sta ($22),y
	iny
	bne ploop
	inc $23
	lda $23
	cmp #$c0
	bne ploop

	; patch CLR to flush cache, too
	lda #<clrall
	sta $a661
	lda #>clrall
	sta $a662

	; patch GOTO/FNDLIN
	lda #<fndlnc
	sta $a8a4
	lda #>fndlnc
	sta $a8a5

	lda #$4c
	sta $a8a6
	lda #$c3
	sta $a8a7
	lda #$a8
	sta $a8a8

	dec $01
	rts
