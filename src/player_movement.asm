; Movement and physucs-related player code

; Move players about based on vector variables
players_move:

	sum16 player_state+PLAYER_XOFF, player_state+PLAYER_DXOFF
	sum16 player_state+PLAYER_YOFF, player_state+PLAYER_DYOFF
	sum16 player_state+PLAYER_SIZE+PLAYER_XOFF, player_state+PLAYER_SIZE+PLAYER_DXOFF
	sum16 player_state+PLAYER_SIZE+PLAYER_YOFF, player_state+PLAYER_SIZE+PLAYER_DYOFF

@xy_done:

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
	jmp @toploop
@endloop:
	rts

; ====================================================
; D-pad subroutine for the input handler
; Preconditions:
;	X is loaded with the offset for the player (0 or PLAYER_SIZE)
; Postconditions:
;	Player state struct has been modified based on D-Pad inputs
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
	rts
