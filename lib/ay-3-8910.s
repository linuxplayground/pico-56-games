; vim: set ft=asm_ca65 ts=4 sw=4 et:
; 6502 - AY-3-819x PSG
;
; Copyright (c) 2021 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/hbc-56

.include "ay-3-8910.inc"
.export ayInit

.code

ayInit: ; disable everything ayWrite AY_PSG0, AY_ENABLES, $ff
        ayWrite AY_PSG1, AY_ENABLES, $ff

        aySetVolume AY_PSG0, AY_CHA, 0
        aySetVolume AY_PSG0, AY_CHB, 0
        aySetVolume AY_PSG0, AY_CHC, 0

        ayPlayNote AY_PSG0, AY_CHA, 0
        ayPlayNote AY_PSG0, AY_CHB, 0
        ayPlayNote AY_PSG0, AY_CHC, 0

        aySetEnvelopePeriod AY_PSG0, 0
        aySetEnvShape AY_PSG0, 0
        aySetNoise  AY_PSG0, 0

        aySetVolume AY_PSG1, AY_CHA, 0
        aySetVolume AY_PSG1, AY_CHB, 0
        aySetVolume AY_PSG1, AY_CHC, 0

        ayPlayNote AY_PSG1, AY_CHA, 0
        ayPlayNote AY_PSG1, AY_CHB, 0
        ayPlayNote AY_PSG1, AY_CHC, 0

        aySetEnvelopePeriod AY_PSG1, 0
        aySetEnvShape AY_PSG1, 0
        aySetNoise  AY_PSG1, 0
        rts
; Note frequencies from https://pages.mtu.edu/~suits/notefreqs.html

