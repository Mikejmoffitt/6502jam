; Clear the OAM table
spr_init:
	ldx #$00
	lda #$FF
@clroam_loop:
	sta OAM_BASE, x
	inx
	cpx #$00
	bne @clroam_loop
	rts
