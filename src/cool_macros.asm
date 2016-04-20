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

.macro inc16 addr
        clc
        lda        addr
        adc #$01
        sta        addr
        lda        addr+1
        adc        #$00
        sta        addr+1
.endmacro

; Run an OAM DMA
.macro spr_dma
        lda #$02
        sta OAMDMA
.endmacro

; Copy binary nametable + attribute data into VRAM

.macro ppu_load_nametable source, screen
        ldy screen                      ; Upper byte of VRAM Address
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
