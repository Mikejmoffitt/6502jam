wait_nmi:
	lda vblank_waiting
	beq wait_nmi			; Spin here until NMI lets us through
	lda #$01
	sta vblank_waiting 
	rts
