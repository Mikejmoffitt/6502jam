.segment "HEADER"

; Magic cookie
.byte "NES", $1a

; Size of PRG in 16 KB units
.byte 1

; Size of CHR in 8 KB units (0 = CHR RAM)
.byte 1

; Mirroring, save RAM, trainer, mapper low nybble
.byte $42                                   ; mapper 4 (MMC3), save RAM

; Vs., PlayChoice-10, NES 2.0, mapper high nybble
.byte $00

; Size of PRG RAM in 8 KB units
.byte 1

; NTSC/PAL
.byte $00
