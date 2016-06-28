wait_nmi:
	 lda vblank_flag
	 bne wait_nmi			; Spin here until NMI lets us through
	 lda #$01
	 sta vblank_flag
	 rts

; Controller reading code from NESDev
; Out: A=buttons pressed, where bit 0 is A button
read_joypads:
	; Strobe controller
	lda #1
	sta $4016
	sta pad_2
	lsr a
	sta $4016
:
	lda $4016
	and #$03
	cmp #$01
	rol pad_1
	lda $4017
	and #$03
	cmp #$01
	rol pad_2
	bcc :-
	rts

; temp is a zero-page variable

; Reads controller. Reliable when DMC is playing.
; Out: A=buttons held, A button in bit 0
read_joy_safe:
	; Back up previous ones for edge comparisons
	lda pad_1
	sta pad_1_prev
	lda pad_2
	sta pad_2_prev
	; Get first reading
	jsr read_joypads
:
	; Save previous reading
	lda pad_1
	sta temp
	lda pad_2
	sta temp2
	
	; Read again and compare. If they differ,
	; read again.
	jsr read_joypads
	lda pad_1
	cmp temp
	bne :-
	lda pad_2
	cmp temp2
	bne :-
	rts

player_load_gfx:
	lda #$00
	sta temp
	sta temp2
	inc temp2
					; Temp.w contains the amount to increment
					; addr_ptr by during each loop

	ldx #$00			; Lower byte of VRAM destination

; Latch starting address into PPUADDR
	bit PPUSTATUS
	sty PPUADDR
	stx PPUADDR

	ldy #$00
	ldx #$00

; Copy from (addr_ptr), $700 bytes
:
	lda (addr_ptr), y		; Offset within both girl_chr and dest.
	sta PPUDATA
	iny
	bne :-
	sum16 addr_ptr, temp		; Increment source by $100
	inx
	cpx #$07
	bne :-
	rts

fence_mask_draw:
	; Mask bottom of playfield
	lda #FENCE_SPR_Y
	sec
	sbc yscroll
	write_oam_y 1
	write_oam_y 2
	write_oam_y 3
	write_oam_y 4
	write_oam_y 5
	write_oam_y 6
	write_oam_y 7
	write_oam_y 8
	lda #$00
	write_oam_x 1
	write_oam_x 2
	write_oam_x 3
	write_oam_x 4
	write_oam_x 5
	write_oam_x 6
	write_oam_x 7
	write_oam_x 8
	lda #$FF
	write_oam_tile 1
	write_oam_tile 2
	write_oam_tile 3
	write_oam_tile 4
	write_oam_tile 5
	write_oam_tile 6
	write_oam_tile 7
	write_oam_tile 1
	lda #%00100000
	write_oam_attr 1
	write_oam_attr 2
	write_oam_attr 3
	write_oam_attr 4
	write_oam_attr 5
	write_oam_attr 6
	write_oam_attr 7
	write_oam_attr 8
	rts
