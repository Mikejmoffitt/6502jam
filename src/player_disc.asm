; Player's interaction with the disc code

; ========================================
; Increments the hold counter when appropriate, cuases a throw if it reaches
; the maximum hold time.
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; ========================================
player_run_hold_counter:
	lda $5555
; Abort if a throw is already in progress.
	lda player_state + PLAYER_THROW_CNTOFF, x
	bne @do_not_run_counter
; Is the player holding the disc?
	lda player_state + PLAYER_HOLDING_DISCOFF, x
	bne :+
; Set the holding timer to zero and return if not.
@do_not_run_counter:
	sta player_state + PLAYER_HOLD_CNTOFF, x
	rts
: 
; If so, increment the timer
	inc player_state + PLAYER_HOLD_CNTOFF, x
	lda player_state + PLAYER_HOLD_CNTOFF, x
; Have we reached the autothrow threshhold?
	cmp #PLAYER_AUTOTHROW_DELAY
	beq :+
	rts
:
; If so, incur a throw
	lda #PLAYER_THROW_DELAY
	sta player_state + PLAYER_THROW_CNTOFF, x
	rts

; ========================================
; Collision checks against disc 
; No preconditions.
players_check_disc:
	ldx #$00
	jsr player_check_disc
	ldx #PLAYER_SIZE
	jsr player_check_disc
	rts

; =======================================
; Run when the disc has touched the player.
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; =======================================
player_touched_disc:

; TODO: If player was blocking, pop up disc and don't catch it
	lda player_state + PLAYER_BLOCK_CNTOFF, x
	beq @disc_catch
	neg16 disc_state + DISC_DXOFF
	rts	

; Player wasn't blocking, so just catch the disc:
@disc_catch:
	ldy #$FF

; Mark player as holding disc
	sty player_state + PLAYER_HOLDING_DISCOFF, x

; Mark disc as being held
	sty disc_state + DISC_HELDOFF

; Halt the player
	iny	; Y is now zero
	sty player_state + PLAYER_DXOFF, x
	sty player_state + PLAYER_DXOFF + 1, x
	sty player_state + PLAYER_DYOFF, x
	sty player_state + PLAYER_DYOFF + 1, x
	sty player_state + PLAYER_SLIDE_CNTOFF, x
	sty player_state + PLAYER_BLOCK_CNTOFF, x
	
	rts

; ========================================
; Check one player against the disc.
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; =======================================
player_check_disc:

; If the player was the last one to have thrown the disc, do not check for
; collisions with it.
	cpx disc_state + DISC_LAST_PLAYEROFF
	bne :+
	rts
:

; If the player is holding the disc, skip this check.
	lda player_state + PLAYER_HOLDING_DISCOFF, x
	beq @not_holding_disc

	rts

@not_holding_disc:

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

; A collision has occured!
	jsr player_touched_disc

@nocollision:
	
	rts

; ==========================================
; Helper function for player_throw_disc. Makes the player throw the disc
; normally (not curved, not a lob)
; Pre:
;	X is loaded with the player struct offset.
; Post:
;	Disc state has been modified.	
;	temp contains gamepad state for the player.
;	temp2 is mangled
player_do_normal_throw:
	
; Load pad info
	cpx #$00
	bne @use_p2_pad
	lda pad_1
	sta temp
	jmp @post_pad
@use_p2_pad:
	lda pad_2
	sta temp
@post_pad:

; Get stats struct address in addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF + 1, x
	sta addr_ptr + 1

; Determine major offset (normal, strong, weak) inside of throws struct and
; store it in temp2

	; TODO: Implement at all. For now, use normal (0).
	lda #$00
	sta temp2

; Using the pad state, determine which throw is to be used and add to temp2
	
	; TODO: Implement this one too. For now, use fwd (0).
	ldy #STATS_THROWS
	lda (addr_ptr), y
	sta disc_state + DISC_DXOFF
	iny
	lda (addr_ptr), y
	sta disc_state + DISC_DXOFF + 1
	iny
	lda (addr_ptr), y
	sta disc_state + DISC_DYOFF
	iny
	lda (addr_ptr), y
	sta disc_state + DISC_DYOFF + 1

; Is it player 2?
	cpx #$00
	bne @p2_neg_dx
	rts
; If so, negate dx to put the disc off to the left
@p2_neg_dx:
	neg16 disc_state + DISC_DXOFF
	rts

; ===========================================
; Run when the player's disc throwing counter has expired.
; Preconditions:
;	X is loaded with the player struct offset.
; Postconditions:
;	The disc's state has been modified in reflection of 
; 	the disc toss.
player_throw_disc:

	; Place disc at player's position
	lda player_state + PLAYER_XOFF, x
	sta disc_state + DISC_XOFF
	lda player_state + PLAYER_YOFF, x
	sta disc_state + DISC_YOFF
	lda player_state + PLAYER_XOFF + 1, x
	sta disc_state + DISC_XOFF + 1
	lda player_state + PLAYER_YOFF + 1, x
	; Move disc up a tiny bit to compensate for player position
	sec
	sbc #$05
	sta disc_state + DISC_YOFF + 1

	lda #$00
	sta disc_state + DISC_DZOFF
	sta disc_state + DISC_DZOFF + 1


; Check the throw type
	lda player_state + PLAYER_THROW_TYPEOFF, x
	cmp #THROW_NORMAL
	bne @chk_lob
; Do a normal throw:

	jsr player_do_normal_throw

	cpx #$00
	bne @p2_dx

; Send disc off to the right
	lda #$01

	jmp @post_throw
@p2_dx:
; Send disc off to the left
	lda #<-$01

	jmp @post_throw
; End of normal throw

@chk_lob:
	cmp #THROW_LOB
	bne @chk_wheel
; Do a lob throw

	jmp @post_throw

@chk_wheel:
	cmp #THROW_WHEEL
	bne @chk_special
; Do a wheel throw

	jmp @post_throw

@chk_special:
	cmp #THROW_SPECIAL
	bne @post_throw
; Do a special throw

	jmp @post_throw

@post_throw:
	; Clear player's "holding disc" flag and disc's "behind held" flag
	lda #$00
	sta player_state + PLAYER_HOLDING_DISCOFF, x
	sta disc_state + DISC_HELDOFF

	; Record player as the last one to have thrown the disc
	stx disc_state + DISC_LAST_PLAYEROFF

	rts