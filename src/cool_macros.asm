.IFNDEF COOL_MACROS_ASM
.DEFINE COOL_MACROS_ASM

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


.macro ppu_load_addr addr, addr_e
	ldx addr
	stx PPUADDR
	ldy addr_e
	sty PPUADDR
.endmacro

.macro ppu_load_scroll cam_x, cam_y
	bit PPUSTATUS
	lda cam_x
	sta PPUSCROLL
	lda cam_y
	sta PPUSCROLL
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

.ENDIF
