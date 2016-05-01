
PLAYER_W = $18
PLAYER_H = $20

PLAYER_SPR_NUM = 18

PLAYER_DIR_RIGHT = $00
PLAYER_DIR_LEFT = $01

; Struct access offsets
PLAYER_XOFF = $00
PLAYER_YOFF = $02
PLAYER_DXOFF = $04
PLAYER_DYOFF = $06
PLAYER_NUMOFF = $08
PLAYER_DIRXOFF = $09
PLAYER_DIRYOFF = $0a
PLAYER_SLIDE_CNTOFF = $0b
PLAYER_BLOCK_CNTOFF = $0c
PLAYER_SPR_NUMOFF = $0d

PLAYER_ANIM_LOOKUPOFF = $0e		; Animation lookup table; MUST be right before anim_addr
PLAYER_ANIM_ADDROFF = $10		; Address of animation script
PLAYER_ANIM_TABLEOFF = $12		; Address of table of animations to use
PLAYER_ANIM_FRAMEOFF = $13		; Currently displayed frame of animation
PLAYER_ANIM_CNTOFF = $14		; Countup for frame duration; When cnt == len, frame++
PLAYER_ANIM_LENOFF = $15		; Anim length; When frame == len, frame <= 0.
PLAYER_ANIM_NUMOFF = $16

; Player struct size

players_init:
	ldx #PLAYER_SIZE*2 - 1
	lda #$00

@clear_players:
	sta player_state, x

	dex
	beq @clear_players

; Load player initial state information

; P1 faces right
	ldx #PLAYER_DIR_RIGHT
	stx player_state + PLAYER_DIRXOFF	
	inx ; X gets PLAYER_DIR_LEFT
; P2 faces left
	stx player_state + PLAYER_DIRXOFF + PLAYER_SIZE

; both players start at half-height on the field
	lda playfield_top		; A = Playfield top
	lsr				; A = Top/2
	sta temp			
	lda playfield_bottom		; A = Playfield bottom
	lsr				; A = Bottom/2
	clc				
	adc temp			; A += Top/2 == center Y
	sta player_state + PLAYER_YOFF+1
	sta player_state + PLAYER_YOFF+1 + PLAYER_SIZE

	lda playfield_top
	sta player_state + PLAYER_YOFF+1

; TODO: Choose this based on character selection
; temporarily set up player to run the girl's animations
	lda #<girl_anim_num_lookup
	sta player_state + PLAYER_ANIM_LOOKUPOFF
	sta player_state + PLAYER_ANIM_LOOKUPOFF + PLAYER_SIZE
	lda #>girl_anim_num_lookup
	sta player_state + PLAYER_ANIM_LOOKUPOFF + 1
	sta player_state + PLAYER_ANIM_LOOKUPOFF + 1 + PLAYER_SIZE

; P1 on the left side
	lda playfield_left
	clc
	adc #$10
	sta player_state + PLAYER_XOFF+1
; P2 on the right
	lda playfield_right
	sec
	sbc #$10
	sta player_state + PLAYER_XOFF+1+PLAYER_SIZE


	rts


.include "player_movement.asm"
.include "player_render.asm"
.include "../assets/cmaps/girl.asm"
