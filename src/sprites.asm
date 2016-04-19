; Clear the OAM table
spr_init:
	ldx #$00
	lda #$00
	sta next_spr			; Zero out pointer to next sprite to plcae
	lda #$FF
@clroam_loop:
	sta OAM_BASE, x
	inx
	cpx #$00
	bne @clroam_loop
	rts
