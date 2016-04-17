; Speed names are percentages in the Pac-Man Dossier
; e.g. Spd80 is the speed given as 80% in the Dossier

Speed40  = $22222222    ; 00100010001000100010001000100010
Speed45  = $91222448    ; 10010001001000100010010001001000
Speed50  = $24922492    ; 00100100100100100010010010010010
Speed55  = $49252492    ; 01001001001001010010010010010010
Speed60  = $25252525    ; 00100101001001010010010100100101
Speed75  = $55552AAA    ; 01010101010101010010101010101010
Speed80  = $55555555    ; 01010101010101010101010101010101
Speed85  = $D5556AAA    ; 11010101010101010110101010101010
Speed90  = $6AD56AD5    ; 01101010110101010110101011010101
Speed95  = $B5AD5AD6    ; 10110101101011010101101011010110
Speed100 = $6D6D6D6D    ; 01101101011011010110110101101101
Speed105 = $DB6D7DB6    ; 11011011011011010111110110110110


.segment "ZEROPAGE"

pSpeedL:    .res 1
pSpeedH:    .res 1


.segment "CODE"

; This does a 32-bit rotate right on the variable pointed to by pSpeed
; Carry flag will be the least significant bit before rotation
SpeedTick:
        ; Get least significant bit of speed value so we can rotate it in
        ldy     #0
        lda     (pSpeedL),y
        lsr                                 ; put the bit in the carry flag
        iny                                 ; point y at MSB
        iny
        iny
        lda     (pSpeedL),y
        ror
        sta     (pSpeedL),y
        dey
        lda     (pSpeedL),y
        ror
        sta     (pSpeedL),y
        dey
        lda     (pSpeedL),y
        ror
        sta     (pSpeedL),y
        dey
        lda     (pSpeedL),y
        ror
        sta     (pSpeedL),y

        rts
