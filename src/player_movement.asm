; Movement and physucs-related player code

; ==============================================
; Player deceleration routine. Used for when sliding.
; Pre-conditions:
;	X is loaded with player struct offset
; Post-conditions:
;	Player's dx/dy have been attenuated
; ==============================================
player_decel:
; Set up addr_ptr with player stats struct
	lda player_state + PLAYER_STATS_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF + 1, x
	sta addr_ptr + 1

; Load correct player's gamepad into temp3
	cpx #$00
	beq @p1_pad
	lda pad_2
	sta temp3
	jmp @load_decel_mag
@p1_pad:
	lda pad_1
	sta temp3

; Choose which stat offset to use
@load_decel_mag:
	lda temp3
	bit btn_a
	bne @a_held
	ldy #STATS_DECEL_F; Stats offset for high deceleration
	bne @load_decel_magnitude ; Cheap relative jump since Z = 0

@a_held:
	ldy #STATS_DECEL_S ; Stats offset for low deceleration

@load_decel_magnitude:
	lda (addr_ptr), y
	sta temp
	iny
	lda (addr_ptr), y
	sta temp+1

@deceleration_start:
	lda player_state + PLAYER_DXOFF, x
	sta temp3
	lda player_state + PLAYER_DXOFF + 1, x
	sta temp3+1

; Check sign of dx
	bpl @dx_positive

@dx_negative:
; Add temp.w to dx.w
	lda temp3
	clc
	adc temp
	sta player_state + PLAYER_DXOFF, x
	lda temp3+1
	adc temp+1
	sta player_state + PLAYER_DXOFF + 1, x
	bmi @dx_final ; If dx is still negative, don't zero it out
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF + 1, x
	jmp @dx_final

@dx_positive:
; Subtract temp.w from dx.w
	lda temp3
	sec
	sbc temp
	sta player_state + PLAYER_DXOFF, x
	lda temp3+1
	sbc temp+1
	sta player_state + PLAYER_DXOFF + 1, x
	bpl @dx_final ; If dx is still positive, don't zero it out
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF + 1, x

@dx_final:

	lda player_state + PLAYER_DYOFF, x
	sta temp3
	lda player_state + PLAYER_DYOFF + 1, x
	sta temp3+1

; Check sign of dy
	bpl @dy_positive

@dy_negative:
; Add temp.w to dy.w
	lda temp3
	clc
	adc temp
	sta player_state + PLAYER_DYOFF, x
	lda temp3+1
	adc temp+1
	sta player_state + PLAYER_DYOFF + 1, x
	bmi @dy_final ; If dy has gone positive, zero it out
	lda #$00
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF + 1, x
	jmp @dy_final

@dy_positive:
; Subtract temp.w from dy.w
	lda temp3
	sec
	sbc temp
	sta player_state + PLAYER_DYOFF, x
	lda temp3+1
	sbc temp+1
	sta player_state + PLAYER_DYOFF + 1, x
	bpl @dy_final ; If dy has gone negative, zero it out
	lda #$00
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF + 1, x

@dy_final:
	rts

; ===============================================
; Player movement support function
; Constrains the player in X to their respective
; movement boundaries.
; Pre-conditions:
;	X is loaded with player struct offset
;	Temp is loaded with the left boundary
;	Temp2 is loaded with the right boundary
; Post-conditions:
;	Player position is snapped to any exceeded side of the field.
; ===============================================
player_check_bounds:

@y_check:
	ldy #$00
	lda player_state + PLAYER_YOFF + 1, x
	; Top of player
	sec
	sbc #PLAYER_H/2
	cmp playfield_top 	; if (player.y < playfield_top)
	bcc @snap_top
	; Add to get the bottom of the player
	clc
	adc #PLAYER_H
	cmp playfield_bottom	; else if (player.y > playfield_top)
	beq @snap_bottom
	bcs @snap_bottom
	bcc @x_check		; else { goto x_check }

@snap_top:
	; If so, snap to top of playfield
	lda playfield_top
	clc
	adc #PLAYER_H/2
	sta player_state + PLAYER_YOFF + 1, x
	sty player_state + PLAYER_YOFF, x
	jmp @x_check

@snap_bottom:
	; If so, snap to bottom of playfield
	lda playfield_bottom
	sec
	sbc #PLAYER_H/2
	sta player_state + PLAYER_YOFF + 1, x
	sty player_state + PLAYER_YOFF, x
	; jmp @x_check

@x_check:
	; Left of player
	ldy #$00
	lda player_state + PLAYER_XOFF + 1, x
	sec
	sbc #PLAYER_W/2
	cmp temp7	 	; if (player.x < playfield_left)
	bcc @snap_left
	; Add to get the right of the player
	clc
	adc #PLAYER_W
	cmp temp8		; else if (player.x > playfield_right)
	beq @snap_right
	bcs @snap_right
	bcc @postloop		; else { goto postloop }

