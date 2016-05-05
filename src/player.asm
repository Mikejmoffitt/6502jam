
PLAYER_W = $0c
PLAYER_H = $08

PLAYER_SPR_NUM = 18

PLAYER_DIR_RIGHT = $00
PLAYER_DIR_LEFT = $01

PLAYER_FACING_UP = $00
PLAYER_FACING_DOWN = $01
PLAYER_FACING_LEFT = $02
PLAYER_FACING_RIGHT = $03

ANIM_STAND_FWD 	= $00
ANIM_STAND_UP 	= $01
ANIM_STAND_DOWN	= $02
ANIM_RUN_FWD	= $03
ANIM_RUN_UP	= $04
ANIM_RUN_DOWN	= $05


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

PLAYER_ANIM_MAPOFF = $0e		; Animation MAP table; MUST be right before anim_addr
PLAYER_ANIM_ADDROFF = $10		; Address of animation script
PLAYER_ANIM_TABLEOFF = $12		; Address of table of animations to use
PLAYER_ANIM_FRAMEOFF = $13		; Currently displayed frame of animation
PLAYER_ANIM_CNTOFF = $14		; Countup for frame duration; When cnt == len, frame++
PLAYER_ANIM_LENOFF = $15		; Anim length; When frame == len, frame <= 0.
PLAYER_ANIM_NUMOFF = $16

PLAYER_FACINGOFF = $17

PLAYER_STATS_ADDROFF = $18		; Pointer to stats block

.include "../assets/cmaps/girl.asm"

; Player init and load_gfx are in utils.

.include "player_movement.asm"
.include "player_render.asm"
