

PLAYER_W = $18
PLAYER_H = $20

PLAYER_SPR_NUM = 18 

PLAYER_OFFSET = $0e

PLAYER_DIR_RIGHT = $00
PLAYER_DIR_LEFT = $01

; Struct access offsets
PLAYER_XOFF = $00
PLAYER_YOFF = $02
PLAYER_DXOFF = $04
PLAYER_DYOFF = $06
PLAYER_NUMOFF = $08
PLAYER_DIROFF = $09
PLAYER_SLIDE_CNTOFF = $0a
PLAYER_BLOCK_CNTOFF = $0b
PLAYER_SPR_NUMOFF = $0c
PLAYER_ANIM_FRAMEOFF = $0d

; Animation mapping constant data
; Four bytes follow the mapping of what goes into OAM, mostly
;       Sprite Y (relative to player's Y), signed; set to $FF to end the frame
;       Tile selection
;       Attributes; if bit 1 is set, then bit 0 will be set for player 2
;       Sprite X (relative to player's X), signed; flipped to face left
; Twelve sprites are allocated for a frame.
player_mapping_stand:
        .byte   <-32, $22, %00000001, <-4
        .byte   <-32, $23, %00000001, 4
        .byte   <-24, $32, %00000001, <-4
        .byte   <-24, $33, %00000001, 4
        .byte   <-16, $43, %00000010, <-4
        .byte   <-16, $44, %00000010, 4
        .byte   <-8, $53, %00000010, <-4
        .byte   <-8, $54, %00000010, 4
        .byte   $FF


; Have players respond to gamepad input
; Pre-entry conditions:
;       X is loaded with the player struct offset
player_handle_input:

@handle_accel:
        key_isdown pad_1, btn_up
        sub16 p1_y, #$40
:
        key_isdown pad_1, btn_down
        add16 p1_y, #$40
:
        key_isdown pad_1, btn_left
        sub16 p1_x, #$40
:
        key_isdown pad_1, btn_right
        add16 p1_x, #$40
:
        rts

; Draws a shadow below the players, much like the disc has
player_draw_shadow:
        
        rts

; Responsible for drawing both players to the screen based on state structs.
players_draw:      

        key_isdown pad_1, btn_left
        lda #$01
        sta player_state + PLAYER_DIROFF
:

        key_isdown pad_1, btn_right
        lda #$00
        sta player_state + PLAYER_DIROFF
:

; Set some sprite base numbers
        lda #PLAYER_SPR_NUM
        sta player_state + PLAYER_SPR_NUMOFF

        lda #PLAYER_SPR_NUM+16
        sta player_state + PLAYER_SPR_NUMOFF + PLAYER_OFFSET


        ldx #$00
        lda #<player_mapping_stand
        sta addr_ptr              
        lda #>player_mapping_stand
        sta addr_ptr+1
        jsr player_draw

@xoffset:
        ;ldx #PLAYER_OFFSET
@otherplayer:
        ldx #PLAYER_OFFSET
        lda #<player_mapping_stand
        sta addr_ptr                            
        lda #>player_mapping_stand
        sta addr_ptr+1

        jsr player_draw
        rts

; Draws a player to the screen; called by players_draw.
; Pre-entry conditions:
;       X is loaded with the player struct offset
;       addr_ptr is loaded with the address of the animation frame struct.
player_draw:

        lda player_state + PLAYER_SPR_NUMOFF, x 
        asl                                     ; * 2
        asl                                     ; * 2
        tay                                     ; Y = index into OAM table

        clc
        adc #$30                                
        sta temp                                ; Y base case

        sty temp2                               ; OAM index offset
        sub16 addr_ptr, temp2                   ; Subtract to correct for Y off

        lda #%00000010                          ; Store for                   
        sta temp2                               ; Palette comparison


; Pre-loop entry conditions:
        ; Y contains the offset from OAM_BASE to begin writing to (Y pos of first sprite)
        ; addr_ptr is a ZP 16-bit pointer to the base of the animation data to copy from
        ;     addr_ptr has initial Y subtracted from it to counter Y's offset
        ; X contains the player state offset (right now it is zero and unused anyway)
        ; temp2 contains #%00000010 for an attribute modification, presently unused
        ; temp contains Y + 48, which is the base case to end this loop
@oam_copy_loop:
                                                ; Y = OAM Y position
        ; Y position
        lda (addr_ptr), y                       ; Y pos relative to player
        cmp #$FF                                ; Check unused flag
        beq @end_frame                          ; Y-Pos was $FF; terminate loop
        clc
        adc player_state + PLAYER_YOFF + 1, x       ; Offset from player's Y center
        sta OAM_BASE, y
        iny                                     ; Y = OAM tile select

        lda (addr_ptr), y             
        sta OAM_BASE, y                     
        iny                                     ; Y = OAM attributes
        

        lda (addr_ptr), y
        cpx #$00
        beq @nomod_pal                          ; Don't modify palette for P1
        bit temp2                               ; Only modify the palette to #3 
        beq @nomod_pal                          ; if palette #2 is being used
        ora #%00000001

@nomod_pal:
        rol a
        rol a
        rol a
        ora player_state + PLAYER_DIROFF, x     ; X flip
        ror a
        ror a
        ror a
        sta OAM_BASE, y
        iny                                     ; Y = OAM X position


        lda player_state + PLAYER_DIROFF, x
        beq @noflipx
        sec
        lda #$00
        sbc (addr_ptr), y                       ; Reverse relative X position
        cld
        adc player_state + PLAYER_XOFF + 1, x       ; Offset from player's X center
        sta OAM_BASE, y
        iny 
        cpy temp
        bne @oam_copy_loop
        rts

@noflipx:
        lda (addr_ptr), y                       ; X pos relative to player
        clc                                     ; Add one to X offset
        adc player_state + PLAYER_XOFF + 1, x       ; Offset from player's X center
        sta OAM_BASE, y
        iny
       
        cpy temp
        bne @oam_copy_loop
        rts
        
; This branch is for when a sprite is to be hidden so we can ignore everything
; other than the Y position
@end_frame:
        sta OAM_BASE, y                         ; Hide this sprite
        iny
        iny
        iny
        iny
        cpy temp                                ; Hide all remaining sprites
        bne @end_frame                          ; for this player.
        rts
