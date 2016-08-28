; Routines for the flying disc.
; This serves as the base for the disc's state and processing, but all
; functions here are reflexive - the disc acting on the disc. Interactions
; between the disc and other objects will be done elsewhere.


; Some constants
DISC_H = $0c
DISC_W = $0c
DISC_MAX_Z = $40
DISC_NOMINAL_Z = $0A
DISC_SPR_NUM = 10
DISC_SHADOW_SPR_NUM = 50

; Physics variable struct offsets
DISC_XOFF = $00
DISC_YOFF = $02
DISC_ZOFF = $04
DISC_DXOFF = $06
DISC_DYOFF = $08
DISC_DZOFF = $0a

DISC_CURVE_NONE = $00
DISC_CURVE_UP = $01
DISC_CURVE_DOWN = $02

; Misc gameplay
DISC_ANIMOFF = $0c	; Animation counter
DISC_GRAV_ENOFF = $0d	; If nonzero, dz += gravity
DISC_HELDOFF = $0e	; If nonzero, hide disc and don't move it
DISC_FLIPPINGOFF = $0f	; If nonzero, show flipping anim, have gravity
DISC_LAST_PLAYEROFF = $10 ; offset of player who last touched the disc

DISC_CURVINGOFF = $11   ; Offset for disc curve state
DISC_CURVESTROFF = $12  ; Offset for disc curve intensity

DISC_SPINNINGOFF = $13  ; If nonzero, disc is spinning using the table as
                        ; indicated by the number stored here

DISC_SPINNING_CYCLE_ADDROFF = $14 ; Two words, for sine and cosine
DISC_SPINNING_CYCLE_POSOFF = $18 ; Position in spinning lookup table
DISC_SPINNING_CYCLE_LENOFF = $19

.segment "BANKE"

.include "trig.asm"

; Sets up the disc for spinning
; Pre:
;	A is loaded with the desired spin config
disc_begin_spinning:
	cmp #$00
	bne @not_0
	sta disc_state + DISC_SPINNING_CYCLE_ADDROFF
	sta disc_state + DISC_SPINNING_CYCLE_ADDROFF + 1
	rts
@not_0:
	cmp #$01
	bne @not_1
	lda #<sin_512_24
	clc
	adc #$01
	sta disc_state + DISC_SPINNING_CYCLE_ADDROFF
	lda #>sin_512_24
	sta disc_state + DISC_SPINNING_CYCLE_ADDROFF + 1

	lda #<cos_512_24
	sta disc_state + DISC_SPINNING_CYCLE_ADDROFF + 2
	lda #>cos_512_24
	sta disc_state + DISC_SPINNING_CYCLE_ADDROFF + 3

	lda 

@not_1:
	rts

; Movement function that makes the disc spin
; Pre:
;	None
; Post:
;	Disc has moved a bunch, hits walls and stuff

do_spin:
	; Check that the disc is spinning
	; ( that the spin cycle table address is non-NULL)
	lda disc_state + DISC_SPINNING_CYCLE_ADDROFF
	bne @nonzero
	lda disc_state + DISC_SPINNING_CYCLE_ADDROFF+1
	bne @nonzero
	; We aren't spinning, get out of here
	rts

@nonzero:
	lda #$01
	jsr disc_begin_spinning
;	; debug len
	lda #24
	sta disc_state + DISC_SPINNING_CYCLE_LENOFF
	; /debug

	lda disc_state + DISC_SPINNING_CYCLE_POSOFF
	clc
	asl a
	tay

	; Offset by 1, first byte is length
	iny

	; Load dx/dy pair for present index
	lda (disc_state + DISC_SPINNING_CYCLE_ADDROFF), y
	sta temp
	iny
	lda (disc_state + DISC_SPINNING_CYCLE_ADDROFF), y
	sta temp2
	dey
	lda (disc_state + DISC_SPINNING_CYCLE_ADDROFF + 2), y
	sta temp3
	iny
	lda (disc_state + DISC_SPINNING_CYCLE_ADDROFF + 2), y
	sta temp4

	; Apply to X
	sum16 disc_state+DISC_XOFF, temp
	
	; And Y
	sum16 disc_state+DISC_YOFF, temp3

	; Did we just collide with a wall?	
	; Top
	lda playfield_top
	clc
	adc #(DISC_H/2)
	cmp disc_state + DISC_YOFF+1
	bcc @post_col				; No collision, get out of here. 
	sta disc_state + DISC_YOFF+1		; Clamp disc Y to top of playfield
	stx disc_state + DISC_YOFF
	neg16 disc_state+DISC_DYOFF		; Invert dy

	; put table index out of phase
	lda disc_state + disc_spinning_cycle_lenoff
	lsr a
	clc
	adc disc_state + disc_spinning_cycle_posoff ; pos += len/2

