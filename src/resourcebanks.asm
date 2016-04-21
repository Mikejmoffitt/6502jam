; Some banks mostly contain data rather than code.


; Palettes and CHR
.segment "BANK00"

palettes:
.incbin "assets/palettes.dat"

gfx1:
.incbin "assets/gfx1.chr"

; Nametables
.segment "BANK01"

table1:
.incbin "assets/test1.nam"
table2:
.incbin "assets/test2.nam"
