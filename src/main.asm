.include "header.asm"
.include "cool_macros.asm"
.include "ram.asm"
.include "resourcebanks.asm"

PLAYFIELD_HEIGHT = $b0
PLAYFIELD_Y      = $40
PLAYFIELD_WIDTH  = $e8
PLAYFIELD_X      = $0c

FENCE_SPR_Y = $CF

; Some gameplay code goes here
.segment "BANKE"
.include "disc.asm"
.include "player.asm"

.segment "BANKF"

; Turn off rendering
.macro ppu_disable
	lda #$00		
	sta PPUMASK			; Disable rendering
.endmacro

; Turn on rendering
.macro ppu_enable
	lda ppumask_config
	sta PPUMASK			; Put back PPU rendering state to what it was before

	lda ppuctrl_config
	ora xscroll+1			; Bring in X scroll coarse bit
	ora yscroll+1			; Y scroll coarse bit
	sta PPUCTRL			; Re-enable NMI
.endmacro

; ============================
;	  NMI ISR
; ============================
nmi_vector:
	pha				; Preseve registers on stack
	txa
	pha
	tya
	pha
	
	inc frame_counter		; Update frame counter

	lda #$00
	sta PPUCTRL			; Disable NMI
	sta vblank_flag

	lda #$80			; Bit 7, VBlank activity flag
@vbl_done:
	bit PPUSTATUS			; Check if vblank has finished
	bne @vbl_done			; Repeat until vblank is over

	lda #%10011011
	sta PPUCTRL			; Re-enable NMI

	pla				; Restore registers from stack
	tay
	pla
	tax
	pla

	rti

; ============================
;	  IRQ ISR
; ============================
irq_vector:
	rti

; ============================
;	Entry Point
; ============================

reset_vector:
; Basic 6502 init
	sei				; ignore IRQs
	cld				; No decimal mode, it isn't supported
	ldx #$40
	stx $4017			; Disable APU frame IRQ
	ldx #$ff
	txs				; Set up stack

; Clear some PPU registers
	inx				; X = 0 now
	stx PPUCTRL			; Disable NMI
	stx PPUMASK			; Disable rendering
	stx DMCFREQ			; Disable DMC IRQs

; Configure UOROM

	lda #$00
	sta $8000

; Wait for first vblank
@waitvbl1:
	lda #$80
	bit PPUSTATUS
	bne @waitvbl1

; Wait for the PPU to go stable
	txa				; X still = 0; clear A with this
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
	ldx #%10010000			; Nominal PPUCTRL settings
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

	jmp main_entry			; GOTO main loop

; ============================
;   Initialize the playfield
; ============================
playfield_init:

	bank_load #$00
	; Playfield #1's CHR data
	ppu_write_32kbit gfx1 + $1000, #$10

	bank_load #$01
	; Playfield #1's mappings
	ppu_write_8kbit field1_table, #$20
	; Playfield #1's palettes
	ppu_load_bg_palette playfield_palettes


; Store playfield dimensions
	lda #PLAYFIELD_X
	sta playfield_left
	lda #(PLAYFIELD_X + PLAYFIELD_WIDTH)
	sta playfield_right
	lda #PLAYFIELD_Y
	sta playfield_top
	lda #(PLAYFIELD_Y + PLAYFIELD_HEIGHT)
	sta playfield_bottom

	lda playfield_left
	lsr a
	sta temp
	lda playfield_right
	lsr a
	clc
	adc temp
	sta playfield_center

	; Player sprite test graphics
	bank_load #$00
	; Sprites
	ppu_write_32kbit gfx1, #$00

	rts

; ============================
;	 Main loop
; ============================

main_entry:
	jsr spr_init
	jsr wait_nmi
	ppu_disable
	jsr playfield_init

	bank_load #$0E
	jsr disc_init
	jsr players_init

	lda #$00
	sta xscroll
	sta xscroll+1
	sta yscroll+1
	sta yscroll

	spr_dma
	ppu_enable

@toploop:
; Logic updates ------------------------
; Update controller state captures
	jsr read_joy_safe

; Disc and player logic are in bank E
	bank_load #$0E

; Establish frame tick preconditions
	jsr players_handle_input

; Run a tick of physics
	jsr disc_move
	jsr players_move
	jsr players_check_disc

; Render from new result
	jsr disc_draw
	jsr players_draw
	jsr fence_mask_draw

; Graphics updates ---------------------
	jsr wait_nmi
	ppu_disable

	spr_dma
	ppu_load_scroll xscroll, yscroll

	ppu_enable
	jmp @toploop

	rts