@do_not_reduce_pos:
	sta disc_state + DISC_SPINNING_CYCLE_POSOFF

	jmp @post_col

	; Bottom
	lda disc_state + DISC_YOFF+1
	clc
	adc #(DISC_H/2)				; Offset by height of disc
	cmp playfield_bottom
	bcc @post_col
	lda playfield_bottom
	sec
	sbc #(DISC_H/2)
	sta disc_state + DISC_YOFF+1		; Clamp disc Y to top of playfield
	stx disc_state + DISC_YOFF
	neg16 disc_state+DISC_DYOFF

	; put table index out of phase
	lda disc_state + disc_spinning_cycle_lenoff
	lsr a
	clc
	adc disc_state + disc_spinning_cycle_posoff ; pos += len/2

	; Fall-through to post_col

@post_col:

	; Increment spin table pointer
	lda disc_state + DISC_SPINNING_CYCLE_POSOFF
	clc
	adc #$01
	cmp disc_state + DISC_SPINNING_CYCLE_LENOFF
	bcc @do_not_reset_cnt			; If (pos >= len)
	sec
	sbc disc_state + DISC_SPINNING_CYCLE_LENOFF

@do_not_reset_cnt:
	sta disc_state + DISC_SPINNING_CYCLE_POSOFF
	rts
	
; ============================
;  Initialize disc
; ============================
disc_init:
; Zero out the disc's variables
	ldx #DISC_SIZE
	lda #$00
@clear_loop:
	sta disc_state, x
	dex
	bne @clear_loop

; Initialize some physics stuff
	lda #$80
	sta disc_state + DISC_YOFF + 1
	sta disc_state + DISC_XOFF + 1

	lda #DISC_NOMINAL_Z
	sta disc_state + DISC_ZOFF + 1

	lda #$00
	;lda #$A0
	sta disc_state + DISC_DXOFF
	sta disc_state + DISC_DYOFF
	;lda #$FF
	sta disc_state + DISC_DXOFF+1
	sta disc_state + DISC_DYOFF+1
	sta disc_state + DISC_LAST_PLAYEROFF

	rts

; ============================
;       Basic movement
; ============================

disc_move:
	ldx #$00
; Is disc being held by a player?
	lda disc_state + DISC_HELDOFF
	beq @not_being_held

; If so, set some defaults and exit

; Turn off disc gravity
	stx disc_state + DISC_GRAV_ENOFF

; Put disc back at normal height (if it had been lobbed)
	lda #DISC_NOMINAL_Z
	stx disc_state + DISC_ZOFF
	sta disc_state + DISC_DZOFF + 1

	rts


@not_being_held:
	; Apply vectors
	sum16 disc_state + DISC_XOFF, disc_state + DISC_DXOFF
	sum16 disc_state + DISC_YOFF, disc_state + DISC_DYOFF
	sum16 disc_state + DISC_ZOFF, disc_state + DISC_DZOFF
	jsr do_spin

	; Check that the disc is moving upwards first
	lda disc_state + DISC_DYOFF+1
	bpl @moving_downwards

	; Top
	lda playfield_top
	clc
	adc #(DISC_H/2)
	cmp disc_state + DISC_YOFF+1
	bcc @h_check				; No collision, get out of here. 
	sta disc_state + DISC_YOFF+1		; Clamp disc Y to top of playfield
	stx disc_state + DISC_YOFF
	neg16 disc_state+DISC_DYOFF		; Invert dy
	jmp @h_check

@moving_downwards:

	; Bottom
	lda disc_state + DISC_YOFF+1
	clc
	adc #(DISC_H/2)				; Offset by height of disc
	cmp playfield_bottom
	bcc @h_check
	lda playfield_bottom
	sec
	sbc #(DISC_H/2)
	sta disc_state + DISC_YOFF+1		; Clamp disc Y to top of playfield
	stx disc_state + DISC_YOFF
	neg16 disc_state+DISC_DYOFF
	; Fall through to h_check

