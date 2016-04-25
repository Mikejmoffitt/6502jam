;this file for FamiTone2 libary generated by text2data tool

danger_streets_music_data:
	db 1
	dw @instruments
	dw @samples-3
	dw @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4,307,256

@instruments:
	db $30 ;instrument $00
	dw @env1,@env0,@env0
	db $00
	db $30 ;instrument $01
	dw @env2,@env0,@env0
	db $00
	db $30 ;instrument $02
	dw @env3,@env14,@env0
	db $00
	db $30 ;instrument $03
	dw @env4,@env15,@env0
	db $00
	db $70 ;instrument $04
	dw @env5,@env16,@env0
	db $00
	db $70 ;instrument $05
	dw @env5,@env17,@env0
	db $00
	db $70 ;instrument $06
	dw @env6,@env0,@env20
	db $00
	db $70 ;instrument $07
	dw @env10,@env16,@env21
	db $00
	db $70 ;instrument $08
	dw @env10,@env17,@env21
	db $00
	db $30 ;instrument $09
	dw @env1,@env18,@env0
	db $00
	db $30 ;instrument $0a
	dw @env7,@env0,@env0
	db $00
	db $70 ;instrument $0b
	dw @env8,@env0,@env20
	db $00
	db $70 ;instrument $0c
	dw @env9,@env17,@env0
	db $00
	db $30 ;instrument $0d
	dw @env6,@env0,@env20
	db $00
	db $30 ;instrument $0e
	dw @env8,@env0,@env20
	db $00
	db $70 ;instrument $0f
	dw @env5,@env19,@env0
	db $00
	db $70 ;instrument $10
	dw @env9,@env16,@env0
	db $00
	db $70 ;instrument $11
	dw @env11,@env16,@env21
	db $00
	db $b0 ;instrument $12
	dw @env12,@env0,@env0
	db $00
	db $30 ;instrument $13
	dw @env13,@env0,@env0
	db $00

@samples:
@env0:
	db $c0,$00,$00
@env1:
	db $cf,$00,$00
@env2:
	db $ca,$c6,$c4,$c3,$c2,$c1,$c1,$c0,$00,$07
@env3:
	db $cb,$ca,$c9,$c0,$00,$03
@env4:
	db $cf,$cb,$c7,$c6,$c5,$c4,$c3,$c2,$c1,$c0,$00,$09
@env5:
	db $c7,$c7,$c6,$c5,$c5,$c4,$c4,$c3,$02,$c2,$02,$c1,$02,$c0,$00,$0d
@env6:
	db $cc,$cb,$ca,$ca,$c9,$03,$c8,$03,$c7,$07,$c6,$08,$c5,$0a,$c4,$0c
	db $c3,$0c,$c2,$12,$c1,$19,$c0,$00,$16
@env7:
	db $c6,$c2,$c1,$03,$c0,$00,$04
@env8:
	db $c4,$02,$c3,$0c,$c2,$0b,$c1,$12,$c0,$00,$08
@env9:
	db $c3,$c3,$c2,$03,$c1,$06,$c0,$00,$06
@env10:
	db $c3,$c3,$c2,$05,$c1,$05,$c0,$00,$06
@env11:
	db $c3,$c3,$c2,$c2,$c1,$04,$c0,$00,$06
@env12:
	db $c6,$c6,$c7,$c7,$c6,$c6,$c5,$c5,$c4,$c4,$c3,$03,$c2,$05,$c1,$05
	db $c0,$00,$10
@env13:
	db $cf,$c0,$cf,$c0,$00,$03
@env14:
	db $cc,$c0,$00,$01
@env15:
	db $c8,$c0,$c4,$00,$02
@env16:
	db $c0,$c0,$c3,$c3,$c7,$c7,$00,$00
@env17:
	db $c0,$c0,$c4,$c4,$c7,$c7,$00,$00
@env18:
	db $c0,$05,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5,$b4,$b3,$b2
	db $b1,$b0,$af,$ae,$ad,$ac,$ab,$aa,$a9,$a8,$a8,$a7,$a7,$a6,$a6,$a5
	db $a5,$a4,$a4,$a3,$a3,$a2,$a2,$a1,$a1,$00,$28
@env19:
	db $c0,$c0,$c3,$c3,$c8,$c8,$00,$00
@env20:
	db $c0,$0f,$c1,$02,$c2,$02,$c1,$02,$c0,$c0,$c0,$00,$02
@env21:
	db $c4,$00,$00
@env22:
	db $c1,$00,$00


@song0ch0:
	db $fb,$03
@song0ch0loop:
@ref0:
	db $87,$88,$2c,$85,$2d,$2c,$85,$2c,$89,$2c,$85,$2d,$2c,$89,$a0,$2c
	db $85,$88,$2c,$85,$2d,$2c,$85,$2c,$89,$8a,$32,$85,$37,$36,$85,$98
	db $36,$81