@snap_left:
	; If so, snap to top of playfield
	lda temp7
	clc
	adc #PLAYER_W/2
	sta player_state + PLAYER_XOFF + 1, x
	sty player_state + PLAYER_XOFF, x
	jmp @postloop

@snap_right:
	; If so, snap to bottom of playfield
	lda temp8
	sec
	sbc #PLAYER_W/2
	sta player_state + PLAYER_XOFF + 1, x
	sty player_state + PLAYER_XOFF, x

@postloop:
	rts

; ========================================
; Player movement support function
; Increments/Decrements counters, and affects player movement.
; Pre-conditions:
;	X is loaded with player struct offset
; Post-conditions:
;	Player counters modified, movement potentially halted.
; ========================================
player_counters:
; Only decrement the slide counter if the player is not in motion.
	lda player_state + PLAYER_DXOFF, x
	ora player_state + PLAYER_DXOFF + 1, x
	ora player_state + PLAYER_DYOFF, x
	ora player_state + PLAYER_DYOFF + 1, x
	bne @ignore_slide

; Decrement the slide counter
	lda player_state + PLAYER_SLIDE_CNTOFF, x
	beq :+
	dec player_state + PLAYER_SLIDE_CNTOFF, x
:
@ignore_slide:
; Decrement the block counter
	lda player_state + PLAYER_BLOCK_CNTOFF, x
	beq :+
	dec player_state + PLAYER_BLOCK_CNTOFF, x
:
; Decrement the throw counter
	lda player_state + PLAYER_THROW_CNTOFF, x
	beq :+
	dec player_state + PLAYER_THROW_CNTOFF, x
	bne :+
; Counter just now reached zero! Time to throw the disc.
	jsr player_throw_disc ; <-- player_disc.asm
	;lda #$11
	;jsr disc_spin_left
:

	jsr player_run_hold_counter ; <-- player_disc.asm

	rts

; ========================================
; Player top-level movement routine
; No pre-entry conditions
; ========================================
players_move:
	ldx #$00

; Set up boundaries for position comparisons
	lda playfield_left
	sta temp7
	lda playfield_center
	sta temp8

@toploop:

; Is the player holding the disc?
	lda player_state + PLAYER_HOLDING_DISCOFF, x
; If so, go straight to counters and don't do any movement
	bne @counters

; Process basic newtonian movement for both players
	clc
	lda player_state + PLAYER_XOFF, x
	adc player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_XOFF, x
	lda player_state + PLAYER_XOFF + 1, x
	adc player_state + PLAYER_DXOFF + 1, x
	sta player_state + PLAYER_XOFF + 1, x

	clc
	lda player_state + PLAYER_YOFF, x
	adc player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_YOFF, x
	lda player_state + PLAYER_YOFF + 1, x
	adc player_state + PLAYER_DYOFF + 1, x
	sta player_state + PLAYER_YOFF + 1, x

; If slide count is > 0, run decelleration
	lda player_state + PLAYER_SLIDE_CNTOFF, x
	beq @no_decel

	jsr player_decel

@no_decel:

	jsr player_check_bounds

@counters:
	jsr player_counters

@postloop:
	cpx #$00
	bne @endloop

; Change X bounds for Player 2's loop
	lda playfield_right
	sta temp8
	lda playfield_center
	sta temp7
	ldx #PLAYER_SIZE
	jmp @toploop

@endloop:
	rts

; ====================================================
; Routine to have players respond to controller inputs
; Encapsulates several other routines which run.
; No pre-entry conditions must be gauranteed.
; ====================================================
players_handle_input:

	ldx #$00			; Start with P1
@toploop:
        lda player_state + PLAYER_SLIDE_CNTOFF, x	;Is the player sliding?
        cmp #$00			; If so,
        bne @post_inputs		; Skip input handling

@normal_state_inputs:
	jsr player_input_dpad
	jsr player_input_buttons

; --- End of Loop ---
@post_inputs:
	cpx #$00			; Did we just check player 1?
	bne @endloop 			; If not, we're done here (both done)
	ldx #PLAYER_SIZE		; Now it's time to check player 2's
	bne @toploop
@endloop:
	rts


; ===================================================
; Support subroutine for player_input_buttons
; Preconditions:
;	X is loaded with the offset for the player
; Postconditions:
;	Temp and Temp2 contain the pad and pad_prev data for the player
; ===================================================
player_load_pad_to_temp:

; Load appropriate pad for P1 or P2 into temp and temp2
	cpx #$00
	bne @p2_check
	lda pad_1
	sta temp
	lda pad_1_prev
	sta temp2
	rts

