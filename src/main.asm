.include "header.asm"
.include "cool_macros.asm"
.include "zeropage.asm"

OAM_BASE = $200

.segment "BSS"
xscroll:                                .res 1
xscroll_coarse:                         .res 1
yscroll:                                .res 1
yscroll_coarse:                         .res 1
ppuctrl_config:                         .res 1

.segment "CODE"

; Turn off rendering
.macro ppu_disable
        lda #$00                        ; 
        sta PPUMASK                     ; Disable rendering
.endmacro

; Turn on rendering
.macro ppu_enable
        lda ppu_normal_state
        sta PPUMASK                     ; Put back PPU rendering state to what it was before

        lda ppuctrl_config
        ora xscroll_coarse              ; Bring in X scroll coarse bit
        ora yscroll_coarse              ; Y scroll coarse bit
        sta PPUCTRL                     ; Re-enable NMI
.endmacro

; ============================ 
;           NMI ISR
; ============================
nmi_vector:
        pha
        php

        lda #$00
        sta PPUCTRL                     ; Disable NMI
        sta vblank_flag

        lda #$80                        ; Bit 7, VBlank activity flag
@vbl_done:
        bit PPUSTATUS                   ; Check if vblank has finished
        bne @vbl_done                   ; Repeat until vblank is over
        
        lda #%10011011
        sta PPUCTRL                     ; Re-enable NMI

        plp
        pla
        
        rti

; ============================ 
;           IRQ ISR
; ============================
irq_vector:
        rti

; ============================ 
;         Entry Point
; ============================

reset_vector:
        sei                              ; ignore IRQs
        cld                              ; No decimal mode, it isn't supported
        ldx #$40
        stx $4017                        ; Disable APU frame IRQ
        ldx #$ff
        txs                              ; Set up stack
        
        inx                              ; X = 0 now
        stx PPUCTRL                      ; Disable NMI
        stx PPUMASK                      ; Disable rendering
        stx DMCFREQ                      ; Disable DMC IRQs
        stx $e000                        ; Disable MMC3 IRQs

; Wait for first vblank
@waitvbl1:
        lda #$80
        bit PPUSTATUS
        bne @waitvbl1

; Wait for the PPU to go stable
        txa                              ; X still = 0; clear A with this
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

; PPU configuration for actual use
        ldx #%10010000                  ; Nominal PPUCTRL settings 
                                        ; NMI enable
                                        ; Slave mode
                                        ; 8x8 sprites
                                        ; BG at $1000
                                        ; SPR at $0000
                                        ; VRAM auto-inc 1
        stx ppuctrl_config
        stx PPUCTRL


        ldx #%00011110
        stx ppu_normal_state
        stx PPUMASK

        ppu_enable


        jmp main_entry                   ; GOTO main loop

test_pal:
        .byt $22, $37, $17, $0F
        .byt $22, $30, $31, $0F
        .byt $22, $29, $19, $0F
        .byt $22, $26, $15, $0F
        .byt $22, $16, $36, $12
        .byt $22, $37, $3a, $3d
        .byt $22, $38, $3b, $3e
        .byt $22, $39, $3c, $3f

test_table:
.incbin "assets/blank.nam"

; ============================ 
;          Main loop
; ============================

main_entry:
        jsr wait_nmi
        ppu_disable

        ppu_load_nametable test_table, #$20

        ppu_load_full_palette test_pal

        ppu_enable
        jsr wait_nmi
        ppu_disable

        jsr spr_init

        jsr sprite_test

        spr_dma

        lda #$00
        sta yscroll

        ppu_enable

@toploop:
; Logic Updates
        ldx xscroll
        inx
        bne @no_reset_scroll

        lda xscroll_coarse
        eor #XCOARSE
        sta xscroll_coarse

@no_reset_scroll:

        stx xscroll
        

; Graphics updates
        jsr wait_nmi
        ppu_disable

        ppu_load_scroll xscroll, yscroll

        ppu_enable
        jmp @toploop
; ============================
;      Place some sprites
; ============================
sprite_test:
        ; Top-left of head
        ldx #$60 ; Y
        stx OAM_BASE
        ldx #$32 ; Tile
        stx OAM_BASE + 1
        ldx #%00000000
        stx OAM_BASE + 2
        ldx #$40 ; X
        stx OAM_BASE + 3

        ; Top-right
        ldx #$60
        stx OAM_BASE + 4 ; Y
        ldx #$41
        stx OAM_BASE + 5 ; Tile
        ldx #%00000000
        stx OAM_BASE + 6
        ldx #$48
        stx OAM_BASE + 7 ; X

        ; Bottom-left of head
        ldx #$68
        stx OAM_BASE + 8; Y
        ldx #$42
        stx OAM_BASE + 9 ; Tile
        ldx #%00000000
        stx OAM_BASE + 10
        ldx #$40
        stx OAM_BASE + 11 ; X

        ; Bottom-right
        ldx #$68
        stx OAM_BASE + 12; Y
        ldx #$43
        stx OAM_BASE + 13 ; Tile
        ldx #%00000000
        stx OAM_BASE + 14
        ldx #$48
        stx OAM_BASE + 15 ; X


        rts

; ============================ 
;     Goofy palette cycle
; ============================

palcycle_test:
; Set write address to backdrop palette
        ppu_load_addr #$3f, #$00

; Increment backdrop palette value
        ldx pal_val
        inx
        stx PPUDATA
        stx pal_val
        rts


.include "utils.asm"                    ; Pull in NMI support code
.include "sprites.asm"

.segment "CHR"
.incbin "assets/mario.chr"

;.segment "SAVE"
;        .res 1

.segment "VECTORS"

        .addr        nmi_vector
        .addr        reset_vector
        .addr        irq_vector