@ref1:
	db $87,$88,$2c,$85,$2d,$2c,$85,$2c,$89,$2c,$85,$2d,$2c,$89,$a0,$2c
	db $85,$88,$2c,$85,$2d,$2c,$85,$2c,$89,$8a,$33,$32,$85,$98,$33,$8a
	db $36,$85
	db $ff,$1d
	dw @ref0
@ref3:
	db $87,$88,$2c,$85,$2d,$2c,$85,$2c,$89,$2c,$85,$2d,$2c,$89,$a0,$2c
	db $85,$88,$2c,$85,$2d,$2c,$85,$2c,$89,$8a,$32,$85,$36,$85,$98,$36
	db $85
@ref4:
	db $87,$88,$2c,$85,$2d,$2c,$85,$2d,$96,$30,$85,$88,$2d,$96,$33,$88
	db $2d,$2d,$96,$28,$85,$2c,$85,$88,$2d,$96,$2d,$88,$2d,$2d,$96,$2d
	db $88,$2c,$89,$8a,$33,$96,$2d,$8a,$37,$37,$96,$22,$85
@ref5:
	db $87,$88,$2d,$96,$1f,$88,$2d,$2c,$85,$2d,$96,$1e,$20,$23,$88,$2d
	db $96,$23,$88,$2d,$2d,$96,$22,$8d,$88,$2c,$85,$2d,$2c,$85,$2c,$89
	db $8a,$32,$85,$37,$36,$89
	db $ff,$1e
	dw @ref4
@ref7:
	db $87,$88,$2d,$96,$1f,$88,$2d,$2d,$96,$1f,$88,$2c,$89,$2d,$96,$23
	db $88,$2d,$2d,$96,$28,$85,$2c,$85,$88,$2d,$96,$2d,$88,$2d,$2d,$96
	db $2d,$88,$2c,$89,$8a,$32,$85,$37,$36,$89
@ref8:
	db $87,$24,$85,$25,$25,$9c,$33,$8a,$25,$9c,$34,$36,$83,$8a,$25,$9c
	db $37,$8a,$25,$25,$9c,$28,$85,$2a,$2c,$83,$8a,$25,$9c,$2d,$8a,$25
	db $24,$85,$24,$89,$29,$96,$33,$88,$2d,$2d,$96,$30,$85
@ref9:
	db $2c,$85,$8a,$24,$85,$25,$25,$9c,$33,$8a,$25,$9c,$34,$36,$83,$8a
	db $25,$9c,$37,$8a,$25,$25,$9c,$28,$85,$2a,$2c,$83,$8a,$25,$9c,$2d
	db $8a,$25,$24,$85,$24,$89,$29,$96,$3b,$88,$2d,$2d,$96,$40,$85
@ref10:
	db $4e,$85,$8a,$29,$96,$4f,$8a,$29,$28,$85,$29,$96,$48,$85,$8a,$29
	db $96,$49,$8a,$29,$29,$96,$44,$85,$46,$48,$83,$8a,$29,$96,$49,$8a
	db $29,$28,$85,$29,$9c,$46,$48,$83,$88,$2d,$9c,$4b,$8a,$33,$33,$9c
	db $44,$85
@ref11:
	db $48,$85,$8a,$29,$9c,$49,$8a,$29,$28,$85,$29,$9c,$4a,$85,$8a,$29
	db $9c,$4b,$8a,$29,$29,$9c,$4e,$83,$4c,$4a,$85,$8a,$29,$9c,$4b,$8a
	db $29,$28,$85,$29,$96,$48,$85,$88,$2d,$96,$4b,$8a,$33,$33,$96,$40
	db $85
@ref12:
	db $44,$85,$88,$2d,$96,$45,$88,$2d,$2d,$96,$45,$88,$2c,$89,$2c,$85
	db $2d,$2c,$89,$a0,$2c,$85,$88,$2c,$85,$2d,$2c,$85,$2c,$85,$a0,$2d
	db $8a,$32,$85,$37,$36,$85,$98,$36,$81
	db $ff,$1c
	dw @ref1
	db $ff,$1d
	dw @ref0
	db $ff,$1c
	dw @ref3
@ref16:
	db $8a,$24,$85,$25,$96,$2d,$8a,$25,$25,$96,$2d,$8a,$25,$24,$85,$25
	db $96,$31,$8a,$25,$25,$96,$32,$85,$8a,$25,$96,$2d,$8a,$25,$96,$2d
	db $8a,$25,$24,$85,$25,$88,$2c,$85,$2d,$96,$49,$88,$2d,$2d,$96,$4a
	db $85
@ref17:
	db $8a,$25,$96,$45,$8a,$25,$96,$45,$8a,$25,$24,$85,$25,$24,$85,$25
	db $96,$4f,$8a,$25,$25,$96,$44,$85,$8a,$25,$96,$49,$8a,$25,$96,$49
	db $8a,$25,$24,$85,$25,$88,$2c,$85,$2d,$96,$41,$88,$2d,$2d,$96,$48
	db $85
