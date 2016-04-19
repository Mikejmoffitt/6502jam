wait_nmi:
	lda vblank_flag				
	cmp #$00				; Wait for the blank flag to be zero
	bne wait_nmi			; Spin here until NMI lets us through
	lda #$01
	sta vblank_flag
	rts


