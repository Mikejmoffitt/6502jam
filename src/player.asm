.include "../assets/cmaps/girl.asm"

PLAYER_W = $18
PLAYER_H = $20

PLAYER_SPR_NUM = 18


PLAYER_DIR_RIGHT = $00
PLAYER_DIR_LEFT = $01

; Struct access offsets
PLAYER_XOFF = $00
PLAYER_YOFF = $02
PLAYER_DXOFF = $04
PLAYER_DYOFF = $06
PLAYER_NUMOFF = $08
PLAYER_DIRXOFF = $09
PLAYER_DIRYOFF = $0a
PLAYER_SLIDE_CNTOFF = $0b
PLAYER_BLOCK_CNTOFF = $0c
PLAYER_SPR_NUMOFF = $0d
PLAYER_ANIM_FRAMEOFF = $0e

; Player struct size
PLAYER_OFFSET = $0e

players_init:
	ldx #PLAYER_OFFSET*2 - 1
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
	stx player_state + PLAYER_DIRXOFF + PLAYER_OFFSET

; both players start at half-height on the field
	lda playfield_top		; A = Playfield top
	lsr				; A = Top/2
	sta temp			
	lda playfield_bottom		; A = Playfield bottom
	lsr				; A = Bottom/2
	clc				
	adc temp			; A += Top/2 == center Y
	sta player_state + PLAYER_YOFF+1
	sta player_state + PLAYER_YOFF+1 + PLAYER_OFFSET

; P1 on the left side
	lda playfield_left
	clc
	adc #$10
	sta player_state + PLAYER_XOFF+1
; P2 on the right
	lda playfield_right
	sec
	sbc #$10
	sta player_state + PLAYER_XOFF+1+PLAYER_OFFSET


	rts

; Move players about based on vector variables
players_move:

	sum16 player_state+PLAYER_XOFF, player_state+PLAYER_DXOFF
	sum16 player_state+PLAYER_YOFF, player_state+PLAYER_DYOFF
	sum16 player_state+PLAYER_OFFSET+PLAYER_XOFF, player_state+PLAYER_OFFSET+PLAYER_DXOFF
	sum16 player_state+PLAYER_OFFSET+PLAYER_YOFF, player_state+PLAYER_OFFSET+PLAYER_DYOFF

@xy_done:

	rts
	
; D-pad subroutine for the input handler
players_input_dpad:
	ldx #$00			; Start by checking player 1's inputs

@handle_accel_top:			; Top of this loop, run twice
	cpx #$00			; Which player?
	bne @p2_check			; Branch for player 2
	lda pad_1
	sta temp3
	lda pad_1_prev
	sta temp4
	jmp @handle_directions		; Now to check buttons

@p2_check:
	lda pad_2
	sta temp3
	lda pad_2_prev
	sta temp4
; Pre-entry conditions:
;	addr_ptr is loaded with the address of the controller to check
@handle_directions:

	lda temp3			; Y = pad to check
	and #(BUTTON_RIGHT|BUTTON_LEFT|BUTTON_UP|BUTTON_DOWN)
	tay

; Orthagonals are checked first.
	cpy #(BUTTON_RIGHT)
	bne :+
	lda girl_stats + 0
	sta player_state + PLAYER_DXOFF, x
	lda girl_stats + 1
	sta player_state + PLAYER_DXOFF+1, x
	lda #$00
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF+1, x
	sta player_state + PLAYER_DIRXOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_DOWN)
	bne :+
	lda girl_stats + 0
	sta player_state + PLAYER_DYOFF, x
	lda girl_stats + 1
	sta player_state + PLAYER_DYOFF+1, x
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF+1, x
	sta player_state + PLAYER_DIRYOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_UP)
	bne :+
	lda girl_stats + 0
	sta temp
	lda girl_stats + 1
	sta temp2
	neg16 temp
	lda temp
	sta player_state + PLAYER_DYOFF, x
	lda temp2
	sta player_state + PLAYER_DYOFF+1, x
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF+1, x
	lda #$01
	sta player_state + PLAYER_DIRYOFF, x
	jmp @post_dpad
:
        jmp @ldpad

