.include "header.asm"
.include "cool_macros.asm"
.include "zeropage.asm"
.include "resourcebanks.asm"

.segment "RAM"

; Button comparison table
button_table:
        btn_a:                                  .res 1
        btn_b:                                  .res 1
        btn_sel:                                .res 1
        btn_start:                              .res 1
        btn_up:                                 .res 1
        btn_down:                               .res 1
        btn_left:                               .res 1
        btn_right:                              .res 1

        xscroll:                                .res 2
        yscroll:                                .res 2
        ppuctrl_config:                         .res 1

        pad_1:                                  .res 1
        pad_1_prev:                             .res 1
        pad_2:                                  .res 1
        pad_2_prev:                             .res 1

        mario_dir:                              .res 1

        mario_x:                                .res 2
        mario_y:                                .res 2
        mario_dx:                               .res 2
        mario_dy:                               .res 2
        mario_speed:                            .res 2


.segment "BANK15"

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
        lda #$01
        ldx #$00
@build_controller_table:
        sta button_table, x
        inx
        rol a
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
        stx ppu_normal_state
        stx PPUMASK

        ppu_enable

        jmp main_entry                   ; GOTO main loop

; ============================
;   Simple sprite movement
; ============================

move_mario:

        lda pad_1
        bit btn_a
        beq @noa
        add16 mario_speed, #$01
@noa:

        lda pad_1
        bit btn_b
        beq @nob
        sub16 mario_speed, #$01
@nob:

        lda pad_1
        bit btn_start
        beq @nostart
        lda #$00
        sta mario_dy
        sta mario_dy+1
        sta mario_dx
        sta mario_dx+1

@nostart:

        lda pad_1 
        bit btn_up                      ; Up
        beq @noup
        sub16 mario_dy, mario_speed

@noup:
        lda pad_1 
        bit btn_down                    ; Down
        beq @nodown
        add16 mario_dy, mario_speed

@nodown:
        lda pad_1 
        bit btn_left                    ; Left
        beq @noleft
        sub16 mario_dx, mario_speed

@noleft:
        lda pad_1 
        bit btn_right                   ; Right
        beq @noright
        add16 mario_dx, mario_speed        

@noright:

        ; Apply X and Y vectors to Mario
        sum16 mario_x, mario_dx
        sum16 mario_y, mario_dy


        rts

; ============================ 
;          Main loop
; ============================

main_entry:
        jsr wait_nmi
        ppu_disable

        bank_load #$01
        ppu_write_8kbit table1, #$20
        ppu_write_8kbit table2, #$24

        bank_load #$00
        ; Sprites
        ppu_write_32kbit gfx1, #$00
        ; Backdrop
        ppu_write_32kbit gfx1 + $1000, #$10

        bank_load #$00
        ppu_load_full_palette palettes+$00

        ppu_enable
        jsr wait_nmi
        ppu_disable

        jsr spr_init

        spr_dma

        lda #$00
        sta yscroll

        lda #$04
        sta mario_speed

        ppu_enable

@toploop:
; Logic Updates
        jsr read_joy_safe_1
        jsr move_mario
        jsr draw_mario

        ldx xscroll
        lda #$00
        sta xscroll
        stx xscroll

; Graphics updates
        jsr wait_nmi
        ppu_disable

        spr_dma

        ppu_load_scroll xscroll, yscroll

        ppu_enable
        jmp @toploop
; ============================
;      Place some sprites
; ============================
draw_mario:
        clc
        lda mario_y+1
        sta OAM_BASE
        sta OAM_BASE + 4 ; Y
        adc #$08
        sta OAM_BASE + 8; Y
        sta OAM_BASE + 12; Y

        lda mario_dir
        bne @rightside                  ; Facing to the right
        lda #%01000000
        sta OAM_BASE + 2
        sta OAM_BASE + 6
        sta OAM_BASE + 10
        sta OAM_BASE + 14

        clc
        lda mario_x+1
        sta OAM_BASE + 3
        sta OAM_BASE + 11 ; X
        adc #$08
        sta OAM_BASE + 7 ; X
        sta OAM_BASE + 15 ; X
        lda #$00
        beq @tile_sel



@rightside:
        lda #%00000000
        sta OAM_BASE + 2
        sta OAM_BASE + 6
        sta OAM_BASE + 10
        sta OAM_BASE + 14

        clc
        lda mario_x
        sta OAM_BASE + 7 ; X
        sta OAM_BASE + 15 ; X
        adc #$08
        sta OAM_BASE + 3
        sta OAM_BASE + 11 ; X
        lda #$00
        beq @tile_sel

@tile_sel:
        
        lda mario_speed
        and #$04
        bne @frame2

        lda #$02 ; Tile
        sta OAM_BASE + 1
        lda #$03
        sta OAM_BASE + 5 ; Tile
        lda #$12
        sta OAM_BASE + 9 ; Tile
        lda #$13
        sta OAM_BASE + 13 ; Tile
        lda #$00
        beq @donetiles

@frame2:
        lda #$00 ; Tile
        sta OAM_BASE + 1
        lda #$01
        sta OAM_BASE + 5 ; Tile
        lda #$10
        sta OAM_BASE + 9 ; Tile
        lda #$11
        sta OAM_BASE + 13 ; Tile

        lda #$00
        beq @donetiles

@donetiles:

        lda mario_dir
        beq :+  
        lda #%01000000                  ; Set flip
        bne :++
:
        lda #%00000000                  ; Set unflipped
:
        sta OAM_BASE + 2
        sta OAM_BASE + 6
        sta OAM_BASE + 10
        sta OAM_BASE + 14

        rts

.include "utils.asm"                    ; Pull in NMI support code
.include "sprites.asm"

.segment "VECTORS"

        .addr        nmi_vector
        .addr        reset_vector
        .addr        irq_vector

