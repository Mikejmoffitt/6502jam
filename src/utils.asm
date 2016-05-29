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
					; Temp contains the amount to increment
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

; Initialize players. 
players_init:
	ldx #PLAYER_SIZE*2 - 1
	lda #$00

@clear_players:
	sta player_state, x

	dex
	beq @clear_players

; Load player initial state information

; P1 faces right
	ldx #PLAYER_DIR_RIGHT
	stx player_state + PLAYER_DIRXOFF	
	inx ; X gets PLAYER_DIR_LEFT
; P2 faces left
	stx player_state + PLAYER_DIRXOFF + PLAYER_SIZE

; both players start at half-height on the field
	lda playfield_top		; A = Playfield top
	lsr				; A = Top/2
	sta temp			
	lda playfield_bottom		; A = Playfield bottom
	lsr				; A = Bottom/2
	clc				
	adc temp			; A += Top/2 == center Y
	sta player_state + PLAYER_YOFF+1
	sta player_state + PLAYER_YOFF+1 + PLAYER_SIZE

	lda playfield_top
	sta player_state + PLAYER_YOFF+1

; TODO: Choose graphics based on character selection
	bank_load #02	
	lda #<girl_chr
	sta addr_ptr
	lda #>girl_chr
	sta addr_ptr+1
	ldy #$02
	jsr player_load_gfx
	lda #<girl_chr
	sta addr_ptr
	lda #>girl_chr
	sta addr_ptr+1
	ldy #$09
	jsr player_load_gfx

; TODO: Choose palettes based on character selection
	bank_load #02
	

; TODO: Choose this based on character selection
; temporarily set up player to run the girl's animations
	bank_load #02
	lda #<girl_anim_num_map
	sta player_state + PLAYER_ANIM_MAPOFF
	sta player_state + PLAYER_ANIM_MAPOFF + PLAYER_SIZE
	lda #>girl_anim_num_map
	sta player_state + PLAYER_ANIM_MAPOFF + 1
	sta player_state + PLAYER_ANIM_MAPOFF + 1 + PLAYER_SIZE

; TODO: Also character selected
; Load with stats
	lda #<girl_stats
	sta player_state + PLAYER_STATS_ADDROFF
	lda #<girl_stats
	sta player_state + PLAYER_STATS_ADDROFF + PLAYER_SIZE
	lda #>girl_stats
	sta player_state + PLAYER_STATS_ADDROFF + 1
	lda #>girl_stats
	sta player_state + PLAYER_STATS_ADDROFF + PLAYER_SIZE + 1

; P1 on the left side
	lda playfield_left
	clc
	adc #$10
	sta player_state + PLAYER_XOFF+1
; P2 on the right
	lda playfield_right
	sec
	sbc #$10
	sta player_state + PLAYER_XOFF+1+PLAYER_SIZE

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
