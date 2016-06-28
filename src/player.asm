
PLAYER_W = $0c
PLAYER_H = $08

PLAYER_SPR_NUM = 18

PLAYER_DIR_RIGHT = $00
PLAYER_DIR_LEFT = $01
PLAYER_DIR_DOWN = $00
PLAYER_DIR_UP = $01

PLAYER_FACING_UP = $00
PLAYER_FACING_DOWN = $01
PLAYER_FACING_LEFT = $02
PLAYER_FACING_RIGHT = $03

ANIM_STAND_FWD 		= $00
ANIM_STAND_UP 		= $01
ANIM_STAND_DOWN		= $02
ANIM_RUN_FWD		= $03
ANIM_RUN_UP		= $04
ANIM_RUN_DOWN		= $05
ANIM_BLOCK		= $06
ANIM_SLIDE_FWD		= $07
ANIM_SLIDE_FWDUP	= $08
ANIM_SLIDE_FWDDOWN	= $09
ANIM_SLIDE_UP		= $0A
ANIM_SLIDE_DOWN		= $0B

MAP_END			= $7F

PLAYER_BLOCK_DELAY = $0D
PLAYER_SLIDE_DELAY = $03

; player_state member offsets
STATS_WALK_S = $00
STATS_WALK_D = $02
STATS_DASH_STR = $04
STATS_DECEL_F = $06
STATS_DECEL_S = $08
STATS_THROW_STR = $0A
STATS_THROW_STALE = $0C
STATS_CHR_BANK = $0E
STATS_CHR_PTR = $0F
STATS_PAL_PTR = $11
STATS_ANIM_PTR = $13

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

; Pointer to character description (stats, anim table pointer, etc)
PLAYER_STATS_ADDROFF = $16		; Pointer to stats block

; Gameplay player variables
PLAYER_SLIDE_CNTOFF = $20		; When nonzero, decremnts when dx and dy == 0, 
					; restoring control once it reaches zero.
PLAYER_BLOCK_CNTOFF = $21		; Decrements; halts player and locks control
					; until it reaches zero. 
PLAYER_CHARGE_CNTOFF = $22		; Counts upwards when the player is under the disc's
					; drop target. Controls lock when non-zero, dx/dy zeroed.
PLAYER_THROW_CNTOFF = $23		; Counts down while player is in throwing animation.

; characeter_x struct offsets



.include "player_movement.asm"
.include "player_render.asm"