@h_check:
	; Check which way the disc is going
	lda disc_state + DISC_DXOFF+1
	bpl @moving_rightwards

	; Left bound first
	lda playfield_left
	clc
	adc #(DISC_W/2)
	cmp disc_state + DISC_XOFF+1
	bcc @xy_done

	; Clamp disc to left side
	sta disc_state + DISC_XOFF+1
	stx disc_state + DISC_XOFF

	; Reverse dx
	neg16 disc_state + DISC_DXOFF
	;stx disc_state + DISC_DXOFF+1
	;stx disc_state + DISC_DXOFF

	jmp @xy_done

@moving_rightwards:
	lda disc_state + DISC_XOFF+1
	clc
	adc #(DISC_W/2)				;Offset by width of disc
	cmp playfield_right
	bcc @xy_done
	lda playfield_right
	sec
	sbc #(DISC_W/2)

	; Clamp disc to right side
	sta disc_state + DISC_XOFF+1
	stx disc_state + DISC_XOFF

	; Reverse dx
	neg16 disc_state + DISC_DXOFF
	;stx disc_state + DISC_DXOFF+1
	;stx disc_state + DISC_DXOFF

@xy_done:
	; Has the disc landed onto the ground?
	lda disc_state + DISC_ZOFF+1
	bmi @clamp_z

	; Has it gone up too high?
	cmp #DISC_MAX_Z
	bpl @clamp_z_hi
	rts

@clamp_z:
	stx disc_state + DISC_ZOFF
	stx disc_state + DISC_ZOFF+1
	stx disc_state + DISC_DZOFF
	stx disc_state + DISC_DZOFF+1
	stx disc_state + DISC_DXOFF
	stx disc_state + DISC_DXOFF+1
	stx disc_state + DISC_DYOFF
	stx disc_state + DISC_DYOFF+1
	rts

@clamp_z_hi:
	lda #DISC_MAX_Z
	sta disc_state + DISC_ZOFF+1
	stx disc_state + DISC_ZOFF
	stx disc_state + DISC_DZOFF
	stx disc_state + DISC_DZOFF+1
	rts

; ============================
;  Render the disc on-screen
; ============================
disc_draw:
	; Is disc being held by a player?
	lda disc_state + DISC_HELDOFF
	beq @not_being_held

	; If so, we don't render the disc - the player holding it is
	; responsible for drawing it with the player sprite.

	lda #$FF
	write_oam_y DISC_SPR_NUM
	write_oam_y DISC_SPR_NUM+1
	write_oam_y DISC_SPR_NUM+2
	write_oam_y DISC_SPR_NUM+3
	write_oam_y DISC_SHADOW_SPR_NUM
	write_oam_y DISC_SHADOW_SPR_NUM+1
	write_oam_y DISC_SHADOW_SPR_NUM+2
	write_oam_y DISC_SHADOW_SPR_NUM+3
	rts

@not_being_held:

	lda playfield_bottom
	sec
	sbc #$20
	sta temp3			; Temp3 = disc priority cutoff

	lda #%00000000			; Attributes defaults
	sta temp
	sta temp2
	; Increment disc animation counter
	ldy disc_state + DISC_ANIMOFF
	iny
	sty disc_state + DISC_ANIMOFF
	; Y position
	lda disc_state + DISC_YOFF+1
	sec
	sbc #((DISC_H/2)+1)		; Disc height offset
	sec
	sbc disc_state + DISC_ZOFF+1	; Disc Z offset
	sec
	sbc yscroll			; Y scroll offset

					; Determine if it should be behind BG
	cmp temp3
	bcc @disc_top
	pha
	lda #%00100000
	sta temp			; Behind BG storage
	pla

@disc_top:
	write_oam_y DISC_SPR_NUM
	write_oam_y DISC_SPR_NUM+1
	clc
	adc #$08

	cmp temp3
	bcc @disc_bottom

	pha
	lda #%00100000
	sta temp2
	pla

@disc_bottom:
	write_oam_y DISC_SPR_NUM+2
	write_oam_y DISC_SPR_NUM+3

@tile_sel:
	; Tile selection
	lda disc_state + DISC_ANIMOFF
	and #%0001000

	bne @firsthalf_anim
	jmp @secondhalf_anim

