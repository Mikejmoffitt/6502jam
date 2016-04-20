wait_nmi:
         lda vblank_flag                                    
         bne wait_nmi                      ; Spin here until NMI lets us through
         lda #$01
         sta vblank_flag
         rts

; Controller reading code from NESDev
; Out: A=buttons pressed, where bit 0 is A button
read_joy_1:
        ; Strobe controller
        lda #1
        sta $4016
        lda #0
        sta $4016
        
        ; Read all 8 buttons
        ldx #8
:
        pha
        
        ; Read next button state and mask off low 2 bits.
        ; Compare with $01, which will set carry flag if
        ; either or both bits are set.
        lda $4016
        and #$03
        cmp #$01
        
        ; Now, rotate the carry flag into the top of A,
        ; land shift all the other buttons to the right
        pla
        ror a
        
        dex
        bne :-
        
        rts

; temp is a zero-page variable

; Reads controller. Reliable when DMC is playing.
; Out: A=buttons held, A button in bit 0
read_joy_safe_1:
        ; Get first reading
        jsr read_joy_1
:
        ; Save previous reading
        sta temp
        
        ; Read again and compare. If they differ,
        ; read again.
        jsr read_joy_1
        cmp temp
        bne :-
        ldx pad_1
        stx pad_1_prev
        sta pad_1
        rts

; Controller reading code from NESDev
; Out: A=buttons pressed, where bit 0 is A button
read_joy_2:
        ; Strobe controller
        lda #1
        sta $4017
        lda #0
        sta $4017
        
        ; Read all 8 buttons
        ldx #8
:
        pha
        
        ; Read next button state and mask off low 2 bits.
        ; Compare with $01, which will set carry flag if
        ; either or both bits are set.
        lda $4017
        and #$03
        cmp #$01
        
        ; Now, rotate the carry flag into the top of A,
        ; land shift all the other buttons to the right
        pla
        ror a
        
        dex
        bne :-
        
        rts

; temp is a zero-page variable

; Reads controller. Reliable when DMC is playing.
; Out: A=buttons held, A button in bit 0
read_joy_safe_2:
        ; Get first reading
        jsr read_joy_2
:
        ; Save previous reading
        sta temp
        
        ; Read again and compare. If they differ,
        ; read again.
        jsr read_joy_2
        cmp temp
        bne :-
        ldx pad_2
        stx pad_2_prev
        sta pad_2
        rts
