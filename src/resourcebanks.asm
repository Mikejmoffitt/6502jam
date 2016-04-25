; Some banks mostly contain data rather than code.


; Palettes and CHR
.segment "BANK0"

palettes:
.incbin "assets/palettes.dat"

gfx1:
.incbin "assets/gfx1.chr"

; Nametables
.segment "BANK1"

field1_table:
.incbin "assets/field1.nam"
