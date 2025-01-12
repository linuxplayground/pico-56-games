; vim: set ft=asm_ca65 ts=4 sw=4 et:

; 6502 KB Controller - HBC-56
;
; Copyright (c) 2021 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github@com/visrealm/hbc-56
;
.include "io.inc"
.export nes1_pressed, nes2_pressed

.code

nes1_pressed:
        bit     NES1_IO_ADDR
        clc
        bne :+
        sec
:       rts

nes2_pressed:
        bit     NES2_IO_ADDR
        clc
        bne :+
        sec
:       rts