@ref18:
	db $8a,$29,$96,$4f,$8a,$29,$96,$4f,$8a,$29,$28,$85,$29,$28,$85,$29
	db $96,$4f,$8a,$29,$29,$96,$44,$85,$8a,$29,$96,$4b,$8a,$29,$96,$4b
	db $8a,$29,$28,$85,$29,$9e,$30,$85,$31,$9c,$49,$9e,$31,$31,$9c,$40
	db $85
@ref19:
	db $8a,$29,$9c,$49,$8a,$29,$9c,$49,$8a,$29,$28,$85,$29,$28,$85,$29
	db $96,$33,$8a,$29,$29,$96,$36,$85,$8a,$29,$96,$31,$8a,$29,$96,$31
	db $8a,$29,$29,$9c,$37,$8a,$29,$9e,$31,$9c,$31,$9e,$31,$9c,$31,$9e
	db $31,$31,$9c,$29,$1e,$81
	db $ff,$20
	dw @ref16
@ref21:
	db $8a,$25,$96,$45,$8a,$25,$96,$45,$8a,$25,$24,$85,$25,$24,$85,$25
	db $96,$37,$8a,$25,$25,$96,$2c,$85,$8a,$25,$96,$31,$8a,$25,$96,$31
	db $8a,$25,$24,$85,$25,$88,$2c,$85,$2d,$9c,$31,$88,$2d,$9c,$33,$96
	db $49,$9c,$36,$81
@ref22:
	db $88,$23,$9c,$3b,$88,$23,$9c,$3b,$88,$23,$23,$9c,$41,$88,$23,$23
	db $9c,$41,$88,$22,$85,$23,$23,$9c,$44,$85,$8a,$29,$9c,$49,$8a,$29
	db $9c,$49,$8a,$29,$28,$85,$29,$28,$85,$29,$96,$49,$8a,$29,$29,$96
	db $3a,$85
@ref23:
	db $88,$2d,$96,$45,$88,$2d,$96,$45,$88,$2d,$2d,$96,$45,$88,$2d,$2c
	db $85,$2c,$85,$2d,$2c,$85,$2d,$2c,$85,$2c,$85,$2d,$2c,$89,$2c,$8d
	db $a0,$2c,$8d
@ref24:
	db $8f,$2c,$85,$2c,$85,$2d,$2c,$85,$2c,$8d,$96,$16,$18,$87,$10,$95
	db $a0,$2d,$96,$0b,$a0,$2d,$96,$0b,$a0,$2d,$2d,$96,$0a,$85
@ref25:
	db $87,$06,$85,$a0,$2d,$96,$07,$a0,$2c,$85,$2d,$2d,$96,$0b,$a0,$2c
	db $d1
	db $ff,$17
	dw @ref24
@ref27:
	db $87,$12,$14,$83,$a0,$2d,$96,$15,$a0,$2d,$96,$15,$a0,$2d,$2d,$96
	db $15,$a0,$2c,$b1,$1f,$1f,$37,$1f,$23,$23,$3b,$22,$81
@ref28:
	db $8f,$2c,$85,$2c,$85,$2d,$2c,$85,$2c,$8d,$9c,$2e,$30,$87,$28,$95
	db $a0,$2d,$9c,$23,$a0,$2d,$9c,$23,$a0,$2d,$2d,$9c,$22,$85
@ref29:
	db $87,$1e,$85,$a0,$2c,$85,$2c,$85,$2d,$2d,$9c,$29,$a0,$2c,$99,$a4
	db $12,$14,$83,$1a,$85,$1e,$85,$26,$28,$83,$22,$85,$1e,$85,$1a,$85
@ref30:
	db $87,$9c,$30,$32,$83,$a0,$2d,$9c,$33,$a0,$2d,$9c,$33,$a0,$2d,$2d
	db $9c,$33,$a0,$2c,$89,$9c,$34,$36,$83,$3a,$95,$40,$85,$a0,$2d,$9c
	db $41,$a0,$2d,$9c,$41,$a0,$2d,$2d,$9c,$40,$85
@ref31:
	db $87,$40,$42,$45,$a0,$2d,$9c,$45,$a0,$2d,$9c,$45,$a0,$2d,$2d,$9c
	db $45,$a0,$2d,$9c,$3e,$40,$83,$44,$a5,$14,$9d
	db $ff,$1e
	dw @ref4
	db $ff,$1c
	dw @ref5
	db $ff,$1e
	dw @ref4
	db $ff,$1c
	dw @ref7
	db $ff,$20
	dw @ref8
	db $ff,$21
	dw @ref9
	db $ff,$22
	dw @ref10
	db $ff,$21
	dw @ref11
