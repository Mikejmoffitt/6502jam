; Movement and physucs-related player code

; ========================================
; Collision checks against disc 
; No preconditions.
players_check_disc:
	ldx #$00
	jsr player_check_disc
	ldx #PLAYER_SIZE
	jsr player_check_disc
	rts


; ========================================
; Check one player against the disc.
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
player_check_disc:
; Check left of disc against right of player
	lda player_state + PLAYER_XOFF + 1, x
	clc
	adc #PLAYER_W/2
	sta temp

	lda disc_state + DISC_XOFF + 1
	sec
	sbc #DISC_W/2

	cmp temp
	beq @nocollision
	bcs @nocollision

; Check right of disc against left of player
	lda player_state + PLAYER_XOFF + 1, x
	sec
	sbc #PLAYER_W/2
	sta temp

	lda disc_state + DISC_XOFF + 1
	clc
	adc #DISC_W/2

	cmp temp
	bcc @nocollision

; Check top of disc against bottom of player
	lda player_state + PLAYER_YOFF + 1, x
	clc
	adc #PLAYER_H/2
	sta temp

	lda disc_state + DISC_YOFF + 1
	sec
	sbc #DISC_H/2

	cmp temp
	beq @nocollision
	bcs @nocollision

; Check bottom of disc against top of player
	lda player_state + PLAYER_YOFF + 1, x
	sec
	sbc #PLAYER_H/2
	sta temp

	lda disc_state + DISC_YOFF + 1
	clc
	adc #DISC_H/2

	cmp temp
	bcc @nocollision

; Collision:	

@nocollision:
	
	rts

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

; Load temp.w with deceleration amount
	ldy #$06
	lda (addr_ptr), y
	sta temp
	iny
	lda #$00
	lda (addr_ptr), y
	sta temp2
	sta $5555 ; debug poke

; Put abs(dx+1) in temp3 to compare magnitude with dash
	lda player_state + PLAYER_DXOFF + 1, x
	bpl @no_invert_dx
	lda #$00
	sec
	sbc player_state + PLAYER_DXOFF + 1, x

@no_invert_dx:
; Compare magnitude of dx to dash
	cmp temp2
	bcs @no_clamp_dx
	lda #$00
	sta player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF + 1, x
	jmp @dx_final

; Magnitude is less; do the deceleration.
@no_clamp_dx:

; Check sign of dx
	lda player_state + PLAYER_DXOFF + 1, x
	and #%10000000
	beq @dx_pos

@dx_neg:
; Add temp.w to dx.w
	clc
	lda player_state + PLAYER_DXOFF, x
	adc temp
	sta player_state + PLAYER_DXOFF, x
	lda player_state + PLAYER_DXOFF + 1, x
	adc temp + 1
	sta player_state + PLAYER_DXOFF + 1, x
	jmp @dx_final

@dx_pos:
; Subtract temp.w from dx.w
	sec
	lda player_state + PLAYER_DXOFF, x
	sbc temp
	sta player_state + PLAYER_DXOFF, x
	lda player_state + PLAYER_DXOFF + 1, x
	sbc temp + 1
	sta player_state + PLAYER_DXOFF + 1, x
	jmp @dx_final

@dx_final:
; TODO: Above logic, with Dy
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
	cmp temp	 	; if (player.x < playfield_left)
	bcc @snap_left
	; Add to get the right of the player
	clc
	adc #PLAYER_W
	cmp temp2		; else if (player.x > playfield_right)
	beq @snap_right
	bcs @snap_right
	bcc @postloop		; else { goto postloop }

@snap_left:
	; If so, snap to top of playfield
	lda temp
	clc
	adc #PLAYER_W/2
	sta player_state + PLAYER_XOFF + 1, x
	sty player_state + PLAYER_XOFF, x
	jmp @postloop

@snap_right:
	; If so, snap to bottom of playfield
	lda temp2
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
	beq @ignore_slide

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
:
	rts

; ========================================
; Player top-level movement routine
; No pre-entry conditions
; ========================================
players_move:
	ldx #$00
	lda playfield_left
	sta temp
	lda playfield_center
	sta temp2

@toploop:

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
	jsr player_counters

