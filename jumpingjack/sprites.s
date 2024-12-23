; vim: set ft=asm_ca65 ts=4 sw=4 et:

; 1 = jack_idle_f0
; 2 = jack_right_f0
; 3 = jack_left_f0
; 4 = jack_jumping_f0
; 5 = jack_falling_f0
; 6 = jack_stunned_f0
; 7 = jack_crash_f0
;

; A total of 128 sprite patterns can be stored in VRAM.
; Beyond that the patterns will need to be dynamically loaded
; at runtime.
;

; always have one empty sprite at the beginning
; 0-
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
; 1-0-stand_0 - 4
.byte $03,$07,$09,$0E,$0B,$08,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$20,$E0,$A0,$20,$C0,$80
.byte $C0,$20,$90,$88,$40,$40,$20,$30
; 1-1-stand_1 - 8
.byte $03,$07,$09,$1F,$3E,$08,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$E0,$E0,$60,$E0,$C0,$80
.byte $C0,$20,$A0,$90,$40,$40,$20,$60
; 1-2-stand_2 - 12
.byte $03,$07,$09,$0E,$0B,$08,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$20,$E0,$A0,$20,$C0,$80
.byte $C0,$20,$90,$88,$40,$40,$20,$30
; 1-3-stand_3 - 16
.byte $03,$07,$0F,$0F,$0C,$0E,$07,$03
.byte $07,$09,$0A,$12,$04,$04,$08,$0C
.byte $80,$C0,$20,$F0,$F8,$20,$C0,$80
.byte $C0,$20,$90,$88,$40,$40,$20,$30
; 2-4-run_right_0 - 20
.byte $03,$07,$0F,$0F,$0C,$0E,$07,$03
.byte $07,$0F,$01,$01,$01,$07,$05,$01
.byte $80,$C0,$20,$F0,$F8,$20,$C0,$90
.byte $A0,$C0,$80,$40,$20,$E0,$00,$80
; 2-5-run_right_1 - 24
.byte $03,$07,$0F,$0F,$0C,$0E,$07,$03
.byte $03,$0B,$06,$02,$04,$04,$08,$0C
.byte $80,$C0,$20,$F0,$F8,$20,$C0,$90
.byte $A0,$E0,$10,$10,$18,$00,$00,$00
; 2-6-run_right_2 - 28
.byte $03,$07,$0F,$0F,$0C,$0E,$07,$03
.byte $1F,$01,$22,$02,$04,$1C,$20,$00
.byte $80,$C0,$20,$F0,$F8,$20,$C0,$80
.byte $C4,$28,$90,$40,$20,$10,$08,$0C
; 2-7-run_right_3 - 32
.byte $03,$07,$0F,$0F,$0C,$0E,$07,$03
.byte $03,$05,$08,$06,$03,$04,$04,$00
.byte $80,$C0,$20,$F0,$F8,$20,$C0,$90
.byte $A0,$C0,$80,$80,$C0,$40,$20,$30
; 3-8-run_left_0 - 36
.byte $01,$03,$04,$0F,$1F,$04,$03,$09
.byte $05,$03,$01,$02,$04,$07,$00,$01
.byte $C0,$E0,$F0,$F0,$30,$70,$E0,$C0
.byte $E0,$F0,$80,$80,$80,$E0,$A0,$80
; 3-9-run_left_1 - 40
.byte $01,$03,$04,$0F,$1F,$04,$03,$09
.byte $05,$07,$08,$08,$18,$00,$00,$00
.byte $C0,$E0,$F0,$F0,$30,$70,$E0,$C0
.byte $C0,$D0,$60,$40,$20,$20,$10,$30
; 3-10-run_left_2 - 44
.byte $01,$03,$04,$0F,$1F,$04,$03,$01
.byte $23,$14,$09,$02,$04,$08,$10,$30
.byte $C0,$E0,$F0,$F0,$30,$70,$E0,$C0
.byte $F8,$80,$44,$40,$20,$38,$04,$00
; 3-11-run_left_3 - 48
.byte $01,$03,$04,$0F,$1F,$04,$03,$09
.byte $05,$03,$01,$01,$03,$02,$04,$0C
.byte $C0,$E0,$F0,$F0,$30,$70,$E0,$C0
.byte $C0,$A0,$10,$60,$C0,$20,$20,$00
; 4-12-jump_0 - 52
.byte $0B,$0F,$01,$06,$03,$00,$0F,$0B
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $A0,$E0,$00,$C0,$80,$00,$E0,$A0
.byte $C0,$20,$90,$88,$40,$40,$20,$30
; 4-13-jump_1 - 56
.byte $03,$07,$09,$0E,$08,$0B,$07,$03
.byte $07,$09,$0A,$0A,$0A,$02,$02,$04
.byte $80,$C0,$20,$E0,$20,$A0,$C0,$80
.byte $C0,$20,$A0,$A0,$A0,$80,$80,$40
; 4-14-jump_2 - 60
.byte $0B,$0F,$01,$06,$03,$00,$0F,$0B
.byte $07,$09,$0A,$0A,$0A,$02,$02,$04
.byte $A0,$E0,$00,$C0,$80,$00,$E0,$A0
.byte $C0,$20,$A0,$A0,$A0,$80,$80,$40
; 4-15-jump_3 - 64
.byte $0B,$0F,$01,$06,$03,$00,$0F,$0B
.byte $07,$09,$0A,$0A,$0A,$02,$02,$04
.byte $A0,$E0,$00,$C0,$80,$00,$E0,$A0
.byte $C0,$20,$A0,$A0,$A0,$80,$80,$40
; 5-16-fall_0 - 68
.byte $03,$27,$19,$0E,$0F,$0C,$07,$0B
.byte $07,$01,$02,$02,$04,$04,$08,$18
.byte $80,$C8,$30,$E0,$E0,$60,$C0,$A0
.byte $C0,$00,$80,$80,$40,$40,$20,$30
; 5-17-fall_1 - 72
.byte $03,$07,$09,$0E,$0F,$0C,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$20,$E0,$E0,$60,$C0,$80
.byte $C0,$20,$90,$80,$40,$40,$20,$30
; 5-18-fall_2 - 76
.byte $03,$07,$09,$0E,$0F,$0C,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$20,$E0,$E0,$60,$C0,$80
.byte $C0,$20,$90,$80,$40,$40,$20,$30
; 5-19-fall_3 - 80
.byte $03,$07,$09,$0E,$0F,$0C,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$20,$E0,$E0,$60,$C0,$80
.byte $C0,$20,$90,$80,$40,$40,$20,$30
; 6-20-stun_0 - 84
.byte $00,$00,$01,$C0,$00,$00,$00,$00
.byte $84,$44,$42,$22,$21,$1F,$00,$00
.byte $00,$18,$82,$00,$00,$00,$00,$10
.byte $18,$3C,$5E,$5B,$DF,$DF,$FE,$3C
; 6-21-stun_1 - 88
.byte $00,$00,$00,$00,$00,$02,$00,$C0
.byte $84,$44,$42,$22,$21,$1F,$00,$00
.byte $00,$08,$80,$02,$00,$10,$00,$10
.byte $18,$3C,$5E,$5B,$DF,$DF,$FE,$3C
; 6-22-stun_2 - 92
.byte $00,$00,$00,$00,$02,$00,$00,$18
.byte $11,$11,$11,$11,$11,$1F,$00,$00
.byte $00,$04,$40,$00,$02,$20,$00,$10
.byte $18,$3C,$5E,$5B,$DF,$DF,$FE,$3C
; 6-23-stun_3 - 96
.byte $00,$00,$00,$01,$00,$00,$00,$18
.byte $11,$11,$11,$11,$11,$1F,$00,$00
.byte $00,$26,$00,$00,$00,$00,$40,$10
.byte $18,$3C,$5E,$5B,$DF,$DF,$FE,$3C
; 7-24-crash_0 - 100
.byte $03,$07,$09,$0E,$0F,$0C,$07,$03
.byte $07,$09,$12,$22,$04,$04,$08,$18
.byte $80,$C0,$20,$E0,$E0,$60,$C0,$80
.byte $C0,$20,$90,$88,$40,$40,$20,$30
; 7-25-crash_1 104
.byte $03,$07,$09,$0E,$0F,$2C,$17,$0B
.byte $27,$31,$0D,$03,$00,$00,$00,$00
.byte $80,$C0,$20,$E0,$E0,$68,$D0,$A0
.byte $C8,$18,$60,$80,$00,$00,$00,$00
; 7-26-crash_2 - 108
.byte $00,$00,$48,$84,$42,$21,$16,$08
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $10,$18,$3C,$5A,$DB,$DF,$DF,$7E
.byte $3C,$00,$00,$00,$00,$00,$00,$00
; 7-27-crash_2 112
.byte $00,$00,$48,$84,$42,$25,$12,$08
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $10,$18,$3C,$5A,$DB,$DF,$DF,$7E
.byte $3C,$00,$00,$00,$00,$00,$00,$00