; Initialize players. 
; TODO: Scrappy hack test that should be remove. 
players_init:

	lda #<character_girl
	sta addr_ptr
	lda #>character_girl
	sta addr_ptr + 1
	ldx #$00
	jsr load_character

	lda #<character_girl
	sta addr_ptr
	lda #>character_girl
	sta addr_ptr + 1
	ldx #PLAYER_SIZE
	jsr load_character

	rts


; Routine to load a 
; character's graphics, set the
; stats pointer, etc.
;
; Pre:
;     X: Player offset to load into (0 for P1, PLAYER_SIZE for p2)
;     addr_ptr loaded with address of desired character
; Post:
;     Player struct at X contains requisite character info
;         - Clear player struct
;         - Set player direction
;         - Set player position
;         - Load stats struct pointer (transfer addr_ptr to player_state)
;         - Load anim map pointer (transfer to PLAYER_ANIM_MAPOFF)
;         - Set invalid anim number to force reload
;         - Load palette
;         - Load CHR into VRAM slot
load_character:

	lda $5555
	txa
	pha

; - Clear the player struct
	lda #$00
	tay
@clear_pl_loop:
	sta player_state, x
	inx
	iny
	cpy #PLAYER_SIZE
	bne @clear_pl_loop

; We've manged X; it needs to be put back
	pla
	tax

; - Set player dir
; Now set the player dir based on X
	beq @dir_set
	lda #PLAYER_DIR_LEFT 	; P2 gets left dir
@dir_set:
	sta player_state + PLAYER_DIRXOFF, x

; Also which direciton is being faced
	lda #PLAYER_FACING_RIGHT
	cpx #$00
	beq @facing_set
	lda #PLAYER_FACING_LEFT

@facing_set:
	sta player_state + PLAYER_FACINGOFF, x

; - Set player position

	cpx #$00
	bne @p2_pos
@p1_pos:
; P1 on the left side
	lda playfield_left
	clc
	adc #$10
	jmp @postpos;

@p2_pos:
; P2 on the right
	lda playfield_right
	sec
	sbc #$10
@postpos:
	sta player_state + PLAYER_XOFF+1, x

; Vertical position as well
	lda playfield_top		; A = Playfield top
	lsr				; A = Top/2
	sta temp			
	lda playfield_bottom		; A = Playfield bottom
	lsr				; A = Bottom/2
	clc				
	adc temp			; A += Top/2 == center Y
	; Calculated vertical center
	sta player_state + PLAYER_YOFF+1, x

; - Set up stats struct pointer	
	lda addr_ptr
	sta player_state + PLAYER_STATS_ADDROFF, x
	lda addr_ptr + 1
	sta player_state + PLAYER_STATS_ADDROFF + 1, x

; - Set up anim map pointer
	ldy #STATS_ANIM_PTR
	lda (addr_ptr), y
	sta player_state + PLAYER_ANIM_MAPOFF, x
	iny
	lda (addr_ptr), y
	sta player_state + PLAYER_ANIM_MAPOFF + 1, x

; - Set invalid anim number
	lda #$FF
	sta player_state + PLAYER_ANIM_NUMOFF, x

; - Load player palette
	ldy #STATS_PAL_PTR
	lda (addr_ptr), y
	sta temp
	iny
	lda (addr_ptr), y
	sta temp2

	cpx #$00
	bne @p2_pal_dest
@p1_pal_dest:
	ppu_load_addr #$3F, #$11
	ldy #$01 ; Normal palette, index 1
	jmp @player_pal_set
@p2_pal_dest:
	ldy #$09 ; Alt palette, index 1
	ppu_load_addr #$3F, #$19

@player_pal_set:
	lda (temp), y
	sta PPUDATA	
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA	
	iny
	lda (temp), y
	sta PPUDATA
	iny
	lda (temp), y
	sta PPUDATA


; - Load CHR into VRAM
	; Load bank number
	ldy #STATS_CHR_BANK
	lda (addr_ptr), y
	tay
	sta bank_load_table, y

; Back up player ptr into temp
	lda addr_ptr
	sta temp
	lda addr_ptr+1
	sta temp+1

; Put CHR pointer into addr_Ptr
	ldy #STATS_CHR_PTR
	lda (temp), y
	sta addr_ptr
	iny
	lda (temp), y
	sta addr_ptr+1

	ldy #$02 ; Player 1 starts on the third row
	cpx #$00
	beq @do_load
	ldy #$09 ; Player 2 starts on the tenth row
@do_load:
	jsr player_load_gfx

	lda temp
	sta addr_ptr
	lda temp+1
	sta addr_ptr+1

	rts


.include "utils.asm"				; Pull in NMI support code
.include "sprites.asm"

; This can be "written to" to avoid bus conflicts when loading banks
bank_load_table:
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	
.segment "VECTORS"

	.addr	nmi_vector
	.addr	reset_vector
	.addr	irq_vector
