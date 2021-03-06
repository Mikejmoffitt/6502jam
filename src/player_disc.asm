; Player's interaction with the disc code

; ========================================
; Increments the hold counter when appropriate, cuases a throw if it reaches
; the maximum hold time.
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; ========================================
player_run_hold_counter:
; Abort if a throw is already in progress.
	lda player_state + PLAYER_THROW_CNTOFF, x
	beq @not_throwing
	rts

@not_throwing:
; Is the player holding the disc?
	lda player_state + PLAYER_HOLDING_DISCOFF, x
	bne @counter_inc
; Abort if any conditions failed.
	rts

; Increment the timer.
@counter_inc:
	inc player_state + PLAYER_HOLD_CNTOFF, x
	lda player_state + PLAYER_HOLD_CNTOFF, x
; Have we reached the autothrow threshhold?
	cmp #PLAYER_AUTOTHROW_DELAY

	beq :+
; If not, get out of here
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

; Clear hold-time counter
	sty player_state + PLAYER_HOLD_CNTOFF, x

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
; normally (not a lob)
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
	ldy #$00
	sty temp3 ; Forward button is held
	sty temp4 ; Backward button is held
	dey

; Determine if forward/back is held, store in temp3 and temp4
	cpx #$00
	bne @check_p2_dir
	; Checking P1 fwd/back
	lda temp
	bit btn_right
	; Is right held? (fwd)
	bne @fwd_held_p1
	bit btn_left
	; Is left held? (back)
	bne @back_held_p1
	jmp @post_dirs

@fwd_held_p1:
	sty temp3 ; Mark forward as being held
	jmp @post_dirs

@back_held_p1:
	sty temp4 ; Mark backward as being held
	jmp @post_dirs

@check_p2_dir:
	; Checking P2 fwd/back
	lda temp
	bit btn_left
	; Is left held? (fwd)
	bne @fwd_held_p2
	bit btn_right
	; Is right held? (back)
	bne @back_held_p2
	jmp @post_dirs

@fwd_held_p2:
	sty temp3 ; Mark forward as being held
	jmp @post_dirs

@back_held_p2:
	sty temp4 ; Mark backward as being held
	; Fall through to @post_dirs

@post_dirs:

; Get stats struct address in addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF, x
	sta addr_ptr
	lda player_state + PLAYER_STATS_ADDROFF + 1, x
	sta addr_ptr + 1

; Determine major offset (strong, normal, weak) inside of throws struct and
; store it in temp2 to control throw strength / speed, based on how quickly
; the player chooses to throw after having caught the disc.

; Is the throw counter less than the strong cutoff?
	lda player_state + PLAYER_HOLD_CNTOFF, x
	cmp #PLAYER_THROW_STRONG_CUTOFF
	bcs @throw_not_strong
	; If so, use the strong throw stats
	lda #THROW_STRONG_OFFSET
	sta temp2
	jmp @mod_direction

@throw_not_strong:
	; Is the throw counter less than the normal cutoff?
	cmp #PLAYER_THROW_NORMAL_CUTOFF
	bcs @throw_not_normal
	; If so, use the normal throw stats
	lda #THROW_NORMAL_OFFSET
	sta temp2
	jmp @mod_direction

@throw_not_normal:
	; Finally, fall back to the weak offset.
	lda #THROW_WEAK_OFFSET
	sta temp2

@mod_direction:
; Using the pad state, determine which throw is to be used and add to temp2
	lda temp2
	clc
	adc #STATS_THROWS

	; TODO: Remove all the above
	lda #STATS_THROWS

	; Back up offset we've built, we're going to mangle A to check the
	; button / pad state
	sta temp5

; Are we holding up/down?
	lda temp
	bit btn_up
	bne @up_held
	bit btn_down
	bne @down_held
	; If not, use the forward throw vector (0), and we're done.
	jmp @load_disc_vec

	; If up or down are held, we use vectors 1-3, not 0
@up_held:
@down_held:
	lda temp5
	clc
	adc #$02
	sta temp5