@ldpad:
	cpy #(BUTTON_LEFT)
	bne :+
	lda girl_stats + 0
	sta temp
	lda girl_stats + 1
	sta temp2
	neg16 temp
	lda temp
	sta player_state + PLAYER_DXOFF, x
	lda temp2
	sta player_state + PLAYER_DXOFF+1, x
	lda #$00
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF+1, x
	lda #$01
	sta player_state + PLAYER_DIRXOFF, x
	jmp @post_dpad
:

; Diagonals are checked second
	cpy #(BUTTON_RIGHT | BUTTON_DOWN)
	bne :+
	lda girl_stats + 2
	sta player_state + PLAYER_DXOFF, x
	lda girl_stats + 3
	sta player_state + PLAYER_DXOFF+1, x
	lda girl_stats + 2
	sta player_state + PLAYER_DYOFF, x
	lda girl_stats + 3
	sta player_state + PLAYER_DYOFF+1, x 
	lda #$00
	sta player_state + PLAYER_DIRXOFF, x
	sta player_state + PLAYER_DIRYOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_RIGHT | BUTTON_UP)
	bne :+
	lda girl_stats + 2
	sta player_state + PLAYER_DXOFF, x 
	sta temp
	lda girl_stats + 3
	sta player_state + PLAYER_DXOFF+1, x 
	sta temp2
	neg16 temp
	lda temp
	sta player_state + PLAYER_DYOFF, x
	lda temp+1
	sta player_state + PLAYER_DYOFF + 1, x
	lda #$00
	sta player_state + PLAYER_DIRXOFF, x
	lda #$01
	sta player_state + PLAYER_DIRYOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_LEFT | BUTTON_UP)
	bne :+
	lda girl_stats + 2
	sta temp
	lda girl_stats + 3
	sta temp2
	neg16 temp
	lda temp
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DYOFF, x
	lda temp+1
	sta player_state + PLAYER_DXOFF + 1, x
	sta player_state + PLAYER_DYOFF + 1, x
	lda #$01
	sta player_state + PLAYER_DIRXOFF, x
	sta player_state + PLAYER_DIRYOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_LEFT | BUTTON_DOWN)
	bne :+
	lda girl_stats + 2
	sta player_state + PLAYER_DYOFF, x
	sta temp
	lda girl_stats + 3
	sta player_state + PLAYER_DYOFF+1, x
	sta temp2
	neg16 temp
	lda temp
	sta player_state + PLAYER_DXOFF, x
	lda temp+1
	sta player_state + PLAYER_DXOFF + 1, x
	lda #$01
	sta player_state + PLAYER_DIRXOFF, x
	lda #$00
	sta player_state + PLAYER_DIRYOFF, x
	jmp @post_dpad
:

; No button presses detected; zero out player movement.
@nodpad:
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF+1, x
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF+1, x
; A pad has been checked; see if we need to now check the other or if we 
; are completely finished.
@post_dpad:


	cpx #$00			; Did we just check player 1?
	bne @endloop 			; If not, we're done here (both done)
	ldx #PLAYER_OFFSET		; Now it's time to check player 2's
	jmp @handle_accel_top

@endloop:
	rts


; Have players respond to gamepad input.
; No special pre-entry conditions.
players_handle_input:

        lda player_state + PLAYER_SLIDE_CNTOFF, x
        cmp #$00
        bne @post_dpad
	jsr players_input_dpad
@post_dpad:

	rts

; Draws a shadow below the players, much like the disc has
player_draw_shadow:

	rts

; Responsible for drawing both players to the screen based on state structs.
players_draw:

	key_isdown pad_1, btn_left
	lda #$01
	sta player_state + PLAYER_DIRXOFF
:

	key_isdown pad_1, btn_right
	lda #$00
	sta player_state + PLAYER_DIRXOFF
:

; Set some sprite base numbers
	lda frame_counter
	and #%00000001
	beq @p1_first
	ldx #PLAYER_SPR_NUM
	jmp @set_p1spr
@p1_first:
	ldx #PLAYER_SPR_NUM+16
@set_p1spr:
	txa
	sta player_state + PLAYER_SPR_NUMOFF

	lda frame_counter
	and #%00000001
	beq @p2_first
	ldx #PLAYER_SPR_NUM+16
	jmp @set_p2spr
