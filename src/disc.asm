; Routines for the flying disc


DISC_H = $0c
DISC_W = $0c
DISC_MAX_Z = $1c
DISC_SPR_NUM = 10
DISC_SHADOW_SPR_NUM = 50

; ============================
;  Initialize disc
; ============================
disc_init:
	lda #$00
	sta disc_y
	sta disc_x
	sta disc_dy
	sta disc_dy+1
	sta disc_dx
	sta disc_dx+1
	sta disc_dz
	sta disc_dz+1
	lda #$80
	sta disc_y+1
	sta disc_x+1
	rts

; ============================
;       Basic movement
; ============================

disc_move:
	key_down pad_2, btn_start
	lda #$00
	sta disc_dz
	sta disc_dz+1
	sta disc_dy
	sta disc_dy+1
	sta disc_dx
	sta disc_dx+1
:
	key_isdown pad_2, btn_up
	sub16 disc_dy, #$08
:
	key_isdown pad_2, btn_down
	add16 disc_dy, #$08
:
	key_isdown pad_2, btn_left
	sub16 disc_dx, #$08
:
	key_isdown pad_2, btn_right
	add16 disc_dx, #$08
:
	key_isdown pad_2, btn_a
	add16 disc_dz, #$10
:
	key_isdown pad_2, btn_b
	sub16 disc_dz, #$10
:


	sub16 disc_dz, #$03
	; Apply vectors
	sum16 disc_x, disc_dx
	sum16 disc_y, disc_dy
	sum16 disc_z, disc_dz

	ldx #$00

	; Check that the disc is moving upwards first
	lda disc_dy+1
	bpl @moving_downwards

	; Top
	lda playfield_top
	clc
	adc #(DISC_H/2)
	cmp disc_y+1
	bcc @h_check
	sta disc_y+1		    ; Clamp disc Y to top of playfield
	stx disc_y		      ;
	jmp @flip_dy		    ; Invert dY

@moving_downwards:

	; Bottom
	lda disc_y+1
	clc
	adc #(DISC_H/2)		     ; Offset by height of disc
	cmp playfield_bottom
	bcc @h_check
	lda playfield_bottom
	sec
	sbc #(DISC_H/2)		     ;
	sta disc_y+1		    ; Clamp disc Y to top of playfield
	stx disc_y		      ;
	jmp @flip_dy		    ; Invert dY


@flip_dy:
	; Invert dY
	neg16 disc_dy

@h_check:
	; Check which way the disc is going
	lda disc_dx+1
	bpl @moving_rightwards

	; Left bound first
	lda playfield_left
	clc
	adc #(DISC_W/2)
	cmp disc_x+1
	bcc @xy_done

	sta disc_x+1
	stx disc_x
	stx disc_dx+1
	stx disc_dx

	jmp @xy_done

@moving_rightwards:
	lda disc_x+1
	clc
	adc #(DISC_W/2)		     ;Offset by width of disc
	cmp playfield_right
	bcc @xy_done
	lda playfield_right
	sec
	sbc #(DISC_W/2)		     ;
	sta disc_x+1		    ;X clamping
	stx disc_x
	stx disc_dx+1
	stx disc_dx

@xy_done:
	lda disc_z+1
	bmi @clamp_z
	cmp #DISC_MAX_Z
	bpl @clamp_z_hi
	rts
@clamp_z:
	lda #$00
	sta disc_z
	sta disc_z+1
	sta disc_dz
	sta disc_dz+1
	sta disc_dx
	sta disc_dx+1
	sta disc_dy
	sta disc_dy+1
	rts
@clamp_z_hi:
	lda #DISC_MAX_Z
	sta disc_z+1
	lda #$00
	sta disc_z
	sta disc_dz
	sta disc_dz+1
	rts

disc_bottom_mask_draw:
	; Mask bottom of playfield
	lda #$cf
	write_oam_y 1
	write_oam_y 2
	write_oam_y 3
	write_oam_y 4
	write_oam_y 5
	write_oam_y 6
	write_oam_y 7
	write_oam_y 8
	lda #$00
	write_oam_x 1
	write_oam_x 2
	write_oam_x 3
	write_oam_x 4
	write_oam_x 5
	write_oam_x 6
	write_oam_x 7
	write_oam_x 8
	lda #$FF
	write_oam_tile 1
	write_oam_tile 2
	write_oam_tile 3
	write_oam_tile 4
	write_oam_tile 5
	write_oam_tile 6
	write_oam_tile 7
	write_oam_tile 1
	lda #%00100000
	write_oam_attr 1
	write_oam_attr 2
	write_oam_attr 3
	write_oam_attr 4
	write_oam_attr 5
	write_oam_attr 6
	write_oam_attr 7
	write_oam_attr 8
	rts

; ============================
;  Render the disc on-screen
; ============================
disc_draw:


	lda #%00000000		  ; Attributes defaults
	sta temp
	sta temp2
	; Increment disc animation counter
	ldy disc_anim
	iny
	sty disc_anim
	; Y position
	lda disc_y+1
	sec
	sbc #((DISC_H/2)+1)
	sbc disc_z+1

					; Determine if it should be behind BG
	cmp #$d0
	bcc @disc_top
	pha
	lda #%00100000
	sta temp			; Behind BG storage
	pla

@disc_top:
	write_oam_y DISC_SPR_NUM
	write_oam_y (DISC_SPR_NUM + 1)
	clc
	adc #$05

	cmp #$d0
	bcc @disc_bottom

	pha
	lda #%00100000
	sta temp2
	pla

@disc_bottom:
	write_oam_y (DISC_SPR_NUM + 2)
	write_oam_y (DISC_SPR_NUM + 3)

@tile_sel:
	; Tile selection
	lda disc_anim
	and #%0001000

	bne @firsthalf_anim
	jmp @secondhalf_anim

@firsthalf_anim:
	lda disc_anim
	and #%0000110

	write_oam_tile DISC_SPR_NUM
	clc
	adc #$01
	write_oam_tile DISC_SPR_NUM + 1
	clc
	adc #$0F
	write_oam_tile DISC_SPR_NUM + 2
	clc
	adc #$01
	write_oam_tile DISC_SPR_NUM + 3

	lda #%00000000		  ; Unflipped
	ora temp
	write_oam_attr DISC_SPR_NUM
	write_oam_attr DISC_SPR_NUM + 1
	lda #%00000000
	ora temp2
	write_oam_attr DISC_SPR_NUM + 2
	write_oam_attr DISC_SPR_NUM + 3

	; X position
	lda disc_x+1
	sec
	sbc #(DISC_W/2)
	write_oam_x DISC_SPR_NUM
	write_oam_x (DISC_SPR_NUM + 2)
	clc
	adc #$08
	write_oam_x (DISC_SPR_NUM + 1)
	write_oam_x (DISC_SPR_NUM + 3)

	jmp @postanim

@secondhalf_anim:
	ldy temp
	lda disc_anim
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
	lda disc_x+1
	sec
	sbc #((DISC_W/2)+03)
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
	lda disc_y+1
	sec
	sbc #(DISC_H/2)
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
	lda disc_z+1
	lsr
	clc
	adc disc_x+1
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
