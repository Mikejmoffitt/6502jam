.include "header.inc"
.include "cool_macros.asm"
.include "zeropage.asm"

.segment "VECTORS"

	.addr	nmi_vector
	.addr	reset_vector
	.addr	irq_vector

.segment "CODE"

.macro ppu_disable
	lda #$00			; 
	sta PPUMASK			; Disable rendering
	sta PPUCTRL			; Disable NMI
.endmacro

.macro ppu_enable
	ldx ppu_normal_state
	stx PPUMASK			; Put back PPU rendering state to what it was before
	lda #$C0	
	sta PPUCTRL			; Re-enable NMI
.endmacro

nmi_vector:
irq_vector:
	ppu_disable			; Disable rendering and NMI

	lda #$80			; Bit 7, VBlank activity flag
@vbl_done:
	bit PPUSTATUS		; Check if vblank has finished
	bne @vbl_done		; Repeat until vblank is over

	jsr goofy_cycle		; Run stupid palette cycle thing

	ppu_enable			; Enable rendering and NMI

	lda #$00
	sta vblank_waiting	; Clear waiting flag
	rti

; ============================ 
;         Entry Point
; ============================

reset_vector:
	sei					; ignore IRQs
	cld					; No decimal mode, it isn't supported
	ldx #$40
	stx $4017			; Disable APU frame IRQ
	ldx #$ff
	txs					; Set up stack
	
	inx					; X = 0
	stx PPUCTRL			; Disable NMI
	stx PPUMASK			; Disable rendering
	stx DMCFREQ			; Disable DMC IRQs
	stx $e000			; Disable MMC3 IRQs

; Wait for first vblank
@waitvbl1:
	lda #$80
	bit PPUSTATUS
	bne @waitvbl1

; Wait for the PPU to go stable
	txa					; X still = 0; clear A with this
@clrmem:
	sta $000, x
	sta $100, x 		
	; Reserving $200 for OAM display list
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x

	inx
	bne @clrmem
; One more vblank
@waitvbl2:
	lda #$80
	bit PPUSTATUS
	bne @waitvbl2

; Okay, set up the PPU for real
	ldx #$80
	stx PPUCTRL

	ldx #$1e
	stx ppu_normal_state
	stx PPUMASK

	ppu_enable

; ============================ 
;          Main loop
; ============================

main_loop:
	jsr wait_nmi

	jmp main_loop


; ============================ 
;     Goofy palette cycle
; ============================

goofy_cycle:
; Set write address to backdrop palette
	ppu_load_addr #$3f, #$00

; Increment backdrop palette value
	ldx pal_val
	inx
	stx PPUDATA
	stx pal_val
	rts

.include "utils.asm"


.segment "CHR"
.incbin "assets/mario.chr"

;.segment "SAVE"
;	.res 1
