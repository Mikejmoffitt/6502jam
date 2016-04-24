; Routines for the flying disc

; ============================
;       Basic movement
; ============================


DISC_H = $0e
DISC_W = $0c
DISC_SPR_NUM = 10

disc_movement:
        key_down pad_1, btn_start
        lda #$00
        sta disc_dy
        sta disc_dy+1
        sta disc_dx
        sta disc_dx+1
:
        key_isdown pad_1, btn_up
        sub16 disc_dy, #$08
:
        key_isdown pad_1, btn_down
        add16 disc_dy, #$08
:
        key_isdown pad_1, btn_left
        sub16 disc_dx, #$08
:
        key_isdown pad_1, btn_right
        add16 disc_dx, #$08
:

        ; Apply vectors
        sum16 disc_x, disc_dx
        sum16 disc_y, disc_dy

        ldx #$00

        ; Check that the disc is moving upwards first
        lda disc_dy+1
        bpl @moving_downwards

        ; Top
        lda playfield_top
        cmp disc_y+1
        bcc @h_check                            
        sta disc_y+1                    ; Clamp disc Y to top of playfield
        stx disc_y                      ;
        jmp @flip_dy                    ; Invert dY

@moving_downwards:

        ; Bottom
        lda disc_y+1
        clc
        adc #DISC_H                     ; Offset by height of disc
        cmp playfield_bottom
        bcc @h_check       
        lda playfield_bottom
        sec
        sbc #DISC_H                     ;
        sta disc_y+1                    ; Clamp disc Y to top of playfield
        stx disc_y                      ;
        jmp @flip_dy                    ; Invert dY


@flip_dy:
        ; Invert dY
        sec
        lda #$00
        sbc disc_dy
        sta disc_dy
        lda #$00
        sbc disc_dy+1
        sta disc_dy+1
        

@h_check:
        ; Check which way the disc is going
        lda disc_dx+1
        bpl @moving_rightwards

        ; Left bound first
        lda playfield_left
        cmp disc_x+1
        bcc @checks_done

        sta disc_x+1
        stx disc_x
        stx disc_dx+1
        stx disc_dx

        jmp @checks_done

@moving_rightwards:
        lda disc_x+1
        clc
        adc #DISC_W                     ;Offset by width of disc
        cmp playfield_right
        bcc @checks_done
        lda playfield_right
        sec
        sbc #DISC_W                     ;         
        sta disc_x+1                    ;X clamping
        stx disc_x
        stx disc_dx+1
        stx disc_dx  

@checks_done:
        rts

; ============================
;  Render the disc on-screen
; ============================
disc_draw:
        ; Increment disc animation counter
        ldy disc_anim
        iny
        sty disc_anim
        ; Mask bottom of playfield
        lda playfield_bottom
        sec
        sbc #$01
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
        ; Y position
        lda disc_y+1
        sec
        sbc #$01
        write_oam_y DISC_SPR_NUM
        write_oam_y (DISC_SPR_NUM + 1)
        clc
        adc #$08
        write_oam_y (DISC_SPR_NUM + 2)
        write_oam_y (DISC_SPR_NUM + 3)

        ; X position
        lda disc_x+1
        write_oam_x DISC_SPR_NUM
        write_oam_x (DISC_SPR_NUM + 2)
        clc
        adc #$08
        write_oam_x (DISC_SPR_NUM + 1)
        write_oam_x (DISC_SPR_NUM + 3)
        
        ; Tile selection
        lda disc_anim
        ;and #$0001000
        ;bne @secondhalf_anim

@firsthalf_anim:
        lda disc_anim
        and #%0001100
        lsr

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
@secondhalf_anim:
    
        ; Attributes
        lda #%00000000                  ; Unflipped
        write_oam_attr DISC_SPR_NUM
        write_oam_attr DISC_SPR_NUM + 1
        write_oam_attr DISC_SPR_NUM + 2
        write_oam_attr DISC_SPR_NUM + 3
        lda frame_counter
        and #%00000001
        beq @noshadow

        
        ; Every other frame, a shadow is drawn with sprites 5-8
        ; Shadow Y
        lda disc_y+1
        clc
        adc #$03
        write_oam_y DISC_SPR_NUM + 4
        write_oam_y DISC_SPR_NUM + 5
        clc
        adc #$08
        write_oam_y DISC_SPR_NUM + 6
        write_oam_y DISC_SPR_NUM + 7
        
        ; Shadow X
        lda disc_x+1
        clc
        adc #$02
        write_oam_x DISC_SPR_NUM + 4
        write_oam_x DISC_SPR_NUM + 6
        clc
        adc #$08
        write_oam_x DISC_SPR_NUM + 5
        write_oam_x DISC_SPR_NUM + 7

        ; Shadow tile
        set_oam_tile DISC_SPR_NUM + 4, #$08
        set_oam_tile DISC_SPR_NUM + 5, #$09
        set_oam_tile DISC_SPR_NUM + 6, #$18
        set_oam_tile DISC_SPR_NUM + 7, #$19

        ; Shadow attr
        lda #$00
        write_oam_attr DISC_SPR_NUM + 4
        write_oam_attr DISC_SPR_NUM + 5
        write_oam_attr DISC_SPR_NUM + 6
        write_oam_attr DISC_SPR_NUM + 7
        rts

@noshadow:
        ; Hide the shadow sprite entirely
        lda #$FE
        write_oam_y DISC_SPR_NUM + 4
        write_oam_y DISC_SPR_NUM + 5 
        write_oam_y DISC_SPR_NUM + 6
        write_oam_y DISC_SPR_NUM + 7

        rts