; Are we holding forward?
	lda temp3
	; If so, we are done, already at dn-fwd index (4).
	bne @load_disc_vec
	; If not, are we holding backward?
	lda temp4
	bne @holding_back
	; If not, just jump to the down-only offset (8)
	lda temp5
	clc
	adc #$02
	sta temp5
	jmp @load_disc_vec

	; Holding back, go to the dn-back offset (12)
@holding_back:
	lda temp5
	clc
	adc #$04
	sta temp5
	; Fall-through to @load_disc_vec

@load_disc_vec:
	; Restore calculated vector offset, put it in Y
	lda temp5
	tay

	; Load disc vector from throw stats (addr_ptr) and apply
	lda (addr_ptr), y
	sta disc_state + DISC_DXOFF
	iny
	lda (addr_ptr), y
	sta disc_state + DISC_DYOFF

	; TODO: Load scale coefficient based on how long the player has held
	; the disc before pressing the A button.

	; Subtract hold counter from (autothrow delay + strength padding)
	lda #(PLAYER_AUTOTHROW_DELAY + PLAYER_THROW_STR_PADDING)
	sec
	sbc player_state + PLAYER_HOLD_CNTOFF, x
	sta temp8
	sta temp7

	; Back up X; multiply mangles it.
	stx temp4

	; Scale dX (coefficient is in temp7)
	lda disc_state + DISC_DXOFF
	jsr mul_func

	sta disc_state + DISC_DXOFF + 1
	lda temp5
	sta disc_state + DISC_DXOFF

	; Scale dY
	lda temp8 ; Coefficient from the hold counter
	sta temp7
	lda disc_state + DISC_DYOFF
	jsr mul_func

	sta disc_state + DISC_DYOFF + 1
	lda temp5
	sta disc_state + DISC_DYOFF

	; Restore preserved X
	ldx temp4

; Is the player holding up?
	lda temp
	bit btn_up
	beq @check_p2_dx_reverse
	; If so, reverse disc dy
	neg16 disc_state + DISC_DYOFF

@check_p2_dx_reverse:
; Is it player 2?
	cpx #$00
	bne @p2_neg_dx
	; If not, we're done and can exit.
	rts

; If so, negate dx to put the disc off to the left
@p2_neg_dx:
	neg16 disc_state + DISC_DXOFF
	rts

; ===========================================
; Helper function for player_throw_disc. Adds spin to a normal throw if
; appropriate. 
; Preconditions:
;	X is loaded with the player struct offset.
; Postconditions:
;	The disc's spin has been configured (or not).
player_spin_throw_add:
	; Preserve X
	txa
	pha

	lda player_state + PLAYER_ROTATING_RIGHTOFF, x
	beq :+
	lda #$81
	jsr disc_spin_right	; <-- disc.asm (BANKE)
	jmp @done
:
	lda player_state + PLAYER_ROTATING_LEFTOFF, x
	beq :+
	lda #$81
	jsr disc_spin_left	; <-- disc.asm (BANKE)
	jmp @done
:
; No spinning; disable disc spinning entirely
	jsr disc_stop_spinning
@done:
	; Restore X
	pla
	tax
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

; Record player as the last one to have thrown the disc
	stx disc_state + DISC_LAST_PLAYEROFF

; Check the throw type
	lda player_state + PLAYER_THROW_TYPEOFF, x
	cmp #THROW_NORMAL
	bne @chk_lob
; Do a normal throw:

	jsr player_do_normal_throw
	jsr player_spin_throw_add

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

	rts

; Rotation code helper macro
.macro rot_state_transition cur, new_left, new_right
:
	; Check for the current state "cur"
	lda player_state + PLAYER_ROTATE_STATEOFF, x
	cmp cur
	bne :+++

	; Check for transitions from cur
	lda temp
	cmp new_left
	bne :+
	; Newleft was hit, mark rotating left
	jsr player_rotate_mark_left
	rts
:
	cmp new_right
	bne :+
	; Newright was hit, mark rotating right
	jsr player_rotate_mark_right
	rts
:
	; Neither was hit, mark not rotating.
	jsr player_rotate_mark_none
	rts
.endmacro