@ref40:
	db $44,$8d,$a0,$2d,$96,$45,$a0,$2d,$96,$45,$a0,$2d,$2c,$85,$2c,$b1
	db $2c,$85,$2c,$85,$2d,$2c,$89
@ref41:
	db $8f,$2c,$85,$2c,$85,$2d,$2c,$85,$2c,$b1,$8e,$2d,$2d,$2d,$2d,$88
	db $2d,$2d,$2d,$2c,$81
	db $ff,$20
	dw @ref16
	db $ff,$20
	dw @ref17
	db $ff,$20
	dw @ref18
	db $ff,$21
	dw @ref19
	db $ff,$20
	dw @ref16
	db $ff,$21
	dw @ref21
	db $ff,$20
	dw @ref22
	db $ff,$1b
	dw @ref23
	db $fd
	dw @song0ch0loop

@song0ch1:
@song0ch1loop:
@ref50:
	db $87,$8e,$2c,$85,$2d,$2c,$85,$2c,$89,$2c,$85,$2d,$2c,$91,$2c,$85
	db $2d,$2c,$85,$2c,$89,$90,$32,$85,$37,$36,$89
@ref51:
	db $87,$8e,$2c,$85,$2d,$2c,$85,$2c,$89,$2c,$85,$2d,$2c,$91,$2c,$85
	db $2d,$2c,$85,$2c,$89,$90,$33,$32,$89,$36,$85
	db $ff,$19
	dw @ref50
@ref53:
	db $87,$8e,$2c,$85,$2d,$2c,$85,$2c,$89,$2c,$85,$2d,$2c,$91,$2c,$85
	db $2d,$2c,$85,$2c,$89,$90,$32,$85,$36,$8d
@ref54:
	db $97,$8c,$30,$83,$96,$30,$8c,$30,$32,$83,$30,$85,$28,$85,$2c,$a5
	db $28,$2c,$83,$28,$85,$22,$8d
@ref55:
	db $1e,$95,$1e,$20,$22,$e1
@ref56:
	db $97,$30,$83,$96,$30,$8c,$30,$32,$83,$30,$85,$28,$85,$2c,$a5,$28
	db $2c,$83,$28,$85,$22,$8d
@ref57:
	db $1e,$9d,$1e,$22,$87,$28,$89,$2c,$c5
@ref58:
	db $8f,$9a,$32,$85,$34,$36,$8b,$32,$85,$28,$85,$2a,$2c,$a3,$8c,$30
	db $32,$87,$30,$89,$2c,$85
@ref59:
	db $8f,$9a,$32,$85,$34,$36,$8b,$32,$85,$28,$85,$2a,$2c,$a3,$8c,$36
	db $3a,$87,$40,$89,$4e,$85
@ref60:
	db $97,$48,$95,$44,$85,$46,$48,$9b,$9a,$46,$48,$83,$4a,$85,$48,$85
	db $44,$85,$48,$85
@ref61:
	db $97,$4a,$95,$4e,$83,$4c,$4a,$9d,$8c,$48,$85,$4a,$85,$48,$85,$40
	db $85,$44,$85
@ref62:
	db $c7,$a2,$2c,$85,$2d,$2c,$85,$2c,$89,$90,$32,$85,$37,$36,$89
	db $ff,$19
	dw @ref51
	db $ff,$19
	dw @ref50
	db $ff,$18
	dw @ref53
@ref66:
	db $8c,$28,$2c,$9b,$30,$89,$32,$87,$2e,$2c,$a5,$48,$89,$4a,$89,$40
	db $44,$83
@ref67:
	db $9f,$4e,$89,$44,$89,$48,$a5,$40,$85,$44,$85,$48,$85,$4e,$85
@ref68:
	db $9f,$4e,$85,$4a,$85,$44,$85,$48,$4a,$a3,$9a,$48,$85,$44,$85,$40
	db $85,$46,$48,$83
@ref69:
	db $9f,$8c,$32,$89,$36,$89,$30,$8d,$9a,$49,$41,$37,$41,$37,$31,$37
	db $31,$29,$31,$29,$1f,$29,$1e,$81
	db $ff,$11
	dw @ref66
@ref71:
	db $9f,$36,$89,$2c,$89,$30,$a5,$9a,$2e,$30,$83,$32,$85,$36,$85,$3a
	db $85
@ref72:
	db $8f,$40,$95,$44,$8d,$46,$48,$a3,$8c,$46,$48,$83,$40,$89,$96,$41
	db $8c,$42,$44,$83
@ref73:
	db $f9,$85
@ref74:
	db $8f,$a2,$2c,$85,$2c,$85,$2d,$2c,$85,$2c,$85,$8c,$16,$18,$87,$10
	db $95,$0a,$a5
@ref75:
	db $06,$95,$08,$0a,$e3
	db $ff,$11
	dw @ref74
@ref77:
	db $12,$14,$f9,$81
