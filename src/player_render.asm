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
	jsr player_animate
	jsr player_choose_animation
	jsr player_choose_mapping
	jsr player_draw


					; Re-run loop for player 2
	cpx #$0
	bne @draw_finished
	ldx #PLAYER_SIZE
	bne @player_loop

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

	lda $5555
	; Check for the block counter
	lda player_state + PLAYER_BLOCK_CNTOFF, x
	beq :+
	lda #ANIM_BLOCK
	jsr player_set_anim_num
	rts
:


@standard_anim: ; For normal states (no counters, etc)
	lda player_state + PLAYER_DXOFF, x
	bne @moving
	lda player_state + PLAYER_DXOFF + 1, x
	bne @moving
	lda player_state + PLAYER_DYOFF, x
	bne @moving
	lda player_state + PLAYER_DYOFF + 1, x
	bne @moving

	lda #PLAYER_FACING_UP
	cmp player_state + PLAYER_FACINGOFF, x
	beq @facing_up_s
	lda #PLAYER_FACING_DOWN
	cmp player_state + PLAYER_FACINGOFF, x
	beq @facing_down_s

	; If we're here, then we are facing left/right
	lda #ANIM_STAND_FWD
	jsr player_set_anim_num
	rts

@facing_up_s:
	lda #ANIM_STAND_FWD
	jsr player_set_anim_num
	rts

@facing_down_s:
	lda #ANIM_STAND_FWD
	jsr player_set_anim_num
	rts

@moving:
	lda #PLAYER_FACING_UP
	cmp player_state + PLAYER_FACINGOFF, x
	beq @facing_up
	lda #PLAYER_FACING_DOWN
	cmp player_state + PLAYER_FACINGOFF, x
	beq @facing_down
	; If we're here, then we are facing left/right
	lda #ANIM_RUN_FWD
	jsr player_set_anim_num
	rts

@facing_up:
	lda #ANIM_RUN_UP
	jsr player_set_anim_num
	rts

@facing_down:
	lda #ANIM_RUN_DOWN
	jsr player_set_anim_num
	rts

; Sets the player's animation to the number loaded in A. If the animation is
; already loaded, do nothing. Otherwise, reset animation counters.
; Preconditions:
;	A is loaded with the desired animation script
;	X is loaded with the player struct offset
; Postconditions:
;	If a new animation is chosen, player_struct has these fields updated:
;		-Animation script address (ANIM_ADDROFF)
;		-Animation script length (ANIM_LENOFF)
;		-Animation number (ANIM_NUMOFF)
;		-Animation frame accumulator (ANIM_CNTOFF) (reset to zero)
;		-Animation frame number (ANIM_FRAMEOFF) (reset to zero)
player_set_anim_num:

	sta temp3				; Store number argument
	cmp player_state + PLAYER_ANIM_NUMOFF, x
	beq @done
	sta player_state + PLAYER_ANIM_NUMOFF, x
	lda #$00
	sta player_state + PLAYER_ANIM_CNTOFF, x
	sta player_state + PLAYER_ANIM_FRAMEOFF, x

	; First we need the address of the animation script from the map
	lda player_state + PLAYER_ANIM_MAPOFF, x
	sta addr_ptr
	lda player_state + PLAYER_ANIM_MAPOFF + 1, x
	sta addr_ptr + 1

	; addr_ptr now contains the map address
	lda temp3
	asl a					; Multiply by two
	tay					; Get our animation # from A
	lda (addr_ptr), y			; Get lobyte
	sta player_state + PLAYER_ANIM_ADDROFF, x
	sta temp
	iny		
	lda (addr_ptr), y			; Get hibyte
	sta player_state + PLAYER_ANIM_ADDROFF + 1, x
	sta temp2

	; The player struct now has a reference to the chosen animation script.
	; From that we can extract the length, but we need to put it into temp.

	ldy #$00				; First parameter is length.
	lda (temp), y				; A gets animation length
	sta player_state + PLAYER_ANIM_LENOFF, x ; Store it in player struct

@done:
	rts