; ============================================================================
; Detect whether or not the player is rotating the D-Pad.
; Pre:
;	X = player struct offset
; Post:
;	PLAYER_ROTATING_RIGHTOFF or PLAYER_ROTATING_LEFTOFF are non-zero
player_detect_rotation:
; Load pad and mask off non-directional buttons
	cpx #$00
	bne @use_p2_pad
	lda pad_1
	and #DPAD_MASK
	sta temp
	jmp @post_pad
@use_p2_pad:
	lda pad_2
	and #DPAD_MASK
	sta temp
@post_pad:
	; Temp contains the new state. Time to check for state transitions.

	; Is our new state different than the last one?
	cmp player_state + PLAYER_ROTATE_STATEOFF, x
	bne @new_state
	; If not, just go to decrement the cooldown

	jmp @post_detect

@new_state:

	; Load previous state, to determine valid new states
	lda player_state + PLAYER_ROTATE_STATEOFF, x
	; Implicit: cmp DPAD_NONE ; DPAD_NONE is zero
	bne @chk_directions

@nonzero_cooldown:
	; No prior state, so capture the new one
	lda temp
	sta player_state + PLAYER_ROTATE_STATEOFF, x
	lda #ROTATE_COOLDOWN_DELAY
	sta player_state + PLAYER_ROTATE_COOLDOWNOFF, x
	rts

	; Dummy branch to squash a warning about an unreferenced unnamed label
	; which comes from the rot_state_transition macro
	bne :+

@chk_directions:
	rot_state_transition 	#DPAD_UP,		#DPAD_UPLEFT,		#DPAD_UPRIGHT
	rot_state_transition 	#DPAD_UPLEFT,		#DPAD_LEFT,		#DPAD_UP
	rot_state_transition 	#DPAD_LEFT,		#DPAD_DOWNLEFT,		#DPAD_UPLEFT
	rot_state_transition 	#DPAD_DOWNLEFT,		#DPAD_DOWN,		#DPAD_LEFT
	rot_state_transition 	#DPAD_DOWN,		#DPAD_DOWNRIGHT,	#DPAD_DOWNLEFT
	rot_state_transition 	#DPAD_DOWNRIGHT,	#DPAD_RIGHT,		#DPAD_DOWN
	rot_state_transition 	#DPAD_RIGHT,		#DPAD_UPRIGHT,		#DPAD_DOWNRIGHT
	rot_state_transition 	#DPAD_UPRIGHT,		#DPAD_UP,		#DPAD_RIGHT
:

@post_detect:
	; No new direction, just decrement the cooldown if we have it
	lda player_state + PLAYER_ROTATE_COOLDOWNOFF, x

	beq @post_cooldown_dec

	sec
	sbc #$01
	sta player_state + PLAYER_ROTATE_COOLDOWNOFF, x
	bne @post_cooldown_dec

	jsr player_rotate_mark_none

@post_cooldown_dec:

	rts

; D-pad rotation support function stuff
player_rotate_mark_right:
	; If cooldown > 0, mark left rotation flag
	lda player_state + PLAYER_ROTATE_COOLDOWNOFF, x
	beq player_rotate_mark_base
	lda #$FF
	sta player_state + PLAYER_ROTATING_RIGHTOFF, x
	jmp player_rotate_mark_base

player_rotate_mark_left:
	; If cooldown > 0, mark left rotation flag
	lda player_state + PLAYER_ROTATE_COOLDOWNOFF, x
	beq player_rotate_mark_base
	lda #$FF
	sta player_state + PLAYER_ROTATING_LEFTOFF, x
	; Fall-through to player_rotate_mark_base

player_rotate_mark_base:
	; Reset the cooldown
	lda #ROTATE_COOLDOWN_DELAY
	sta player_state + PLAYER_ROTATE_COOLDOWNOFF, x
	; Capture state
	lda temp
	sta player_state + PLAYER_ROTATE_STATEOFF, x
	rts

player_rotate_mark_none:
	; Not a valid state transition. Clear cooldown, capture direction,
	; and clear the rotation flags.
	lda temp
	sta player_state + PLAYER_ROTATE_STATEOFF, x
	lda #$00
	sta player_state + PLAYER_ROTATE_COOLDOWNOFF, x
	sta player_state + PLAYER_ROTATING_LEFTOFF, x
	sta player_state + PLAYER_ROTATING_RIGHTOFF, x
	rts