@ref78:
	db $8f,$a2,$2c,$85,$2c,$85,$2d,$2c,$85,$2c,$85,$9a,$2e,$30,$87,$28
	db $95,$22,$a5
@ref79:
	db $1e,$95,$26,$28,$93,$2c,$cd
@ref80:
	db $30,$32,$ab,$34,$36,$83,$3a,$95,$40,$ad
@ref81:
	db $40,$42,$44,$f9
	db $ff,$14
	dw @ref54
	db $ff,$06
	dw @ref55
	db $ff,$14
	dw @ref56
	db $ff,$09
	dw @ref57
	db $ff,$14
	dw @ref58
	db $ff,$14
	dw @ref59
	db $ff,$13
	dw @ref60
	db $ff,$12
	dw @ref61
@ref90:
	db $f9,$85
@ref91:
	db $f9,$85
@ref92:
	db $28,$2c,$9b,$30,$89,$32,$87,$2e,$2c,$a5,$48,$89,$4a,$89,$40,$44
	db $83
	db $ff,$0f
	dw @ref67
	db $ff,$13
	dw @ref68
	db $ff,$16
	dw @ref69
	db $ff,$11
	dw @ref66
	db $ff,$10
	dw @ref71
	db $ff,$11
	dw @ref72
@ref99:
	db $f9,$85
	db $fd
	dw @song0ch1loop

@song0ch2:
@song0ch2loop:
@ref100:
	db $80,$2c,$00,$2c,$00,$2d,$00,$a9,$28,$00,$28,$00,$2c,$00,$2c,$00
	db $2d,$00,$99,$32,$00,$32,$00,$87,$37,$00,$81
@ref101:
	db $2c,$00,$2c,$00,$2d,$00,$a9,$28,$00,$28,$00,$2c,$00,$2c,$00,$2d
	db $00,$91,$1a,$00,$1a,$00,$33,$01,$1e,$00,$1e,$00,$37,$00,$81
@ref102:
	db $2c,$00,$2c,$00,$2d,$00,$a9,$28,$00,$28,$00,$2c,$00,$2c,$00,$2d
	db $00,$99,$32,$00,$32,$00,$87,$37,$00,$81
@ref103:
	db $2c,$00,$2c,$00,$2d,$00,$a9,$28,$00,$28,$00,$2c,$00,$2c,$00,$2d
	db $01,$2c,$00,$83,$2c,$00,$83,$32,$00,$83,$32,$00,$32,$00,$92,$36
	db $8d
@ref104:
	db $80,$2c,$00,$2c,$00,$2d,$01,$44,$00,$44,$00,$28,$00,$28,$00,$2c
	db $00,$2c,$00,$2d,$01,$45,$2c,$00,$41,$28,$00,$2c,$00,$2c,$00,$2d
	db $01,$44,$00,$83,$28,$00,$28,$00,$32,$00,$32,$00,$4b,$33,$36,$00
	db $36,$00,$4f,$36,$81
@ref105:
	db $2c,$00,$2c,$00,$2d,$01,$44,$00,$44,$00,$28,$00,$28,$00,$2c,$00
	db $2c,$00,$2d,$01,$45,$2c,$00,$41,$28,$00,$2c,$00,$2c,$00,$2d,$01
	db $44,$00,$83,$28,$00,$28,$00,$32,$00,$32,$00,$4b,$33,$36,$00,$36
	db $00,$4f,$36,$81
	db $ff,$34
	dw @ref105
	db $ff,$34
	dw @ref105
@ref108:
	db $24,$00,$24,$00,$25,$01,$3c,$00,$3c,$00,$20,$00,$20,$00,$24,$00
	db $24,$00,$25,$01,$3d,$24,$00,$39,$20,$00,$24,$00,$24,$00,$25,$01
	db $3c,$00,$83,$20,$00,$20,$00,$96,$28,$00,$28,$00,$41,$29,$2c,$00
	db $2c,$00,$45,$2c,$81
@ref109:
	db $80,$24,$00,$24,$00,$25,$01,$3c,$00,$3c,$00,$20,$00,$20,$00,$24
	db $00,$24,$00,$25,$01,$3d,$24,$00,$39,$20,$00,$24,$00,$24,$00,$25
	db $01,$3c,$00,$83,$20,$00,$20,$00,$96,$28,$00,$28,$00,$41,$29,$2c
	db $00,$2c,$00,$45,$2c,$81
@ref110:
	db $80,$28,$00,$28,$00,$29,$01,$40,$00,$40,$00,$24,$00,$24,$00,$28
	db $00,$28,$00,$29,$01,$41,$28,$00,$3d,$24,$00,$28,$00,$28,$00,$29
	db $01,$40,$00,$83,$24,$00,$24,$00,$2c,$00,$2c,$00,$45,$2d,$32,$00
	db $32,$00,$4b,$32,$81
