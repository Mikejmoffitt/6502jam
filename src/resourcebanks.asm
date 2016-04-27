;Some banks mostly contain data rather than code.


; CHR
.segment "BANK0"

gfx1:
.incbin "assets/gfx1.chr"

; Nametables, palettes
.segment "BANK1"

field1_table:
.incbin "assets/field1.nam"

palettes:
.incbin "assets/gfx1.dat"
