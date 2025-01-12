; vim: set ft=asm_ca65 ts=4 sw=4 et:

; 6502 - AY-3-819x PSG
;
; Copyright (c) 2021 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/hbc-56

AY_IO_PORT = $40
AY_PSG0 = $00
AY_PSG1 = $04

; IO Ports
AY_S0 = IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_PSG0
AY_S1 = IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_PSG1
AY_INACTIVE = $03
AY_READ     = $02
AY_WRITE    = $01
AY_ADDR     = $00

AY_S0_READ  = AY_S0 | AY_READ
AY_S0_WRITE = AY_S0 | AY_WRITE
AY_S0_ADDR  = AY_S0 | AY_ADDR

AY_S1_READ  = AY_S1 | AY_READ
AY_S1_WRITE = AY_S1 | AY_WRITE
AY_S1_ADDR  = AY_S1 | AY_ADDR

; Registers (they're named using Octal values)
AY_R0 = 0
AY_R1 = 1
AY_R2 = 2
AY_R3 = 3
AY_R4 = 4
AY_R5 = 5
AY_R6 = 6
AY_R7 = 7
AY_R10 = 8
AY_R11 = 9
AY_R12 = 10
AY_R13 = 11
AY_R14 = 12
AY_R15 = 13
AY_R16 = 14
AY_R17 = 15

AY_CHA = 0
AY_CHB = 1
AY_CHC = 2
AY_CHN = 3

AY_CHA_TONE_L   = AY_R0
AY_CHA_TONE_H   = AY_R1
AY_CHB_TONE_L   = AY_R2
AY_CHB_TONE_H   = AY_R3
AY_CHC_TONE_L   = AY_R4
AY_CHC_TONE_H   = AY_R5
AY_NOISE_GEN    = AY_R6
AY_ENABLES      = AY_R7
AY_CHA_AMPL     = AY_R10
AY_CHB_AMPL     = AY_R11
AY_CHC_AMPL     = AY_R12
AY_ENV_PERIOD_L = AY_R13
AY_ENV_PERIOD_H = AY_R14
AY_ENV_SHAPE    = AY_R15
AY_PORTA        = AY_R16
AY_PORTB        = AY_R17

AY_ENV_SHAPE_CONTINUE  = $08
AY_ENV_SHAPE_ATTACK    = $04
AY_ENV_SHAPE_ALTERNATE = $02
AY_ENV_SHAPE_HOLD      = $01

;  /\  /\  /\  /\  /\ 
; /  \/  \/  \/  \/  \
AY_ENV_SHAPE_TRIANGLE     = (AY_ENV_SHAPE_CONTINUE | AY_ENV_SHAPE_ATTACK | AY_ENV_SHAPE_ALTERNATE)

; \  /\  /\  /\  /\  /
;  \/  \/  \/  \/  \/
AY_ENV_SHAPE_TRIANGLE2    = (AY_ENV_SHAPE_CONTINUE | AY_ENV_SHAPE_ALTERNATE)

;  /------------------
; /
AY_ENV_SHAPE_FADE_IN      = (AY_ENV_SHAPE_CONTINUE | AY_ENV_SHAPE_ATTACK | AY_ENV_SHAPE_HOLD)

; \
;  \__________________
AY_ENV_SHAPE_FADE_OUT     = (AY_ENV_SHAPE_CONTINUE | AY_ENV_SHAPE_HOLD)

; \ |\ |\ |\ |\ |\ |\ |
;  \| \| \| \| \| \| \|
AY_ENV_SHAPE_SAW1         = (AY_ENV_SHAPE_CONTINUE)

;  /| /| /| /| /| /| /|
; / |/ |/ |/ |/ |/ |/ |
AY_ENV_SHAPE_SAW2         = (AY_ENV_SHAPE_CONTINUE | AY_ENV_SHAPE_ATTACK)

;  /|
; / |__________________
AY_ENV_SHAPE_FADE_IN_STOP = (AY_ENV_SHAPE_ATTACK)


AY_CLOCK_FREQ   = 2000000

.macro ayWrite dev, reg, val 
        lda #reg
        sta IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_ADDR | dev
        lda #val
        sta IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_WRITE | dev
.endmacro

.macro ayRead dev, reg 
        lda #reg
        sta IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_ADDR | dev
        lda IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_READ | dev
.endmacro

.macro ayWriteX dev, reg 
        lda #reg
        sta IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_ADDR | dev
        stx IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_WRITE | dev
.endmacro

.macro ayWriteA dev, reg 
        ldx #reg
        stx IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_ADDR | dev
        sta IO_PORT_BASE_ADDRESS | AY_IO_PORT | AY_WRITE | dev
.endmacro

.macro ayPlayNote dev, chan, freq 
        .local val
        .if freq <= 0 
                val = 0
        .else 
                val = AY_CLOCK_FREQ / (16 * freq)
        .endif
        ayWrite dev, AY_CHA_TONE_L | (chan * 2), <val
        ayWrite dev, AY_CHA_TONE_H | (chan * 2), >val
.endmacro

.macro ayToneWordPeriod periodHz 
        .word ((AY_CLOCK_FREQ * periodHz) / 16)
.endmacro

.macro ayToneWord freq 
        .word (AY_CLOCK_FREQ / (16 * freq))
.endmacro

.macro ayToneByteL freq 
        .byte <(AY_CLOCK_FREQ / (16 * freq))
.endmacro

.macro ayToneByteH freq 
        .byte >(AY_CLOCK_FREQ / (16 * freq))
.endmacro

.macro ayToneEnable dev, chan 
        ayRead dev, AY_ENABLES
        and #($01 << chan)
        ayWriteA dev, AY_ENABLES
.endmacro

.macro ayToneDisable dev, chan 
        ayRead dev, AY_ENABLES
        ora #($01 << chan)
        ayWriteA dev, AY_ENABLES
.endmacro

.macro ayNoiseEnable dev, chan 
        ayRead dev, AY_ENABLES
        eor #($08 << chan)
        ayWriteA dev, AY_ENABLES
.endmacro

.macro ayNoiseDisable dev, chan 
        ayRead dev, AY_ENABLES
        ora #($08 << chan)
        ayWriteA dev, AY_ENABLES
.endmacro

.macro aySetVolume dev, chan, vol 
        ayWrite dev, (AY_CHA_AMPL | chan), (vol >> 4)
.endmacro

.macro aySetVolumeAcc dev, chan 
        ayWriteA dev, (AY_CHA_AMPL | chan)
.endmacro

.macro aySetVolumeEnvelope dev, chan 
        ayWrite dev, (AY_CHA_AMPL | chan), $10
.endmacro

.macro aySetEnvelopePeriod dev, period 
        ayWrite dev, AY_ENV_PERIOD_L, <period
        ayWrite dev, AY_ENV_PERIOD_H, >period
.endmacro

.macro aySetEnvShape dev, shape 
        ayWrite dev, AY_ENV_SHAPE, shape
.endmacro

.macro aySetNoise dev, freq 
        ayWrite dev, AY_ENV_SHAPE, freq >> 3
.endmacro

.macro ayStop dev, chan 
        ayPlayNote dev, chan, 0
        ayToneDisable dev, chan
.endmacro

NOTE_FREQ_C0  = 16
NOTE_FREQ_CS0 = 17
NOTE_FREQ_D0  = 18
NOTE_FREQ_DS0 = 19
NOTE_FREQ_E0  = 20
NOTE_FREQ_F0  = 21
NOTE_FREQ_FS0 = 23
NOTE_FREQ_G0  = 24
NOTE_FREQ_GS0 = 25
NOTE_FREQ_A0  = 27
NOTE_FREQ_AS0 = 29
NOTE_FREQ_B0  = 30
NOTE_FREQ_C1  = 32
NOTE_FREQ_CS1 = 34
NOTE_FREQ_D1  = 36
NOTE_FREQ_DS1 = 38
NOTE_FREQ_E1  = 41
NOTE_FREQ_F1  = 43
NOTE_FREQ_FS1 = 46
NOTE_FREQ_G1  = 49
NOTE_FREQ_GS1 = 51
NOTE_FREQ_A1  = 55
NOTE_FREQ_AS1 = 58
NOTE_FREQ_B1  = 61
NOTE_FREQ_C2  = 65
NOTE_FREQ_CS2 = 69
NOTE_FREQ_D2  = 73
NOTE_FREQ_DS2 = 77
NOTE_FREQ_E2  = 82
NOTE_FREQ_F2  = 87
NOTE_FREQ_FS2 = 92
NOTE_FREQ_G2  = 98
NOTE_FREQ_GS2 = 103
NOTE_FREQ_A2  = 110
NOTE_FREQ_AS2 = 116
NOTE_FREQ_B2  = 123
NOTE_FREQ_C3  = 130
NOTE_FREQ_CS3 = 138
NOTE_FREQ_D3  = 146
NOTE_FREQ_DS3 = 155
NOTE_FREQ_E3  = 164
NOTE_FREQ_F3  = 174
NOTE_FREQ_FS3 = 185
NOTE_FREQ_G3  = 196
NOTE_FREQ_GS3 = 207
NOTE_FREQ_A3  = 220
NOTE_FREQ_AS3 = 233
NOTE_FREQ_B3  = 246
NOTE_FREQ_C4  = 261
NOTE_FREQ_CS4 = 277
NOTE_FREQ_D4  = 293
NOTE_FREQ_DS4 = 311
NOTE_FREQ_E4  = 329
NOTE_FREQ_F4  = 349
NOTE_FREQ_FS4 = 369
NOTE_FREQ_G4  = 392
NOTE_FREQ_GS4 = 415
NOTE_FREQ_A4  = 440
NOTE_FREQ_AS4 = 466
NOTE_FREQ_B4  = 493
NOTE_FREQ_C5  = 523
NOTE_FREQ_CS5 = 554
NOTE_FREQ_D5  = 587
NOTE_FREQ_DS5 = 622
NOTE_FREQ_E5  = 659
NOTE_FREQ_F5  = 698
NOTE_FREQ_FS5 = 739
NOTE_FREQ_G5  = 783
NOTE_FREQ_GS5 = 830
NOTE_FREQ_A5  = 880
NOTE_FREQ_AS5 = 932
NOTE_FREQ_B5  = 987
NOTE_FREQ_C6  = 104
NOTE_FREQ_CS6 = 110
NOTE_FREQ_D6  = 117
NOTE_FREQ_DS6 = 124
NOTE_FREQ_E6  = 131
NOTE_FREQ_F6  = 139
NOTE_FREQ_FS6 = 147
NOTE_FREQ_G6  = 156
NOTE_FREQ_GS6 = 166
NOTE_FREQ_A6  = 176
NOTE_FREQ_AS6 = 186
NOTE_FREQ_B6  = 197
NOTE_FREQ_C7  = 209
NOTE_FREQ_CS7 = 221
NOTE_FREQ_D7  = 234
NOTE_FREQ_DS7 = 248
NOTE_FREQ_E7  = 263
NOTE_FREQ_F7  = 279
NOTE_FREQ_FS7 = 295
NOTE_FREQ_G7  = 313
NOTE_FREQ_GS7 = 332
NOTE_FREQ_A7  = 352
NOTE_FREQ_AS7 = 372
NOTE_FREQ_B7  = 395
NOTE_FREQ_C8  = 418
NOTE_FREQ_CS8 = 443
NOTE_FREQ_D8  = 469
NOTE_FREQ_DS8 = 497
NOTE_FREQ_E8  = 527
NOTE_FREQ_F8  = 558
NOTE_FREQ_FS8 = 591
NOTE_FREQ_G8  = 627
NOTE_FREQ_GS8 = 664
NOTE_FREQ_A8  = 704
NOTE_FREQ_AS8 = 745
NOTE_FREQ_B8  = 790