@p2_first:
	ldx #PLAYER_SPR_NUM
@set_p2spr:
	txa
	sta player_state + PLAYER_SPR_NUMOFF + PLAYER_OFFSET

	ldx #$00

; Calculate frame to draw
	lda frame_counter
	tay
	and #%00001000
	beq @load_f0
	tya
	and #%00010000
	beq @load_f1
@load_f2:
	lda #<girl_mapping_fwd2
	sta addr_ptr
	lda #>girl_mapping_fwd2
	sta addr_ptr+1
	jmp @draw

@load_f1:
	lda #<girl_mapping_fwd1
	sta addr_ptr
	lda #>girl_mapping_fwd1
	sta addr_ptr+1
	jmp @draw

@load_f0:
	lda #<girl_mapping_fwd0
	sta addr_ptr
	lda #>girl_mapping_fwd0
	sta addr_ptr+1
@draw:

	jsr player_draw

@otherplayer:
	ldx #PLAYER_OFFSET
	lda #<girl_mapping_fwd2
	sta addr_ptr
	lda #>girl_mapping_fwd2
	sta addr_ptr+1

	jsr player_draw
	rts

; Draws a player to the screen; called by players_draw.
; Pre-entry conditions:
; X is loaded with the player struct offset
; addr_ptr is loaded with the address of the animation frame struct.
player_draw:

	lda player_state + PLAYER_SPR_NUMOFF, x
	asl a				; * 2
	asl a				; * 2
	tay				 ; Y = index into OAM table

	clc
	adc #$30
	sta temp				; Y base case

	sty temp2			 ; OAM index offset
	sub16 addr_ptr, temp2		 ; Subtract to correct for Y off

	lda #%00000010			; Store for
	sta temp2			 ; Palette comparison


; Pre-loop entry conditions:
	; Y contains the offset from OAM_BASE to begin writing to (Y pos of first sprite)
	; addr_ptr is a ZP 16-bit pointer to the base of the animation data to copy from
	; addr_ptr has initial Y subtracted from it to counter Y's offset
	; X contains the player state offset (right now it is zero and unused anyway)
	; temp2 contains #%00000010 for an attribute modification, presently unused
	; temp contains Y + 48, which is the base case to end this loop
@oam_copy_loop:
					; Y = OAM Y position
	; Y position
	lda (addr_ptr), y		; Y pos relative to player
	cmp #$FF			; Check unused flag
	beq @end_frame			; Y-Pos was $FF; terminate loop
	clc
	adc player_state + PLAYER_YOFF + 1, x ; Offset from player's Y center
	sta OAM_BASE, y
	iny				; Y = OAM tile select

	lda (addr_ptr), y
	sta OAM_BASE, y
	iny				; Y = OAM attributes

	lda (addr_ptr), y
	cpx #$00
	beq @nomod_pal			; Don't modify palette for P1
	bit temp2			; Only modify the palette to #3
	beq @nomod_pal			; if palette #2 is being used
	ora #%00000001

@nomod_pal:
	rol a
	rol a
	rol a
	eor player_state + PLAYER_DIRXOFF, x ; X flip
	ror a
	ror a
	ror a
	sta OAM_BASE, y
	iny				 ; Y = OAM X position


	lda player_state + PLAYER_DIRXOFF, x
	beq @noflipx
	lda #$00
	sec
	sbc (addr_ptr), y		 ; Reverse relative X position
	sec
	sbc #$08
	clc
	adc player_state + PLAYER_XOFF + 1, x ; Offset from player's X center
	sec
	sta OAM_BASE, y
	iny
	cpy temp
	bne @oam_copy_loop
	rts

@noflipx:
	lda (addr_ptr), y		 ; X pos relative to player
	clc				 ; Add one to X offset
	adc player_state + PLAYER_XOFF + 1, x ; Offset from player's X center
	sta OAM_BASE, y
	iny

	cpy temp
	bne @oam_copy_loop
	rts

; This branch is for when a sprite is to be hidden so we can ignore everything
; other than the Y position
@end_frame:
	sta OAM_BASE, y			 ; Hide this sprite
	iny
	iny
	iny
	iny
	cpy temp				; Hide all remaining sprites
	bne @end_frame			; for this player.
	rts
