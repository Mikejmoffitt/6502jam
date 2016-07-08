; Player initialization routines

; ==================================================================
; Initialize players. 
; Presently hardcoded to load two of the only available character.
; TODO: Scrappy hack test that should be removed. 
; ==================================================================
players_init:

	lda #<character_girl
	sta addr_ptr
	lda #>character_girl
	sta addr_ptr + 1
	ldx #$00
	jsr player_load

	lda #<character_girl
	sta addr_ptr
	lda #>character_girl
	sta addr_ptr + 1
	ldx #PLAYER_SIZE
	jsr player_load

	rts

; ==================================================================
; Routine to load a character's graphics, set the stats pointer, etc.
;
; Pre:
;     X: Player offset to load into (0 for P1, PLAYER_SIZE for p2)
;     addr_ptr loaded with address of desired character
; Post:
;     Player struct at X contains requisite character info
;         - Clear player struct
;         - Set player direction
;         - Set player position
;         - Load stats struct pointer (transfer addr_ptr to player_state)
;         - Load anim map pointer (transfer to PLAYER_ANIM_MAPOFF)
;         - Set invalid anim number to force reload
;         - Load palette
;         - Load CHR into VRAM slot
; =================================================================
player_load:

	txa
	pha

; - Clear the player struct
	lda #$00
	tay
@clear_pl_loop:
	sta player_state, x
	inx
	iny
	cpy #PLAYER_SIZE
	bne @clear_pl_loop

; We've manged X; it needs to be put back
	pla
	tax

; - Set player dir
; Now set the player dir based on X
	beq @dir_set
	lda #PLAYER_DIR_LEFT 	; P2 gets left dir
@dir_set:
	sta player_state + PLAYER_DIRXOFF, x

; Also which direciton is being faced
	lda #PLAYER_FACING_RIGHT
	cpx #$00
	beq @facing_set
	lda #PLAYER_FACING_LEFT

@facing_set:
	sta player_state + PLAYER_FACINGOFF, x

; - Set player position

	cpx #$00
	bne @p2_pos
@p1_pos:
; P1 on the left side
	lda playfield_left
	clc
	adc #$10
	jmp @postpos;

@p2_pos:
; P2 on the right
	lda playfield_right
	sec
	sbc #$10
@postpos:
	sta player_state + PLAYER_XOFF+1, x

; Vertical position as well
	lda playfield_top		; A = Playfield top
	lsr				; A = Top/2
	sta temp			
	lda playfield_bottom		; A = Playfield bottom
	lsr				; A = Bottom/2
	clc				
	adc temp			; A += Top/2 == center Y
	; Calculated vertical center
	sta player_state + PLAYER_YOFF+1, x

; - Set up stats struct pointer	
	lda addr_ptr
	sta player_state + PLAYER_STATS_ADDROFF, x
	lda addr_ptr + 1
	sta player_state + PLAYER_STATS_ADDROFF + 1, x

; - Set up anim map pointer
	ldy #STATS_ANIM_PTR
	lda (addr_ptr), y
	sta player_state + PLAYER_ANIM_MAPOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_ANIM_MAPOFF + 1, x

; - Set invalid anim number
	lda #$FF
	sta player_state + PLAYER_ANIM_NUMOFF, x

; - Load player palette
	ldy #STATS_PAL_PTR
	lda (addr_ptr), y
	sta temp
	iny
	lda (addr_ptr), y
	sta temp2

	cpx #$00
	bne @p2_pal_dest
@p1_pal_dest:
	ppu_load_addr #$3F, #$11
	ldy #$01 ; Normal palette, index 1
	jmp @player_pal_set
@p2_pal_dest:
	ldy #$09 ; Alt palette, index 1
	ppu_load_addr #$3F, #$19

@player_pal_set:
	lda (temp), y
	sta PPUDATA	
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA	
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA


; - Load CHR into VRAM
	; Load bank number
	ldy #STATS_CHR_BANK
	lda (addr_ptr), y
	tay
	sta bank_load_table, y

; Back up player ptr into temp
	lda addr_ptr
	sta temp
	lda addr_ptr+1
	sta temp+1

; Put CHR pointer into addr_Ptr
	ldy #STATS_CHR_PTR
	lda (temp), y
	sta addr_ptr
	iny
	lda (temp), y
	sta addr_ptr+1

	ldy #$02 ; Player 1 starts on the third row
	cpx #$00
	beq @do_load
	ldy #$09 ; Player 2 starts on the tenth row
@do_load:
	jsr player_load_gfx

	lda temp
	sta addr_ptr
	lda temp+1
	sta addr_ptr+1

	rts

; =============================================
; Load a player's graphics into a VRAM slot.
; Preconditions:
;	The appropriate bank has been loaded already.
;	addr_ptr points to the CHR data for the player.
;	Y is loaded with the upper VRAM destination address.
; Postconditions:
;	A player's CHR data is loaded into a slot in VRAM.
; =============================================
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