@ref111:
	db $28,$00,$28,$00,$29,$01,$40,$00,$40,$00,$24,$00,$24,$00,$28,$00
	db $28,$00,$29,$01,$41,$28,$00,$3d,$24,$00,$28,$00,$28,$00,$29,$01
	db $40,$00,$83,$24,$00,$24,$00,$2c,$00,$2c,$00,$45,$2d,$32,$00,$32
	db $00,$4b,$32,$81
	db $ff,$1a
	dw @ref102
	db $ff,$1f
	dw @ref101
	db $ff,$1a
	dw @ref102
	db $ff,$20
	dw @ref103
@ref116:
	db $80,$24,$83,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00
	db $24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$20,$85,$24,$83
	db $00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$2c,$00,$2c
	db $00,$2c,$00,$2c,$00,$28,$00,$28,$00,$28,$00,$28,$00
@ref117:
	db $24,$83,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24
	db $00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$20,$85,$24,$83,$00
	db $24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$24,$00,$2c,$00,$2c,$00
	db $2c,$00,$2c,$00,$28,$00,$28,$00,$28,$00,$28,$00
@ref118:
	db $28,$83,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28
	db $00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$24,$85,$28,$83,$00
	db $28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$30,$00,$30,$00
	db $30,$00,$30,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00
	db $ff,$3c
	dw @ref118
	db $ff,$3c
	dw @ref117
	db $ff,$3c
	dw @ref117
@ref122:
	db $22,$83,$00,$22,$00,$22,$00,$22,$00,$22,$00,$22,$00,$22,$00,$22
	db $00,$22,$00,$22,$00,$22,$00,$22,$00,$22,$00,$1c,$85,$28,$83,$00
	db $28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00,$28,$00
	db $28,$00,$28,$00,$28,$00,$28,$00,$20,$85
@ref123:
	db $2c,$83,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$2c
	db $00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$28,$85,$2c,$83,$00
	db $2c,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$2c,$00,$92,$44,$9d
@ref124:
	db $80,$2c,$00,$2d,$00,$ed,$40,$00,$40,$00
@ref125:
	db $2c,$00,$2d,$00,$d5,$1e,$00,$1e,$00,$37,$1e,$00,$22,$00,$22,$00
	db $3b,$22,$00
@ref126:
	db $2c,$00,$2d,$00,$ed,$40,$00,$40,$00
	db $ff,$13
	dw @ref125
	db $ff,$09
	dw @ref126
	db $ff,$13
	dw @ref125
	db $ff,$09
	dw @ref126
@ref131:
	db $2c,$00,$2d,$00,$b5,$2c,$00,$2d,$00,$95,$2a,$2c,$87,$92,$2c,$91
	db $ff,$34
	dw @ref104
	db $ff,$34
	dw @ref105
	db $ff,$34
	dw @ref105
	db $ff,$34
	dw @ref105
	db $ff,$34
	dw @ref108
	db $ff,$34
	dw @ref109
	db $ff,$34
	dw @ref110
	db $ff,$34
	dw @ref111
@ref140:
	db $2c,$00,$2d,$00,$85,$a6,$44,$9d,$44,$9d,$44,$9d,$44,$85,$94,$28
	db $00,$28,$00
@ref141:
	db $80,$2c,$00,$2d,$00,$85,$a6,$44,$9d,$44,$9d,$44,$8d,$80,$2c,$00
	db $2c,$00,$2c,$00,$2c,$00,$44,$00,$44,$00,$44,$00,$44,$00
	db $ff,$3c
	dw @ref117
	db $ff,$3c
	dw @ref117
	db $ff,$3c
	dw @ref118
	db $ff,$3c
	dw @ref118
	db $ff,$3c
	dw @ref117
	db $ff,$3c
	dw @ref117
	db $ff,$3a
	dw @ref122
	db $ff,$2e
	dw @ref123
	db $fd
	dw @song0ch2loop

@song0ch3:
@song0ch3loop:
@ref150:
	db $84,$21,$21,$94,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f
	db $84,$21,$94,$1f,$84,$21,$21,$94,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f
	db $84,$21,$94,$1f,$1d,$1f,$84,$21,$94,$1e,$81
@ref151:
	db $84,$21,$21,$94,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$1d,$1f
	db $84,$21,$94,$1f,$84,$21,$21,$94,$1d,$1f,$1d,$1f,$1d,$1f,$84,$21
	db $21,$86,$13,$82,$1f,$84,$21,$21,$86,$13,$82,$1e,$81
@ref152:
	db $84,$21,$21,$82,$1d,$94,$1f,$86,$13,$82,$1f,$84,$21,$21,$82,$1d
	db $94,$1f,$84,$21,$94,$1f,$86,$13,$94,$1f,$84,$21,$94,$1f,$84,$21
	db $21,$82,$1d,$94,$1f,$86,$13,$94,$1f,$84,$21,$21,$82,$1d,$84,$21
	db $86,$13,$94,$1f,$82,$1d,$84,$21,$86,$13,$94,$1e,$81
