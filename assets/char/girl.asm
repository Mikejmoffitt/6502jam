; character_girl character file

; Scripts should be in BANKF to not require banking.
.segment "BANKF"

; =============== Animation Mappings ====================
; Arrangements of sprites to form single animation frames, or "metasprites"
; Four bytes follow the mapping of what goes into OAM, mostly
;       Sprite Y (relative to player's Y), signed; set to MAP_END to end list
;       Tile selection
;       Attributes; player 2 is ORed with %00000010
;       Sprite X (relative to player's X), signed; flipped to face left
; Twelve sprites are allocated for a frame.

girl_mapping_fwd0:
        .byte   <-32, $02, %00000001, <-8
        .byte   <-32, $01, %00000001, 0
        .byte   <-24, $12, %00000001, <-8
        .byte   <-24, $13, %00000001, 0
        .byte   <-16, $23, %00000001, <-5
        .byte   <-8,  $33, %00000000, <-5
        .byte   MAP_END

girl_mapping_fwd1:
        .byte   <-33, $00, %00000001, <-8
        .byte   <-33, $01, %00000001, 0
        .byte   <-25, $10, %00000001, <-8
        .byte   <-25, $11, %00000001, 0
        .byte   <-17, $20, %00000001, <-9
        .byte   <-17, $21, %00000001, <-1
        .byte   <-9,  $30, %00000000, <-10
        .byte   <-9,  $31, %00000000, 0
        .byte   MAP_END

girl_mapping_fwd2:
        .byte   <-33, $04, %00000001, <-8
        .byte   <-33, $01, %00000001, 0
        .byte   <-25, $14, %00000001, <-8
        .byte   <-25, $15, %00000001, 0
        .byte   <-17, $22, %00000001, <-10
        .byte   <-17, $03, %00000001, <-2
        .byte   <-9,  $30, %00000000, <-11
        .byte   <-9,  $31, %00000000, <-1
        .byte   MAP_END

girl_mapping_down0:
        .byte   <-32, $05, %00000001, <-4
        .byte   <-24, $25, %00000001, <-8
        .byte   <-24, $25, %01000001, 0
        .byte   <-16, $34, %00000001, <-8
        .byte   <-16, $34, %01000001, 0
        .byte   <-8,  $35, %00000000, <-8
        .byte   <-8,  $35, %01000000, 0
        .byte   MAP_END

girl_mapping_down1:
        .byte   <-33, $05, %00000001, <-4
        .byte   <-25, $06, %00000001, <-8
        .byte   <-25, $07, %00000001, 0
        .byte   <-17, $16, %00000001, <-8
        .byte   <-17, $17, %00000001, 0
        .byte   <-9,  $26, %00000000, <-8
        .byte   <-9,  $27, %00000000, 0
        .byte   MAP_END

girl_mapping_down2:
        .byte   <-33, $05, %00000001, <-4
        .byte   <-25, $07, %01000001, <-8
        .byte   <-25, $06, %01000001, 0
        .byte   <-17, $17, %01000001, <-8
        .byte   <-17, $16, %01000001, 0
        .byte   <-9,  $27, %01000000, <-8
        .byte   <-9,  $26, %01000000, 0
        .byte   MAP_END

girl_mapping_up0:
        .byte   <-32, $08, %00000001, <-4
        .byte   <-24, $37, %00000001, <-8
        .byte   <-24, $37, %01000001, 0
        .byte   <-16, $24, %00000001, <-8
        .byte   <-16, $24, %01000001, 0
        .byte   <-8,  $35, %00000000, <-8
        .byte   <-8,  $35, %01000000, 0
        .byte   MAP_END

girl_mapping_up1:
        .byte   <-33, $08, %00000001, <-4
        .byte   <-25, $18, %00000001, <-8
        .byte   <-25, $19, %00000001, 0
        .byte   <-17, $28, %00000001, <-8
        .byte   <-17, $29, %00000001, 0
        .byte   <-9,  $36, %00000000, <-8
        .byte   <-9,  $27, %00000000, 0
        .byte   MAP_END

girl_mapping_up2:
        .byte   <-33, $08, %00000001, <-4
        .byte   <-25, $19, %01000001, <-8
        .byte   <-25, $18, %01000001, 0
        .byte   <-17, $29, %01000001, <-8
        .byte   <-17, $28, %01000001, 0
        .byte   <-9,  $27, %01000000, <-8
        .byte   <-9,  $36, %01000000, 0
        .byte   MAP_END

girl_mapping_block0:
	.byte	<-32, $02, %00000001, <-9
	.byte	<-32, $01, %00000001, <-1
	.byte	<-24, $40, %00000001, <-9
	.byte	<-24, $41, %00000001, <-1
	.byte	<-16, $50, %00000001, <-9
	.byte	<-16, $51, %00000001, <-1
	.byte	<-8,  $60, %00000000, <-8
	.byte	<-8,  $61, %00000000, <-2
	.byte	MAP_END

girl_mapping_block1:
	.byte	<-31, $02, %00000001, <-11
	.byte	<-31, $01, %00000001, <-3
	.byte	<-24, $40, %00000001, <-11
	.byte	<-24, $41, %00000001, <-3
	.byte	<-16, $50, %00000001, <-10
	.byte	<-16, $51, %00000001, <-2
	.byte	<-8,  $60, %00000000, <-9
	.byte	<-8,  $61, %00000000, <-1
	.byte	MAP_END

girl_mapping_slide_fwd0:
	.byte	<-25, $42, %00000001, <-16
	.byte	<-25, $43, %00000001, <-8
	.byte	<-17, $52, %00000001, <-16
	.byte	<-17, $53, %00000001, <-8
	.byte	<-17, $54, %00000001, 0
	.byte	<-9,  $62, %00000001, <-11
	.byte	<-9,  $63, %00000001, <-3
	.byte	<-9,  $64, %00000000, 4
	.byte	<-9,  $65, %00000000, 12
	.byte	MAP_END

girl_mapping_slide_fwd1:
	.byte	<-25, $32, %00000001, <-16
	.byte	<-25, $43, %00000001, <-8
	.byte	<-17, $44, %00000001, <-16
	.byte	<-17, $53, %00000001, <-8
	.byte	<-17, $54, %00000001, 0
	.byte	<-9,  $62, %00000001, <-11
	.byte	<-9,  $63, %00000001, <-3
	.byte	<-9,  $64, %00000000, 4
	.byte	<-9,  $65, %00000000, 12
	.byte	MAP_END

girl_mapping_slide_fwddown0:
	.byte	<-25, $46, %00000001, <-10
	.byte	<-25, $47, %00000001, <-2
	.byte	<-17, $56, %00000001, <-10
	.byte	<-17, $57, %00000001, <-2
	.byte	<-9, $45, %00000000, <-7 ; foot overlay
	.byte	<-9, $66, %00000001, <-8
	.byte	<-9, $67, %00000001, 0
	.byte	<-1, $55, %00000000, 3 ; bottom foot
	.byte	MAP_END

girl_mapping_slide_fwddown1:
	.byte	<-25, $09, %00000001, <-10 ; alt hair
	.byte	<-25, $47, %00000001, <-2
	.byte	<-17, $56, %00000001, <-10
	.byte	<-17, $57, %00000001, <-2
	.byte	<-9, $45, %00000000, <-7 ; foot overlay
	.byte	<-9, $66, %00000001, <-8
	.byte	<-9, $67, %00000001, 0
	.byte	<-1, $55, %00000000, 3 ; bottom foot
	.byte	MAP_END

girl_mapping_slide_fwdup0:
	.byte	<-24, $55, %10000000, 2
	.byte	<-17, $48, %00000001, <-10
	.byte	<-17, $49, %00000001, <-2
	.byte	<-9, $58, %00000001, <-10
	.byte	<-9, $59, %00000001, <-2
	.byte	<-1, $68, %00000001, <-12
	.byte	<-1, $69, %00000001, <-4
	.byte	MAP_END

girl_mapping_slide_fwdup1:
	.byte	<-24, $55, %10000000, 2
	.byte	<-17, $48, %00000001, <-10
	.byte	<-17, $49, %00000001, <-2
	.byte	<-9, $58, %00000001, <-10
	.byte	<-9, $59, %00000001, <-2
	.byte	<-1, $38, %00000001, <-12
	.byte	<-1, $39, %00000001, <-4
	.byte	MAP_END

girl_mapping_dummy:
	.byte	<-$20, <-$20, 0, 0
	.byte	MAP_END


; =============== Animation Scripts ===============
; Sequences of mappings to form animation sequences
; Animation scripts are simply like this:
; 	Length
; 	Loop P oint in frames
; --------- Then, for every frame:
; 	Mapping address		(.addr)
; 	Length in frames	(.byte)
; 	Padding			(.byte)

girl_anim_stand_fwd:
	.byte	1
	.byte	0

	.addr	girl_mapping_fwd0
	.byte	128
	.byte	0

girl_anim_stand_up:
	.byte	1
	.byte	0

	.addr	girl_mapping_up0
	.byte	128
	.byte	0

girl_anim_stand_down:
	.byte	1
	.byte	0

	.addr	girl_mapping_down0
	.byte	128
	.byte	0

girl_anim_run_fwd:
	.byte	4
	.byte	0

	.addr	girl_mapping_fwd1 ; ------------
	.byte	7, 0

	.addr	girl_mapping_fwd0 ; ------------
	.byte	5, 0

	.addr	girl_mapping_fwd2 ; ------------
	.byte	7, 0

	.addr	girl_mapping_fwd0 ; ------------
	.byte	5, 0

girl_anim_run_up:
	.byte	4
	.byte	0

	.addr	girl_mapping_up1 ; ------------
	.byte	7, 0

	.addr	girl_mapping_up0 ; ------------
	.byte	5, 0

	.addr	girl_mapping_up2 ; ------------
	.byte	7, 0

	.addr	girl_mapping_up0 ; ------------
	.byte	5, 0

girl_anim_run_down:
	.byte	4
	.byte	0

	.addr	girl_mapping_down1 ; ------------
	.byte	7, 0

	.addr	girl_mapping_down0 ; ------------
	.byte	5, 0

	.addr	girl_mapping_down2 ; ------------
	.byte	7, 0

	.addr	girl_mapping_down0 ; ------------
	.byte	5, 0

girl_anim_block:
	.byte	3
	.byte	2

	.addr	girl_mapping_block0 ; -----------
	.byte	3, 0

	.addr	girl_mapping_block1 ; -----------
	.byte	7, 0

	.addr	girl_mapping_block0 ; -----------
	.byte	3, 0

girl_anim_slide_fwd:
	.byte	2
	.byte	0

	.addr	girl_mapping_slide_fwd0 ; ------
	.byte	3, 0

	.addr	girl_mapping_slide_fwd1 ; ------
	.byte	3, 0

girl_anim_slide_down:		; TODO: Individual slide mapping
girl_anim_slide_fwddown:
	.byte	2
	.byte	0

	.addr	girl_mapping_slide_fwddown0
	.byte	3, 0

	.addr	girl_mapping_slide_fwddown1
	.byte	3, 0

girl_anim_slide_up:		; TODO: Individual slide mapping
girl_anim_slide_fwdup:
	.byte	2
	.byte	0

	.addr	girl_mapping_slide_fwdup0
	.byte	3, 0

	.addr	girl_mapping_slide_fwdup1
	.byte	3, 0


; ============ Animation Number Map ====================
; An array containing the addresses of animation numbers. Used to
; number to an animation script.

girl_anim_num_map:
girl_anims:
	.addr	girl_anim_stand_fwd
	.addr	girl_anim_stand_up
	.addr	girl_anim_stand_down
	.addr	girl_anim_run_fwd
	.addr	girl_anim_run_up
	.addr	girl_anim_run_down
	.addr	girl_anim_block
	.addr	girl_anim_slide_fwd
	.addr	girl_anim_slide_fwdup
	.addr	girl_anim_slide_fwddown
	.addr	girl_anim_slide_up
	.addr	girl_anim_slide_down


.macro throw_stats_macro arg
	.word (1100 * arg) / 128;		; dx; Fwd
	.word 0;				; dy; Fwd (nonzero would be nonsensical)

	.word (900 * arg) / 128;		; dx; Dn-Fwd
	.word (300 * arg) / 128;		; dy; Dn-Fwd

	.word (500 * arg) / 128;		; dx; Dn
	.word (700 * arg) / 128;		; dy; Dn

	.word (200 * arg) / 128;		; dx; Dn-Back
	.word (1000 * arg) / 128;		; dy; Dn-Back

.endmacro


; Fix16 multiplication is really just 16-bit multiplication, but with >> 8 at the end.
; In other words, hibyte <= hihibyte (17-24), lowbyte <= hibyte requires 24 bits.
; A cheaper solution can be to shift right 4 times both operands, truncating the lower 4 bits of precision,
; OR to truncate the lower 8 bits and then perform no shifting. Both solutions degrade precision.

; Physics constants
;	fix16: Walk speed (Orthagonal)
;	fix16: Walk speed (Diagonal); should be orthagonal * 0.707
;	fix16: Dash strength
;	fix16: Dash decel magnitude

	.byte $ED
	.byte $80, $12

character_girl:
; Movement physics data
	.word	400		; Straight walk speed
	.word	282		; Diagonal walk speed
	.word	1136		; Dash strength
	.word	88		; Fast dash decel
	.word	34		; Slow dash decel
; Asset information
	.byte	2		; Graphics data bank number
	.addr	girl_chr	; Graphics data pointer
	.addr	girl_pal	; Pointer to palette data
	.addr	girl_anims	; Pointer to animation table

; Throw stats
	throw_stats_macro 202	; Stats for a strong throw
	throw_stats_macro 128	; Stats for a normal throw
	throw_stats_macro 56	; Stats for a weak throw

.delmacro throw_stats_macro

; Character graphics
.segment "BANK2"

	girl_chr:
	.incbin "../assets/char/girl.chr";

	girl_pal:
	;     null blck skin extra
	.byte $00, $0F, $35, $30
	.byte $00, $0F, $35, $11
	;     null blck skin extra
	.byte $00, $0F, $26, $30
	.byte $00, $0F, $26, $15
