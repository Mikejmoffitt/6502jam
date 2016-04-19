; Some potentially useful macros for NES stuff
; Handy NES defines
PPUCTRL     = $2000
PPUMASK     = $2001
PPUSTATUS   = $2002
OAMADDR     = $2003
OAMDATA     = $2004
PPUSCROLL   = $2005
PPUADDR     = $2006
PPUDATA     = $2007
OAMDMA      = $4014
DMCFREQ     = $4010

; Turn off rendering
.macro ppu_disable
	lda #$00			; 
	sta PPUMASK			; Disable rendering
.endmacro

; Turn on rendering
.macro ppu_enable
	lda ppu_normal_state
	sta PPUMASK			; Put back PPU rendering state to what it was before
	lda #%10011000
	sta PPUCTRL			; Re-enable NMI
.endmacro


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

.macro	inc16	addr
	clc
	lda	addr
	adc #$01
	sta	addr
	lda	addr+1
	adc	#$00
	sta	addr+1
.endmacro