; Based on current animation number and frame number, choose a mapping to
; draw the player with.
; Preconditions:
;	X is loaded with the player struct offset
; Postconditions:
;	addr_ptr is loaded with the appropriate mapping
player_choose_mapping:

	; Get address of script into temp
	lda player_state + PLAYER_ANIM_ADDROFF, x
	sta temp
	lda player_state + PLAYER_ANIM_ADDROFF + 1, x
	sta temp2

	; Temp contains the script offset; we want the address of the first
	; mapping, which is $02 in

	add16 temp, #$02		; addr_ptr = script's first mapping

	lda player_state + PLAYER_ANIM_FRAMEOFF, x ; Get current frame #
	asl a				
	asl a				; A = index into script for frame
					; A = current frame * 4
	sta temp3
	add16 temp, temp3		; addr_ptr = address of frame now


	; Temp has the address of the animation mapping now.

	ldy #$00
	lda (temp), y			
	sta addr_ptr			; addr_ptr = lowaddr of mapping
	iny
	lda (temp), y
	sta addr_ptr+1			; addr_ptr+1 = hiaddr of mapping

	;addr_ptr now contains the mapping address. 

	rts


; Have the player step through an animation script.
; Preconditions:
;	X is loaded with the player struct offset
;	ANIM_ADDROFF is loaded wtih a valid animation script address.
; Postconditions:
;	ANIM_CNTOFF has incremented, and if it's reached the current frame
;	  length, it will have reset to zero and incremented ANIM_FRAMEOFF.
;	ANIM_FRAMEOFF will reset to zero when it has reached the script length.
player_animate:
	
	; Get address of script into temp
	lda player_state + PLAYER_ANIM_ADDROFF, x
	sta temp
	lda player_state + PLAYER_ANIM_ADDROFF + 1, x
	sta temp2

	add16 temp, #$04		; Point at the duration marker		

	lda player_state + PLAYER_ANIM_FRAMEOFF, x ; Get current frame #
	asl a				
	asl a				; A = index into script for frame
	sta temp3
	add16 temp, temp3

	; Temp points to the current frame's length
	ldy #$00
	lda (temp), y
	sta temp

	; Temp now contains the frame duration to compare against

	; Increment animation accumulator
	ldy player_state + PLAYER_ANIM_CNTOFF, x
	iny
	cpy temp		; Have we reached the end of this frame?
	beq @frame_inc		; If so, increment frame number.
	; Otherwise, just increment the accumulator.
	sty player_state + PLAYER_ANIM_CNTOFF, x
	rts

@frame_inc:
	lda #$00
	sta player_state + PLAYER_ANIM_CNTOFF, x ; Reset frame accumulator
	ldy player_state + PLAYER_ANIM_FRAMEOFF, x
	iny
	tya
	cmp player_state + PLAYER_ANIM_LENOFF, x ; Is the animation over?
	beq @anim_loop	; If so, loop animation
	; Otherwise, just increment the frame number.
	sty player_state + PLAYER_ANIM_FRAMEOFF, x
	rts
@anim_loop:
	; Get address of script into temp
	lda player_state + PLAYER_ANIM_ADDROFF, x
	sta temp
	lda player_state + PLAYER_ANIM_ADDROFF + 1, x
	sta temp2

	add16 temp, #$01		; Point at the loop point	

	ldy #$00
	lda (temp), y
	sta player_state + PLAYER_ANIM_FRAMEOFF, x
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

; Pre-loop entry conditions:
	; Y contains the offset from OAM_BASE to begin writing to (Y pos of first sprite)
	; addr_ptr is a ZP 16-bit pointer to the base of the animation data to copy from
	; addr_ptr has initial Y subtracted from it to counter Y's offset
	; X contains the player state offset (right now it is zero and unused anyway)
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
	sta temp4
	iny				; Y = OAM tile select

	lda $5555
	lda (addr_ptr), y
	cpx #$00			; Are we drawing player 1?
	beq @p1_tile			; Branch for P2's tile offset
@p2_tile:
	clc
	adc #$90			; Offset for P1 VRAM Slot
	jmp @tile_store
@p1_tile:
	clc
	adc #$20			; Offset for P2 VRAM slot
@tile_store:
	sta OAM_BASE, y
	iny				; Y = OAM attributes

	lda (addr_ptr), y
	cpx #$00			; Are we drawing player 1?
	beq @nomod_pal			; Don't modify palette for P1
	ora #%00000010

@nomod_pal:
	; Process X flip for attributes
	rol a
	rol a
	rol a
	eor player_state + PLAYER_DIRXOFF, x; X flip
	ror a
	ror a
	ror a

					; Is sprite below the fence height?
					; If so, set priority to behind BG
	sty temp3
	ldy temp4
	cpy #FENCE_SPR_Y
	bcc :+
	ora #%00100000
:
	ldy temp3

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
	cpy temp			; Hide all remaining sprites
	bne @end_frame			; for this player.
	rts

