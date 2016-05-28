
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

PLAYER_BLOCK_DELAY = $0A
PLAYER_SLIDE_DELAY = $07

; Struct access offsets

; Basic movement variables
PLAYER_XOFF = $00
PLAYER_YOFF = $02
PLAYER_DXOFF = $04
PLAYER_DYOFF = $06
PLAYER_NUMOFF = $08
PLAYER_DIRXOFF = $09
PLAYER_DIRYOFF = $0a
PLAYER_FACINGOFF = $0b

; Animation scripting variables
PLAYER_SPR_NUMOFF = $0c
PLAYER_ANIM_MAPOFF = $0d		; Animation MAP table; MUST be right before anim_addr
PLAYER_ANIM_ADDROFF = $0f		; Address of animation script
PLAYER_ANIM_TABLEOFF = $11		; Address of table of animations to use
PLAYER_ANIM_FRAMEOFF = $12		; Currently displayed frame of animation
PLAYER_ANIM_CNTOFF = $13		; Countup for frame duration; When cnt == len, frame++
PLAYER_ANIM_LENOFF = $14		; Anim length; When frame == len, frame <= 0.
PLAYER_ANIM_NUMOFF = $15


PLAYER_STATS_ADDROFF = $16		; Pointer to stats block

; Gameplay player variables
PLAYER_SLIDE_CNTOFF = $20		; When nonzero, decremnts when dx and dy == 0, 
					; restoring control once it reaches zero.
PLAYER_BLOCK_CNTOFF = $21		; Decrements; halts player and locks control
					; until it reaches zero. 
PLAYER_CHARGE_CNTOFF = $22		; Counts upwards when the player is under the disc's
					; drop target. Controls lock when non-zero, dx/dy zeroed.
PLAYER_THROW_CNTOFF = $23		; Counts down while player is in throwing animation.


.include "../assets/cmaps/girl.asm"

; Player init and load_gfx are in utils.

.include "player_movement.asm"
.include "player_render.asm"
