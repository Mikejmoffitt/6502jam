;Some banks mostly contain data rather than code.


; Players
; =======
;
; Player scripts and stats information structs are stored in BANKF so as to not
; require any banking. 
; Player graphics are stored in other banks, determined by the player file.
;
; Players will make their own segment assigments and therefore that should not
; be assigned here.
;
.include "../assets/char/girl.asm"

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