@firsthalf_anim:
	lda disc_state + DISC_ANIMOFF
	and #%0000110

	write_oam_tile DISC_SPR_NUM
	clc
	adc #$01
	write_oam_tile DISC_SPR_NUM+1
	clc
	adc #$0F
	write_oam_tile DISC_SPR_NUM+2
	clc
	adc #$01
	write_oam_tile DISC_SPR_NUM+3

	lda #%00000000		  ; Unflipped
	ora temp
	write_oam_attr DISC_SPR_NUM
	write_oam_attr DISC_SPR_NUM+1
	lda #%00000000
	ora temp2
	write_oam_attr DISC_SPR_NUM+2
	write_oam_attr DISC_SPR_NUM+3

	; X position
	lda disc_state + DISC_XOFF+1
	sec
	sbc #(DISC_W/2)
	write_oam_x DISC_SPR_NUM
	write_oam_x DISC_SPR_NUM+2
	clc
	adc #$08
	write_oam_x DISC_SPR_NUM+1
	write_oam_x DISC_SPR_NUM+3

	jmp @postanim

@secondhalf_anim:
	ldy temp
	lda disc_state + DISC_ANIMOFF
	and #%0000110
	lsr
	sta temp
	lda #$03
	sec
	sbc temp
	asl
	sty temp

	write_oam_tile DISC_SPR_NUM + 1
	clc
	adc #$01
	write_oam_tile DISC_SPR_NUM
	clc
	adc #$0F
	write_oam_tile DISC_SPR_NUM + 3
	clc
	adc #$01
	write_oam_tile DISC_SPR_NUM + 2
	lda #%01000000		  ; Flipped
	ora temp
	write_oam_attr DISC_SPR_NUM
	write_oam_attr DISC_SPR_NUM + 1
	lda #%01000000
	ora temp2
	write_oam_attr DISC_SPR_NUM + 2
	write_oam_attr DISC_SPR_NUM + 3

	; X position
	lda disc_state + DISC_XOFF+1
	sec
	sbc #((DISC_W/2)+03)
	sec
	sbc xscroll
	write_oam_x DISC_SPR_NUM
	write_oam_x (DISC_SPR_NUM + 2)
	clc
	adc #$08
	write_oam_x (DISC_SPR_NUM + 1)
	write_oam_x (DISC_SPR_NUM + 3)

	jmp @postanim

@nobottomdisc:
	; Hide the shadow sprite entirely
	lda #$FF
	write_oam_y DISC_SPR_NUM+2
	write_oam_y DISC_SPR_NUM+3

	rts



@postanim:
	; Drawing the shadow every other frame
	lda frame_counter
	and #%00000001
	bne @remove_shadow

	; Every other frame, a shadow is drawn with sprites 5-8
	; Shadow Y
	lda disc_state + DISC_YOFF+1
	sec
	sbc #(DISC_H/2)
	sec
	sbc yscroll
	clc
	adc #$06
	cmp #$d0
	bcc @doshadow
@remove_shadow:
	lda #$FF
	write_oam_y DISC_SHADOW_SPR_NUM
	write_oam_y DISC_SHADOW_SPR_NUM+1
	rts
@doshadow:
	write_oam_y DISC_SHADOW_SPR_NUM
	write_oam_y DISC_SHADOW_SPR_NUM+1


	; Shadow X
	lda disc_state + DISC_DZOFF+1
	lsr
	clc
	adc disc_state + DISC_XOFF+1
	sec
	sbc xscroll
	sec
	sbc #(DISC_W/2)
	write_oam_x DISC_SHADOW_SPR_NUM
	clc
	adc #$05
	bcs :+			  ; Check if sprite has wrapped around
	write_oam_x DISC_SHADOW_SPR_NUM+1
	clc
	bcc :++
:
	lda #$FE			; Hide the sprite if it's wrapped
	write_oam_y DISC_SHADOW_SPR_NUM
	write_oam_y DISC_SHADOW_SPR_NUM+1
:

	; Shadow tile
	lda #$08
	write_oam_tile DISC_SHADOW_SPR_NUM
	write_oam_tile DISC_SHADOW_SPR_NUM+1

	; Shadow attr
	lda #$03			 ; Palette 3
	write_oam_attr DISC_SHADOW_SPR_NUM
	ora #%01000000
	write_oam_attr DISC_SHADOW_SPR_NUM+1
	rts