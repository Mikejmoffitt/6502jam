;Some banks mostly contain data rather than code.


; CHR
.segment "BANK0"

gfx1:
	.incbin "assets/gfx1.chr"

; Nametables, palettes
.segment "BANK1"

field1_table:
	.incbin "assets/field1.nam"

playfield_palettes:
	.incbin "assets/gfx1.dat"

; Sets of two sprite palette entries, specifying colors.
; The first of a pair should have $30 in the fourth entry, as the disc uses the
; first sprite palette.
; The third color may be overwritten as a skin color, but it defaults to $35.
player_palettes:
	;     null blck skin extra
	.byte $00, $0F, $35, $30
	.byte $00, $0F, $35, $11
	;     null blck skin extra
	.byte $00, $0F, $26, $30
	.byte $00, $0F, $26, $15
	;     null blck skin extra
	.byte $00, $0F, $17, $30
	.byte $00, $0F, $17, $1A


; Player graphics
.segment "BANK2"
	.include "player_gfx.asm"
