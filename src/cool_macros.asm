; Some potentially useful macros for NES stuff
; Handy NES defines
PPUCTRL         = $2000
PPUMASK         = $2001
PPUSTATUS       = $2002
OAMADDR         = $2003
OAMDATA         = $2004
PPUSCROLL       = $2005
PPUADDR         = $2006
PPUDATA         = $2007
OAMDMA          = $4014
DMCFREQ         = $4010

XCOARSE         = $01
YCOARSE         = $02

BUTTON_A        = %00000001
BUTTON_B        = %00000010
BUTTON_SEL      = %00000100
BUTTON_START    = %00001000
BUTTON_UP       = %00010000
BUTTON_DOWN     = %00100000
BUTTON_LEFT     = %01000000
BUTTON_RIGHT    = %10000000

; Latch the PPU address; mangles Y
.macro ppu_load_addr addr, addr_e
        bit PPUSTATUS
        lda addr
        sta PPUADDR
        lda addr_e
        sta PPUADDR
.endmacro

; Latch the PPU fine scroll; mangles X
.macro ppu_load_scroll cam_x, cam_y
        bit PPUSTATUS
        lda cam_x
        sta PPUSCROLL
        lda cam_y
        sta PPUSCROLL
.endmacro

; Switch UOROM banks
.macro bank_load num
:
        ldy num
        sty :- + 1 ; This is done this way to avoid bus conflicts
.endmacro

; Load a full palette
.macro ppu_load_full_palette pal_data
        ppu_load_addr #$3f, #$00
        ldx #$00
:
        lda pal_data, x
        sta PPUDATA
        inx
        cpx #$20
        bne :-
.endmacro

; Load a full BG palette
.macro ppu_load_bg_palette pal_data
        ppu_load_addr #$3f, #$00
        ldx #$00
:
        lda pal_data, x
        sta PPUDATA
        inx
        cpx #$10
        bne :-
.endmacro

; Load a full SPR palette
.macro ppu_load_spr_palette pal_data
        ppu_load_addr #$3f, #$10
        ldx #$00
:
        lda pal_data, x
        sta PPUDATA
        inx
        cpx #$10
        bne :-
.endmacro

.macro ppu_write_data data
        lda data
        sta PPUDATA
.endmacro

; Add a 16-bit memory value to addr
.macro sum16 addr, val
        clc
        lda addr
        adc val
        sta addr
        lda addr+1
        adc val+1
        sta addr+1
.endmacro

.macro add16 addr, amt
        clc
        lda addr
        adc amt
        sta addr
        lda addr+1
        adc #$00
        sta addr+1
.endmacro

.macro sub16 addr, amt
        sec
        lda addr
        sbc amt
        sta addr
        lda addr+1
        sbc #$00
        sta addr+1
.endmacro


; Run an OAM DMA
.macro spr_dma
        lda #$02
        sta OAMDMA
.endmacro

; Copy binary nametable + attribute data into VRAM

.macro ppu_write_4k source, index
        ldy index                       ; Upper byte of VRAM Address
        ldx #$00                        ; Lower byte of VRAM Address

        bit PPUSTATUS
        sty PPUADDR
        stx PPUADDR

; X is the offset in both the source table and the nametable destination.
; PPUADDR increments with every write to PPUDATA, so an unrolled two-level
; nested loop becomes four single loops, taking us through the source
; table in four chunks.

:
        lda source, x                   ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $100, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $200, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $300, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
.endmacro

.macro ppu_write_16k source, index
        ldy index                       ; Upper byte of VRAM Address
        ldx #$00                        ; Lower byte of VRAM Address

        bit PPUSTATUS
        sty PPUADDR
        stx PPUADDR

; X is the offset in both the source table and the nametable destination.
; PPUADDR increments with every write to PPUDATA, so an unrolled two-level
; nested loop becomes four single loops, taking us through the source
; table in four chunks.

:
        lda source, x                   ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $100, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $200, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $300, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $400, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $500, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $600, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $700, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $800, x                   ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $900, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $a00, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $b00, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $c00, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $d00, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $e00, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
:
        lda source + $f00, x            ; Offset within both source and dest.
        sta PPUDATA
        inx
        bne :-
.endmacro

; Load $100 of pattern data into index in CHR RAM
.macro ppu_write_1k source, index
        ldy index
        ldx #$00
        bit PPUSTATUS
        sty PPUADDR
        stx PPUADDR
:
        lda source, x
        sta PPUDATA
        inx
        bne :-
.endmacro
