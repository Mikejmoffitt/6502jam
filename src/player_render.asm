; Animation and rendering related player code

; Responsible for drawing both players to the screen based on state structs.
; No particular pre-conditions; this is a wrapper for the various subroutines
; which draw both players to the screen.
players_draw:
; Precondition routines run on both players
	 jsr player_select_draw_priority

; Things that are one once per player
; Iterations:
;	1. X is loaded with 0
;	2. X is loaded with PLAYER_SIZE
;	3. n/a

	ldx #$00			; Loop runs first for player 1.

@player_loop:
	jsr player_choose_animation
	jsr player_choose_mapping
	jsr player_draw

					; Re-run loop for player 2
	cpx #$0
	bne @draw_finished
	ldx #PLAYER_SIZE
	jmp @player_loop

; --- End of loop ---
@draw_finished:
	rts

; Based on player state (position, action, etc) choose an animation sequence
; to run. I
; Preconditions:
;	X is loaded with the player struct offset
; Postconditions:
;	If appropriate, the player's animation number will have changed, and
;	the animation address will update as well.
player_choose_animation:
	lda #$00
	jsr player_set_anim_num
	rts


; Sets the player's animation to the number loaded in A. If the animation is
; already loaded, do nothing. Otherwise, reset animation counters.
; Preconditions:
;	X is loaded with the player struct offset
player_set_anim_num:


	cmp player_state + PLAYER_ANIM_NUMOFF, x
	;beq @done
	sta player_state + PLAYER_ANIM_NUMOFF, x
	lda #$00
	sta player_state + PLAYER_ANIM_CNTOFF, x
	sta player_state + PLAYER_ANIM_FRAMEOFF, x

	
	asl a					
	tay					; Y = lookup into script table

	lda player_state + PLAYER_ANIM_LOOKUPOFF, x
	sta addr_ptr
	lda player_state + PLAYER_ANIM_LOOKUPOFF + 1, x
	sta addr_ptr+1

	; TEMPORARY BAD HACK
	lda #<girl_anim_num_lookup
	sta addr_ptr
	lda #>girl_anim_num_lookup
	sta addr_ptr+1
	; addr_ptr = script address

	lda (addr_ptr), y			; Lower address of anim script
	sta player_state + PLAYER_ANIM_ADDROFF, x
	iny
	lda (addr_ptr), y			; Upper address of anim script
	sta player_state + PLAYER_ANIM_ADDROFF+1, x
	dey

	; ADDROFF contains animation script top

	; Load length from the animation script header
	lda player_state + PLAYER_ANIM_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_ANIM_ADDROFF + 1, x
	sta addr_ptr + 1

	; addr_ptr is the top of the script now
	ldy #$00
	lda (addr_ptr), y
	sta player_state + PLAYER_ANIM_LENOFF, x

@done:
	rts



; Based on current animation number and frame number, choose a mapping to
; draw the player with.
; Preconditions:
;	X is loaded with the player struct offset
; Postconditions:
;	addr_ptr is loaded with the animation frame struct's animation
player_choose_mapping:

	sta $5555
	lda player_state + PLAYER_ANIM_ADDROFF, x
	sta temp
	lda player_state + PLAYER_ANIM_ADDROFF + 1, x
	sta temp2

	add16 temp, #$02		; addr_ptr = script's first frame
	lda player_state + PLAYER_ANIM_FRAMEOFF, x
	asl a
	asl a				; A = index into script for frame
	sta temp3
	add16 temp, temp3		; addr_ptr = *frame address

	ldy #$00
	lda (temp), y
	sta addr_ptr
	lda (temp+1), y
	sta addr_ptr+1

	rts


	;temp & temp2 now point at the animation script


	lda temp
	sta addr_ptr
	lda temp2
	sta addr_ptr+1

	add16 addr_ptr, #$02
	rts

; Test mapping which actually works
;	lda #<girl_mapping_fwd2
;	sta addr_ptr
;	lda #>girl_mapping_fwd2
;	sta addr_ptr+1

	rts


; Based on current frame %2, select either player 1 or player 2 to receive a 
; higher sprite index. This is to resolve flicker should it become a problem.
; Preconditions:
;	-
; Postconditions:
;	Players have had their SPRNUM variable modified appropriately.
player_select_draw_priority:
	lda frame_counter
	and #%00000001
	beq @p1_first

; Player 2 priority
	lda #PLAYER_SPR_NUM+16
	sta player_state + PLAYER_SPR_NUMOFF
	lda #PLAYER_SPR_NUM
	sta player_state + PLAYER_SPR_NUMOFF + PLAYER_SIZE
	rts
@p1_first:
; Player 1 priority
	lda #PLAYER_SPR_NUM
	sta player_state + PLAYER_SPR_NUMOFF
	lda #PLAYER_SPR_NUM+16
	sta player_state + PLAYER_SPR_NUMOFF + PLAYER_SIZE
	rts


; Draws a player to the screen; called by players_draw.
; Preconditions:
;	X is loaded with the player struct offset
;	addr_ptr is loaded with the address of the animation frame struct.
player_draw:

	lda player_state + PLAYER_SPR_NUMOFF, x
	asl a				; * 2
	asl a				; * 2
	tay				; Y = index into OAM table

	clc
	adc #$30
	sta temp			; Y base case

	sty temp2			; OAM index offset
	sub16 addr_ptr, temp2		; Subtract to correct for Y off

	lda #%00000010			; Store for
	sta temp2			; Palette comparison


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
	adc player_state + PLAYER_YOFF + 1, x; Offset from player's Y center
	sec
	sbc yscroll			; Factor in scrolling position
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
	eor player_state + PLAYER_DIRXOFF, x; X flip
	ror a
	ror a
	ror a
	sta OAM_BASE, y
	iny				; Y = OAM X position


	lda player_state + PLAYER_DIRXOFF, x
	beq @noflipx
	lda #$00
	sec
	sbc (addr_ptr), y		; Reverse relative X position
	sec
	sbc #$08
	sec
	sbc xscroll			; Factor in scrolling position
	clc
	adc player_state + PLAYER_XOFF + 1, x; Offset from player's X center
	sec
	sta OAM_BASE, y
	iny
	cpy temp
	bne @oam_copy_loop
	rts

@noflipx:
	lda (addr_ptr), y		; X pos relative to player
	clc				; Add one to X offset
	adc player_state + PLAYER_XOFF + 1, x; Offset from player's X center
	sec
	sbc xscroll			; Factor in scrolling position
	sta OAM_BASE, y
	iny

	cpy temp
	bne @oam_copy_loop
	rts

; This branch is for when a sprite is to be hidden so we can ignore everything
; other than the Y position
@end_frame:
	sta OAM_BASE, y			; Hide this sprite
	iny
	iny
	iny
	iny
	cpy temp				; Hide all remaining sprites
	bne @end_frame			; for this player.
	rts