@postloop:
	cpx #$00
	bne @endloop
	; Change X bounds for Player 2's loop
	lda playfield_right 
	sta temp2
	lda playfield_center
	sta temp
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
	jsr players_input_dpad	
	jsr players_input_buttons

; --- End of Loop ---
@post_inputs:
	cpx #$00			; Did we just check player 1?
	bne @endloop 			; If not, we're done here (both done)
	ldx #PLAYER_SIZE		; Now it's time to check player 2's
	bne @toploop
@endloop:
	rts

; ====================================================
; A/B buttons subroutine for the input handler
; Preconditions:
;	X is loaded with the offset for the player
; Postconditions:
;	Player has slide or block counters set based on inputs
; ====================================================
players_input_buttons:


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

; Load appropriate pad for P1 or P2 into temp and temp2
	cpx #$00
	bne @p2_check
	lda pad_1
	sta temp
	lda pad_1_prev
	sta temp2
	jmp @check_a_button

@p2_check:
	lda pad_2
	sta temp
	lda pad_2_prev
	sta temp2

@check_a_button:
	; Has A just been pressed?
	lda temp
	bit btn_a
	beq @not_a
	lda temp2
	bit btn_a
	bne @not_a
	beq @a_pressed
@not_a:
	rts

@a_pressed:

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
; TODO: Actually launch the player.

; If the d-pad isn't being pressed, don't do anything.
	lda temp
	and #(BUTTON_RIGHT|BUTTON_LEFT|BUTTON_UP|BUTTON_DOWN)
	beq @a_not_pressed

; Set the counter.
	lda #(PLAYER_SLIDE_DELAY)
	sta player_state + PLAYER_SLIDE_CNTOFF, x

; Set up addr_ptr with player stats struct
	lda player_state + PLAYER_STATS_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF + 1, x
	sta addr_ptr + 1

; Launch the player
	lda #$00
	sta temp3			; Temp3 is a "invert dx" flag
	sta temp4			; Temp4 is a "invert dy" flag
	lda player_state + PLAYER_DXOFF + 1, x
	bpl @x_pos
	lda #$01
	sta temp3			; Mark dx for inversion
@x_pos:
	lda player_state + PLAYER_DYOFF + 1, x
	bpl @y_pos
	lda #$01
	sta temp4			; Mark dy for inversion
@y_pos:
	
	; Load velocity for dx
	ldy #$04			; 3rd word, for dash strength (LSB)
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF, x
	iny				; Now grab the MSB
	lda (addr_ptr), y
	sta player_state + PLAYER_DXOFF+1, x

	;Invert DX if temp3 is set
	lda temp3
	beq @no_invert_dx
	sec
	lda #$00
	sbc player_state + PLAYER_DXOFF, x
	sta player_state + PLAYER_DXOFF, x
	lda #$00
	sbc player_state + PLAYER_DXOFF + 1, x
	sta player_state + PLAYER_DXOFF + 1, x
@no_invert_dx:

	; Velocity to load into dy	
	ldy #$04			; 3rd word, for dash strength (LSB)
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	iny				; Now grab the MSB
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF+1, x

	;Invert DX if temp3 is set
	lda temp3
	beq @no_invert_dy
	sec
	lda #$00
	sbc player_state + PLAYER_DYOFF, x
	sta player_state + PLAYER_DYOFF, x
	lda #$00
	sbc player_state + PLAYER_DYOFF + 1, x
	sta player_state + PLAYER_DYOFF + 1, x

@no_invert_dy:

@a_not_pressed: 

	rts

; ====================================================
; D-pad subroutine for the input handler
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; Postconditions:
;	Player state struct has been modified based on D-Pad inputs
; ====================================================
players_input_dpad:
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
;	temp3 is loaded with pad state capture
;	temp4 is loaded with previous frame's pad state capture
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
	ldy #$00
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
	ldy #$00
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_DYOFF+1, x
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
	ldy #$00
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
	lda #PLAYER_FACING_UP
	sta player_state + PLAYER_FACINGOFF, x
	jmp @post_dpad
:
        jmp @ldpad

@ldpad:
	cpy #(BUTTON_LEFT)
	bne :+
	ldy #$00
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
	ldy #$02
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
	ldy #$02
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
	ldy #$02
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
	ldy #$02
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
