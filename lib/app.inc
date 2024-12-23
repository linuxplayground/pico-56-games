; vim: set ft=asm_ca65 et ts=4 sw=4
;
; Copyright (c) 2024 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/linuxplayground/pico-56-games


NAMETABLE               = $3800
COLORTABLE              = $2000
PATTERNTABLE            = $0000
SPRITEATTRIBUTETABLE    = $3B00
SPRITEPATTERNTABLE      = $1800

.enum jstate
    still   = 0
    left    = 1
    right   = 2
    jump_1  = 3 ; 
    jump_2  = 4 ; good jump
    jump_3  = 5 ; good jump
    falling = 6
    crash   = 7 ; when a jump is bad
    crash_fall = 8
    stun    = 9 ; second half of a bad jump
.endenum

.struct sprite
    yp .byte
    xp .byte
    pa .byte
    co .byte
.endstruct