@p2_check:
	lda pad_2
	sta temp
	lda pad_2_prev
	sta temp2

	rts

; ====================================================
; A/B buttons subroutine for the input handler
; Preconditions:
;	X is loaded with the offset for the player
; Postconditions:
;	Player has slide or block counters set based on inputs
; ====================================================
player_input_buttons:
	lda player_state + PLAYER_HOLDING_DISCOFF, x
	beq @not_holding_disc
	jsr player_load_pad_to_temp

; If the throw counter is non-zero, don't accept inputs here
	lda player_state + PLAYER_THROW_CNTOFF, x
	beq :+
	rts
:

; If the player hits A, set the throw countdown
; Throw type is zero, for a normal throw
	; Has A just been pressed?
	lda temp
	bit btn_a
	beq :+
	lda temp2
	bit btn_a
	bne :+
	beq :++
: ; NOT pressed
	jmp @b_check

: ; Pressed

	lda #PLAYER_THROW_DELAY
	sta player_state + PLAYER_THROW_CNTOFF, x

; TODO: Check if player is charged
	lda #THROW_NORMAL
	sta player_state + PLAYER_THROW_TYPEOFF, x
	rts

; If the player hits A, set the countdown, but mark it
; as a lob in TYPEOFF
@b_check:
	lda temp
	bit btn_b
	beq :+
	lda temp2
	bit btn_b
	bne :+
	beq :++
: ; NOT pressed
	rts
: ; Pressed

	lda #PLAYER_THROW_DELAY
	sta player_state + PLAYER_THROW_CNTOFF, x

; TODO: Check if player is charged
	lda #THROW_LOB
	sta player_state + PLAYER_THROW_TYPEOFF, x
	rts



@not_holding_disc:

; If either counter is non-zero, don't accept inputs here
	lda player_state + PLAYER_SLIDE_CNTOFF, x
	beq :+
	rts
:
; Blocking counter
	lda player_state + PLAYER_BLOCK_CNTOFF, x
	beq :+
	rts
:
; If the player is charging, don't accept inputs
	lda player_state + PLAYER_CHARGE_CNTOFF, x
	beq :+
	rts
:

; Check if the player hit A
	jsr player_load_pad_to_temp
	lda temp
	bit btn_a
	beq :+
	lda temp2
	bit btn_a
	bne :+
	beq :++

: ; NOT pressed
	rts

: ; Pressed

; Check if the player is moving
; At this point, A = 0 (otherwise we would not be here)
	lda player_state + PLAYER_DXOFF, x
	ora player_state + PLAYER_DXOFF + 1, x
	ora player_state + PLAYER_DYOFF, x
	ora player_state + PLAYER_DYOFF + 1, x

; If dx or dy are nonzero, modify the slide counter.
	bne @do_slide

; Otherwise, we'll set the block counter and halt the player.
@do_block:
	lda #(PLAYER_BLOCK_DELAY)
	sta player_state + PLAYER_BLOCK_CNTOFF, x
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF + 1, x
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF + 1, x
	rts

@do_slide:
; Set the slide counter, and launch the player.

; If the d-pad isn't being pressed, don't do anything.
	lda temp
	and #(BUTTON_RIGHT|BUTTON_LEFT|BUTTON_UP|BUTTON_DOWN)
	beq @end_dir_check

; Set the counter.
	lda #(PLAYER_SLIDE_DELAY)
	sta player_state + PLAYER_SLIDE_CNTOFF, x

; Set up addr_ptr with player stats struct
	lda player_state + PLAYER_STATS_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF + 1, x
	sta addr_ptr + 1

; Launch the player
@right_check:
	; Check if right is hold
	lda temp
	bit btn_right
	beq @left_check ; if we're not holding right, check for left

	; Load velocity for dx
	ldy #STATS_DASH_STR			; 3rd word, for dash strength (LSB)
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF, x
	iny				; Now grab the MSB
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF + 1, x

	; dx now contains positive slide velocity

	jmp @y_check

@left_check:
	; now check for left d-pad
	bit btn_left
	beq @no_dx ; if we're not holding left at this point, skip to up/down

	; Load velocity for dx
	ldy #STATS_DASH_STR			; 3rd word, for dash strength (LSB)
	lda #$00
	sec
	sbc (addr_ptr), y		; Negate it
	sta player_state + PLAYER_DXOFF, x
	iny				; Now grab the MSB
	lda #$00
	sbc (addr_ptr), y		; Once more negate dx
	sta player_state + PLAYER_DXOFF + 1, x

	; dx now contains negative slide velocity

	jmp @y_check


@no_dx:
	; Zero out dx, because neither left nor right were held.
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF + 1, x

