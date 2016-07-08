; Player's interaction with the disc code

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

; ===========================================
; Run when the player's disc throwing counter has expired.
; Preconditions:
;	X is loaded with the player struct offset.
; Postconditions:
;	The disc's state has been modified in reflection of 
; 	the disc toss.
player_throw_disc:
; Check the throw type
	lda player_state + PLAYER_THROW_TYPEOFF, x
	cmp #THROW_NORMAL
	bne @chk_lob
; Do a normal throw:

	; Place disc at player's position
	lda player_state + PLAYER_XOFF, x
	sta disc_state + DISC_XOFF
	lda player_state + PLAYER_YOFF, x
	sta disc_state + DISC_YOFF
	lda player_state + PLAYER_XOFF + 1, x
	sta disc_state + DISC_XOFF + 1
	lda player_state + PLAYER_YOFF + 1, x
	sec
	sbc #$05
	sta disc_state + DISC_YOFF + 1

	lda #$00
	sta disc_state + DISC_DYOFF
	sta disc_state + DISC_DYOFF + 1
	sta disc_state + DISC_DZOFF
	sta disc_state + DISC_DZOFF + 1
	sta disc_state + DISC_DXOFF

	cpx #$00
	bne @p2_dx

; Send disc off to the right
	lda #$01
	sta disc_state + DISC_DXOFF + 1

	jmp @post_throw
@p2_dx:
; Send disc off to the left
	lda #<-$01
	sta disc_state + DISC_DXOFF + 1

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
