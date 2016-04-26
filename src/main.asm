.include "header.asm"
.include "cool_macros.asm"
.include "zeropage.asm"
.include "resourcebanks.asm"
.include "ram.asm"

PLAYFIELD_HEIGHT = $9f
PLAYFIELD_Y      = $50
PLAYFIELD_WIDTH  = $ef
PLAYFIELD_X      = $07


.segment "BANKF"

; Turn off rendering
.macro ppu_disable
        lda #$00                        ; 
        sta PPUMASK                     ; Disable rendering
.endmacro

; Turn on rendering
.macro ppu_enable
        lda ppumask_config
        sta PPUMASK                     ; Put back PPU rendering state to what it was before

        lda ppuctrl_config
        ora xscroll+1                   ; Bring in X scroll coarse bit
        ora yscroll+1                    ; Y scroll coarse bit
        sta PPUCTRL                     ; Re-enable NMI
.endmacro

; ============================ 
;           NMI ISR
; ============================
nmi_vector:
        pha                             ; Preseve registers on stack
        txa
        pha
        tya
        pha

        ldx frame_counter               ; Update frame counter
        inx
        stx frame_counter

        lda #$00
        sta PPUCTRL                     ; Disable NMI
        sta vblank_flag

        lda #$80                        ; Bit 7, VBlank activity flag
@vbl_done:
        bit PPUSTATUS                   ; Check if vblank has finished
        bne @vbl_done                   ; Repeat until vblank is over
        
        lda #%10011011
        sta PPUCTRL                     ; Re-enable NMI

        pla                             ; Restore registers from stack
        tay
        pla
        tax
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
; Basic 6502 init
        sei                             ; ignore IRQs
        cld                             ; No decimal mode, it isn't supported
        ldx #$40
        stx $4017                       ; Disable APU frame IRQ
        ldx #$ff
        txs                             ; Set up stack
        
; Clear some PPU registers
        inx                             ; X = 0 now
        stx PPUCTRL                     ; Disable NMI
        stx PPUMASK                     ; Disable rendering
        stx DMCFREQ                     ; Disable DMC IRQs

; Configure UOROM

        lda #$00
        sta $8000

; Wait for first vblank
@waitvbl1:
        lda #$80
        bit PPUSTATUS
        bne @waitvbl1

; Wait for the PPU to go stable
        txa                             ; X still = 0; clear A with this
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

; Make controller comparison table
        lda #$80
        ldx #$00
@build_controller_table:
        sta button_table, x
        inx
        lsr
        bne @build_controller_table
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
        stx ppumask_config
        stx PPUMASK

        ppu_enable

        jmp main_entry                   ; GOTO main loop

; ============================
;   Initialize the playfield
; ============================
playfield_init:

        jsr wait_nmi
        ppu_disable
        
        bank_load #$01
        ppu_write_8kbit field1_table, #$20

        bank_load #$00
        ; Sprites
        ppu_write_32kbit gfx1, #$00
        ; Backdrop
        ppu_write_32kbit gfx1 + $1000, #$10
        ppu_load_full_palette palettes+$00

        lda #PLAYFIELD_X
        sta playfield_left
        lda #(PLAYFIELD_X + PLAYFIELD_WIDTH)
        sta playfield_right
        lda #PLAYFIELD_Y
        sta playfield_top
        lda #(PLAYFIELD_Y + PLAYFIELD_HEIGHT)
        sta playfield_bottom

        lda #$80
        sta disc_y+1
        sta disc_x+1
        lda #$20
        sta p1_x+1
        lda #$D8
        sta p2_x+1

        lda #PLAYFIELD_Y+(PLAYFIELD_HEIGHT/2)
        sta p1_y+1
        sta p2_y+1

        lda #$01
        sta p2_dir

        lda #$00
        sta p1_y
        sta p2_y
        sta p1_x
        sta p2_x

        rts

; ============================ 
;          Main loop
; ============================

main_entry:
        jsr playfield_init
        jsr spr_init
        spr_dma

        lda #$00
        sta yscroll
        jsr wait_nmi   
        ppu_enable
@toploop:
; Logic Updates
        jsr read_joy_safe


; Disc and player logic are in bank E
        bank_load #$0E

        jsr disc_movement
        jsr player_handle_input
       
        jsr disc_draw
        jsr players_draw
        jsr disc_bottom_mask_draw

; Graphics updates
        ; Enable emphasis to test performance
;        key_isdown pad_1, btn_a
;        lda ppumask_config
;        ora #%01100000
;        sta PPUMASK
;:
        jsr wait_nmi
        ppu_disable

        spr_dma

        ppu_load_scroll xscroll, yscroll

        ppu_enable
        jmp @toploop


.include "utils.asm"                    ; Pull in NMI support code
.include "sprites.asm"

; Some gameplay code goes here
.segment "BANKE"
.include "disc.asm"
.include "player.asm"

.segment "VECTORS"

        .addr        nmi_vector
        .addr        reset_vector
        .addr        irq_vector