@ref153:
	db $84,$21,$21,$82,$1d,$94,$1f,$86,$13,$94,$1f,$84,$21,$21,$82,$1d
	db $94,$1f,$84,$21,$94,$1f,$86,$13,$94,$1f,$84,$21,$94,$1f,$84,$21
	db $21,$82,$1d,$94,$1f,$86,$13,$94,$1f,$84,$21,$21,$82,$1d,$84,$21
	db $86,$13,$94,$1f,$86,$12,$8d
@ref154:
	db $84,$21,$82,$1f,$1d,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$82,$1f
	db $1d,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$82,$1f,$1d,$1f,$86,$13
	db $82,$1f,$1d,$1f,$84,$21,$82,$1f,$86,$13,$82,$1f,$84,$21,$82,$1f
	db $86,$13,$82,$1e,$81
@ref155:
	db $84,$21,$82,$1f,$1d,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$82,$1f
	db $1d,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$82,$1f,$1d,$1f,$86,$13
	db $82,$1f,$1d,$1f,$86,$13,$13,$84,$21,$86,$0b,$13,$13,$84,$21,$82
	db $1e,$81
	db $ff,$21
	dw @ref154
	db $ff,$21
	dw @ref155
	db $ff,$21
	dw @ref154
	db $ff,$21
	dw @ref155
	db $ff,$21
	dw @ref154
@ref161:
	db $84,$21,$82,$1f,$1d,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$82,$1f
	db $1d,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$82,$1f,$1d,$1f,$86,$13
	db $82,$1f,$1d,$1f,$86,$15,$13,$15,$13,$15,$13,$15,$12,$81
	db $ff,$21
	dw @ref150
	db $ff,$21
	dw @ref151
	db $ff,$21
	dw @ref152
	db $ff,$1e
	dw @ref153
@ref166:
	db $84,$21,$21,$82,$1d,$1f,$86,$13,$82,$1f,$1d,$86,$13,$82,$1d,$1f
	db $84,$21,$82,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$21,$82,$1d,$1f
	db $86,$13,$82,$1f,$1d,$86,$13,$82,$1d,$1f,$84,$21,$82,$1f,$86,$13
	db $82,$1f,$84,$21,$82,$1e,$81
@ref167:
	db $84,$21,$21,$82,$1d,$1f,$86,$13,$82,$1f,$1d,$86,$13,$82,$1d,$1f
	db $84,$21,$82,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$21,$82,$1d,$1f
	db $86,$13,$82,$1f,$1d,$86,$13,$82,$1d,$1f,$86,$13,$82,$1f,$86,$13
	db $13,$82,$1d,$1e,$81
	db $ff,$21
	dw @ref166
@ref169:
	db $84,$21,$21,$82,$1d,$1f,$86,$13,$82,$1f,$1d,$86,$13,$82,$1d,$1f
	db $84,$21,$82,$1f,$86,$13,$82,$1f,$1d,$1f,$84,$21,$21,$21,$21,$86
	db $13,$82,$1f,$86,$13,$13,$84,$21,$82,$1f,$86,$13,$82,$1f,$86,$13
	db $94,$1f,$1d,$1e,$81
	db $ff,$21
	dw @ref166
	db $ff,$21
	dw @ref167
	db $ff,$21
	dw @ref166
	db $ff,$21
	dw @ref169
@ref174:
	db $84,$21,$94,$1f,$1d,$1f,$82,$1d,$94,$1f,$1d,$1f,$1d,$1f,$1d,$1f
	db $82,$1d,$94,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$82,$1d,$94,$1f,$1d,$82
	db $1d,$94,$1d,$1f,$1d,$1f,$82,$1d,$94,$1f,$1d,$1e,$81
@ref175:
	db $84,$21,$94,$1f,$1d,$1f,$82,$1d,$94,$1f,$1d,$82,$1d,$94,$1d,$1f
	db $1d,$1f,$82,$1d,$94,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$82,$1d,$94,$1f
	db $1d,$1f,$82,$1d,$1d,$94,$1d,$1f,$82,$1d,$1d,$94,$1d,$1e,$81
	db $ff,$21
	dw @ref174
@ref177:
	db $84,$21,$94,$1f,$1d,$1f,$82,$1d,$94,$1f,$1d,$82,$1d,$94,$1d,$1f
	db $1d,$1f,$82,$1d,$94,$1f,$1d,$1f,$1d,$1f,$1d,$1f,$82,$1d,$94,$1f
	db $1d,$1f,$82,$1d,$1d,$86,$13,$94,$1f,$82,$1d,$1d,$86,$13,$94,$1e
	db $81