@y_check:
	; Re-load pad, A may have been mangled
	lda temp
	; Check for up.
	bit btn_up
	beq @down_check

	; Load velocity for dy
	ldy #STATS_DASH_STR
	lda #$00
	sec
	sbc (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	iny
	lda #$00
	sbc (addr_ptr), y
	sta player_state + PLAYER_DYOFF + 1, x

	jmp @end_dir_check

@down_check:

	lda temp
	bit btn_down
	beq @end_dir_check

	ldy #STATS_DASH_STR			; 3rd word, for dash strength (LSB)
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	iny				; Now grab the MSB
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF + 1, x

@end_dir_check:
@a_not_pressed:

	rts

; ====================================================
; D-pad subroutine for the input handler
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; Postconditions:
;	Player state struct has been modified based on D-Pad inputs
; ====================================================
player_input_dpad:
	lda player_state + PLAYER_HOLDING_DISCOFF, x
	beq @not_holding_disc
; Disc is held, check for curved throws
	jsr player_detect_rotation
	rts

@not_holding_disc:
; First check validity - if the player is blocking, sliding, charging, or
; throwing, ignore the dpad here.
	lda player_state + PLAYER_SLIDE_CNTOFF, x
	beq :+
	rts
:
	lda player_state + PLAYER_BLOCK_CNTOFF, x
	beq :+
	rts
:
	lda player_state + PLAYER_CHARGE_CNTOFF, x
	beq :+
	rts
:
	lda player_state + PLAYER_THROW_CNTOFF, x
	beq :+
	rts
:

@handle_accel_top:			; Top of this loop, run twice
	cpx #$00			; Which player?
	bne @p2_check			; Branch for player 2
	lda #PLAYER_DIR_RIGHT
	sta temp5
	lda pad_1
	sta temp3
	lda pad_1_prev
	sta temp4
	jmp @handle_directions		; Now to check buttons

@p2_check:
	lda #PLAYER_DIR_LEFT
	sta temp5
	lda pad_2
	sta temp3
	lda pad_2_prev
	sta temp4

; Pre-entry conditions:
;	temp3 is loaded with pad state capture
;	temp4 is loaded with previous frame's pad state capture
; 	temp5 is loaded with  the direction the player should neutrally face
@handle_directions:

	lda temp3			; Y = pad to check
	and #(BUTTON_RIGHT|BUTTON_LEFT|BUTTON_UP|BUTTON_DOWN)
	tay

	lda player_state + PLAYER_STATS_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF + 1, x
	sta addr_ptr + 1
	; addr_ptr gets the stats block for the player

; Orthagonals are checked first.
	cpy #(BUTTON_RIGHT)
	bne :+
	ldy #STATS_WALK_S
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF+1, x
	lda #$00
	sta player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF+1, x
	sta player_state + PLAYER_DIRXOFF, x
	lda #PLAYER_FACING_RIGHT
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_DOWN)
	bne :+
	ldy #STATS_WALK_S
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF+1, x
	lda temp5
	sta player_state + PLAYER_DIRXOFF, x
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF+1, x
	sta player_state + PLAYER_DIRYOFF, x
	lda #PLAYER_FACING_DOWN
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_UP)
	bne :+
	ldy #STATS_WALK_S
	lda (addr_ptr), y
	sta temp
	iny
	lda (addr_ptr), y
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
	lda temp5
	sta player_state + PLAYER_DIRXOFF, x
	lda #PLAYER_FACING_UP
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
        jmp @ldpad

@ldpad:
	cpy #(BUTTON_LEFT)
	bne :+
	ldy #STATS_WALK_S
	lda (addr_ptr), y
	sta temp
	iny
	lda (addr_ptr), y
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
	lda #PLAYER_FACING_LEFT
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:

; Diagonals are checked second
	cpy #(BUTTON_RIGHT | BUTTON_DOWN)
	bne :+
	ldy #STATS_WALK_D
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF+1, x
	dey
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF+1, x
	lda #$00
	sta player_state + PLAYER_DIRXOFF, x
	sta player_state + PLAYER_DIRYOFF, x
	lda #PLAYER_FACING_RIGHT
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_RIGHT | BUTTON_UP)
	bne :+
	ldy #STATS_WALK_D
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF, x
	sta temp
	iny
	lda (addr_ptr), y
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
	lda #PLAYER_FACING_RIGHT
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_LEFT | BUTTON_UP)
	bne :+
	ldy #STATS_WALK_D
	lda (addr_ptr), y
	sta temp
	iny
	lda (addr_ptr), y
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
	lda #PLAYER_FACING_LEFT
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
	cpy #(BUTTON_LEFT | BUTTON_DOWN)
	bne :+
	ldy #STATS_WALK_D
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	sta temp
	iny
	lda (addr_ptr), y
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
	lda #PLAYER_FACING_LEFT
	sta player_state + PLAYER_FACINGOFF, x
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
	rts
