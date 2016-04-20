wait_nmi:
        lda vblank_flag                                
        bne wait_nmi                    ; Spin here until NMI lets us through
        lda #$01
        sta vblank_flag
        rts


