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
	lda player_state + PLAYER_SLIDE_CNTOFF, x
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

	jsr player_counters

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

	jsr player_check_bounds

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
        bne @post_dpad			; Skip input handling

@normal_state_inputs:
	jsr players_input_dpad	

; --- End of Loop ---
@post_dpad:
	cpx #$00			; Did we just check player 1?
	bne @endloop 			; If not, we're done here (both done)
	ldx #PLAYER_SIZE		; Now it's time to check player 2's
	bne @toploop
@endloop:
	rts

; ====================================================
; D-pad subroutine for the input handler
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; Postconditions:
;	Player state struct has been modified based on D-Pad inputs
; ====================================================
players_input_dpad:
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