@ref178:
	db $84,$21,$94,$1f,$1d,$1f,$86,$13,$94,$1f,$82,$1b,$1b,$94,$1d,$1f
	db $82,$1b,$94,$1f,$86,$13,$94,$1f,$1d,$1f,$82,$1b,$94,$1f,$1d,$1f
	db $86,$13,$94,$1f,$82,$1b,$1b,$94,$1d,$1f,$82,$1b,$94,$1f,$86,$13
	db $94,$1f,$1d,$1e,$81
@ref179:
	db $84,$21,$94,$1f,$1d,$1f,$86,$13,$94,$1f,$82,$1b,$1b,$94,$1d,$1f
	db $82,$1b,$94,$1f,$86,$13,$94,$1f,$1d,$1f,$82,$1b,$94,$1f,$1d,$1f
	db $86,$13,$94,$1f,$82,$1b,$1b,$1d,$1f,$86,$13,$82,$1f,$1d,$1f,$86
	db $13,$82,$1e,$81
	db $ff,$21
	dw @ref178
@ref181:
	db $84,$21,$94,$1f,$1d,$1f,$86,$13,$94,$1f,$82,$1b,$1b,$94,$1d,$1f
	db $82,$1b,$94,$1f,$86,$13,$94,$1f,$1d,$1f,$84,$21,$94,$1f,$1d,$1f
	db $86,$13,$94,$1f,$1c,$85,$86,$12,$85,$82,$1e,$8d,$86,$12,$85
	db $ff,$21
	dw @ref154
	db $ff,$21
	dw @ref155
	db $ff,$21
	dw @ref154
	db $ff,$21
	dw @ref155
	db $ff,$21
	dw @ref154
	db $ff,$21
	dw @ref155
	db $ff,$21
	dw @ref154
	db $ff,$21
	dw @ref161
@ref190:
	db $84,$21,$94,$1f,$1d,$1f,$82,$1b,$94,$1f,$1d,$1f,$1d,$1f,$1d,$1f
	db $82,$1b,$94,$1f,$1d,$1f,$84,$21,$94,$1f,$1d,$1f,$82,$1b,$94,$1f
	db $1d,$82,$1b,$94,$1d,$1f,$1d,$1f,$82,$1b,$94,$1f,$1d,$1e,$81
@ref191:
	db $84,$21,$94,$1f,$1d,$1f,$82,$1b,$94,$1f,$1d,$82,$1d,$94,$1d,$1f
	db $1d,$1f,$82,$1b,$94,$1f,$1d,$1f,$84,$21,$94,$1f,$1d,$1f,$82,$1b
	db $94,$1f,$1d,$1f,$86,$13,$13,$13,$13,$13,$13,$13,$12,$81
	db $ff,$21
	dw @ref166
	db $ff,$21
	dw @ref167
	db $ff,$21
	dw @ref166
	db $ff,$21
	dw @ref169
	db $ff,$21
	dw @ref166
	db $ff,$21
	dw @ref167
	db $ff,$21
	dw @ref166
	db $ff,$21
	dw @ref169
	db $fd
	dw @song0ch3loop

@song0ch4:
@song0ch4loop:
@ref200:
	db $f9,$85
@ref201:
	db $f9,$85
@ref202:
	db $f9,$85
@ref203:
	db $f9,$85
@ref204:
	db $f9,$85
@ref205:
	db $f9,$85
@ref206:
	db $f9,$85
@ref207:
	db $f9,$85
@ref208:
	db $f9,$85
@ref209:
	db $f9,$85
@ref210:
	db $f9,$85
@ref211:
	db $f9,$85
@ref212:
	db $f9,$85
@ref213:
	db $f9,$85
@ref214:
	db $f9,$85
@ref215:
	db $f9,$85
@ref216:
	db $f9,$85
@ref217:
	db $f9,$85
@ref218:
	db $f9,$85
@ref219:
	db $f9,$85
@ref220:
	db $f9,$85
@ref221:
	db $f9,$85
@ref222:
	db $f9,$85
@ref223:
	db $f9,$85
@ref224:
	db $f9,$85
@ref225:
	db $f9,$85
@ref226:
	db $f9,$85
@ref227:
	db $f9,$85
@ref228:
	db $f9,$85
@ref229:
	db $f9,$85
@ref230:
	db $f9,$85
@ref231:
	db $f9,$85
@ref232:
	db $f9,$85
@ref233:
	db $f9,$85
@ref234:
	db $f9,$85
@ref235:
	db $f9,$85
@ref236:
	db $f9,$85
@ref237:
	db $f9,$85
@ref238:
	db $f9,$85
@ref239:
	db $f9,$85
@ref240:
	db $f9,$85
@ref241:
	db $f9,$85
@ref242:
	db $f9,$85
@ref243:
	db $f9,$85
@ref244:
	db $f9,$85
@ref245:
	db $f9,$85
@ref246:
	db $f9,$85
@ref247:
	db $f9,$85
@ref248:
	db $f9,$85
@ref249:
	db $f9,$85
	db $fd
	dw @song0ch4loop
