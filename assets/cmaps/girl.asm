; Animation mapping constant data
; Four bytes follow the mapping of what goes into OAM, mostly
;       Sprite Y (relative to player's Y), signed; set to $FF to end the frame
;       Tile selection
;       Attributes; if bit 1 is set, then bit 0 will be set for player 2
;       Sprite X (relative to player's X), signed; flipped to face left
; Twelve sprites are allocated for a frame.



girl_mapping_fwd0:
        .byte   <-32, $22, %00000001, <-4
        .byte   <-32, $21, %00000001, 4
        .byte   <-24, $32, %00000001, <-4
        .byte   <-24, $33, %00000001, 4
        .byte   <-16, $43, %00000010, <-4
        .byte   <-16, $44, %00000010, 4
        .byte   <-8, $53, %00000010, <-4
        .byte   <-8, $54, %00000010, 4
        .byte   $FF

girl_mapping_fwd1:
        .byte   <-33, $20, %00000001, <-4
        .byte   <-33, $21, %00000001, 4
        .byte   <-25, $30, %00000001, <-4
        .byte   <-25, $31, %00000001, 4
        .byte   <-17, $40, %00000010, <-6
        .byte   <-17, $41, %00000010, 2
        .byte   <-9, $50, %00000010, <-8
        .byte   <-9, $51, %00000010, 0
        .byte   <-9, $52, %00000010, 7
        .byte   $FF

girl_mapping_fwd2:
        .byte   <-33, $24, %00000001, <-4
        .byte   <-33, $21, %00000001, 4
        .byte   <-25, $34, %00000001, <-4
        .byte   <-25, $35, %00000001, 4
        .byte   <-17, $42, %00000010, <-6
        .byte   <-17, $23, %00000010, 2
        .byte   <-9, $50, %00000010, <-8
        .byte   <-9, $51, %00000010, 0
        .byte   <-9, $52, %00000010, 7
        .byte   $FF

girl_mapping_down0:
        .byte   <-32, $25, %00000001, <-4
        .byte   <-32, $25, %01000001, 4
        .byte   <-24, $45, %00000001, <-4
        .byte   <-24, $45, %01000001, 4
        .byte   <-16, $56, %00000010, <-4
        .byte   <-16, $57, %00000010, 4
        .byte   <-8, $55, %00000010, <-4
        .byte   <-8, $49, %00000010, 4
        .byte   $ff

girl_mapping_down1:
        .byte   <-33, $25, %00000001, <-4
        .byte   <-33, $25, %01000001, 4
        .byte   <-25, $26, %00000001, <-4
        .byte   <-25, $27, %00000001, 4
        .byte   <-17, $36, %00000010, <-4
        .byte   <-17, $37, %00000010, 4
        .byte   <-9, $46, %00000010, <-4
        .byte   <-9, $47, %00000010, 4
        .byte   $FF

girl_mapping_down2:
        .byte   <-33, $25, %00000001, <-4
        .byte   <-33, $25, %01000001, 4
        .byte   <-25, $27, %01000001, <-4
        .byte   <-25, $26, %01000001, 4
        .byte   <-17, $37, %01000010, <-4
        .byte   <-17, $36, %01000010, 4
        .byte   <-9, $47, %01000010, <-4
        .byte   <-9, $46, %01000010, 4
        .byte   $FF

girl_mapping_up0:
        .byte   <-32, $28, %00000001, <-4
        .byte   <-32, $28, %01000001, 4
        .byte   <-24, $48, %00000001, <-4
        .byte   <-24, $48, %01000001, 4
        .byte   <-16, $58, %00000010, <-4
        .byte   <-16, $59, %00000010, 4
        .byte   <-8, $55, %00000010, <-4
        .byte   <-8, $49, %00000010, 4
        .byte   $FF

girl_mapping_up1:
        .byte   <-33, $28, %00000001, <-4
        .byte   <-33, $28, %01000001, 4
        .byte   <-25, $38, %00000001, <-4
        .byte   <-25, $39, %00000001, 4
        .byte   <-17, $2a, %00000010, <-4
        .byte   <-17, $37, %00000010, 4
        .byte   <-9, $29, %00000010, <-4
        .byte   <-9, $47, %00000010, 4
        .byte   $FF

girl_mapping_up2:
        .byte   <-33, $28, %00000001, <-4
        .byte   <-33, $28, %01000001, 4
        .byte   <-25, $39, %01000001, <-4
        .byte   <-25, $38, %01000001, 4
        .byte   <-17, $37, %01000010, <-4
        .byte   <-17, $2a, %01000010, 4
        .byte   <-9, $47, %01000010, <-4
        .byte   <-9, $29, %01000010, 4
        .byte   $FF
