;===============================================================================
;                'JUMPING JACK' (ZX SPECTRUM) - DISASSEMBLY
;                 Chris Ward, 2012 (cjw116@googlemail.com)
;                 Original game (c) 1983 Imagine Software
;===============================================================================
;
; This is file 4 of 4:
;
;    1) JJLoader.txt       Commented RAM disassembly of loader program with all
;                          addresses & object code
;
;    2) JJLoader.asm       Address-independent assembler source file of above -
;                          can be reassembled at any address
;
;    3) JJGame.txt         Commented RAM disassembly of game with all addresses
;                          & object code. Also a list of useful POKES.
;
;   *4) JJGame.asm         Address-independent assembler source file of above -
;                          can be reassembled at any address
;
;
; NB: All mistakes are mine. Please forgive the amount of comments and the way
; the files are formatted. I've never disassembled anything before and this
; worked for me! Hope it is of interest to someone.
;
; The .asm files have been tested with Pasmo (http://pasmo.speccy.org/) and
; they produce exact binary matches of the original.
;
; Enjoy!
;
;
;===============================================================================
; Definitions for comments:
;
; Jline     One of the 8 red lines that Jack has to jump through. Each Jline
;           is two pixels thick and spans the width of the screen.
;           The Jlines are numbered 0-7 where 0 is the top and 7 the bottom.
;
; InfoLine  The 32 cells in screen line 22 - which include the 'lives
;           remaining' symbols and the High Score.
;===============================================================================

; This will assemble to create a 8818 byte binary - identical to the code in
; the original game.


ROM_BEEP       EQU     03b5h
FRAMES         EQU     5c78h

               ORG     5d8eh       ; This is the ORG used by the original - but
                                   ; can be whatever you want.
                                   ; NB: Program start is at ORG + 11b4h (4532d)


; GFX DATA
;
; The following 4232 bytes define all the GFX bitmap data for the game. There
; are 13 different animation sequences for Jack, 10 animations for the different
; Hazards and 1 Lives Remaining Symbol.

GFXJStil:      ; Jack standing still GFX data
               ; 2x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 1/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 1/4 - Cell (1,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 1/4 - Cell (1,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 2/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001111b
               db      00011111b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 2/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      11110000b
               db      11110000b
               db      00110000b
               db      01110000b
               db      11100000b
               db      11000000b

; Frame 2/4 - Cell (1,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 2/4 - Cell (1,1)
               db      11100000b
               db      10010000b
               db      01010000b
               db      01001000b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00110000b

; Frame 3/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 3/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 3/4 - Cell (1,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 3/4 - Cell (1,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 4/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000111b
               db      00000110b
               db      00000111b
               db      00000011b
               db      00000001b

; Frame 4/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      11111000b
               db      01111100b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 4/4 - Cell (1,0)
               db      00000011b
               db      00000100b
               db      00000101b
               db      00001001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00000110b

; Frame 4/4 - Cell (1,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b


GFXJLeft:      ; Jack running left GFX data
               ; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001111b
               db      00011111b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 1/4 - Cell (0,2)
               db      11000000b
               db      11100000b
               db      11110000b
               db      11110000b
               db      00110000b
               db      01110000b
               db      11100000b
               db      11000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      00100011b
               db      00010100b
               db      00001001b
               db      00000010b
               db      00000100b
               db      00001000b
               db      00010000b
               db      00110000b

; Frame 1/4 - Cell (1,2)
               db      11111000b
               db      10000100b
               db      01000100b
               db      01000000b
               db      00100000b
               db      00111100b
               db      00000100b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000111b
               db      00001111b
               db      00010011b
               db      00111111b
               db      01111100b
               db      00010001b
               db      00001111b
               db      00100111b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      10000000b
               db      11000000b
               db      11000000b
               db      11000000b
               db      11000000b
               db      10000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      00010111b
               db      00001110b
               db      00000100b
               db      00000101b
               db      00001000b
               db      00001111b
               db      00010000b
               db      00110000b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      10000000b
               db      01000000b
               db      10000000b
               db      00000000b
               db      10000000b
               db      10000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00011100b
               db      00111110b
               db      01001111b
               db      11111111b
               db      11110011b
               db      01000111b
               db      00111110b
               db      10011100b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      01011110b
               db      00111111b
               db      00011000b
               db      00101000b
               db      01001000b
               db      01111110b
               db      00001010b
               db      00011000b

; Frame 3/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000001b
               db      00000000b
               db      00000010b

; Frame 4/4 - Cell (0,1)
               db      01110000b
               db      11111000b
               db      00111100b
               db      11111100b
               db      11001100b
               db      00011100b
               db      11111000b
               db      01110000b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000001b
               db      00000001b
               db      00000010b
               db      00000010b
               db      00000110b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      01110000b
               db      11111000b
               db      00011100b
               db      00010000b
               db      00001000b
               db      00001000b
               db      00000100b
               db      00001100b

; Frame 4/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b


GFXJRgt:       ; Jack running right GFX data
               ; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000111b
               db      00000110b
               db      00000111b
               db      00000011b
               db      00000001b

; Frame 1/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      11111000b
               db      01111100b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00001111b
               db      00010000b
               db      00010001b
               db      00000001b
               db      00000010b
               db      00011110b
               db      00010000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      11100010b
               db      10010100b
               db      01001000b
               db      00100000b
               db      00010000b
               db      00001000b
               db      00000100b
               db      00000110b

; Frame 1/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      01110000b
               db      11111000b
               db      11100100b
               db      11111110b
               db      10011111b
               db      11000100b
               db      11111000b
               db      01110010b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      01110100b
               db      10111000b
               db      00010000b
               db      11010000b
               db      00001000b
               db      11111000b
               db      10000100b
               db      00000110b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00011100b
               db      00111110b
               db      01111001b
               db      01111111b
               db      01100111b
               db      01110001b
               db      00111110b
               db      00011100b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      00000000b
               db      00000000b
               db      10000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00111101b
               db      01111110b
               db      00001100b
               db      00001010b
               db      00001001b
               db      00111111b
               db      00101000b
               db      00001100b

; Frame 3/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000111b
               db      00001111b
               db      00011110b
               db      00011111b
               db      00011001b
               db      00011100b
               db      00001111b
               db      00000111b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      10000000b
               db      01000000b
               db      11100000b
               db      11110000b
               db      01000000b
               db      10000000b
               db      00100000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00000111b
               db      00001111b
               db      00011100b
               db      00000100b
               db      00001000b
               db      00001000b
               db      00010000b
               db      00011000b

; Frame 4/4 - Cell (1,2)
               db      01000000b
               db      11000000b
               db      00100000b
               db      00100000b
               db      00110000b
               db      00000000b
               db      00000000b
               db      00000000b


GFXJLEOf:      ; Jack running off left edge GFX data
               ; 2x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001111b
               db      00011111b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 1/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      11110000b
               db      11110000b
               db      00110000b
               db      01110000b
               db      11100000b
               db      11000000b

; Frame 1/4 - Cell (1,0)
               db      00100011b
               db      00010100b
               db      00001001b
               db      00000010b
               db      00000100b
               db      00001000b
               db      00010000b
               db      00110000b

; Frame 1/4 - Cell (1,1)
               db      11111000b
               db      10000100b
               db      01000100b
               db      01000000b
               db      00100000b
               db      00111100b
               db      00000100b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00011100b
               db      00111110b
               db      01001111b
               db      11111111b
               db      11110011b
               db      01000111b
               db      00111110b
               db      00011100b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00011110b
               db      00011111b
               db      00011000b
               db      00101000b
               db      01001000b
               db      01111110b
               db      00001010b
               db      00011000b

; Frame 2/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      11000000b
               db      11100000b
               db      11110000b
               db      11110000b
               db      00110000b
               db      01110000b
               db      11100000b
               db      11000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      11111000b
               db      10000100b
               db      01000100b
               db      01000000b
               db      00100000b
               db      00111100b
               db      00000100b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b


GFXJREOn:      ; Jack running in from right edge GFX data
               ; 2x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001111b
               db      00011111b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00100011b
               db      00010100b
               db      00001001b
               db      00000010b
               db      00000100b
               db      00001000b
               db      00010000b
               db      00110000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00011100b
               db      00111110b
               db      01001111b
               db      11111111b
               db      11110011b
               db      01000111b
               db      00111110b
               db      00011100b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00011110b
               db      00011111b
               db      00011000b
               db      00101000b
               db      01001000b
               db      01111110b
               db      00001010b
               db      00011000b


GFXJLEOn:      ; Jack running in from left edge GFX data
               ; 2x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      00000000b
               db      00000000b
               db      10000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      11000000b
               db      11100000b
               db      10010000b
               db      11111000b
               db      01111100b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      11100010b
               db      10010100b
               db      01001000b
               db      00100000b
               db      00010000b
               db      00001000b
               db      00000100b
               db      00000110b

; Frame 3/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00001110b
               db      00011111b
               db      00111100b
               db      00111111b
               db      00110011b
               db      00111000b
               db      00011111b
               db      00001110b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      11100000b
               db      10000000b
               db      00000000b
               db      01000000b

; Frame 4/4 - Cell (1,0)
               db      00011110b
               db      00111111b
               db      00000110b
               db      00000101b
               db      00000100b
               db      00011111b
               db      00010100b
               db      00000110b

; Frame 4/4 - Cell (1,1)
               db      10000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      10000000b
               db      00000000b
               db      00000000b


GFXJREOf:      ; Jack running off right edge GFX data
               ; 2x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000111b
               db      00000110b
               db      00000111b
               db      00000011b
               db      00000001b

; Frame 1/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      11111000b
               db      01111100b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 1/4 - Cell (1,0)
               db      00001111b
               db      00010000b
               db      00010001b
               db      00000001b
               db      00000010b
               db      00011110b
               db      00010000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      11100010b
               db      10010100b
               db      01001000b
               db      00100000b
               db      00010000b
               db      00001000b
               db      00000100b
               db      00000110b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00011100b
               db      00111110b
               db      01111001b
               db      01111111b
               db      01100111b
               db      01110001b
               db      00111110b
               db      00011100b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      00111101b
               db      01111110b
               db      00001100b
               db      00001010b
               db      00001001b
               db      00111111b
               db      00101000b
               db      00001100b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000111b
               db      00000110b
               db      00000111b
               db      00000011b
               db      00000001b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00001111b
               db      00010000b
               db      00010001b
               db      00000001b
               db      00000010b
               db      00011110b
               db      00010000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b


GFXJGJp1:      ; Jack Good Jump Part 1 GFX data
               ; 3x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b

; Frame 1/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b

; Frame 1/4 - Cell (2,0)
               db      00000100b
               db      00000011b
               db      00001001b
               db      00000101b
               db      00000011b
               db      00000100b
               db      00001000b
               db      00011000b

; Frame 1/4 - Cell (2,1)
               db      00010000b
               db      11100000b
               db      11001000b
               db      11010000b
               db      11100000b
               db      00010000b
               db      00001000b
               db      00001100b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 2/4 - Cell (1,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 2/4 - Cell (2,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 2/4 - Cell (2,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 3/4 - Cell (1,0)
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b

; Frame 3/4 - Cell (1,1)
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b

; Frame 3/4 - Cell (2,0)
               db      00000001b
               db      00000010b
               db      00000010b
               db      00000110b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (2,1)
               db      01000000b
               db      00100000b
               db      00100000b
               db      00110000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 4/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 4/4 - Cell (1,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 4/4 - Cell (1,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 4/4 - Cell (2,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (2,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b


GFXJGJp2:      ; Jack Good Jump Part 2 GFX data
               ; 4x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 1/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 1/4 - Cell (2,0)
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000101b
               db      00000101b

; Frame 1/4 - Cell (2,1)
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01010000b
               db      01010000b

; Frame 1/4 - Cell (3,0)
               db      00000101b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00000010b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (3,1)
               db      01010000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      00100000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 2/4 - Cell (1,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 2/4 - Cell (2,0)
               db      00000011b
               db      00000100b
               db      00000101b
               db      00000101b
               db      00000101b
               db      00000001b
               db      00000001b
               db      00000001b

; Frame 2/4 - Cell (2,1)
               db      11100000b
               db      10010000b
               db      01010000b
               db      01010000b
               db      01010000b
               db      01000000b
               db      01000000b
               db      01000000b

; Frame 2/4 - Cell (3,0)
               db      00000010b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (3,1)
               db      00100000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 3/4 - Cell (1,0)
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000101b
               db      00000101b

; Frame 3/4 - Cell (1,1)
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01010000b
               db      01010000b

; Frame 3/4 - Cell (2,0)
               db      00000101b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00000010b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (2,1)
               db      01010000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      00100000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (3,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (3,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 4/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 4/4 - Cell (1,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 4/4 - Cell (1,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 4/4 - Cell (2,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (2,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (3,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (3,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b


GFXJFal1:      ; Jack Falling Through Gap Part 1 GFX data
               ; 4x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 1/4 - Cell (1,0)
               db      00000111b
               db      00010110b
               db      00001011b
               db      00000101b
               db      00000011b
               db      00000000b
               db      00000001b
               db      00000001b

; Frame 1/4 - Cell (1,1)
               db      11110000b
               db      00110100b
               db      11101000b
               db      11010000b
               db      11100000b
               db      10000000b
               db      01000000b
               db      01000000b

; Frame 1/4 - Cell (2,0)
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (2,1)
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (3,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (3,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000111b
               db      00010110b
               db      00001011b
               db      00000101b

; Frame 2/4 - Cell (1,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11110000b
               db      00110100b
               db      11101000b
               db      11010000b

; Frame 2/4 - Cell (2,0)
               db      00000011b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 2/4 - Cell (2,1)
               db      11100000b
               db      10000000b
               db      01000000b
               db      01000000b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 2/4 - Cell (3,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (3,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 3/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 3/4 - Cell (2,0)
               db      00000111b
               db      00000110b
               db      00000011b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b

; Frame 3/4 - Cell (2,1)
               db      11110000b
               db      00110000b
               db      11100000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b

; Frame 3/4 - Cell (3,0)
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (3,1)
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (2,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000111b
               db      00000110b
               db      00000011b
               db      00000001b

; Frame 4/4 - Cell (2,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11110000b
               db      00110000b
               db      11100000b
               db      11000000b

; Frame 4/4 - Cell (3,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 4/4 - Cell (3,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b


GFXJBdJp:      ; Jack Bad Jump GFX data
               ; 3x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 1/4 - Cell (1,0)
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b

; Frame 1/4 - Cell (1,1)
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b

; Frame 1/4 - Cell (2,0)
               db      00000001b
               db      00000010b
               db      00000010b
               db      00000110b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (2,1)
               db      01000000b
               db      00100000b
               db      00100000b
               db      00110000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000111b
               db      00010110b
               db      00001011b
               db      00000101b

; Frame 2/4 - Cell (0,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11110000b
               db      00110100b
               db      11101000b
               db      11010000b

; Frame 2/4 - Cell (1,0)
               db      00010011b
               db      00011000b
               db      00000110b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      11100100b
               db      10001100b
               db      10110000b
               db      11000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (2,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (2,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      01001000b
               db      10000100b
               db      01000010b
               db      00100001b
               db      00010110b
               db      00001000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00011000b
               db      00111100b
               db      01011010b
               db      11011011b
               db      11011111b
               db      11011111b
               db      01111110b
               db      00111100b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (2,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (2,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000011b
               db      00000001b

; Frame 4/4 - Cell (1,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b
               db      00010000b
               db      11100000b
               db      11000000b

; Frame 4/4 - Cell (2,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 4/4 - Cell (2,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b


GFXJStun:      ; Jack stunned GFX data
               ; 2x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000010b
               db      00000000b
               db      00000000b
               db      00011000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000100b
               db      01000000b
               db      00000000b
               db      00000010b
               db      00100000b
               db      00000000b
               db      00010000b

; Frame 1/4 - Cell (1,0)
               db      00010001b
               db      00010001b
               db      00010001b
               db      00010001b
               db      00010001b
               db      00011111b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      00011000b
               db      00111100b
               db      01011110b
               db      01011011b
               db      11011111b
               db      11011111b
               db      11111110b
               db      00111100b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00011000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00100010b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000100b
               db      01000000b
               db      00010000b

; Frame 2/4 - Cell (1,0)
               db      00010001b
               db      00010001b
               db      00010001b
               db      00010001b
               db      00010001b
               db      00011111b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      00011000b
               db      00111100b
               db      01011110b
               db      01011011b
               db      11011111b
               db      11011111b
               db      11111110b
               db      00111100b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00010000b
               db      00000010b
               db      00000000b
               db      00000000b
               db      00001000b
               db      10000000b
               db      00010000b

; Frame 3/4 - Cell (1,0)
               db      10000100b
               db      01000100b
               db      01000010b
               db      00100010b
               db      00100001b
               db      00011111b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00011000b
               db      00111100b
               db      01011110b
               db      01011011b
               db      11011111b
               db      11011111b
               db      11111110b
               db      00111100b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000010b
               db      00000000b
               db      11000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00001000b
               db      10000000b
               db      00000010b
               db      00000000b
               db      00010000b
               db      00000000b
               db      00010000b

; Frame 4/4 - Cell (1,0)
               db      10000100b
               db      01000100b
               db      01000010b
               db      00100010b
               db      00100001b
               db      00011111b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00011000b
               db      00111100b
               db      01011110b
               db      01011011b
               db      11011111b
               db      11011111b
               db      11111110b
               db      00111100b


GFXJFal2:      ; Jack Falling Through Gap Part 2 GFX data
               ; 4x2 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b

; Frame 1/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b

; Frame 1/4 - Cell (2,0)
               db      00000111b
               db      00000110b
               db      00000011b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b

; Frame 1/4 - Cell (2,1)
               db      11110000b
               db      00110000b
               db      11100000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b

; Frame 1/4 - Cell (3,0)
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (3,1)
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (2,0)
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000111b
               db      00000110b
               db      00000011b
               db      00000001b

; Frame 2/4 - Cell (2,1)
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11110000b
               db      00110000b
               db      11100000b
               db      11000000b

; Frame 2/4 - Cell (3,0)
               db      00000011b
               db      00000100b
               db      00001001b
               db      00010001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00001100b

; Frame 2/4 - Cell (3,1)
               db      11100000b
               db      10010000b
               db      01001000b
               db      01000100b
               db      00100000b
               db      00100000b
               db      00010000b
               db      00011000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (2,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000100b
               db      00000111b
               db      00000101b

; Frame 3/4 - Cell (2,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      10010000b
               db      01110000b
               db      11010000b

; Frame 3/4 - Cell (3,0)
               db      00000100b
               db      00000011b
               db      00001001b
               db      00000101b
               db      00000011b
               db      00000100b
               db      00001000b
               db      00011000b

; Frame 3/4 - Cell (3,1)
               db      00010000b
               db      11100000b
               db      11001000b
               db      11010000b
               db      11100000b
               db      00010000b
               db      00001000b
               db      00001100b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (2,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000010b
               db      00000000b
               db      00000000b
               db      00011000b

; Frame 4/4 - Cell (2,1)
               db      00000000b
               db      00000100b
               db      01000000b
               db      00000000b
               db      00000010b
               db      00100000b
               db      00000000b
               db      00010000b

; Frame 4/4 - Cell (3,0)
               db      00010001b
               db      00010001b
               db      00010001b
               db      00010001b
               db      00010001b
               db      00011111b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (3,1)
               db      00011000b
               db      00111100b
               db      01011110b
               db      01011011b
               db      11011111b
               db      11011111b
               db      11111110b
               db      00111100b




GFXHzrds:

; Hazard 1 - Octopus
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000001b
               db      00000111b
               db      00001111b
               db      00011001b
               db      00011111b
               db      00001111b
               db      00000011b
               db      00000111b

; Frame 1/4 - Cell (1,1)
               db      00001011b
               db      00010011b
               db      00010101b
               db      00100101b
               db      00100100b
               db      01000100b
               db      01001001b
               db      01001001b

; Frame 1/4 - Cell (0,2)
               db      11000000b
               db      11110000b
               db      11111000b
               db      11001100b
               db      11111100b
               db      11111000b
               db      11100000b
               db      11110000b

; Frame 1/4 - Cell (1,2)
               db      11101000b
               db      11000100b
               db      11010100b
               db      11010010b
               db      10010010b
               db      10010001b
               db      01001001b
               db      01001001b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00000100b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00011100b
               db      01111111b
               db      11111111b
               db      10011100b
               db      11111111b
               db      11111111b

; Frame 2/4 - Cell (1,1)
               db      00111110b
               db      01111111b
               db      10111110b
               db      00111110b
               db      01011101b
               db      01011101b
               db      10001000b
               db      10010100b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      11000000b
               db      10000000b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      10000000b
               db      01000000b
               db      00100000b
               db      00100000b
               db      10010000b
               db      10010000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000111b
               db      00001111b
               db      00011001b

; Frame 3/4 - Cell (1,1)
               db      00011111b
               db      00001111b
               db      00000011b
               db      00000111b
               db      00001011b
               db      00010011b
               db      00100100b
               db      01001001b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b
               db      11110000b
               db      11111000b
               db      11001100b

; Frame 3/4 - Cell (1,2)
               db      11111100b
               db      11111000b
               db      11100000b
               db      11110000b
               db      11101000b
               db      11100100b
               db      10010010b
               db      01001001b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000010b
               db      00000010b
               db      00000100b
               db      00000100b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00011100b
               db      01111111b
               db      11111111b
               db      10011100b
               db      11111111b
               db      11111111b

; Frame 4/4 - Cell (1,1)
               db      00111110b
               db      01111111b
               db      10111110b
               db      00111110b
               db      01011101b
               db      01011101b
               db      10001000b
               db      10010100b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      11000000b
               db      10000000b

; Frame 4/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      10000000b
               db      01000000b
               db      00100000b
               db      00100000b
               db      10010000b
               db      10010000b


; Hazard 2 - Train
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000010b
               db      00000011b
               db      00000010b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00111100b
               db      00011000b
               db      00011000b
               db      00011000b
               db      00011000b
               db      00011000b
               db      00011000b
               db      11111111b

; Frame 1/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      00101100b
               db      00110100b
               db      00011000b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000111b
               db      00000100b
               db      00000100b
               db      01000100b
               db      11100100b
               db      11100100b
               db      11111111b

; Frame 1/4 - Cell (1,2)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      00101100b
               db      00110100b
               db      00011000b

; Frame 2/4 - Cell (0,0)
               db      00000001b
               db      00001000b
               db      00000011b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00001111b

; Frame 2/4 - Cell (1,0)
               db      00001111b
               db      00001111b
               db      00001111b
               db      01001111b
               db      01111111b
               db      01000011b
               db      00000010b
               db      00000001b

; Frame 2/4 - Cell (0,1)
               db      01000000b
               db      00010000b
               db      11000000b
               db      10000000b
               db      10000100b
               db      10001110b
               db      10001110b
               db      11111111b

; Frame 2/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      01000011b
               db      11000010b
               db      10000001b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      01110000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      11110000b

; Frame 2/4 - Cell (1,2)
               db      11110000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      01000000b
               db      11000000b
               db      10000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00001000b
               db      00001111b
               db      00001000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00101000b
               db      10000100b
               db      01010001b
               db      10000010b
               db      00111100b
               db      00011000b
               db      00011000b
               db      11111111b

; Frame 3/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      00101100b
               db      00110100b
               db      00011000b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000111b
               db      00000100b
               db      00000100b
               db      01000100b
               db      11100100b
               db      11100100b
               db      11111111b

; Frame 3/4 - Cell (1,2)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      00101100b
               db      00110100b
               db      00011000b

; Frame 4/4 - Cell (0,0)
               db      00000001b
               db      00001000b
               db      00000011b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00000001b
               db      00001111b

; Frame 4/4 - Cell (1,0)
               db      00001111b
               db      00001111b
               db      00001111b
               db      01001111b
               db      01111111b
               db      01000011b
               db      00000010b
               db      00000001b

; Frame 4/4 - Cell (0,1)
               db      01000000b
               db      00010000b
               db      11000000b
               db      10000000b
               db      10000100b
               db      10001110b
               db      10001110b
               db      11111111b

; Frame 4/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      01000011b
               db      11000010b
               db      10000001b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      01110000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      01000000b
               db      11110000b

; Frame 4/4 - Cell (1,2)
               db      11110000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      01000000b
               db      11000000b
               db      10000000b


; Hazard 3 - Ray
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000001b
               db      00000011b
               db      00100111b
               db      01111111b
               db      11111001b
               db      11111001b
               db      01111111b
               db      01111111b

; Frame 1/4 - Cell (1,1)
               db      01111111b
               db      00111111b
               db      00111111b
               db      00111111b
               db      00111111b
               db      00011111b
               db      00001111b
               db      00000001b

; Frame 1/4 - Cell (0,2)
               db      10000000b
               db      11000000b
               db      11100100b
               db      11111110b
               db      10011111b
               db      10011111b
               db      11111110b
               db      11111110b

; Frame 1/4 - Cell (1,2)
               db      11111110b
               db      11111100b
               db      11111100b
               db      11111100b
               db      11111100b
               db      11111000b
               db      11110000b
               db      10000000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000110b
               db      00001111b
               db      00111111b
               db      01111111b
               db      11100110b
               db      11100110b
               db      11111111b
               db      11111111b

; Frame 2/4 - Cell (1,1)
               db      11111111b
               db      01111111b
               db      01111111b
               db      01111111b
               db      01111111b
               db      00111111b
               db      00111111b
               db      00011110b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      01110000b
               db      01110000b
               db      11110000b
               db      11110000b

; Frame 2/4 - Cell (1,2)
               db      11100000b
               db      11100000b
               db      11100000b
               db      11100000b
               db      11000000b
               db      11000000b
               db      10000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000011b
               db      00000111b
               db      00001110b
               db      00001110b
               db      00001111b
               db      00000111b
               db      00000111b

; Frame 3/4 - Cell (1,1)
               db      00000011b
               db      00000011b
               db      00000001b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,2)
               db      11000000b
               db      11111000b
               db      11111110b
               db      11011111b
               db      11011110b
               db      11111100b
               db      11111100b
               db      11111000b

; Frame 3/4 - Cell (1,2)
               db      11111000b
               db      11111000b
               db      11111000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      01111000b
               db      00011100b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000110b
               db      00001111b
               db      00111111b
               db      01111111b
               db      11100110b
               db      11100110b
               db      11111111b
               db      11111111b

; Frame 4/4 - Cell (1,1)
               db      11111111b
               db      01111111b
               db      01111111b
               db      01111111b
               db      01111111b
               db      00111111b
               db      00111111b
               db      00011110b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      11000000b
               db      11100000b
               db      01110000b
               db      01110000b
               db      11110000b
               db      11110000b

; Frame 4/4 - Cell (1,2)
               db      11100000b
               db      11100000b
               db      11100000b
               db      11100000b
               db      11000000b
               db      11000000b
               db      10000000b
               db      00000000b


; Hazard 4 - Farmer
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000100b
               db      00000001b

; Frame 1/4 - Cell (1,0)
               db      00000100b
               db      00000001b
               db      00000100b
               db      00000001b
               db      00000100b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000011b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      01000000b
               db      00001111b
               db      01000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000011b

; Frame 1/4 - Cell (0,2)
               db      00111000b
               db      00111000b
               db      01111100b
               db      11111111b
               db      10111100b
               db      11111100b
               db      01001000b
               db      01111000b

; Frame 1/4 - Cell (1,2)
               db      00110000b
               db      11111111b
               db      01111111b
               db      01110001b
               db      01010000b
               db      10001000b
               db      10001000b
               db      00011000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      01000000b
               db      00010000b

; Frame 2/4 - Cell (1,0)
               db      01000100b
               db      00010000b
               db      01000100b
               db      00010000b
               db      01000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000011b
               db      00000011b
               db      00000111b
               db      00111111b
               db      00001011b
               db      00011111b
               db      00001000b
               db      00000111b

; Frame 2/4 - Cell (1,1)
               db      00000011b
               db      11111111b
               db      00000111b
               db      00000111b
               db      00000101b
               db      00000100b
               db      00000100b
               db      00001100b

; Frame 2/4 - Cell (0,2)
               db      10000000b
               db      10000000b
               db      11000000b
               db      11110000b
               db      11000000b
               db      11000000b
               db      10000000b
               db      10000000b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      11110000b
               db      11110000b
               db      00010000b
               db      10000000b
               db      01000000b
               db      00100000b
               db      01000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000011b
               db      00000000b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,1)
               db      00000000b
               db      00001111b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,2)
               db      00111000b
               db      00111000b
               db      01111100b
               db      11111111b
               db      10111100b
               db      11111100b
               db      10001000b
               db      01111000b

; Frame 3/4 - Cell (1,2)
               db      00110000b
               db      11111111b
               db      01111111b
               db      01110001b
               db      00110000b
               db      00011000b
               db      00010000b
               db      00110000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000011b
               db      00000011b
               db      00000111b
               db      00111111b
               db      00001011b
               db      00011111b
               db      00001000b
               db      00000111b

; Frame 4/4 - Cell (1,1)
               db      00000011b
               db      11111111b
               db      00000111b
               db      00000111b
               db      00000100b
               db      00000100b
               db      00011000b
               db      00000000b

; Frame 4/4 - Cell (0,2)
               db      10000000b
               db      10000000b
               db      11000000b
               db      11110000b
               db      11000000b
               db      11000000b
               db      10000000b
               db      10000000b

; Frame 4/4 - Cell (1,2)
               db      00000000b
               db      11110000b
               db      11110000b
               db      00010000b
               db      10000000b
               db      10000000b
               db      01000000b
               db      11000000b


; Hazard 5 - Aeroplane
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000011b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,1)
               db      11111111b
               db      01001001b
               db      11111111b
               db      11111111b
               db      00000011b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000010b
               db      00000110b
               db      00001110b

; Frame 1/4 - Cell (1,2)
               db      11111110b
               db      00100111b
               db      11111111b
               db      11111110b
               db      11000000b
               db      11100000b
               db      11110000b
               db      00110000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00011111b
               db      00110100b

; Frame 2/4 - Cell (1,0)
               db      01111111b
               db      00111111b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11111111b
               db      10010010b

; Frame 2/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      00111100b
               db      00011110b
               db      00001111b
               db      00000011b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00100000b
               db      01100000b
               db      11100000b
               db      11100000b
               db      01110000b

; Frame 2/4 - Cell (1,2)
               db      11110000b
               db      11100000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b
               db      00000111b
               db      00000011b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11111111b
               db      01001001b
               db      11111111b
               db      11111111b

; Frame 3/4 - Cell (1,1)
               db      00000011b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000010b
               db      00000110b
               db      00001110b
               db      11111110b
               db      00100111b
               db      11111111b
               db      11111110b

; Frame 3/4 - Cell (1,2)
               db      11000000b
               db      11100000b
               db      11110000b
               db      00110000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00011111b
               db      00110100b

; Frame 4/4 - Cell (1,0)
               db      01111111b
               db      00111111b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11111111b
               db      10010010b

; Frame 4/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      00111100b
               db      00011110b
               db      00001111b
               db      00000011b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00100000b
               db      01100000b
               db      11100000b
               db      11100000b
               db      01110000b

; Frame 4/4 - Cell (1,2)
               db      11110000b
               db      11100000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b


; Hazard 6 - Bus
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000011b

; Frame 1/4 - Cell (1,0)
               db      00000011b
               db      00000011b
               db      00000011b
               db      00000011b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      01111111b
               db      01001001b
               db      01001001b
               db      01001001b
               db      01111111b
               db      11111111b

; Frame 1/4 - Cell (1,1)
               db      11111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      01000111b
               db      10010011b
               db      10111011b
               db      00010000b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      11111110b
               db      00100010b
               db      00100010b
               db      00100010b
               db      11100010b
               db      11100010b

; Frame 1/4 - Cell (1,2)
               db      11100010b
               db      11100010b
               db      11100010b
               db      11111110b
               db      11100010b
               db      11001001b
               db      11011101b
               db      00001000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000111b
               db      00000100b
               db      00000100b
               db      00000100b
               db      00010111b

; Frame 2/4 - Cell (1,0)
               db      00111111b
               db      00111111b
               db      00111111b
               db      00111111b
               db      00000100b
               db      00001010b
               db      00001001b
               db      00000010b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11111111b
               db      10010010b
               db      10010010b
               db      10010010b
               db      11111110b

; Frame 2/4 - Cell (1,1)
               db      11111110b
               db      11111110b
               db      11111110b
               db      11111111b
               db      01111110b
               db      10111101b
               db      00111100b
               db      10000001b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11100000b
               db      00100000b
               db      00100000b
               db      00100000b
               db      00100000b

; Frame 2/4 - Cell (1,2)
               db      00100000b
               db      00100000b
               db      00100000b
               db      11100000b
               db      00100000b
               db      01010000b
               db      10010000b
               db      01000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000001b
               db      00000011b
               db      00000011b
               db      00000011b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      01111111b
               db      01001001b
               db      01001001b
               db      01001001b

; Frame 3/4 - Cell (1,1)
               db      01111111b
               db      11111111b
               db      11111111b
               db      11111111b
               db      01000111b
               db      10010011b
               db      10111011b
               db      00010000b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11111110b
               db      00100010b
               db      00100010b
               db      00100010b

; Frame 3/4 - Cell (1,2)
               db      11100010b
               db      11100010b
               db      11100010b
               db      11111110b
               db      11100010b
               db      11001001b
               db      11011101b
               db      00001000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000111b
               db      00000100b
               db      00000100b
               db      00000100b
               db      00010111b

; Frame 4/4 - Cell (1,0)
               db      00111111b
               db      00111111b
               db      00111111b
               db      00111111b
               db      00000100b
               db      00001010b
               db      00001001b
               db      00000010b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11111111b
               db      10010010b
               db      10010010b
               db      10010010b
               db      11111110b

; Frame 4/4 - Cell (1,1)
               db      11111110b
               db      11111110b
               db      11111110b
               db      11111111b
               db      01111110b
               db      10111101b
               db      00111100b
               db      10000001b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11100000b
               db      00100000b
               db      00100000b
               db      00100000b
               db      00100000b

; Frame 4/4 - Cell (1,2)
               db      00100000b
               db      00100000b
               db      00100000b
               db      11100000b
               db      00100000b
               db      01010000b
               db      10010000b
               db      01000000b


; Hazard 7 - Dinosaur
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00110000b
               db      01011000b
               db      01111100b
               db      01101100b
               db      00001110b

; Frame 1/4 - Cell (1,1)
               db      00001111b
               db      00011111b
               db      01111111b
               db      10000111b
               db      00000111b
               db      00001111b
               db      00111100b
               db      01111000b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,2)
               db      00000000b
               db      10000000b
               db      10000011b
               db      11000100b
               db      11000100b
               db      11101000b
               db      11111000b
               db      11110000b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000011b
               db      00000101b
               db      00000111b
               db      00000110b
               db      00000000b

; Frame 2/4 - Cell (1,0)
               db      00000000b
               db      00000001b
               db      00000111b
               db      00001000b
               db      00000000b
               db      00000000b
               db      00000011b
               db      00000111b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      11000000b
               db      11100000b

; Frame 2/4 - Cell (1,1)
               db      11110000b
               db      11111000b
               db      11111000b
               db      01111100b
               db      01111100b
               db      11111110b
               db      11001111b
               db      10001111b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00110000b
               db      01000000b
               db      01000000b
               db      10000000b
               db      10000000b
               db      00000000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      11100000b
               db      11010000b
               db      01111000b
               db      00011000b
               db      00011100b

; Frame 3/4 - Cell (1,1)
               db      00011110b
               db      11111111b
               db      00111111b
               db      00001111b
               db      00001111b
               db      00011111b
               db      01111001b
               db      11110010b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      10000011b
               db      11011100b
               db      11110000b
               db      11100000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00001110b
               db      00001101b
               db      00000111b
               db      00000001b
               db      00000001b

; Frame 4/4 - Cell (1,0)
               db      00010001b
               db      00001111b
               db      00000011b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000111b
               db      00001111b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      10000000b
               db      11000000b

; Frame 4/4 - Cell (1,1)
               db      11100000b
               db      11110000b
               db      11110000b
               db      11111000b
               db      11111000b
               db      11111101b
               db      10011111b
               db      00101110b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00110000b
               db      11000000b
               db      00000000b
               db      00000000b


; Hazard 8 - Witch
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000111b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000100b
               db      00001110b
               db      00001110b
               db      00011111b
               db      11111111b
               db      00011111b
               db      00101111b
               db      01111110b

; Frame 1/4 - Cell (1,1)
               db      00011110b
               db      01000100b
               db      00111110b
               db      00001110b
               db      11111111b
               db      00001110b
               db      00000100b
               db      00001100b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11100000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,2)
               db      00000000b
               db      00001111b
               db      00010000b
               db      00100111b
               db      11111100b
               db      00010011b
               db      00001100b
               db      00000011b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00001111b
               db      00000001b
               db      00000010b
               db      00000111b

; Frame 2/4 - Cell (1,0)
               db      00000001b
               db      00000100b
               db      00000011b
               db      00000000b
               db      01111111b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      01000000b
               db      11100000b
               db      11100000b
               db      11110000b
               db      11111110b
               db      11110000b
               db      11110000b
               db      11100000b

; Frame 2/4 - Cell (1,1)
               db      11100000b
               db      01000000b
               db      11100001b
               db      11100010b
               db      11111111b
               db      11100001b
               db      01000000b
               db      11000000b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      11110000b
               db      00000000b
               db      01110000b
               db      11000000b
               db      00110000b
               db      11000000b
               db      00110000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000111b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000100b
               db      00001110b
               db      00001110b
               db      00011111b
               db      11111111b
               db      00011111b
               db      00101111b
               db      01111110b

; Frame 3/4 - Cell (1,1)
               db      00011110b
               db      00000100b
               db      00111110b
               db      01001110b
               db      11111111b
               db      00001110b
               db      00000100b
               db      00001100b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11100000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,2)
               db      00000000b
               db      00001111b
               db      00010000b
               db      00100111b
               db      11111100b
               db      00010011b
               db      00001100b
               db      00000011b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000001b
               db      00001111b
               db      00000001b
               db      00000010b
               db      00000111b

; Frame 4/4 - Cell (1,0)
               db      00000001b
               db      00000000b
               db      00000011b
               db      00000100b
               db      01111111b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      01000000b
               db      11100000b
               db      11100000b
               db      11110000b
               db      11111110b
               db      11110000b
               db      11110000b
               db      11100000b

; Frame 4/4 - Cell (1,1)
               db      11100000b
               db      01000000b
               db      11100001b
               db      11100010b
               db      11111111b
               db      11100001b
               db      01000000b
               db      11000000b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,2)
               db      00000000b
               db      11110000b
               db      00000000b
               db      01110000b
               db      11000000b
               db      00110000b
               db      11000000b
               db      00110000b


; Hazard 9 - Axe
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      00000001b
               db      00000001b
               db      00001111b
               db      01111111b
               db      01111111b
               db      00111111b
               db      00111111b
               db      00011111b

; Frame 1/4 - Cell (1,1)
               db      00011110b
               db      00001100b
               db      00001000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,2)
               db      10000000b
               db      11100000b
               db      11100000b
               db      11100000b
               db      11100000b
               db      11100000b
               db      10110000b
               db      00110000b

; Frame 1/4 - Cell (1,2)
               db      00011000b
               db      00011000b
               db      00001100b
               db      00001100b
               db      00000110b
               db      00000110b
               db      00000011b
               db      00000011b

; Frame 2/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000011b
               db      00000111b

; Frame 2/4 - Cell (1,0)
               db      00001111b
               db      00011111b
               db      00001111b
               db      00000111b
               db      00000011b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      11111000b

; Frame 2/4 - Cell (1,1)
               db      11011100b
               db      11001110b
               db      10000111b
               db      10000011b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      11100000b
               db      01110000b
               db      00110000b

; Frame 3/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000001b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00111110b
               db      00111110b
               db      00011111b
               db      00111111b

; Frame 3/4 - Cell (1,1)
               db      01111100b
               db      11111100b
               db      11111100b
               db      11111000b
               db      11111000b
               db      01111000b
               db      00110000b
               db      00010000b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11000000b

; Frame 3/4 - Cell (1,2)
               db      11110000b
               db      00111100b
               db      00001111b
               db      00000011b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000011b
               db      00000111b

; Frame 4/4 - Cell (1,0)
               db      00001111b
               db      00011111b
               db      00001111b
               db      00000111b
               db      00000011b
               db      00000001b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      11110000b
               db      11110000b
               db      11110000b
               db      11111000b

; Frame 4/4 - Cell (1,1)
               db      11011100b
               db      11001110b
               db      10000111b
               db      10000011b
               db      00000001b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      10000000b
               db      11000000b
               db      11100000b
               db      01110000b
               db      00110000b


; Hazard 10 - Snake
; 2x3 cell sprite / 4 frames in animation

; Frame 1/4 - Cell (0,0)
               db      00000001b
               db      00000010b
               db      00000011b
               db      00000100b
               db      00001000b
               db      01110000b
               db      00010000b
               db      00010000b

; Frame 1/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (0,1)
               db      10000000b
               db      11000000b
               db      11000000b
               db      01100000b
               db      01100000b
               db      01100000b
               db      01100000b
               db      01100000b

; Frame 1/4 - Cell (1,1)
               db      01100001b
               db      01100011b
               db      01100011b
               db      01100110b
               db      01100110b
               db      01111100b
               db      00111100b
               db      00011000b

; Frame 1/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 1/4 - Cell (1,2)
               db      10000001b
               db      11000011b
               db      11000011b
               db      01100110b
               db      01100110b
               db      00111100b
               db      00111100b
               db      00011000b

; Frame 2/4 - Cell (0,0)
               db      00110000b
               db      01011000b
               db      01111000b
               db      10001100b
               db      00001100b
               db      00001100b
               db      00001100b
               db      00001100b

; Frame 2/4 - Cell (1,0)
               db      00001101b
               db      00001111b
               db      00001111b
               db      00001110b
               db      00001110b
               db      00000100b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,1)
               db      10000001b
               db      11000011b
               db      11000011b
               db      01100110b
               db      01100110b
               db      00111100b
               db      00111100b
               db      00011000b

; Frame 2/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 2/4 - Cell (1,2)
               db      10000000b
               db      11000000b
               db      11000000b
               db      01100000b
               db      01100000b
               db      00110000b
               db      00110000b
               db      00011000b

; Frame 3/4 - Cell (0,0)
               db      00000001b
               db      00000010b
               db      00000011b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,0)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (0,1)
               db      10000000b
               db      11000000b
               db      11000000b
               db      01100000b
               db      01100000b
               db      01100000b
               db      01100000b
               db      01100000b

; Frame 3/4 - Cell (1,1)
               db      01100001b
               db      01100011b
               db      01100011b
               db      01100110b
               db      01100110b
               db      01111100b
               db      00111100b
               db      00011000b

; Frame 3/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 3/4 - Cell (1,2)
               db      10000001b
               db      11000011b
               db      11000011b
               db      01100110b
               db      01100110b
               db      00111100b
               db      00111100b
               db      00011000b

; Frame 4/4 - Cell (0,0)
               db      00110000b
               db      01011000b
               db      01111000b
               db      10001100b
               db      00001100b
               db      00001100b
               db      00001100b
               db      00001100b

; Frame 4/4 - Cell (1,0)
               db      00001101b
               db      00001111b
               db      00001111b
               db      00001110b
               db      00001110b
               db      00000100b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (0,1)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,1)
               db      10000001b
               db      11000011b
               db      11000011b
               db      01100110b
               db      01100110b
               db      00111100b
               db      00111100b
               db      00011000b

; Frame 4/4 - Cell (0,2)
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b
               db      00000000b

; Frame 4/4 - Cell (1,2)
               db      10000000b
               db      11000000b
               db      11000000b
               db      01100000b
               db      01100000b
               db      00110000b
               db      00110000b
               db      00011000b




LifeSym:       ; Lives Remaining symbol GFX

               db      00011000b
               db      00111100b
               db      00111100b
               db      00011000b
               db      01111110b
               db      00011000b
               db      00100100b
               db      01000010b




; VARIABLES
;
; All variables are addressed as an offset from IX which is loaded with VarsIX
; at program startup.

               db      0           ; IX-0ch  -  Result of keypress
                                   ;
                                   ; 03 = Jump (CAPS SHIFT)
                                   ; 02 = Right (SPACE)
                                   ; 01 = Left (SYM SHIFT)
                                   ; 00 = Nothing


               db      0a3h        ; IX-0bh  -  Random number
                                   ;
                                   ; Initialised from FRAMES at program startup
                                   ; and randomly updated every frame by
                                   ; FrmDelay.
                                   ;
                                   ; Used to randomize starting Hazard in each
                                   ; level and to randomize position of new gaps


               db      0           ; IX-0ah  -  SFX/GFX Frame
                                   ;
                                   ; Frame counter for the current SFX/GFX
                                   ; routine


               db      0           ; IX-09h  -  Last SFX/GFX Routine
                                   ;
                                   ; Stores a copy of IX-08h from the last call
                                   ; to SfxGfx. If the 2 values are different
                                   ; on the next call to SfxGfx, then a new
                                   ; routine must have been launched and the
                                   ; procedure knows to reset the SFX/GFX frame
                                   ; counter in IX-0ah


               db      0           ; IX-08h  -  Current SFX/GFX Routine
                                   ;
                                   ; 00 = Standing Still
                                   ; 01 = Running
                                   ; 02 = Hit by Hazard
                                   ; 03 = Good Jump
                                   ; 04 = Falling
                                   ; 05 = Bad Jump
                                   ; 06 = Stunned


               db      0           ; IX-07h  -  Right Gap Tracker
                                   ;
                                   ; Used by AddGap to ensure a new right/down
                                   ; gap doesn't overlap with an existing gap.
                                   ;
                                   ; From 0 at the start of a level, it is
                                   ; incremented every time a right gap moves
                                   ; one cell.


               db      0           ; IX-06h  -  Hazards Draw/Erase flag
                                   ;
                                   ; Bit 0 -->  0 = Erase
                                   ;            1 = Draw
                                   ;
                                   ; Toggled with every call to DrawHzds.


               db      0           ; IX-05h  -  Lost Life flag
                                   ;
                                   ; 1 = Yes, life already lost
                                   ; 0 = No
                                   ;
                                   ; Used when Jack is Stunned at the bottom of
                                   ; the screen to keep track of whether Jack
                                   ; has already lost a life for this incident.


               dw      0           ; IX-04h  -  Score


               db      0           ; IX-02h  -  New Gaps counter
                                   ;
                                   ; Number of gaps (0-6) added so far this
                                   ; level due to good jumps. Each level starts
                                   ; with 2 visible gaps, so after 6 new ones
                                   ; there will be the maximum of 8.


               db      0           ; IX-01h  -  Hazard Collision flag
                                   ;
                                   ; 1 = Collision detected
                                   ; 0 = No collision
                                   ;
                                   ; Used by CollDetn - stores the result of the
                                   ; last collision check.


VarsIX:                            ; VARIABLES INDEX MARKER


                                   ; IX+00h --> IX+07h  -  Gap Positions
                                   ;
                                   ; Each byte describes one of the 8 gaps'
                                   ; positions:
                                   ;
                                   ; Bits (7,6,5) = Jline (0-7)
                                   ; Bits (4,3,2,1,0) = Horizontal position
                                   ; (0-31) of gap's internal 'Cell 1' (see
                                   ; DrawGaps comments)

               db      0           ; IX+00h  These 4 gaps travel Right & Down
               db      0           ; IX+01h
               db      0           ; IX+02h
               db      0           ; IX+03h

               db      0           ; IX+04h  These 4 gaps travel Left & Up
               db      0           ; IX+05h
               db      0           ; IX+06h
               db      0           ; IX+07h


               db      0           ; IX+08h  -  Jack's Animation (Next frame)
                                   ;
                                   ; 00 = Standing Still
                                   ; 03 = Running Left
                                   ; 06 = Running Right
                                   ; 09 = Good Jump Pt1
                                   ; 12 = Falling Pt1
                                   ; 15 = Good Jump Pt2
                                   ; 18 = Falling Pt2
                                   ; 21 = Bad Jump
                                   ; 24 = Stunned
                                   ;
                                   ; Used as a relative jump offset in (and
                                   ; updated by) UpdateGame.


               db      0eah        ; IX+09h  -  Jack's Position (Next frame)
                                   ;
                                   ; Stores (V)ertical & (H)orizontal position:
                                   ;
                                   ; BIT       7 6 5 4 3 2 1 0
                                   ;           V V V H H H H H
                                   ;
                                   ; Bits (7,6,5) = Jline (0-7) immediately
                                   ; above Jack
                                   ; Bits (4,3,2,1,0) = Screen column (0-30) of
                                   ; Jack's left-most* sprite cells.
                                   ;
                                   ; *NB: When Jack is in a GFXJLeft animation
                                   ; (2x3 cell sprite) this indicates the middle
                                   ; column of Jack's cells.


               db      0           ; IX+0ah - Stunned Timer
                                   ;
                                   ; Used by UpdateGame to manage how long Jack
                                   ; is Stunned
                                   ;
                                   ; Decrements every 4 frames Jack is Stunned
                                   ; Increments by 16 when Jack hits Hazard
                                   ; Increments by 8 when Jack falls through gap
                                   ; Set to 24 after a Bad Jump
                                   ; Set to 24 after losing a life


               db      0           ; IX+0bh  -  Game Progress
                                   ;
                                   ; 00 = Game in progress
                                   ; 01 = Level Completed
                                   ; 02 = Game Over (No lives remaining)
                                   ;
                                   ; Set by UpdateGame and tested by GameLoop


               db      6           ; IX+0ch  -  Lives remaining
                                   ;
                                   ; Decremented by UpdateGame when Jack falls
                                   ; through gap in JLine 7
                                   ; Incremented at the start of levels 6, 11 &
                                   ; 16 by CpLvCont.


               db      0           ; IX+0dh  -  Animation Frame (Next frame)
                                   ;
                                   ; BITS       USED BY
                                   ; 6&5        Jack Standing Still (0-3)
                                   ;
                                   ; 1&0        All other Jack animations (0-3)
                                   ;            Gap animation (0-3)
                                   ;
                                   ; Incremented every frame by GameLoop (so
                                   ; bits 6&5 change every 32 frames)


               db      0           ; IX+0eh  -  Level / No. of Hazards in play
                                   ;
                                   ; There are 21 levels (0-20) with that
                                   ; number of Hazards in each


               db      00h         ; IX+0fh --> IX+22h  -  Hazard Positions x20
               db      58h
               db      11h         ; Each position byte stores (V)ertical &
               db      21h         ; (H)orizontal position:
               db      82h
               db      0b3h        ; BIT       7 6 5 4 3 2 1 0
               db      0dh         ;           V V V H H H H H
               db      88h         ;
               db      0c8h        ; Bits (7,6,5) = Jline (0-7) immediately
               db      45h         ; above Hazard
               db      27h         ; Bits (4,3,2,1,0) = Screen column (0-31) of
               db      4ah         ; Hazard's middle sprite column
               db      39h
               db      63h
               db      72h
               db      79h
               db      0a7h
               db      0b8h
               db      9ah
               db      0dch


               db      0           ; IX+23h  -  Score digit 1 (most sig)
               db      0           ; IX+24h  -  Score digit 2
               db      0           ; IX+25h  -  Score digit 3
               db      0           ; IX+26h  -  Score digit 4
               db      0           ; IX+27h  -  Score digit 5 (least sig)


               db      0           ; IX+28h  -  High Score digit 1 (most sig)
               db      0           ; IX+29h  -  High Score digit 2
               db      0           ; IX+2ah  -  High Score digit 3
               db      0           ; IX+2bh  -  High Score digit 4
               db      0           ; IX+2ch  -  High Score digit 5 (least sig)


               db      0           ; IX+2dh  -  Jack's Animation (Current frame)
                                   ;
                                   ; 00 = Standing Still
                                   ; 03 = Running Left
                                   ; 06 = Running Right
                                   ; 09 = Good Jump Pt1
                                   ; 12 = Falling Pt1
                                   ; 15 = Good Jump Pt2
                                   ; 18 = Falling Pt2
                                   ; 21 = Bad Jump
                                   ; 24 = Stunned
                                   ;
                                   ; Used as a relative jmp offset in DrawJack


               db      0           ; IX+2eh  -  Jack's Position (Current frame)
                                   ;
                                   ; Stores (V)ertical & (H)orizontal positions:
                                   ;
                                   ; BIT       7 6 5 4 3 2 1 0
                                   ;           V V V H H H H H
                                   ;
                                   ; Bits (7,6,5) = Jline (0-7) immediately
                                   ; above Jack
                                   ; Bits (4,3,2,1,0) = Screen column (0-30) of
                                   ; Jack's left-most* sprite cells.
                                   ;
                                   ; *NB: When Jack is in a GFXJLeft animation
                                   ; (2x3 cell sprite) this indicates the middle
                                   ; column of Jack's cells.


               db      0           ; IX+2fh  -  Animation Frame (Current frame)
                                   ;
                                   ; BITS       USED BY
                                   ; 6&5        Jack Standing Still (0-3)
                                   ;
                                   ; 1&0        All other Jack animations (0-3)
                                   ;
                                   ; When all bits apart from 6&5 are zero,
                                   ; the value of this byte (0, 32, 64, 96) will
                                   ; be an offset into the GFX data for the
                                   ; GFXJStil animation


               dw      0           ; IX+30h  -  High Score


               db      0           ; IX+32h  -  Jack Draw/Erase flag
                                   ;
                                   ; Bit 0 -->  0 = Erase
                                   ;            1 = Draw
                                   ;
                                   ; Toggled with every call to DrawJack


               db      0           ; IX+33h  -  Hazards Current Frame
                                   ;
                                   ; Bits 2&1 = Current GFX frame (0-3) to be
                                   ; drawn/erased for each Hazard (used by
                                   ; DrawHzds).
                                   ;
                                   ; Loaded with IX+0dh (Animation Frame - Next)
                                   ; every other frame in GameLoop


               db      0           ; IX+34h  -  Left Gap Tracker
                                   ;
                                   ; Used by AddGap to ensure a new left/up gap
                                   ; doesn't overlap with an existing gap.
                                   ;
                                   ; From 0 at the start of a level, it is
                                   ; decremented every time a left gap moves one
                                   ; cell.


               db      0           ; IX+35h  -  Length of delay in PrtDelay
                                   ;
                                   ; Determines the speed that characters are
                                   ; printed by PrtEText. Used in the Completed
                                   ; Level and Game Over screens.


                                   ; Gap Cell Bitmaps (Used by DrawGaps)
               db      0           ; IX+36h  -  Gap Cell 1 Bitmap (Right-moving)
               db      0           ; IX+37h  -  Gap Cell 3 Bitmap (Left-moving)
               db      0           ; IX+38h  -  Gap Cell 4 Bitmap (Right-moving)
               db      0           ; IX+39h  -  Gap Cell 0 Bitmap (Left-moving)




Rhyme3:        ; 'Once found a peculiar track...'
               db      3ah, 13h, 08h, 4ah, 0bh, 14h, 1ah, 13h, 49h, 46h, 15h
               db      0ah, 08h, 1ah, 11h, 0eh, 06h, 57h, 19h, 17h, 06h, 08h
               db      90h




;-------------------------------------------------------------------------------
RndGaps:       ; Initialises all 8 gaps to begin from the same random place
;-------------------------------------------------------------------------------
; ENTRY
; IX = Address of Gap position data (8 bytes)

               ld      a,(ix-0bh)  ; Use random number as gap position
               and     0fch        ; Zero low 2 bits so horizontal position
                                   ; is 0,4,8,12,16,20,24 or 28.
               push    ix
               pop     hl          ; HL points to Gap position bytes
               ld      b,08h       ; 8 bytes to initialise

L001:          ld      (hl),a      ; Store random position
               inc     hl          ; Point to next gap position byte
               djnz    L001        ; Initialise all 8 gaps
               ret




Rhyme4:        ; 'There were dangers galore...'
               db      3fh, 0dh, 0ah, 17h, 4ah, 1ch, 0ah, 17h, 4ah, 09h, 06h
               db      13h, 0ch, 0ah, 17h, 58h, 0ch, 06h, 11h, 14h, 17h, 8ah




;-------------------------------------------------------------------------------
InitScreen:    ; Clears the screen and sets the desired attributes
;-------------------------------------------------------------------------------
               ld      a,07h
               out     (0feh),a    ; Set the border to white

               ld      a,00111000b ; A=Attributes (Paper White, Ink Black)
               call    ClrScreen
               ret




Rhyme5:        ; 'Even holes in the floor...'
               db      30h, 1bh, 0ah, 53h, 0dh, 14h, 11h, 0ah, 58h, 0eh, 53h
               db      19h, 0dh, 4ah, 0bh, 11h, 14h, 14h, 97h




;-------------------------------------------------------------------------------
ClrScreen:     ; Clears the Display and fills Attributes
;-------------------------------------------------------------------------------
; ENTRY
; A = Desired Attributes

               ; Clear display memory

               ld      hl,4000h    ; HL points to screen memory
               ld      bc,17ffh    ; Set counter to size of screen memory
               ld      de,4001h    ; DE points to second byte of screen memory
               ld      (hl),00h    ; Zero first byte of screen memory
               ldir                ; Zero screen memory

               ; Set attributes

               ld      hl,5800h    ; HL points to display attributes
               ld      bc,02ffh    ; Set counter to size of attributes
               ld      de,5801h    ; DE points to second byte of attributes
               ld      (hl),a      ; Set first byte of attributes
               ldir                ; Fill display attributes
               ret




Rhyme6:        ; 'So he kept falling flat on'
               ; 'his back...'
               db      3eh, 54h, 0dh, 4ah, 10h, 0ah, 15h, 59h, 0bh, 06h, 11h
               db      11h, 0eh, 13h, 4ch, 0bh, 11h, 06h, 59h, 14h, 0d3h, 0dh
               db      0eh, 58h, 07h, 06h, 08h, 90h




;-------------------------------------------------------------------------------
InfoAtts:      ; Sets the InfoLine attributes so ink is magenta
;-------------------------------------------------------------------------------
               ld      hl,5ac0h    ; HL points to attributes for (22,0)
               ld      b,20h       ; 32 cells in a line
               ld      a,00111011b ; A=Attributes (Paper White, Ink Magenta)

L002:          ld      (hl),a      ; Apply attributes
               inc     hl          ; Point to next cell in line
               djnz    L002        ; Fill attributes for rest of line
               ret




Rhyme7:        ; 'Quite soon he got used to'
               ; 'the place...'
               db      3ch, 1ah, 0eh, 19h, 4ah, 18h, 14h, 14h, 53h, 0dh, 4ah
               db      0ch, 14h, 59h, 1ah, 18h, 0ah, 49h, 19h, 0d4h, 19h, 0dh
               db      4ah, 15h, 11h, 06h, 08h, 8ah




;-------------------------------------------------------------------------------
DrawScreen:    ; Draws all the screen elements for a new game
;-------------------------------------------------------------------------------
               call    InfoAtts    ; Set InfoLine ink to magenta
               call    DrawJlines  ; Draw all 8 Jlines
               call    JlineAtts   ; Make the Jlines red
               call    CvtHiBCD    ; Convert High Score to BCD
               call    PrtHigh     ; Print High Score digits
               call    PrtInfoTxt  ; Print 'HI' & 'SC' on InfoLine
               call    CvtScBCD    ; Convert Score to BCD
               call    PrtScore    ; Print Score digits
               call    PrtLives    ; Print 'Lives Remaining' symbols
               call    UpdJkFrm    ; Copy Jack's Next Frame to Current
               call    DrawJack    ; Draw Jack
               ret




;-------------------------------------------------------------------------------
RndHazds:      ; Randomize the starting Hazard
;-------------------------------------------------------------------------------
; The order in which the Hazards appear in consecutive levels is based on the
; order that their GFX data appears in memory. This rotates the Hazards GFX data
; a random number (1-8) times so the starting Hazard is different each game.

               ld      a,(ix-0bh)  ; A=Random number
               and     07h         ; Zero top 5 bits to make it a number
               ld      b,a         ; between 0-7, and put it in B
               inc     b           ; Make it a number between 1-8.

L003:          call    RotHzrds    ; Rotate Hazards GFX data B times.
               djnz    L003
               ret




;-------------------------------------------------------------------------------
Start:         ; ENTRY POINT
;-------------------------------------------------------------------------------
               ; Program initialisation / Setup stack, variables index and random
               ; number

               di
               ld      sp,5c00h    ; Move stack to the 16K/48K printer buffer
               ld      ix,VarsIX   ; Point IX to game variables
               ld      a,(FRAMES)  ; Store least sig. byte of FRAMES system
                                   ; variable (3 byte counter incremented every
                                   ; 20ms) for use as a random number in later
               ld      (ix-0bh),a  ; routines

               ; Setup for new game

               call    RndGaps     ; Randomize start position of gaps

               call    InitScreen  ; Clear screen & set attributes
               call    DrawScreen  ; Draw all the screen elements

               call    RndHazds    ; Randomize the starting Hazard
               call    DrawHzds    ; No Hazards to actually draw for first level
                                   ; this just toggles draw/erase flag




;-------------------------------------------------------------------------------
GameLoop:      ; Main Game Loop
;-------------------------------------------------------------------------------
; The game loop works on a 4 frame cycle since all elements of the game (Gaps,
; Hazards, Jack) are always in a particular 4-frame animation. (NB: Hazards are
; only drawn every other frame, so actually take 2 game loops to complete their
; animation).
;
; User input is only processed on every 4th frame to determine which animations
; to play for the following 4 frames.  In the interim frames, none of the sprite
; elements actually 'move' - their animations merely give the illusion of
; movement.

               ; FRAME 1/4
               ; In Frame 1, the current SfxGfx is played (which also regulates
               ; the game speed), Jack is erased and redrawn (if required) and
               ; the gaps are drawn.

               call    SfxGfx      ; Play SFX/GFX for current animation

               inc     (ix+0dh)    ; Increment Animation Frame (Next Frame)
               call    TstJkDrw    ; Does Jack need redrawing this frame
               jr      z,L004      ; Skip erase/draw sequence if not

               call    DrawJack    ; Erase Jack
               call    UpdJkFrm    ; Copy Jack's Next Frame to Current
               call    DrawJack    ; Draw Jack

L004:          call    DrawGaps    ; Draw Gaps

               ; FRAME 2/4
               ; In Frame 2, all the same elements of Frame 1 are repeated, but
               ; this time the Hazards are also erased and redrawn.

               call    SfxGfx      ; Play SFX/GFX for current animation

               inc     (ix+0dh)    ; Increment Animation Frame (Next Frame)
               call    TstJkDrw    ; Does Jack need redrawing this frame
               jr      z,L005      ; Skip erase/draw sequence if not

               call    DrawJack    ; Erase Jack
               call    UpdJkFrm    ; Copy Jack's Next Frame to Current
               call    DrawJack    ; Draw Jack

L005:          call    DrawGaps    ; Draw Gaps

               call    DrawHzds    ; Erase Hazards
               ld      a,(ix+0dh)
               ld      (ix+33h),a  ; Copy Hazards' Next Anim Frame to Current
               call    DrawHzds    ; Draw Hazards

               ; FRAME 3/4
               ; Frame 3 is the same as Frame 1.

               call    SfxGfx      ; Play SFX/GFX for current animation

               inc     (ix+0dh)    ; Increment Animation Frame (Next Frame)
               call    TstJkDrw    ; Does Jack need redrawing this frame
               jr      z,L006      ; Skip erase/draw sequence if not

               call    DrawJack    ; Erase Jack
               call    UpdJkFrm    ; Copy Jack's Next Frame to Current
               call    DrawJack    ; Draw Jack

L006:          call    DrawGaps    ; Draw Gaps

               ; FRAME 4/4
               ; All the game logic and subsequent movements of Jack, Gaps and
               ; Hazards are performed in Frame 4.  This is also where the game
               ; loop can end if the player has lost the game or completed a
               ; level.

               call    SfxGfx      ; Play SFX/GFX for current animation
               inc     (ix+0dh)    ; Increment Animation Frame (Next Frame)

               call    GetInput    ; Read player's keypress
               call    UpdateGame  ; Process input, move Jack, move Gaps
               ld      (ix-0ch),0  ; Reset Keyboard Input to 'Nothing'

               call    DrawGaps    ; Draw Gaps

               call    DrawHzds    ; Erase Hazards
               ld      a,(ix+0dh)
               ld      (ix+33h),a  ; Copy Hazards' Next Anim Frame to Current
               call    UpdHazds    ; Move all the Hazards
               call    DrawHzds    ; Draw Hazards

               ; Has level been completed or game lost?

               ld      a,(ix+0bh)  ; A=Game Progress
               and     a           ; Is it 0? (i.e. game still in progress)
               jr      z,GLFm4Cont ; If so, continue Frame 4/4

               dec     a           ; Game is no longer in progress - initiate..
               jr      z,GLLevlWon ; ..completed level sequence
               call    GameLost    ; ..or Final SFX & Game Over Screen


GLNewGame:     ; Setup for new game

               call    RndGaps     ; Randomize start position of gaps
               call    InitScreen  ; Clear screen & set attributes
               call    RstLvDat    ; Resets variables for a new level
               call    RstGmDat    ; Reset variables for new game
               call    DrawScreen  ; Draw all the screen elements
               call    RndHazds    ; Randomize the starting monster
               call    DrawHzds    ; No Hazards to actually draw for first level
                                   ; this just toggles draw/erase flag
               jp      GameLoop


GLFm4Cont:     ; FRAME 4/4 (continued)

               call    TstJkDrw    ; Does Jack need redrawing this frame
               jr      z,L007      ; Skip erase/draw sequence if not

               call    DrawJack    ; Erase Jack
               call    UpdJkFrm    ; Copy Jack's Next Frame to Current
               call    DrawJack    ; Draw Jack

L007:          jp      GameLoop    ; Start again from Frame 1


GLLevlWon:     ; Level completed

               call    LevlDone    ; Play SFX and show Completed Level screen
                                   ; This returns with C flag set if there are
                                   ; more levels to play
               jr      c,GLNewLevl ; Setup for next level unless player has just
                                   ; completed the game

               ; Player has completed all levels. Show a Game Over screen with
               ; final score.

               dec     (ix+0eh)    ; Reset Level/Hazards counter to 20
               call    GameOver    ; Show Game Over screen, score etc.
               jr      GLNewGame   ; Setup for new game


GLNewLevl:     ; Setup for next level

               call    InitScreen  ; Clear screen & set attributes
               call    RstLvDat    ; Resets variables for a new level
               call    RndGaps     ; Randomize start position of gaps
               call    DrawScreen  ; Draw all the screen elements
               call    DrawHzds
               jp      GameLoop




Rhyme8:        ; 'He could jump to escape from'
               ; 'the chase...'
               db      33h, 4ah, 08h, 14h, 1ah, 11h, 49h, 0fh, 1ah, 12h, 55h
               db      19h, 54h, 0ah, 18h, 08h, 06h, 15h, 4ah, 0bh, 17h, 14h
               db      0d2h, 19h, 0dh, 4ah, 08h, 0dh, 06h, 18h, 8ah




;-------------------------------------------------------------------------------
RstLvDat:      ; Resets various variables for a new level
;-------------------------------------------------------------------------------
               ld      (ix-0ch),0  ; Reset Keyboard Input to 'Nothing'
               ld      (ix-08h),0  ; Reset GFX/SFX to Standing Still
               ld      (ix-07h),0  ; Reset Right Gap Tracker
               ld      (ix-06h),0  ; Reset Hazards Draw/Erase flag to Erase
               ld      (ix-02h),0  ; Reset New Gaps counter
               ld      (ix+08h),0  ; Set Jack's animation to Standing Still
               ld      (ix+9),0eah ; Move Jack to starting position
               ld      (ix+0bh),0  ; Reset Game Progress byte to 'In Progress'
               ld      (ix+0dh),0  ; Reset Animation Frame
               ld      (ix+32h),0  ; Reset Jack's Draw/Erase flag to Erase
               ld      (ix+33h),0  ; Reset Hazards current frame
               ld      (ix+34h),0  ; Reset Left Gap Tracker
               ret




;-------------------------------------------------------------------------------
RstGmDat:      ; Resets Score, Level, Stunned and Lives counters for a new game
;-------------------------------------------------------------------------------
               ld      (ix-04h),0  ; Reset Score to zero (Low byte)
               ld      (ix-03h),0  ; Reset Score to zero (High byte)
               ld      (ix+0ah),0  ; Reset Stunned Timer
               ld      (ix+0ch),6  ; Reset Remaining Lives to 6
               ld      (ix+0eh),0  ; Reset Level/Hazards to 0
               ret




Rhyme9:        ; 'But without careful thought...'
               db      2dh, 1ah, 59h, 1ch, 0eh, 19h, 0dh, 14h, 1ah, 59h, 08h
               db      06h, 17h, 0ah, 0bh, 1ah, 51h, 19h, 0dh, 14h, 1ah, 0ch
               db      0dh, 99h




;-------------------------------------------------------------------------------
UpdtGaps:      ; Update Gap positions
;-------------------------------------------------------------------------------
; This updates the position bytes of all 8 Gaps.
; It is called every 4 frames. In the intermediate frames, the animations
; managed by DrawGaps give the illusion of movement even while the gap positions
; remain unchanged.

               ; Update Right Gap Tracker (used By AddGap)

               inc     (ix-07h)

               ; Move the right/down gaps one cell right

               inc     (ix+00h)
               inc     (ix+01h)
               inc     (ix+02h)
               inc     (ix+03h)

               ; Update Left Gap Tracker (used by AddGap)

               dec     (ix+34h)

               ; Move the left/up gaps one cell left

               dec     (ix+04h)
               dec     (ix+05h)
               dec     (ix+06h)
               dec     (ix+07h)
               ret




Rhyme10:       ; 'His leaps came to nought...'
               db      33h, 0eh, 58h, 11h, 0ah, 06h, 15h, 58h, 08h, 06h, 12h
               db      4ah, 19h, 54h, 13h, 14h, 1ah, 0ch, 0dh, 99h




;-------------------------------------------------------------------------------
DrawGaps:      ; Draws the gaps in the JLines
;-------------------------------------------------------------------------------
; This works on a 4 frame cycle.
;
; A gap is made by blanking a section in a JLine (a JLine is made by filling the
; top 2 pixel rows in a screen line of cells).
;
; Each gap is 3 cells (24 pixels) wide, but the routine modifies 5 cells for
; each gap. E.g.
;
;         Cell 0   Cell 1   Cell 2   Cell 3   Cell 4
;        :::::::: -------- -------- -------- ::::::::
;
; Above is the situation every Frame 0 (gap falls perfectly within cells 1-3)
; However, in Frame 1 for a right-moving gap, we'd have:
;
;         Cell 0   Cell 1   Cell 2   Cell 3   Cell 4
;        :::::::: ::------ -------- -------- --::::::
;
; Or for a left-moving gap, Frame 1 would be:
;
;         Cell 0   Cell 1   Cell 2   Cell 3   Cell 4
;        ::::::-- -------- -------- ------:: ::::::::
;
; i.e to simulate the gap moving, cells 0,1,3&4 are altered until the gap has
; 'moved' by a whole cell. Then the gap position byte is updated, and the
; animation begins again.
;
; Gaps move 2 pixels per frame.
;
; There are a maximum of 8 gaps at any time. The 'cell 1' positions of each gap
; are stored in the bytes at IX+0 - IX+7.
;
; The 4 gaps IX+0 - IX+3 move Right & Downwards
; The 4 gaps IX+4 - IX+7 move Left & Upwards
;
; NB: Due to the format of the gap position bytes, this routine will
; automatically handle the drawing of gaps which are halfway off the edge of
; the screen (even those travelling between Jlines 0 & 7).
;
; NB: All 8 gaps are always drawn. At the start of a level, there are less than
; 8 'visible' as all the gaps are initialised to the same position meaning some
; gaps are drawn over each other. The process of 'adding a new gap' after a
; successful jump is actually just moving a gap to make it visible.

               ; First we use the lowest 2 bits of the Animation Frame variable
               ; to determine which frame we're in.

               ld      a,(ix+0dh)  ; Get animation frame
               and     03h         ; Isolate bits 1&0 / A = 0, 1, 2 or 3
               rlca
               rlca                ; Mult by 4 / A is now either 0, 4, 8 or 12
               ld      (L008+1),a  ; Use it as a jump offset
L008:          jr      L008
               jp      GapsF0      ; +0 (Frame 0)
               nop
               jp      GapsF1      ; +4 (Frame 1)
               nop
               jp      GapsF2      ; +8 (Frame 2)
               nop
               jp      GapsF3      ; +12 (Frame 3)

GapsF0:        ; Gaps Sequence - Frame 0

               ; This is the simplest case where the gaps fall perfectly within
               ; cells 1-3.
               ; First, draw cells 0 & 4 for each gap

               ld      bc,08ffh    ; B= Counter (Number of gaps to draw)
                                   ; C= Pixel bitmap for cells 0&4
L009:          ld      a,b
               dec     a
               ld      (L010+2),a
L010:          ld      a,(ix+00h)  ; A= Position byte for next gap to be drawn
               push    af          ; Save copy of position
               dec     a           ; A= Adjusted position to target cell 0
               call    DrawGpCl    ; Draw cell 0
               pop     af          ; Retrieve copy of position byte
               add     a,03h       ; A= Adjusted position to target cell 4
               call    DrawGpCl    ; Draw cell 4
               djnz    L009        ; Do this for all 8 gaps

               ; Cells 0&4 are drawn for each gap, now draw the 'gaps'
               ; themselves in cells 1-3.

               ; By drawing the 'gap' cells 1-3 after the edge cells 0&4, it
               ; means that even if two gaps are crossing over one another, it
               ; will still look fine.

               ld      bc,0800h    ; B= Counter (Number of gaps to draw)
                                   ; C= Pixel bitmap for cells 1,2,3
L011:          ld      a,b
               dec     a
               ld      (L012+2),a
L012:          ld      a,(ix+00h)  ; A= Position byte for next gap to be drawn
               push    af          ; Save copy of position
               call    DrawGpCl    ; Draw cell 1
               pop     af          ; Retrieve copy of position byte
               inc     a           ; A= Adjusted position to target cell 2
               push    af          ; Save copy of position
               call    DrawGpCl    ; Draw cell 2
               pop     af          ; Retrieve copy of position byte
               inc     a           ; A= Adjusted position to target cell 3
               call    DrawGpCl    ; Draw cell 3
               djnz    L011        ; Do this for all 8 gaps
               ret                 ; Frame 0 complete

GapsF1:        ; Gaps Sequence - Frame 1

               ; Get bitmap data for Gap Cells

               ld      (ix+36h),11000000b      ; Cell 1 (Right-moving gaps)
               ld      (ix+37h),00000011b      ; Cell 3 (Left-moving gaps)
               ld      (ix+38h),00111111b      ; Cell 4 (Right-moving gaps)
               ld      (ix+39h),11111100b      ; Cell 0 (Left-moving gaps)
               jr      GapsF123

GapsF2:        ; Gaps Sequence - Frame 2

               ; Get bitmap data for Gap Cells

               ld      (ix+36h),11110000b      ; Cell 1 (Right-moving gaps)
               ld      (ix+37h),00001111b      ; Cell 3 (Left-moving gaps)
               ld      (ix+38h),00001111b      ; Cell 4 (Right-moving gaps)
               ld      (ix+39h),11110000b      ; Cell 0 (Left-moving gaps)
               jr      GapsF123

GapsF3:        ; Gaps Sequence - Frame 3

               ; Get bitmap data for Gap Cells

               ld      (ix+36h),11111100b      ; Cell 1 (Right-moving gaps)
               ld      (ix+37h),00111111b      ; Cell 3 (Left-moving gaps)
               ld      (ix+38h),00000011b      ; Cell 4 (Right-moving gaps)
               ld      (ix+39h),11000000b      ; Cell 0 (Left-moving gaps)

GapsF123:      ; Apart from the different pixel bitmaps above, the procedure
               ; for Frames 1-3 is the same. However, because of the possibility
               ; of gaps crossing over one another, it's more complicated than
               ; Frame 0.

               ; Draw Cell 1 in gaps 0-3 (the Right/Down gaps)

               ld      b,04h       ; 4 gaps to draw
               ld      c,(ix+36h)  ; Get pixel bitmap for this cell

L013:          ld      a,b
               dec     a           ; Start with Gap 3 and work down
               ld      (L014+2),a
L014:          ld      a,(ix+04h)  ; A= Position byte for next gap to be drawn
               call    DrawGpCl    ; Draw Cell 1
               djnz    L013        ; Do this for all 4 Right/Down gaps

               ; Draw Cell 3 in gaps 4-7 (the Left/Up gaps)

               ld      b,04h       ; 4 gaps to draw
               ld      c,(ix+37h)  ; Get pixel bitmap for this cell

L015:          ld      a,b
               add     a,03h       ; Start with Gap 7 and work down
               ld      (L016+2),a
L016:          ld      a,(ix+08h)  ; A= Position byte for next gap to be drawn
               inc     a
               inc     a           ; Point to Cell 3 in this gap
               call    DrawGpCl    ; Draw Cell 3
               djnz    L015        ; Do this for all 4 Left/Up gaps

               ; Draw gaps 0-3 (the Right/Down gaps)
               ; For each, AND the desired contents of cells 1 & 4 with what's
               ; already on the screen to allow for overlapping left-moving
               ; gaps.

               ld      b,04h       ; 4 gaps to draw

L017:          ld      c,(ix+36h)  ; Get pixel bitmap for this cell
               ld      a,b
               dec     a           ; Start with Gap 3 and work down
               ld      (L018+2),a
L018:          ld      a,(ix+04h)  ; A= Position byte for next gap to be drawn
               push    af          ; Save copy of position
               call    AndGpCl     ; AND Cell 1 with desired bitmap
               pop     af          ; Retrieve position
               add     a,03h       ; Point to Cell 4
               push    af          ; Save copy of position
               ld      c,(ix+38h)  ; Get pixel bitmap for this cell
               call    AndGpCl     ; AND Cell 4 with desired bitmap
               pop     af          ; Retrieve position
               dec     a           ; Point to Cell 3
               push    af          ; Save copy of position
               ld      c,00h       ; C= Pixel bitmap for this cell (empty)
               call    DrawGpCl    ; Draw Cell 3
               pop     af          ; Retrieve position
               dec     a           ; Point to Cell 2
               call    DrawGpCl    ; Draw Cell 2
               djnz    L017

               ; Draw gaps 4-7 (the Left/Up gaps)
               ; For each, AND the desired contents of cells 0 & 3 with what's
               ; already on the screen to allow for overlapping right-moving
               ; gaps.

               ld      b,04h       ; 4 gaps to draw

L019:          ld      c,(ix+37h)  ; Get pixel bitmap for this cell
               ld      a,b
               add     a,03h       ; Start with Gap 7 and work down
               ld      (L020+2),a
L020:          ld      a,(ix+08h)  ; A= Position byte for next gap to be drawn
               inc     a
               inc     a           ; Point to Cell 3
               push    af          ; Save copy of position
               call    AndGpCl     ; AND Cell 3 with desired bitmap
               pop     af          ; Retrieve position
               sub     03h         ; Point to Cell 0
               push    af          ; Save copy of position
               ld      c,(ix+39h)  ; Get pixel bitmap for this cell
               call    AndGpCl     ; AND Cell 0 with desired bitmap
               pop     af          ; Retrieve position
               inc     a           ; Point to Cell 1
               push    af          ; Save copy of position
               ld      c,00h       ; C= Pixel bitmap for this cell (empty)
               call    DrawGpCl    ; Draw Cell 1
               pop     af          ; Retrieve position
               inc     a           ; Point to Cell 2
               call    DrawGpCl    ; Draw Cell 2
               djnz    L019        ; 71adh
               ret




Rhyme11:       ; 'And he left with a much'
               ; 'wider face...'
               db      2ch, 13h, 49h, 0dh, 4ah, 11h, 0ah, 0bh, 59h, 1ch, 0eh
               db      19h, 4dh, 46h, 12h, 1ah, 08h, 0cdh, 1ch, 0eh, 09h, 0ah
               db      57h, 0bh, 06h, 08h, 8ah




;-------------------------------------------------------------------------------
DrawGpCl:      ; Draws one of the cells that makes a gap.
;-------------------------------------------------------------------------------
; ENTRY
; A = Cell position (Bits 7,6,5 = Jline 0-7 / Bits 4,3,2,1,0 = Cell 0-31)
; C = 8-bit pixel bitmap to be drawn to the top 2 rows of the cell

               call    GetClPtr    ; HL points to cell in Display
               ld      (hl),c      ; Draw top pixel line
               inc     h           ; Point at second row down in cell
               ld      (hl),c      ; Draw second pixel line
               ret




;-------------------------------------------------------------------------------
GetClPtr:      ; Converts a gap cell position into a Display pointer
;-------------------------------------------------------------------------------
; ENTRY
; A = Cell position (Bits 7,6,5 = Jline 0-7 / Bits 4,3,2,1,0 = Cell 0-31)
; EXIT
; HL = Pointer to cell in Display memory

               push    af          ; Save copy of position byte
               and     0e0h        ; Isolate bits 7,6,5 (i.e which JLine 0-7)
               rlca
               rlca
               rlca                ; Rotate bits so A = 2xJLine
               rlca                ; i.e A= 0, 2, 4, 6, 8, 10, 12 or 14
               ld      e,a         ; This will be an offset into ptr table..
               ld      d,00h       ; Put it into DE
               ld      hl,JLnOffs  ; HL points to JLines offsets table
               add     hl,de       ; HL now points to offset of correct JLine
               jr      L021

JLnOffs:       ; Data: Display pointers to the left-most cells in each JLine

               dw      4000h       ; (0,0)
               dw      4060h       ; (3,0)
               dw      40c0h       ; (6,0)
               dw      4820h       ; (9,0)
               dw      4880h       ; (12,0)
               dw      48e0h       ; (15,0)
               dw      5040h       ; (18,0)
               dw      50a0h       ; (21,0)

L021:          ld      e,(hl)
               inc     hl
               ld      d,(hl)      ; DE= Display Pointer from table
               ex      de,hl       ; HL now points to left-most cell in JLine
               pop     af          ; Retrieve gap position byte
               and     1fh         ; Isolate bits 5,4,3,2,1,0 (which cell 0-31)
               or      l
               ld      l,a         ; Add this onto display pointer
               ret                 ; HL now points to desired gap cell




Rhyme12:       ; 'Things seemed just as bad as'
               ; 'could be...'
               db      3fh, 0dh, 0eh, 13h, 0ch, 58h, 18h, 0ah, 0ah, 12h, 0ah
               db      49h, 0fh, 1ah, 18h, 59h, 06h, 58h, 07h, 06h, 49h, 06h
               db      0d8h, 08h, 14h, 1ah, 11h, 49h, 07h, 8ah




;-------------------------------------------------------------------------------
AndGpCl:       ; Alters one of the cells that makes a gap.
;-------------------------------------------------------------------------------
; This ANDs the contents of C with the pixels in the top two rows of a cell on
; screen, and updates the Display with the result.
;
; ENTRY
; A = Cell position (Bits 7,6,5 = Jline 0-7 / Bits 4,3,2,1,0 = Cell 0-31)
; C = 8-bit pixel bitmap to be ANDed with top 2 rows of the cell on screen

               call    GetClPtr    ; HL points to cell in Display
               ld      a,(hl)      ; A= Pixel data from screen
               and     c           ; AND with pixel bitmap
               ld      (hl),a      ; Replace it on screen
               inc     h           ; Point to next pixel row down in cell..
               ld      a,(hl)
               and     c
               ld      (hl),a      ; ..and do the same.
               ret




Rhyme13:       ; 'Hostile faces were all Jack'
               ; 'could see...'
               db      33h, 14h, 18h, 19h, 0eh, 11h, 4ah, 0bh, 06h, 08h, 0ah
               db      58h, 1ch, 0ah, 17h, 4ah, 06h, 11h, 51h, 35h, 06h, 08h
               db      0d0h, 08h, 14h, 1ah, 11h, 49h, 18h, 0ah, 8ah




;-------------------------------------------------------------------------------
DrawJack:      ; Draw/Erase Jack
;-------------------------------------------------------------------------------
; This uses PtSprite which XORs pixels onto the screen, so drawing to the same
; location will also erase Jack.
;
; This routine also toggles the Jack draw/erase flag (Bit 0 of IX+32h) to
; alternate the action on every call to this procedure.

               ex      af,af'

               ; A' will be used to store an attributes byte for some of screen
               ; cells that make up part of Jack. This is used when Jack is
               ; jumping or falling through cells that make up a Jline.  When
               ; drawing, these cells need to have black ink and when erasing,
               ; they need resetting back to red ink.

               inc     (ix+32h)    ; Toggle Draw/Erase flag
               bit     0,(ix+32h)  ; Test flag
               ld      a,00111010b ; Make attribs byte with red ink..
               jr      z,L022      ; ..and continue if we're erasing
               ld      a,00111000b ; Otherwise, we're drawing - set ink to black

L022:          ex      af,af'      ; Store attributes byte in A'

               ; The other attributes to consider are when Jack is on the
               ; bottom of the screen and potentially clashing with the magenta
               ; text on the InfoLine. Here, the top row of his sprite cells
               ; need the ink setting to black (when drawing), and back to
               ; magenta (when erasing).

               ld      a,(ix+2eh)  ; A=Jack position
               cp      0e0h        ; Is Jack at bottom of screen?
               call    nc,MdInfAts ; If so, modify InfoLine attributes

               ld      a,(ix+2dh)  ; A=Jmp Block offset for current animation
               ld      (L023+1),a
               ld      a,(ix+2eh)  ; A=Jack position
L023:          jr      L023        ; Depending on offset, jump to one of below:

               jp      DJStill     ; +0
               jp      DJLeft      ; +3
               jp      DJRight     ; +6
               jp      DJGoodJmpP1 ; +9
               jp      DJFallP1    ; +12
               jp      DJGoodJmpP2 ; +15
               jp      DJFallP2    ; +18
               jp      DJBadJump   ; +21
               jp      DJStunned   ; +24


DJStill:       ; DrawJack / Standing Still

               ; The Standing Still sprite is 2x2 cells and Jack's position byte
               ; refers to the left column of cells

               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJStil ; HL=GFX data for current animation
               ld      a,(ix+2fh)  ; A=Current frame data (Bits 6&5 = frame)
               and     60h         ; A=Offset into GFX data for current frame
               jp      DJPrt2x2ASt


DJLeft:        ; DrawJack / Running Left

               ; There are 2 possibilites which determine the animation to
               ; draw:-
               ; 1) Jack is not touching either edge
               ; 2) Jack is half-way off the left-edge and re-appearing on the
               ;    right-edge

               and     1fh         ; Test position, Z will be set if Jack's
                                   ; horizontal position is 0 - i.e. Jack is one
                                   ; cell off the left-edge of the screen
               ld      a,(ix+2eh)  ; Put fresh copy of position in A
               jr      z,L024      ; Jump if Jack is off left edge

               ; It's (1) - Jack isn't at the edge. In this case, use GFXJLeft
               ; animation which is 2x3 cells. Jack's position byte refers to
               ; the sprite's middle column.

               dec     a           ; Adjust position byte to left column
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJLeft ; HL=GFX data for current animation
               jp      DJPrt2x3

L024:          ; It's (2) - Jack is half-way off the left edge.

               ; Here two sprites must be drawn - GFXJLEOf for Jack going off
               ; the left edge.
               ; This is a 2x2 cell sprite and Jack's position refers to the
               ; left column.

               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJLEOf ; HL=GFX data for current animation
               call    DJPrt2x2

               ; Now draw GFXJREOn for Jack re-appearing on the right edge -
               ; also 2x2.

               ld      a,(ix+2eh)  ; Put fresh copy of position in A
               add     a,1eh       ; Make Jack's horizontal position 30
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJREOn ; HL=GFX data for current animation
               jp      DJPrt2x2


DJRight:       ; DrawJack / Running Right

               ; There are 2 possibilites which determine the animation to
               ; draw:-
               ; 1) Jack is not touching either edge
               ; 2) Jack is half-way off the right-edge and re-appearing on the
               ;    left-edge

               and     1fh         ; Strip Jline info so A=Screen column
               cp      1eh         ; Is it 30 - is Jack 1 cell off right edge?
               ld      a,(ix+2eh)  ; Put fresh copy of position in A
               jr      z,L025      ; Jump if Jack is off right edge

               ; It's (1) - Jack isn't at the edge. In this case, use GFXJRgt
               ; animation which is 2x3 cells. Jack's position byte refers to
               ; the sprite's left column.

               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJRgt  ; HL=GFX data for current animation
               jp      DJPrt2x3

L025:          ; It's (2) - Jack is half-way off the right edge.

               ; Here two sprites must be drawn - GFXJREOf for Jack going off
               ; the right edge. This is a 2x2 cell sprite and Jack's position
               ; refers to the left column.

               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJREOf ; HL=GFX data for current animation
               call    DJPrt2x2

               ; Now draw GFXJLEOn for Jack re-appearing on the left edge -
               ; also 2x2.

               ld      a,(ix+2eh)  ; Put fresh copy of position in A
               sub     1eh         ; Make Jack's horizontal position 0
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJLEOn ; HL=GFX data for current animation
               jp      DJPrt2x2


DJGoodJmpP1:   ; DrawJack / Jumping through a gap (Part 1)

               ; This animation is the first part of a successful jump. It is a
               ; 3x2 cell sprite which therefore requires an appropriate
               ; vertical offset when calling GetDspPtr. Jack's position byte
               ; refers to the sprite's left column.

               ; The sprite also overlaps with 2 cells forming part of the above
               ; Jline so their attributes must be changed.

               ; This animation is followed by GFXJGJp2

               call    MdJLAtsA    ; Modify Attribs in Jline cells above
               ld      c,00h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJGJp1 ; HL=GFX data for current animation
               jp      DJPrt3x2


DJFallP1:      ; DrawJack / Falling through a gap (Part 1)

               ; This animation is the first part of a fall through a gap. It is
               ; is a 4x2 cell sprite and Jack's position byte refers to the
               ; sprite's left column.

               ; The sprite also overlaps with 2 cells forming part of the below
               ; Jline so their attributes must be changed.

               ; This animation is followed by GFXJFal2

               call    MdJLAtsB    ; Modify Attribs in Jline cells below
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJFal1 ; HL=GFX data for current animation
               jp      DJPrt4x2




Rhyme14:       ; 'He tried to stay calm...'
               db      33h, 4ah, 19h, 17h, 0eh, 0ah, 49h, 19h, 54h, 18h, 19h
               db      06h, 5eh, 08h, 06h, 11h, 92h




DJGoodJmpP2:   ; DrawJack / Jumping through a gap (Part 2)

               ; This animation is the second part of a successful jump through
               ; a gap and follows on from GFXJGJp1. It is a 4x2 cell sprite
               ; which therefore requires an appropriate vertical offset when
               ; calling GetDspPtr. Jack's position byte refers to the sprite's
               ; left column.

               ; The sprite also overlaps with 2 cells forming part of the above
               ; Jline so their attributes must be changed.

               call    MdJLAtsA    ; Modify Attribs in Jline cells above
               ld      c,0feh      ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJGJp2 ; HL=GFX data for current animation
               jp      DJPrt4x2


DJFallP2:      ; DrawJack / Falling through a gap (Part 2)

               ; This animation is the second part of a fall through a gap and
               ; follows on from GFXJFal1. It is a 4x2 cell sprite and requires
               ; an appropriate vertical offset when calling GetDspPtr. Jack's
               ; position byte refers to the sprite's left column.

               ; The sprite also overlaps with 2 cells forming part of the above
               ; Jline (Jack's vertical position will have been decremented
               ; since GFXJFal1) so their attributes must be changed.

               call    MdJLAtsA    ; Modify Attribs in Jline cells above
               ld      c,0ffh      ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJFal2 ; HL=GFX data for current animation
               jp      DJPrt4x2


DJBadJump:     ; DrawJack / Jumping into Jline, hitting head, falling back down

               ; This is a 3x2 cell sprite which therefore requires an
               ; appropriate vertical offset when calling GetDspPtr. Jack's
               ; position byte refers to the sprite's left column.

               ; The sprite does overlap with 2 cells forming part of the above
               ; Jline but no attributes are changed as we want Jack to go red
               ; when he hits Jline.

               ; Unless this failed jump takes Jack's last remaining life, it
               ; will be followed by the GFXJStun animation.

               ld      c,00h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJBdJp ; HL=GFX data for current animation
               jp      DJPrt3x2


DJStunned:     ; DrawJack / Stunned

               ; The Stunned sprite is 2x2 cells and Jack's position byte refers
               ; to the left column of cells.

               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to draw Jack
               ld      hl,GFXJStun ; HL=GFX data for current animation
               jp      DJPrt2x2


DJPrt2x3:      ; Print Jack (2x3 sprites)

               ; Jack is in one of the following: GFXJLeft, GFXJRgt
               ; These animations are 2x3 sprites (48 bytes per GFX frame). At
               ; this point:
               ; HL= Address of Frame 0 GFX data for current animation
               ; DE= Display address to print sprite

               call    DJSet48Off  ; Adjust HL to point to current frame
               ld      bc,0302h    ; 2x3 sprite to be printed


DJPrtJack:     call    PtSprite
               ret


DJPrt3x2:      ; Print Jack (3x2 sprites)

               ; Jack is in one of the following: GFXJGJp1, GFXJBdJp
               ; These animations are 3x2 sprites (48 bytes per GFX frame). At
               ; this point:
               ; HL= Address of Frame 0 GFX data for current animation
               ; DE= Display address to print sprite

               call    DJSet48Off  ; Adjust HL to point to current frame
               ld      bc,0203h    ; 3x2 sprite to be printed
               jr      DJPrtJack


DJSet48Off:    ; Adjusts HL to point to current GFX frame (48 bytes per frame)

               call    DJFrameX64  ; A=Current frame x64 (0,64,128,192)
               rrca                ; Divide by 4..
               rrca                ; A=0,16,32,48 (current frame x16)
               ld      c,a
               ld      b,00h       ; BC=0,16,32,48
               add     hl,bc
               add     hl,bc
               add     hl,bc       ; Add to HL 3 times (current frame x48)
               ret


DJFrameX64:    ; Returns A with Jack's Animation Frame x 64

               ld      a,(ix+2fh)  ; A=Current animation frame (Bits 1&0)
               and     03h         ; Isolate Bits 1&0 - A=0,1,2,3
               rrca
               rrca                ; Multiply by 64
               ret                 ; A=0,64,128,192


DJPrt2x2:      ; Print Jack (2x2 sprites)

               ; Jack is in one of the following: GFXJLEOf, GFXJREOn, GFXJLEOn,
               ; GFXJREOf, GFXJStun.
               ; All these animations are 2x2 sprites (32 bytes per GFX frame).
               ; At this point:
               ; HL= Address of Frame 0 GFX data for current animation
               ; DE= Display address to print sprite

               ; Now, adjust HL to point to the current GFX frame.

               call    DJFrameX64  ; A=Current frame x 64 (0,64,128,192)
               rrca                ; Divide by 2, A=(0,32,64,96)


DJPrt2x2ASt:   ; GFXJStil enters this routine here with A already set as above

               ld      c,a
               ld      b,00h       ; Put GFX offset in BC..
               add     hl,bc       ; ..and use it to adjust HL
               ld      bc,0202h    ; 2x2 sprite to be printed
               jr      DJPrtJack


DJPrt4x2:      ; Print Jack (4x2 sprites)

               ; Jack is in one of the following animations: GFXJGJp2, GFXJFal1
               ; or GFXJFal2
               ; All these animations are 4x2 sprites (64 bytes per GFX frame).
               ; At this point:
               ; HL= Address of Frame 0 GFX data for current animation
               ; DE= Display address to print sprite

               ; Now, adjust HL to point to the current GFX frame.

               call    DJFrameX64  ; A=Current frame x 64 (0,64,128,192)
               ld      c,a
               ld      b,00h       ; Put GFX offset in BC..
               add     hl,bc       ; ..and use it to adjust HL
               ld      bc,0204h    ; 4x2 sprite to be printed
               jr      DJPrtJack




Rhyme15:       ; 'And to come to no harm...'
               db      2ch, 13h, 49h, 19h, 54h, 08h, 14h, 12h, 4ah, 19h, 54h
               db      13h, 54h, 0dh, 06h, 17h, 92h




;-------------------------------------------------------------------------------
GetDspPtr:     ; Calculates the Display address to print a sprite
;-------------------------------------------------------------------------------
; Calculates the Display address for a sprite (Jack or Hazard) based on it's
; position byte and a given vertical offset.
;
; NB: Sprite position bytes only store vertical positions as a number 0-7
; relating to the Jline the sprite is under.  Since different animations require
; sprites of varying heights, a vertical offset needs to be supplied to target
; the specific screen cell that will be the sprite's top-left cell.
;
; ENTRY
; A = Sprite position: Bits (7,6,5) = Jline (0-7) immediately above sprite
;                      Bits (4,3,2,1,0) = Horizontal screen column (0-31)
; C = Vertical offset:
;                      --------------------
;                             C=FE
;                      --------------------
;                             C=FF
;                      ====================  JLINE ABOVE SPRITE
;                             C=00
;                      --------------------
;                             C=01
;                      --------------------
;                             C=02
;                      ====================  JLINE BELOW SPRITE
; EXIT
; DE = Address in display memory to print sprite's top-left cell

               ; First we need to convert the position byte (A) & vertical
               ; offset (C) into screen coordinates.
               ; We want the line (0-23) in D, and column (0-31) in E.

               ld      b,a         ; Save copy of the position byte
               and     1fh         ; Zero top 3 bits - leave horiz position
               ld      e,a         ; E = Screen Column

               ld      a,b         ; Retrieve copy of position byte
               and     0e0h        ; Zero low 5 bits - leave Jline info in 7,6,5
               rlca                ; Rotate the top 3 bits into positions 0,1,2
               rlca                ; so A equals Jline above sprite.
               rlca
               ld      d,a         ; D = Jline

               ; Now convert to screen line:
               ; If x = Jline above sprite, then screen line = 3x + vertical
               ; offset

               rlca                ; 2x
               add     a,d         ; 3x
               add     a,c         ; + Vertical offset
               ld      d,a         ; D=Screen line, E=Screen column

               ; Now we convert the screen line and screen column into a Display
               ; pointer.

; NOTES
; A 16 bit pointer to a cell in Display memory has the form;
;
;              High Byte           Low Byte
;    BIT       7 6 5 4 3 2 1 0     7 6 5 4 3 2 1 0
;              0 1 0 T T 0 0 0     R R R C C C C C
;
; T = Which third of the screen 00=Top, 01=Middle, 10=Bottom
; R = 3 bit value for screen line within that third of screen (0-7)
; C = 5 bit value for screen column (0-31)
;
; AT THIS POINT
; A = Screen line (0-23) - Bits 4&3=TT, Bits 2,1,0=RRR
; D = Screen line (0-23)
; E = Screen column (0-31) - Bits 4,3,2,1,0=CCCCC
;
; N.B. The top 3 bits in A, D & E will all be zero.
;
; EXIT
; DE = Address of cell in Display memory

               and     07h         ; Zero top five bits of screen line - lower
                                   ; 3 bits indicate line number (0-7) within
                                   ; whichever screen-third it's in.
               rrca                ; Rotate them into bits 7,6,5 (as required in
               rrca                ; Display pointer low byte)
               rrca
               or      e           ; Copy lower 5 bits (screen column) from E
                                   ; into A
               ld      e,a         ; And put copy in E

               ; Lower byte is now complete in E. Now construct High byte.

               ld      a,d         ; A = Screen line
               and     18h         ; Zero all bits except 4&3 (screen third-TT)
               add     a,40h       ; Set top 3 bits to 010, completing High byte
               ld      d,a         ; Put copy in D

               ; DE now points to required cell in Display memory

               ret




Rhyme16:       ; 'But more often got squashed'
               ; 'like a flea...'
               db      2dh, 1ah, 59h, 12h, 14h, 17h, 4ah, 14h, 0bh, 19h, 0ah
               db      53h, 0ch, 14h, 59h, 18h, 16h, 1ah, 06h, 18h, 0dh, 0ah
               db      0c9h, 11h, 0eh, 10h, 4ah, 46h, 0bh, 11h, 0ah, 86h




;-------------------------------------------------------------------------------
PtSprite:      ; Prints/erases a multi-cell sprite to/from the screen
;-------------------------------------------------------------------------------
; This routine is used to print & erase sprites on screen. Pixels are XOR'd onto
; the screen - so reprinting to the same location will erase an image.
;
; This is also used to print text (where each character is treated as a 1x1 cell
; sprite).
;
; ENTRY:
; HL = Pointer to GFX data to be printed
; DE = Pointer into Display memory - where to print top left cell
; BC = Size of GFX in cells (B=Width, C=Height)

               push    de          ; Save a copy of current print location
               push    bc          ; Save a copy of the width, height counter

L026:          ; Next horizontal cell

               push    bc          ; Another copy (for width)

               ; Starting painting a cell

               ld      b,08h       ; 8 rows of pixels in this cell

L027:          ; Next pixel row

               ld      c,(hl)      ; C=pixel data for this row
               ld      a,(de)      ; A=pixels currently on screen at position
               xor     c           ; Turn on/off pixels as required
               ld      (de),a      ; Copy back to Display memory
               inc     hl          ; HL points to next row of pixel data
               inc     d           ; Move Display pointer to next pixel row
               djnz    L027        ; Print next pixel row

               ; We've painted a complete cell.

               pop     bc          ; Retrieve width counter (B)
               ld      a,d
               sub     08h
               ld      d,a         ; Return Display pointer (DE) to top of cell
               inc     de          ; Point DE to top of adjacent right cell
               djnz    L026        ; Paint next horizontal cell

               ; We've finished painting a row of cells.

               pop     bc          ; BC= Width, Height counter
               pop     de          ; Reset DE to top of left-most cell in row
               ld      a,e
               add     a,20h
               ld      e,a         ; Point DE to top of cell immediately below
               jr      nc,L028     ; Did we cross screen-third boundary?

               ; We've crossed a screen-third boundary

               ld      a,d         ; If so, adjust DE to point to intended cell
               add     a,08h       ; i.e add 2048 bytes (800h)
               ld      d,a

L028:          ; No boundary cross

               dec     c           ; Decrement height counter
               jr      nz,PtSprite ; Paint next row of cells if req

               ; We've finished painting the last row of cells.

               ret




;-------------------------------------------------------------------------------
DrawJlines:    ; Draws the 8 Jlines
;-------------------------------------------------------------------------------
               ld      a,0ffh
               ld      de,4000h    ; AT 0,0
               call    DrawJline

               ld      de,4060h    ; AT 3,0
               call    DrawJline

               ld      de,40c0h    ; AT 6,0
               call    DrawJline

               ld      de,4820h    ; AT 9,0
               call    DrawJline

               ld      de,4880h    ; AT 12,0
               call    DrawJline

               ld      de,48e0h    ; AT 15,0
               call    DrawJline

               ld      de,5040h    ; AT 18,0
               call    DrawJline

               ld      de,50a0h    ; AT 21,0
               call    DrawJline

               ret




;-------------------------------------------------------------------------------
DrawJline:     ; Draws a complete Jline on the screen
;-------------------------------------------------------------------------------
; A Jline is made by filling the top two pixel rows in a screen-line of cells.
;
; ENTRY:
; A  = 0FFh - Pixel bitmap for top two rows of each cell
; DE = Pointer into Display memory - left-most cell of Jline to be drawn

               scf                 ; Use Carry to mean we're on pixel row 1 of 2

L029:          ; Next pixel line

               ld      b,20h       ; 32 cells in a line
               push    de          ; Save copy of display pointer
               push    de
               pop     hl          ; HL points to first cell in line

L030:          ; Next cell

               ld      (hl),a      ; Set row of pixels in cell
               inc     hl          ; Point to next cell along
               djnz    L030        ; Keep going until end of line

               pop     de          ; Retrieve original display address
               ccf                 ; Toggle Carry
               ret     c           ; Return if we've just drawn pixel row 2 of 2

               inc     d           ; Otherwise point to next pixel row down and
               jr      L029        ; draw second pixel line




Rhyme17:       ; 'By now Jack was in a'
               ; 'great flap...'
               db      2dh, 5eh, 13h, 14h, 5ch, 35h, 06h, 08h, 50h, 1ch, 06h
               db      58h, 0eh, 53h, 0c6h, 0ch, 17h, 0ah, 06h, 59h, 0bh, 11h
               db      06h, 95h




;-------------------------------------------------------------------------------
UpdateGame:    ; Updates Gaps & Jack, processes input and performs game logic
;-------------------------------------------------------------------------------
; This is called every 4 frames. As well as updating the Gap positions, it
; processes player input and sets up accordingly everything for Jack's next
; 4-frame animation.
; Collision & gap detection are also done here and acted upon as necessary
; along with any score and life adjustments.

               call    UpdtGaps    ; Move Gaps
               ld      a,(ix+08h)  ; A=Jack's current animation
               ld      (L031+1),a  ; Use it as a jump offset
L031:          jr      L031+2

               jp      UGStill     ; +0
               jp      UGLeft      ; +3
               jp      UGRight     ; +6
               jp      UGGoodJmpP1 ; +9
               jp      UGFallP1    ; +12
               jp      UGGoodJmpP2 ; +15
               jp      UGFallP2    ; +18
               jp      UGBadJump   ; +21
               jp      UGStunned   ; +24


UGStill:       ; UpdateGame / Standing Still

               ; This is called if Jack was previously standing still or running
               ; left/right. Hazard and Gap detection takes place and if neither
               ; occurs, keyboard input is processed to determine next
               ; action/animation etc.

               ; Hazard detection

               call    CollDetn    ; Is Jack touching a Hazard?
               jr      nc,L032     ; If not, check for gaps under Jack


UGInitHit:     ; Jack is touching a Hazard. Setup for Stunned animation.

               ld      (ix+08h),24 ; Set Jack animation to Stunned
               ld      (ix-08h),2  ; Set SFX/GFX routine to Hit by Hazard
               ld      a,16
               add     a,(ix+0ah)
               ld      (ix+0ah),a  ; Increment Stunned Timer by 16
               jp      UGStunChks  ; Continue to process Stunned status

L032:          ; Gap detection

               call    GapDetn     ; Is Jack standing on a gap?
               jp      c,UGInitFal ; If yes, launch Fall animation

               ; No Hazard collision or gap below. Process keyboard input:

               ld      a,(ix-0ch)  ; A=Keypress data from GetInput
               cp      03h         ; Is it Jump (CAPS SHIFT)?
               jr      z,UGInitJmp

               ; Input is not Jump so must be Right(2), Left(1), or Nothing(0).
               ; Convert this to appropriate value for Jack animation

               rlca                ; A=0,2 or 4
               add     a,(ix-0ch)  ; A=0(Standing Still),3(Left) or 6(Right)
               ld      (ix+08h),a  ; Set Jack animation
               and     a           ; Was it Standing Still?
               jr      nz,L033     ; Jump if not

               ld      (ix-08h),0  ; Set SFX/GFX routine to Standing Still
               ret

L033:          ; Player has pressed 'Left' or 'Right'

               ld      (ix-08h),1  ; Set SFX/GFX routine to Running
               ret


UGInitJmp:     ; Player has pressed 'Jump'

               call    TestJump    ; Is there a gap above Jack?
               jr      c,UGInitGJp ; If so, launch Good Jump animation
                                   ; else fall through to..

UGInitBJp:     ; Setup for Bad Jump animation

               ld      (ix+08h),21 ; Set Jack animation to Bad Jump
               ld      (ix-08h),5  ; Set SFX/GFX routine to Bad Jump
               ld      (ix+0ah),24 ; Set Stunned Timer to 24
               ret


UGInitGJp:     ; Setup for Good Jump animation

               ld      (ix+08h),9 ; Set Jack animation to Good Jump (Part 1)
               ld      (ix-08h),3 ; Set SFX/GFX routine to Good Jump
               ret


UGInitFal:     ; Setup for Falling animation

               ld      (ix+08h),12 ; Set Jack animation to FallPt1
               ld      (ix-08h),4  ; Set SFX/GFX routine to Falling
               ld      a,8
               add     a,(ix+0ah)
               ld      (ix+0ah),a  ; Increment Stunned Timer by 8
               ret




Rhyme18:       ; 'He felt like a rat in a trap...'
               db      33h, 4ah, 0bh, 0ah, 11h, 59h, 11h, 0eh, 10h, 4ah, 46h
               db      17h, 06h, 59h, 0eh, 53h, 46h, 19h, 17h, 06h, 95h




UGLeft:        ; UpdateGame / Running Left

               ; This is called if Jack has just completed a Running Left
               ; animation

               call    MoveLeft    ; Adjust Jack's position 1 cell left
               jp      UGStill     ; Check collisions / Process Input


UGRight:       ; UpdateGame / Running Right

               ; This is called if Jack has just completed a Running Right
               ; animation

               call    MoveRight   ; Adjust Jack's position 1 cell right
               jp      UGStill     ; Check collisions / Process Input


UGGoodJmpP1    ; UpdateGame / Good Jump (Part 1)

               ; This is called if Jack has just completed the first part of a
               ; Good Jump. It sets everything up for Part 2 as well as
               ; increasing the score, adding a new gap and checking if Jack has
               ; completed the level.

               ld      (ix+08h),15 ; Set Jack animation to GoodJumpPt2
               call    AddGap      ; Add a new gap
               call    IncScore    ; Increase score
               call    PrtScore    ; Erase previous score digits
               call    CvtScBCD    ; Convert Score to BCD
               call    PrtScore    ; Print new score digits
               call    TestTop     ; Is Jack jumping through Jline 0?
               ret     nc          ; Return if not

               ; Jack is jumping through top Jline (completing level)

               ld      (ix+0bh),1  ; Update Game Progress to 'Level Completed'
               ld      (ix+08h),0  ; Set Jack animation to Standing Still
               ret                 ; i.e. no need to complete jump


UGFallP1:      ; UpdateGame / Falling through gap (Part 1)

               ; This is called if Jack has just completed the first part of
               ; Falling through a gap. It sets everything up for Part 2
               ; including updating Jack's position to Jline below (as GFXJFal2
               ; animation is drawn 'from below')

               ld      (ix+08h),18 ; Set Jack animation to FallingPt2
               ld      a,(ix+09h)
               add     a,20h
               ld      (ix+09h),a  ; Update Jack's position byte to Jline below
               ret


UGGoodJmpP2:   ; UpdateGame / Good Jump (Part 2)

               ; This is called if Jack has just completed the second part of a
               ; Good Jump. It updates Jack's position to reflect he's now on
               ; the Jline above and resets his animation back to Standing
               ; Still.

               ld      (ix+08h),0  ; Set Jack animation to Standing Still
               ld      (ix-08h),0  ; Set SFX/GFX routine to Standing Still
               ld      a,(ix+09h)
               sub     20h
               ld      (ix+09h),a  ; Update Jack's position byte to Jline above
               ret


UGFallP2:      ; UpdateGame / Falling through gap (Part 2)
UGBadJump:     ; UpdateGame / Bad Jump

               ; This is called if Jack has just completed Falling through a gap
               ; or a Bad Jump. It sets up the Stunned animation, then falls
               ; through into the code for if Jack was already Stunned.

               ld      (ix+08h),24 ; Set Jack animation to Stunned


UGStunned:     ; UpdateGame / Stunned

               ; This is called if Jack was previously Stunnned (or has just
               ; been put into this animation from a Fall or Bad Jump)

               ld      (ix-08h),6  ; Set GFX/SFX routine to Stunned

               ; Hazard/Gap detection

               call    TestBot     ; Is Jack at the bottom of screen?
               jr      c,L034      ; Skip Hazard/Gap detection if yes
               call    CollDetn    ; Is Jack touching a Hazard?
               jp      c,UGInitHit ; Launch appropriate GFX/SFX if so
               jr      UGStunChks  ; Gap detection & Wake-up check

L034:          ; Jack is Stunned at the bottom of the screen, but has he just
               ; got there (from Fall or Bad Jump) i.e. should he lose a life?

               inc     (ix-05h)
               dec     (ix-05h)    ; Test Lost Life flag
               jr      nz,UGWakeCk ; If a life's already been lost, is it time
                                   ; to wakeup?

               ; Jack has only just arrived at the bottom from a Fall or Bad
               ; Jump - so he loses a life

               call    PrtLives    ; Erase 'lives remaining' symbols
               dec     (ix+0ch)    ; Decrement lives counter
               jr      nz,L035     ; Was that his last life?
               ld      (ix+0bh),2  ; If so, update Game Progress to 'Game Over'
               ret

L035:          call    PrtLives    ; Print 'lives remaining' symbols
               ld      (ix-05h),1  ; Set Lost Life flag
               ld      (ix+0ah),24 ; Set Stunned Timer to 24
               jr      UGWakeCk


UGStunChks:    ; Checks to perform when Jack is Stunned

               ; This is called when Jack is Stunned to check for gaps below,
               ; and to check if it's time for Jack to wake-up.
               ; NB: Hazard collision has already been checked when calling
               ; this.

               call    GapDetn     ; Is Jack lying on a gap?
               jp      c,UGInitFal ; If yes, launch Fall animation


UGWakeCk:      ; Is it time to wake-up from being Stunned?

               dec     (ix+0ah)    ; Decrement Stunned Timer..
               ret     nz          ; ..and return if still time remaining

               ; Stunned Timer has run out - Setup for Standing Still animation

               ld      (ix+08h),0  ; Set Jack animation to Standing Still
               ld      (ix-08h),0  ; Set SFX/GFX routine to Standing Still
               ld      (ix-05h),0  ; Reset Lost Life flag
               ret




;-------------------------------------------------------------------------------
GapDetn:       ; Gap Detection - Is Jack standing on a hole?
;-------------------------------------------------------------------------------
; EXIT
;  Carry Flag = 1 if stood on gap / 0 if not

               ; First check if Jack is at the bottom of the screen - if so, he
               ; can't be stood on a gap

               ld      a,(ix+09h)  ; A=Jack's position
               add     a,20h
               cp      20h         ; This will set Carry if Jack's at bottom
               ccf                 ; If Jack's at bottom, Carry is now 0..
               ret     nc          ; ..so return

               ; Jack's stood on a Jline. Since we've altered the position byte
               ; in A (moving Jack down a Jline) we can use TestGap which looks
               ; for a gap above.

               ; Since gaps are 3 cells wide, and their positions are based on
               ; their left-most cells, we need to look for a gap matching
               ; Jack's position byte or the position adjacent to the left.

               call    TestGap     ; Check against first position
               ret     c           ; Return if match found

               dec     a           ; Alter Jack's position 1 cell left..
               call    TestGap     ; ..and check again
               ret




;-------------------------------------------------------------------------------
TestGap:       ; Looks for a Gap above Jack
;-------------------------------------------------------------------------------
; This compares Jack's position byte against the positions of all 8 gaps. Gaps
; are 3 cells wide and their position refers to their left-most cell so
; 2 calls to this procedure with different Jack positions are needed.
;
; ENTRY
; A = Jack's position byte
; EXIT
; Carry = 1 if gap above Jack
;       = 0 if no gap

               push    ix
               pop     hl          ; HL points to 8 Gap position bytes
               ld      bc,8        ; 8 gaps to test
               cpir                ; Compare them with Jack's position in A
               jr      z,L036      ; Jump if match found
               and     a           ; Otherwise clear Carry and return
               ret

L036:          scf                 ; Match found. Set Carry and return
               ret




;-------------------------------------------------------------------------------
TestJump:      ; Is there a gap above Jack for him to jump through?
;-------------------------------------------------------------------------------
; Since gaps are 3 cells wide, and their positions are based on their
; left-most cells, we need to look for a gap matching Jack's position byte or
; the position adjacent to the left.
;
; EXIT
; Carry = 1 if gap above Jack
;       = 0 if no gap

               ld      a,(ix+09h)  ; A=Jack's position
               call    TestGap     ; Check against first position
               ret     c           ; Return if match found

               dec     a           ; Alter Jack's position 1 cell left..
               call    TestGap     ; ..and check again
               ret




;-------------------------------------------------------------------------------
TestTop:       ; Is Jack at the top of the screen (under Jline 0)?
;-------------------------------------------------------------------------------
; EXIT
; Carry = 1 if Yes
;         0 if No

               ld      a,(ix+09h)  ; A=Jack's position
               cp      20h         ; Carry will be set if he's under Jline 0
               ret




;-------------------------------------------------------------------------------
TestBot:       ; Is Jack at the bottom of the screen (under Jline 7)?
;-------------------------------------------------------------------------------
; EXIT
; Carry = 1 if Yes
;         0 if No

               ld      a,(ix+09h)  ; A=Jack's position
               cp      0e0h        ; Carry will be clear if he's under Jline 7
               ccf
               ret




Rhyme19:       ; 'If only he'd guessed...'
               db      34h, 4bh, 14h, 13h, 11h, 5eh, 0dh, 0ah, 24h, 49h, 0ch
               db      1ah, 0ah, 18h, 18h, 0ah, 89h




;-------------------------------------------------------------------------------
MoveRight:     ; Update Jack's position one cell right
;-------------------------------------------------------------------------------
               inc     (ix+09h)    ; Update Jack's position byte one cell right
               ld      a,(ix+09h)
               ld      b,a         ; Put a copy in A & B
               and     1fh         ; Strip Vertical info / A=Horizontal column
               cp      1fh         ; Was Jack half-way off the right edge?
               ret     nz          ; Return if not

               ; Jack must have been at screen column 30 before move (half-way
               ; off right edge and half-way on left). Update will have made his
               ; new horizontal position 31 so need to adjust it to position 0
               ; (fully on left edge).

               ; NB: Jack is never at position 31 - that is simulated when he's
               ; at position 30 and in the off-right/on-left animations.

               ld      a,b         ; Retrieve copy of new position in A
               sub     1fh         ; Adjust position..
               ld      (ix+09h),a  ; ..and store it
               ret




;-------------------------------------------------------------------------------
MoveLeft:      ; Update Jack's position one cell left
;-------------------------------------------------------------------------------
               dec     (ix+09h)    ; Update Jack's position byte one cell left
               ld      a,(ix+09h)
               ld      b,a         ; Put a copy in A & B
               and     1fh         ; Strip Vertical info / A=Horizontal column
               cp      1fh         ; Was Jack half-way off the left edge?
               ret     nz          ; Return if not

               ; Jack must have been at screen column 0 before move (half-way
               ; off left edge and half-way on right). Update will have made his
               ; new horizontal position 31 and moved him up 1 Jline so need to
               ; adjust it to position 30 on Jline below.

               ; NB: Jack is never at position 31 - that is simulated when he's
               ; at position 0 and in the off-left/on-right animations.

               ld      a,b         ; Retrieve copy of new position in A
               add     a,1fh       ; Adjust position..
               ld      (ix+09h),a  ; ..and store it
               ret




;-------------------------------------------------------------------------------
AddGap:        ; Adds a new Gap
;-------------------------------------------------------------------------------
; All 8 gaps already 'exist' from the beginning of the game, but only two are
; visible as all 4 descenders and all 4 ascenders are in the same positions,
; meaning they are drawn on top of one another. Adding a new gap is just a case
; of changing the position of an existing gap so it becomes visible.

               ld      a,(ix-02h)  ; A=New Gaps counter
               cp      06h         ; If we've already added 6 gaps to the
               ret     nc          ; original visible 2, then no more to add.

               inc     a
               ld      (ix-02h),a  ; Increment New Gaps counter

               ; Which sort of gap to add? The first 3 'new' gaps descend, and
               ; the next 3 ascend

               cp      04h         ; Have we already added 3 descenders?
               ld      c,(ix-07h)  ; C=Right Gap Tracker (for descenders)
               jr      c,L037      ; Jump if not

               ld      c,(ix+34h)  ; C=Left Gap Tracker (for ascenders)
               inc     a           ; Adjust A to become IX offset for new gap
                                   ; position byte
L037:          ld      (L038+2),a  ; Adjust later code to target byte where new
                                   ; gap position is to be stored

; Two variables, Right Gap Tracker (IX-07h) and Left Gap Tracker (IX+34) are
; used to ensure that new gaps don't partially overlap with any current gaps.

; When the position of all 8 gaps is randomized at the start of each level
; (RndGaps), they are set with a horizontal position that is a multiple of 4.
; Every time a gap moves one cell (in UpdtGaps), the tracking variables are also
; updated accordingly (becoming an offset of how far the gaps have moved from
; their multiple-of-4 cell positions).
;
; So, to set a new random non-overlapping gap position:
; 1) Start with a random position
; 2) Adjust it horizontally to make it 0,4,8,12,16,20,24 or 28.
; 3) Add on relevant Tracker variable
;
; NB: Occasionally this will generate a position that is exactly the same as a
; current gap and no new gap will appear to have been created.

               ld      a,(ix-0bh)  ; Start with a random value (1)
               and     0fch        ; Make it a multiple of 4 (2)
               add     a,c         ; Add tracker variable (3)
L038:          ld      (ix+00h),a  ; Store it
               ret




;-------------------------------------------------------------------------------
IncScore:      ; Increases score after a good jump
;-------------------------------------------------------------------------------
; Points per good jump are awarded increasingly with each new level:
; Score Increase = (5 x Current Level) + 5 (up to maximum of 100)

               ld      a,(ix+0eh)  ; A=Current Level
               ld      hl,PntsTbl  ; HL points to score lookup table
               add     a,l         ; Use level as offset into table
               jr      nc,L039     ; Check for carry..
               inc     h           ; ..and fix if necessary. NB: This check is
                                   ; unneccessary with the addresses the game
                                   ; is assembled at - but useful if assembled
                                   ; with different ORG
L039:          ld      l,a         ; HL points to score increment amount
               ld      a,(hl)      ; A=Score increment amount
               add     a,(ix-04h)  ; Add to current score (least sig byte)
               jr      nc,L040     ; Check for Carry, and if so..
               inc     (ix-03h)    ; ..increment most sig byte
L040:          ld      (ix-04h),a  ; Update new score (least sig byte)
               ret

PntsTbl:       ; DATA: Lookup table - Points awarded per good jump in each level

               db      5           ; Level 0
               db      10          ; Level 1
               db      15          ; Level 2
               db      20          ; Level 3
               db      25          ; Level 4
               db      30          ; Level 5
               db      35          ; Level 6
               db      40          ; Level 7
               db      45          ; Level 8
               db      50          ; Level 9
               db      55          ; Level 10
               db      60          ; Level 11
               db      65          ; Level 12
               db      70          ; Level 13
               db      75          ; Level 14
               db      80          ; Level 15
               db      85          ; Level 16
               db      90          ; Level 17
               db      95          ; Level 18
               db      100         ; Level 19
               db      100         ; Level 20




Rhyme20:       ; 'That soon he could rest...'
               db      3fh, 0dh, 06h, 59h, 18h, 14h, 14h, 53h, 0dh, 4ah, 08h
               db      14h, 1ah, 11h, 49h, 17h, 0ah, 18h, 99h




;-------------------------------------------------------------------------------
GetInput:      ; Reads keyboard input
;-------------------------------------------------------------------------------
; The result of the player's keyboard input is stored in the byte at IX-0ch.
;
; 03 = Jump (CAPS SHIFT)
; 02 = Right (SPACE)
; 01 = Left (SYM SHIFT)
; 00 = Nothing

               ld      a,(ix-0ch)  ; A=Last keyboard input
               and     a           ; Return if it was anything other than
               ret     nz          ; 'Nothing' as previous input has yet to be
                                   ; processed

               ; Test for Jump

               ld      bc,0fefeh   ; B=Keyboard section containing CAPS SHIFT
                                   ; C=Keyboard port
               in      a,(c)       ; Scan keyboard
               bit     0,a         ; Bit 0 = 'CAPS SHIFT'. Is it pressed? (Jump)
               jr      nz,L041     ; If not, test for Right
               ld      (ix-0ch),3  ; If yes, store result as 'Jump' and return
               ret

L041:          ; Test for Right

               ld      bc,7ffeh    ; B=Keyboard section containing SPACE
                                   ; C=Keyboard port
               in      a,(c)
               bit     0,a         ; Bit 0 = 'SPACE'. Is it pressed? (Right)
               jr      nz,L042     ; If not, test for Left
               ld      (ix-0ch),2  ; If yes, store result as 'Right' and return
               ret

L042:          ; Test for Left

               bit     1,a         ; Bit 1 = 'SYM SHIFT'. Is it pressed? (Left)
               ld      (ix-0ch),0  ; Store result as 'Nothing'
               ret     nz          ; and return if it isn't pressed
               ld      (ix-0ch),1  ; Otherwise store result as 'Left' and return
               ret




;-------------------------------------------------------------------------------
UpdHazds:      ; Update Hazards
;-------------------------------------------------------------------------------
; This updates the positions of all 20 Hazards (regardless of how many Hazards
; are currently in play)
;
; It is called every 4 frames. In the intermediate frames, the Hazards' GFX
; animations give the illusion of leftwards movement even while the sprite
; position remains unchanged.

               ld      b,14h       ; Set counter - 20 Hazards to update

L043:          push    bc          ; Save counter
               call    L044        ; Update current Hazard
               pop     bc          ; Retrieve counter
               djnz    L043        ; Update next Hazard if more to do
               ret

L044:          ld      a,0eh       ; Add 14 to counter to make it an IX offset
               add     a,b         ; into Hazard position bytes (start at IX+22h
                                   ; and work down through them to IX+0fh)
               ld      (L046+2),a
               ld      (L045+2),a  ; Update code with this offset

L045:          ld      a,(ix+00h)  ; A=Current Hazard position byte

               ; To move a Hazard one cell left, the position byte is
               ; decremented. Even when the Hazard reaches the left edge of the
               ; screen, this will automatically move the Hazard up a Jline and
               ; back to the right edge.

               dec     a           ; Move Hazard position one cell left

               ; The exception lies when a Hazard reaches the left edge of Jline
               ; 1 and goes off the screen. At this point the position byte =0
               ; (and DrawHzrd will not print it).  With single decrements, it
               ; will not become printable again until it reaches 0DEh (Jline 7,
               ; Cell 30) - however, this will be a significant time off screen,
               ; so the following code reduces the wait leaving a shorter delay.

               cp      0feh        ; Has Hazard gone off the edge of Jline 1?
               jr      nz,L046     ; If not, continue
               ld      a,0f4h      ; If it has, skip 10 cycles to make position
                                   ; f4h.
L046:          ld      (ix+00h),a  ; Save updated position byte
               ret




;-------------------------------------------------------------------------------
DrawHzds:      ; Draws/erases the Hazards
;-------------------------------------------------------------------------------
; This draws or erases the Hazards in the current level by calling DrawHzrd
; for each.
;
; It also toggles the Hazards draw/erase flag (Bit 0 of IX-06h) to alternate
; the action on every call to this procedure.

               ld      a,(ix+0eh)  ; A=Number of Hazards in this level
               inc     (ix-06h)    ; Toggle draw/erase flag
               and     a           ; Are there 0 Hazards in this level?
               ret     z           ; If so, return

               ; Setup the required info for DrawHzrd

               ld      b,a         ; B=Number of Hazards - use as counter
               ld      hl,GFXHzrds ; HL points to GFX data of 1st Hazard
               ld      a,(ix+33h)  ; Bits 2&1 represent Hazards' current frame
               and     06h         ; Isolate bits 2&1 - A=0, 2, 4 or 6
               rlca                ; Turn it into an offset into 1st Hazard's
               rlca                ; GFX data by multiplying it by 24
               rlca                ; A=A*8
               ld      e,a
               rlca                ; A=A*16
               add     a,e
               ld      e,a         ; E=A*24
               ld      d,00h       ; DE=Offset into Hazard GFX for current frame
                                   ; i.e. 0, 48, 96 or 144
               add     hl,de       ; HL=Hazard GFX for current frame
               ld      a,0fh       ; A=Offset from IX to first Hazard position
                                   ; (Hazard position bytes begin at IX+0fh)

L047:          ; Draw/Erase each Hazard

               push    bc          ; Save Hazards counter
               call    DrawHzrd    ; Draw/Erase current Hazard
                                   ; NB. DrawHzrd returns with HL & A updated
                                   ; to target next Hazard
               pop     bc          ; Retrieve counter
               djnz    L047        ; Repeat for every Hazard in level
               ret




;-------------------------------------------------------------------------------
DrawHzrd:      ; Draws/Erases a Hazard
;-------------------------------------------------------------------------------
; This routine draws or erases a Hazard. Pixels are XOR'd onto the screen - so
; reprinting to the same location will erase an image. Depending on the Hazard
; Draw/Erase flag (IX-06h), the attributes of the Hazard cells on screen will
; either be set or reset appropriately.
;
; ENTRY
; HL = Address of Hazard GFX data for current frame
;  A = Offset from IX to Hazard position byte
; EXIT
; HL = Address of current frame GFX data for next Hazard
;  A = Offset from IX to position byte of next Hazard (A=A+1)
;
;
; Each Hazard is a 2x3 cell sprite:
;      _________________
;     |     |     |     |
;     |  1  |  2  |  3  |
;     |_____|_____|_____|
;     |     |     |     |
;     |  4  |  5  |  6  |
;     |_____|_____|_____|
;
; The screen column data (Bits 4-0) in each Hazard's position byte refers to
; the middle column of each Hazard (Cells 2 & 5)
;
; The actual drawing is done by separate calls to PtHzdCol (Print Hazard Column)
; which draws a 2-cell column of the sprite:
; e.g. Column 1 = Cells 1 & 4.  Column 2 = Cells 2 & 5.  Column 3 = Cells 3 & 6.
;
; Drawing in this way allows the routine to cope when a Hazard is partly on/off
; the edge of the screen and parts of the same Hazard need to be drawn on
; different Jlines.
;
; There are three cases (remember Hazards travel right to left, and move up one
; Jline everytime they reach the left edge of the screen. Upon reaching the
; top-left on Jline 1, they re-appear at the bottom-right on Jline 7)
;
; Case 1: Hazard is fully on the screen not touching either edge - all three
;         columns need to be drawn next to each other.
;
; Case 2: Hazard is going off the left edge of Jlines 2-7 and reappearing on the
;         right edge on the Jline above. The Hazard horizontal position will
;         either be:
;         A) 0, in which case columns 2 & 3 must be drawn on the lower Jline and
;            column 1 must be drawn on the upper Jline.
;         B) 31, in which case column 3 must be drawn on the lower Jline and
;            columns 1 & 2 must be drawn on the upper Jline.
;
; Case 3: Hazard has gone off the left edge of Jline 1 and not yet appeared on
;         Jline 7. In this case, there is no animation off the left edge, the
;         Hazard just disappears. Equally, when it does reappear on Jline 7,
;         (and there is a short gap before it does) there is no animation on, it
;         just appears at position 30. No columns need to be drawn for Case 3.


               call    GetHzAtt    ; A'=Attributes for Hazard cells - either a
                                   ; colour (drawing) or black (erasing)
               push    hl          ; Save GFX pointer
               push    af          ; Save offset to position byte
               ld      (L048+2),a
L048:          ld      a,(ix+00h)  ; A= Hazard position byte

               ; Test for Case 3

               and     a           ; Has Hazard reached cell 0 on Jline1?
                                   ; i.e. it's gone off the screen.
               jr      z,L051      ; If so, we're finished drawing

               cp      0dfh        ; Is Hazard already off the screen, but not
                                   ; yet back on Jline 7?
               jr      nc,L051     ; If so, we're finished drawing

               ; It's not Case 3 - test for Case 2A

               push    af          ; Save position byte
               and     1fh         ; Strip top 3 bits (Jline info) to leave
                                   ; cell info (A=0-31)
               jr      nz,L049     ; Is Hazard at cell 0 on Jline? Test for case
                                   ; 2B if not.

               ; It's Case 2A - draw column 1 on upper Jline

               pop     af          ; Retrieve position byte in A
               push    af          ; and save a copy
               dec     a           ; Adjust position to cell 31 on upper Jline
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address for column 1
               call    PtHzdCol    ; Print/Erase column 1

               ; Now draw columns 2 & 3 on lower Jline

               pop     af          ; Retrieve position byte in A
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address for column 2
               call    PtHzdCol    ; Print/Erase column 2
               call    PtHzdCol    ; Print/Erase column 3
               jr      L051        ; Finished drawing

L049:          ; Test for Case 2B

               cp      1fh         ; Is Hazard at cell 31?
               jr      nz,L050     ; If not, it must be Case 1

               ; It's Case 2B - draw columns 1 & 2 on upper Jline

               pop     af          ; Retrieve position byte in A
               push    af          ; and save a copy
               dec     a           ; Adjust position to cell 30 on upper Jline
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address for column 1
               call    PtHzdCol    ; Print/Erase column 1
               call    PtHzdCol    ; Print/Erase column 2

               ; Now draw column 3 on lower Jline

               pop     af          ; Retrieve position byte in A
               inc     a           ; Adjust position to cell 0 on lower Jline
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address for column 3
               call    PtHzdCol    ; Print/Erase column 3
               jr      L051        ; Finished drawing

L050:          ; It's Case 1 - draw 3 columns together

               pop     af          ; Retrieve position byte
               dec     a           ; Modify position byte to point to Hazard's
                                   ; left column (rather than middle)
               ld      c,01h       ; Vertical Offset for GetDspPtr
               call    GetDspPtr   ; DE=Display address to print Hazard
               call    PtHzdCol    ; Print/Erase column 1
               call    PtHzdCol    ; Print/Erase column 2
               call    PtHzdCol    ; Print/Erase column 3

L051:          ; Finished drawing columns - setup return values for HL & A

               pop     af          ; Retrieve offset to position byte
               pop     hl          ; Retrieve GFX pointer
               inc     a           ; Inc offset to next Hazard's position byte
               ld      de,00c0h    ; Add 192 bytes to HL so it points to the
               add     hl,de       ; next Hazard's GFX data
               cp      19h         ; Is the next Hazard the 11th?
               ret     nz          ; If not, return
               ld      de,0780h    ; If it is, then we've run out of Hazard GFX
               sbc     hl,de       ; as there are only 10 different designs so
               ret                 ; adjust HL to point to the first one again




;-------------------------------------------------------------------------------
PtHzdCol:      ; Print/Erase Hazard Column
;-------------------------------------------------------------------------------
; Prints 2 cells of a Hazard sprite and sets their attributes.
;
; ENTRY
; DE = Display address - where to print top cell
; HL = Address of GFX data for top cell (Bottom cell data to be 8 bytes later)
; EXIT
; DE = Display address of adjacent right cell (DE=DE+1)
; HL = Address of GFX data for next column in sprite (HL=HL+16)

               call    SetHzAtt    ; Set attributes for top cell
               push    de          ; Save display address
               push    de          ; Save display address
               ld      b,08h       ; Counter for 8 pixel rows in cell

L052:          ; Print/Erase top cell

               ld      a,(de)      ; A=Pixel row data already on screen
               xor     (hl)        ; Turn on/off pixels as required
               ld      (de),a      ; Copy back to Display memory
               inc     hl          ; HL points to next row of Hazard GFX data
               inc     d           ; Move Display pointer to next pixel row
               djnz    L052        ; Next pixel row

               ; Move display pointer to bottom cell

               pop     de          ; Retrieve display pointer
               ld      a,e
               add     a,20h       ; Move forward 32 cells, then check if we've
               ld      e,a         ; crossed a screen-third boundary
               jr      nc,L053     ; Continue, if not
               ld      a,d         ; Otherwise increase DE by (8x256) to
               add     a,08h       ; correctly address the bottom cell and
               ld      d,a         ; continue..

L053:          ; Setup for bottom cell

               call    SetHzAtt    ; Set attributes for bottom cell
               ld      b,08h       ; Counter for 8 pixel rows in cell

L054:          ; Print/Erase bottom cell

               ld      a,(de)      ; A=Pixel row data already on screen
               xor     (hl)        ; Turn on/off pixels as required
               ld      (de),a      ; Copy back to Display memory
               inc     hl          ; HL points to next row of Hazard GFX data
               inc     d           ; Move Display pointer to next pixel row
               djnz    L054        ; Next pixel row

               ; Bottom cell complete

               pop     de          ; Retrieve display pointer to top cell
               inc     de          ; Move pointer to adjacent right cell
               ret




;-------------------------------------------------------------------------------
SetHzAtt:      ; Set Hazard Attributes
;-------------------------------------------------------------------------------
; Sets the attributes of a Hazard sprite cell on screen. When drawing, this
; gives the Hazard it's colour. When erasing, it returns the screen attributes
; to their default.
;
; ENTRY
; DE = Display address of cell
; A' = Desired attributes for cell
; EXIT
; DE = Preserved
; A' = Preserved

               push    de          ; Preserve display pointer

               ; To convert Display address (DE) into corresponding Attributes
               ; address:
               ; D = ((D-40h) / 8) + 58h
               ; E = Unchanged

               ld      a,d
               sub     40h         ; Subtract 40h
               rrca
               rrca
               rrca                ; Divide by 8
               add     a,58h       ; Add 58h
               ld      d,a         ; DE points to cell in Attributes memory
               ex      af,af'      ; A=Desired attribs byte
               ld      (de),a      ; Update screen
               ex      af,af'      ; Save attribs byte back in A'
               pop     de          ; Retrieve display pointer
               ret




;-------------------------------------------------------------------------------
CollDetn:      ; Collision Detection - Is Jack touching a Hazard?
;-------------------------------------------------------------------------------
; EXIT
;  Carry Flag = 1 if collision / 0 if no collision

               ld      a,(ix+0eh)  ; A=Number of Hazards in this level
               and     a           ; Are there none? (Also clear Carry)
               ret     z           ; If no Hazards, then no collision - return

               ; The nature of the collision detection means that the same 'hit'
               ; will be detected on two consecutive calls to this routine - so
               ; check there wasn't a hit last time

               inc     (ix-01h)    ; Test Collision flag. Was collision detected
               dec     (ix-01h)    ; on last call to CollDetn?
               jr      z,L055      ; Jump if not
               ld      (ix-01h),0  ; If yes, reset Collision flag - we've
                                   ; already detected the current Hazard.
               and     a           ; Clear Carry
               ret

L055:          ld      (L057+1),a  ; Load counter with number of Hazards
               ld      a,(ix+09h)  ; A=Jack's position
               cp      0e0h        ; Is Jack at the bottom of the screen? If so,
               ret     nc          ; return as he can't be touching a Hazard

               ; As Jack's sprite is at least 2 cells wide, we need to check for
               ; a collision on both sides. First, Jack's position byte (which
               ; corresponds with his left side) is compared with that of every
               ; active Hazard, then the position one cell to the right is also
               ; compared.

               call    L056        ; Compare Jack position with Hazards
               ret     c           ; Finish here if there was a collision

               inc     a           ; Update position byte one cell right
               call    L056        ; Compare positions again
               ret

L056:          ; Subroutine below does the actual comparisons. It compares
               ; Jack'sposition byte in A with the Hazard position bytes
               ; starting at IX+0fh

               push    ix
               pop     hl
               ld      de,000fh    ; DE=Offset from HL to Hazard position bytes
               add     hl,de       ; HL points to Hazard position bytes
L057:          ld      bc,0000h    ; BC=Counter for no. Hazards (loaded earlier)
               cpir                ; Compare position bytes
               jr      z,L058      ; Jump if there a match
               and     a           ; No collision detected - clear Carry
               ret

L058:          ; Collision detected

               ld      (ix-01h),1  ; Set Collision flag
               scf                 ; Set Carry to indicate collision
               ret




;-------------------------------------------------------------------------------
CvtScBCD:      ; Converts Score word to 5 byte Binary Coded Decimal
;-------------------------------------------------------------------------------
; This just sets up the required variables and falls through to CvtBCD

               ld      (ix+23h),0  ; Zero Score digit 1
               ld      (ix+24h),0  ; Zero Score digit 2
               ld      (ix+25h),0  ; Zero Score digit 3
               ld      (ix+26h),0  ; Zero Score digit 4
               ld      (ix+27h),0  ; Zero Score digit 5
               ld      l,(ix-04h)
               ld      h,(ix-03h)  ; HL = Score




;-------------------------------------------------------------------------------
CvtBCD:        ; Converts a 16 bit word into a 5 byte Binary Coded Decimal
;-------------------------------------------------------------------------------
; ENTRY
; HL = 16 bit word to be converted
; IX = Pointer such that IX+23 points to 5 zero'd bytes to be filled with BCD

               ld      de,2710h    ; DE=10,000

L059:          ; This is the 10,000s digit

               and     a           ; Zero carry flag
               sbc     hl,de       ; Subtract 10,000 from word
               jr      c,L060      ; If less than zero, move to 1,000s
               inc     (ix+23h)    ; Otherwise inc BCD digit 1 (10,000s)
               jr      L059        ; and repeat

L060:          ; BCD digit 1 done, set up for digit 2

               add     hl,de       ; Add 10,000 back onto word
               ld      de,03e8h    ; DE=1,000

L061:          ; This is the 1,000s digit

               and     a           ; Zero carry flag
               sbc     hl,de       ; Subtract 1,000 from word
               jr      c,L062      ; If less than zero, move to 100s
               inc     (ix+24h)    ; Otherwise inc BCD digit 2 (1,000s)
               jr      L061        ; and repeat

L062:          ; BCD digit 2 done, set up for digit 3

               add     hl,de       ; Add 1,000 back onto word
               ld      de,0064h    ; DE=100

L063:          ; This is the 100s digit

               and     a           ; Zero carry flag
               sbc     hl,de       ; Subtract 100 from word
               jr      c,L064      ; If less than zero, move to 10s
               inc     (ix+25h)    ; Otherwise inc BCD digit 3 (100s)
               jr      L063        ; and repeat

L064:          ; BCD digit 3 done, set up for digit 4

               add     hl,de       ; Add 100 back onto word
               ld      de,000ah    ; DE=10

L065:          ; This is the 10s digit

               and     a           ; Zero carry flag
               sbc     hl,de       ; Subtract 10 from word
               jr      c,L066      ; If less than zero, move to 1s
               inc     (ix+26h)    ; Otherwise inc BCD digit 4 (10s)
               jr      L065        ; and repeat

L066:          ; BCD digit 4 done, set up for digit 5

               add     hl,de       ; Add 10 back onto word
               ld      de,0001h    ; DE=1

L067:          ; This is the 1s digit

               and     a           ; Zero carry flag
               sbc     hl,de       ; Subtract 1 from word
               ret     c           ; If less than zero, we're finished
               inc     (ix+27h)    ; Otherwise inc BCD digit 5 (1s)
               jr      L067        ; and repeat




;-------------------------------------------------------------------------------
CvtHiBCD:      ; Converts High Score word to 5 byte Binary Coded Decimal
;-------------------------------------------------------------------------------
; This just sets up the required variables for a call to CvtBCD

               ld      h,(ix+31h)
               ld      l,(ix+30h)  ; HL = High score
               ld      ix,VarsIX+5 ; Adjust IX for CvtBCD
               ld      (ix+23h),0  ; Zero High Score digit 1
               ld      (ix+24h),0  ; Zero High Score digit 2
               ld      (ix+25h),0  ; Zero High Score digit 3
               ld      (ix+26h),0  ; Zero High Score digit 4
               ld      (ix+27h),0  ; Zero High Score digit 5
               call    CvtBCD
               ld      ix,VarsIX   ; Restore variables pointer in IX
               ret




;-------------------------------------------------------------------------------
PrtHigh:       ; Prints the 5-digit High Score on InfoLine
;-------------------------------------------------------------------------------
               ld      de,50d3h    ; DE points to (22,19)=First digit after 'HI'
               ld      ix,VarsIX+5 ; Adjust IX for PtScDgts
               call    PtScDgts
               ld      ix,VarsIX   ; Restore variables pointer in IX
               ret




;-------------------------------------------------------------------------------
PrtScore:      ; Prints the 5-digit Score on InfoLine
;-------------------------------------------------------------------------------
               ld      de,50dbh    ; DE points to (22,27)=First digit after 'SC'




;-------------------------------------------------------------------------------
PtScDgts:      ; Prints the score digits to the screen
;-------------------------------------------------------------------------------
; ENTRY:
; DE=Pointer into Display - where to print

               ld      a,(ix+23h)  ; A=Score digit 1 (most sig.)
               call    GetDigDef   ; HL points to char definition
               ld      bc,0101h    ; 1x1 cell to be printed
               push    de          ; Preserve display pointer
               call    PtSprite
               pop     de

               ld      a,(ix+24h)  ; A=Score digit 2
               call    GetDigDef   ; HL points to char definition
               inc     de          ; Point to next cell along
               ld      bc,0101h    ; 1x1 cell to be printed
               push    de          ; Preserve display pointer
               call    PtSprite
               pop     de

               ld      a,(ix+25h)  ; A=Score digit 3
               call    GetDigDef   ; HL points to char definition
               inc     de          ; Point to next cell along
               ld      bc,0101h    ; 1x1 cell to be printed
               push    de          ; Preserve display pointer
               call    PtSprite
               pop     de

               ld      a,(ix+26h)  ; A=Score digit 4
               call    GetDigDef   ; HL points to char definition
               inc     de          ; Point to next cell along
               ld      bc,0101h    ; 1x1 cell to be printed
               push    de          ; Preserve display pointer
               call    PtSprite
               pop     de

               ld      a,(ix+27h)  ; A=Score digit 5 (least sig.)
               call    GetDigDef   ; HL points to char definition
               inc     de          ; Point to next cell along
               ld      bc,0101h    ; 1x1 cell to be printed
               push    de          ; Preserve display pointer
               call    PtSprite
               pop     de
               ret




;-------------------------------------------------------------------------------
GetDigDef:     ; Returns pointer to ROM character definition for digit
;-------------------------------------------------------------------------------
; Given a number between 0-9 in A, this will return with HL pointing to the ROM
; 8-byte character set definition of the same digit.
;
; ENTRY:
; A = Number between 0-9
; EXIT:
; HL = Address in ROM of 8-byte pixel definition.
; DE = Preserved

               push    de
               ld      hl,3d80h    ; HL points to char definition of '0' in ROM
               rlca
               rlca
               rlca                ; A=A*8
               ld      e,a
               ld      d,00h       ; DE=offset from 3d80h to required data
               add     hl,de       ; HL points to char definition of digit in A
               pop     de
               ret




Rhyme21:       ; 'After jumping the very'
               ; 'last gap.      - WELL DONE'
               db      2ch, 0bh, 19h, 0ah, 57h, 0fh, 1ah, 12h, 15h, 0eh, 13h
               db      4ch, 19h, 0dh, 4ah, 1bh, 0ah, 17h, 0deh, 11h, 06h, 18h
               db      59h, 0ch, 06h, 15h, 6bh, 63h, 63h, 63h, 6ah, 02h, 30h
               db      37h, 77h, 2fh, 3ah, 39h, 30h




;-------------------------------------------------------------------------------
PrtLives:      ; Prints the 'lives remaining' symbols on InfoLine
;-------------------------------------------------------------------------------
               ld      a,(ix+0ch)  ; A=Number of lives remaining
               ld      de,50c0h    ; DE=Display location to print (AT 22,0)

L068:          ld      hl,LifeSym  ; HL points to pixel def for symbol
               ld      bc,0101h    ; 1x1 cell to be printed
               push    de          ; Preserve print position
               push    af          ; Preserve lives counter
               call    PtSprite
               pop     af          ; Retrieve lives counter
               pop     de          ; Retrieve print position
               dec     a           ; Decrement lives counter
               ret     z           ; Return if printed enough symbols

               inc     de          ; Otherwise, point DE to next cell along
               jr      L068        ; Print another symbol




;-------------------------------------------------------------------------------
MdJLAtsA:      ; Modify Jline Attributes (Above)
;-------------------------------------------------------------------------------
; Sets the attributes of the 2 cells which are part of the Jline immediately
; above (or below - see alternate entry point) Jack.
;
; This is called from DrawJack when drawing/erasing a Jack sprite which overlaps
; with part of a Jline. When drawing, the ink is set to Black (Jack's colour).
; When erasing, the ink is set to red (Jline colour).
;
; The sprite in this situation is always 2 cells wide and the position byte
; refers to the left sprite column.
;
; ENTRY
; A' = Desired attributes for cells
; A = Jack's position byte
; EXIT:
; A' = Preserved
; A = Preserved

               ld      de,0000h    ; Initialise pointer into Attribs so as to
                                   ; target Jline above.
               jr      L069        ; Skip alternate entry point
;-------------------------------------------------------------------------------
MdJLAtsB:      ; Modify Jline Attributes (Below)
;-------------------------------------------------------------------------------
               ld      de,0060h    ; Initialise pointer into Attribs so as to
                                   ; target Jline below. 60h=90 cells=3 lines.

L069:          ; Calculate address of attributes byte for left Jline cell.
               ; Address = 57a0h + ( (Jline below Jack) * (96 cells) + (Jack's
               ; column) )

               push    af          ; Save 2 copies of position byte
               push    af
               and     1fh         ; Strip top 3 bits / A=Jack's screen column
               ld      c,a         ; C=Jack's screen column
               pop     af          ; Retrieve position byte
               and     0e0h        ; Isolate top 3 bits (Jline above Jack)
               rlca
               rlca
               rlca                ; Rotate them so A=Jline above Jack
               ld      b,a
               inc     b           ; B=Jline beneath Jack
               ld      hl,57a0h    ; HL points to 96 bytes before starts of Atts
               add     hl,de       ; Add initialiser (to target above/below)
               ld      de,0060h    ; 60h = 96 cells = 3 screen lines

L070:          add     hl,de       ; (Jline below Jack) * (96 cells)
               djnz    L070

               add     hl,bc       ; + (Jack's column)
                                   ; HL points to left Jline cell to be changed
               ex      af,af'      ; A=Desired attribs
               ld      (hl),a      ; Modify attribs
               inc     hl          ; Target adjacent right cell
               ld      (hl),a      ; Modify attribs
               ex      af,af'      ; Store Attribs byte back in A'
               pop     af          ; Retrieve position byte
               ret




;-------------------------------------------------------------------------------
GetHzAtt:      ; Get Hazard Attributes
;-------------------------------------------------------------------------------
; This sets A' with the desired attributes for the current Hazard being drawn
; or erased. When drawing, it sets the Ink to be one of 6 colours. When erasing
; it resets the Ink back to the game default of 0.
;
; ENTRY
; A = Offset from IX to current Hazard position byte
; EXIT
; A'= Attributes
; A = Preserved

               bit     0,(ix-06h)  ; Test the Hazard Draw/Erase flag
               jr      nz,L071     ; Jump if it's 'Draw'

               ex      af,af'      ; It's 'Erase' - set A' to screen default
               ld      a,00111000b ; Flash Off, Bright Off, Paper 7, Ink 0
               ex      af,af'      ; Retrieve A and return
               ret

L071:          ; Choose a colour depending on which Hazard we're drawing

               ; With 6 colours and up to 20 Hazards, colours are distributed as
               ; follows:

               ; Hazards 0, 6, 12, 18 - Blue
               ; Hazards 1, 7, 13, 19 - Green
               ; Hazards 2, 8, 14     - Magenta
               ; Hazards 3, 9, 15     - Yellow
               ; Hazards 4, 10, 16    - Black
               ; Hazards 5, 11, 17    - Red

               push    af          ; Save offset to current Hazard position byte
               sub     0fh         ; Change A from offset to Hazard no. (0-19)

L072:          ; Transform Hazard number (0-19) into a number between (0-6)

               sub     06h         ; Calculate the remainder when divided by 6
               jr      nc,L072     ; by subtracting 6 until below zero,
               add     a,06h       ; then add 6 back on

               rlca                ; Transform A (0-6) into a jump offset
               rlca                ; A=A*4
               ld      (L073+1),a  ; A=0, 4, 8, 12, 16, 20 or 24
               ex      af,af'      ; Prepare A' ready for Attributes..
L073:          jr      L073        ; ..and set accordingly

               ld      a,00111001b ; (+0) Ink Blue
               jr      L074

               ld      a,00111100b ; (+4) Ink Green
               jr      L074

               ld      a,00111011b ; (+8) Ink Magenta
               jr      L074

               ld      a,00111110b ; (+12) Ink Yellow
               jr      L074

               ld      a,00111000b ; (+16) Ink Black
               jr      L074

               ld      a,00111010b ; (+20) Ink Red

L074:          ex      af,af'      ; Store Attributes in A'
               pop     af          ; Retrieve offset to Hazard position byte
               ret




;-------------------------------------------------------------------------------
JlineAtts:     ; Makes the Jlines red
;-------------------------------------------------------------------------------
; This changes the ink attribute to red in every cell in screen lines 0, 3, 6
; 9, 12, 15, 18, 21 - i.e. the screen lines which hold the Jlines.

               ld      a,00111010b ; A=Attributes (Paper White, Ink Red)
               ld      de,0040h    ; Offset to advance attribs ptr (64 cells)
               ld      b,08h       ; 8 lines to change
               ld      hl,5800h    ; HL points to display attributes

L075:          ; Next Jline

               push    bc          ; Save lines counter
               ld      b,20h       ; 32 cells in a line

L076:          ; Next horizontal cell

               ld      (hl),a      ; Set attribs for current cell
               inc     hl          ; Point to next cell in line
               djnz    L076        ; Continue until the end of the line

               add     hl,de       ; Advance HL 2 screen lines down (64 cells)
               pop     bc          ; Retrieve lines counter
               djnz    L075        ; Change attribs on next line if req
               ret




;-------------------------------------------------------------------------------
SfxGfx:        ; Sound Effects & Graphics Effects
;-------------------------------------------------------------------------------
; This is called by GameLoop every frame. It plays the appropriate SFX & GFX for
; Jack's current animation. It also scans the keyboard for player input and
; regulates the speed of the game.

               ld      a,(ix-08h)  ; A=Current sfx/gfx routine
               cp      (ix-09h)    ; Has it changed since last call to SfxGfx?
               jr      z,L077      ; Carry on if not
               ld      (ix-09h),a  ; Otherwise store new routine value, and
               ld      (ix-0ah),0ffh ; reset the SFX/GFX frame counter

L077:          inc     (ix-0ah)    ; Increment SFX/GFX frame counter

               rlca                ; Multiply current routine value by 4 to
               rlca                ; make it a jump offset
               ld      (L078+1),a
L078:          jr      L078+2
               jp      SGStill     ; +0
               nop
               jp      SGRunning   ; +4
               nop
               jp      SGHitHzd    ; +8
               nop
               jp      SGGoodJmp   ; +12
               nop
               jp      SGFall      ; +16
               nop
               jp      SGBadJump   ; +20
               nop
               jp      SGStunned   ; +24


SGStill:       ; SfxGfx / Jack is standing still

               ; This animation has a sound effect for each time Jack turns his
               ; head (every 32 game frames). There are two different notes -
               ; one plays on GFXJStil animation frames 0 & 2, the other on
               ; frames 1 & 3.

               ld      a,(ix+0dh)  ; A=Animation frame
               and     3fh         ; Isolate lowest 6 bits. Has anim just begun
               jr      nz,L079     ; frame 0 or 2? If no, test for 1 or 3
               call    PlayJmp4    ; If yes, play note
               ld      hl,509      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret

L079:          cp      20h         ; Has anim just begun frame 1 or 3?
               jr      nz,L080     ; If not, skip sfx
               call    PlayJmp3    ; If yes, play note
               ld      hl,509      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret

L080:          ; No SFX to play this time

               ld      hl,997      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret


SGRunning:     ; SfxGfx / Jack is running left or right

               ; This animation plays a sound effect every 4 frames. There are
               ; two notes which play alternately. Bit 3 of the Animation Frame
               ; counter (IX+0dh) determines which note to play since it flips
               ; every 4 frames.

               ld      a,(ix+0dh)  ; A=Animation frame
               and     07h         ; Isolate lowest 3 bits. Has bit 3 just
               jr      nz,L081     ; turned 0? If no, test for 1
               call    PlayJmp4    ; If yes, play note
               ld      hl,509      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret

L081:          cp      04h         ; Has bit 3 just turned 1?
               jr      nz,L082     ; If no, skip sfx
               call    PlayJmp5    ; If yes, play note
               ld      hl,509      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret

L082:          ; No SFX to play this time

               ld      hl,997      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret


SGHitHzd:      ; SfxGfx / Jack has touched a Hazard

               ; This is a 1 frame effect. The screen is flashed magenta and a
               ; squawk SFX is generated. The current GFX/SFX routine is then
               ; set to Stunned.

               call    MagScnOn    ; Turn screen Magenta
               call    PlaySqwk    ; Play squawk SFX
               ld      hl,7207     ; Set frame delay
               call    FrmDelay    ; Short pause
               call    MagScnOff   ; Turn screen back to white
               ld      (ix-08h),6  ; Set GFX/SFX animation to Stunned
               ret


SGGoodJmp:     ; SfxGfx / Jack is in a good jump

               ; The good jump animation consists of 8 frames (4 each in Pt1 &
               ; Pt2) and there is a different note played for each.

               ld      a,(ix-0ah)  ; A=Current SFX/GFX frame
               and     07h         ; Isolate lowest 3 bits
               rlca
               rlca                ; Multiply it by 4 to make jump offset
               ld      hl,L084     ; Put return address on stack for ret after
               push    hl          ; note has been played
               ld      (L083+1),a  ; Set jump offset and play relevant note
L083:          jr      L083
               jp      PlayJmp1    ; +0
               nop
               jp      PlayJmp2    ; +4
               nop
               jp      PlayJmp3    ; +8
               nop
               jp      PlayJmp4    ; +12
               nop
               jp      PlayJmp5    ; +16
               nop
               jp      PlayJmp6    ; +20
               nop
               jp      PlayJmp7    ; +24
               nop
               jp      PlayJmp8    ; +28

L084:          ; Note played

               ld      hl,2411     ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret


SGFall:        ; SfxGfx / Jack is falling through a gap

               ; The falling animation consists of 8 frames (4 each in Pt1 &
               ; Pt2) and there is a different note played for each.
               ; NB: These are the good jump notes in reverse.

               ld      a,(ix-0ah)  ; A=Current SFX/GFX frame
               and     07h         ; Isolate lowest 3 bits
               rlca
               rlca                ; Multiply it by 4 to make jump offset
               ld      hl,L086     ; Put return address on stack for ret after
               push    hl          ; note has been played
               ld      (L085+1),a  ; Set jump offset and play relevant note
L085:          jr      L085
               jp      PlayJmp8    ; +0
               nop
               jp      PlayJmp7    ; +4
               nop
               jp      PlayJmp6    ; +8
               nop
               jp      PlayJmp5    ; +12
               nop
               jp      PlayJmp4    ; +16
               nop
               jp      PlayJmp3    ; +20
               nop
               jp      PlayJmp2    ; +24
               nop
               jp      PlayJmp1    ; +28

L086:          ; Note played

               ld      hl,2411     ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret


SGBadJump:     ; SfxGfx / Jack is in a bad jump

               ; The bad jump animation consists of 4 frames. On frame 0, 3
               ; notes are played in succession (the first 3 notes of a good
               ; jump sfx). On frames 1 & 2, a white flash GFX and electric
               ; shock SFX are played. On frame 3, the 3 notes are played again
               ; but in reverse order (the last 3 notes of a fall sfx).

               ld      a,(ix-0ah)  ; A=Current SFX/GFX frame
               and     a           ; Are we on frame 0?
               jr      nz,L087     ; Jump if not

               ; Frame 0 - play notes

               call    PlayJmp1
               ld      hl,3001     ; Set frame delay
               call    FrmDelay    ; Short pause
               call    PlayJmp2
               ld      hl,3001     ; Set frame delay
               call    FrmDelay    ; Short pause
               call    PlayJmp3
               ld      hl,3001     ; Set frame delay
               call    FrmDelay    ; Short pause
               ret

L087:          ; Not frame 0.

               cp      03h         ; Are we on frame 3?
               jr      nc,L088     ; Jump if so

               ; Frame 1 or 2 - Play GFX/SFX

               call    BrightOn    ; Flash screen bright white
               call    PlayShck    ; Play electric shock SFX
               call    BrightOff   ; Reset screen colour
               ld      hl,9001     ; Set frame delay
               call    FrmDelay    ; Short pause
               ret

L088:          ; Frame 3 - play notes

               call    PlayJmp3
               ld      hl,3001     ; Set frame delay
               call    FrmDelay    ; Short pause
               call    PlayJmp2
               ld      hl,3001     ; Set frame delay
               call    FrmDelay    ; Short pause
               call    PlayJmp1
               ld      hl,3001     ; Set frame delay
               call    FrmDelay    ; Short pause
               ret


SGStunned:     ; SfxGfx / Jack is stunned

               ; This animation plays a sound effect every 8 frames. There are
               ; four notes which play on a rotation. Bits 4 & 3 of the SFX/GFX
               ; Frame counter (IX-0ah) determine which note to play since they
               ; update every 8 frames.

               ld      a,(ix-0ah)  ; A=Current SFX/GFX frame
               ld      b,a         ; Save a copy
               and     07h         ; Test low 3 bits (if they're all 0, bits
                                   ; 4&3 must have just updated)
               ld      a,b         ; Retrieve copy
               jr      nz,L091     ; Skip sfx if frame not multiple of 8

               and     18h         ; Isolate bits 4&3 to determine which note
               ld      (L089+1),a  ; Set jump offset and play relevant note
L089:          jr      L089

               call    PlayStn1    ; +0
               jr      L090
               nop
               nop
               nop
               call    PlayStn2    ; +8
               jr      L090
               nop
               nop
               nop
               call    PlayStn3    ; +16
               jr      L090
               nop
               nop
               nop
               call    PlayStn4    ; +24

L090:          ; Note played

               ld      hl,509      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret

L091:          ; No SFX to play this time

               ld      hl,997      ; Set frame delay
               call    FrmDelay    ; Regulate game speed
               ret




;-------------------------------------------------------------------------------
FrmDelay:      ; Frame Delay - regulates the speed of the game
;-------------------------------------------------------------------------------
; This is called every frame from SfxGfx. The value passed in HL determines the
; length of a delay loop which in turn regulates the speed of the game.
; The value passed reflects how much processing there is to do elsewhere for the
; current frame. It is then further adjusted based on the number of Hazards to
; draw in the current level.
;
; This routine also scans the keyboard for input (including for Pause) and
; further randomizes the game's random value in IX-0bh.
;
; ENTRY
; HL = Length of Frame Delay

               push    hl          ; Save delay value
               call    ChkPause    ; Has player pressed Pause?
               call    GetInput    ; Check for other keys
               pop     hl          ; Retrieve delay value

               ; Reduce the delay value based on the number of active Hazards

               ld      de,001eh    ; Reduce by 30 for each Hazard
               ld      a,(ix+0eh)  ; A=No. of Hazards
               and     a           ;
               jr      z,L093      ; Skip if 0 Hazards
               ld      b,a         ; Use no. of Hazards as loop counter

L092:          sbc     hl,de       ; Reduce delay value by 30
               ret     c           ; Return if delay value's gone below 0
               djnz    L092        ; Repeat for every active Hazard

L093:          ; Delay loop

               inc     (ix-0bh)    ; Inc Random Number
               dec     hl          ; Decrease delay counter
               ld      a,l
               or      h           ; Is it 0?
               jr      nz,L093     ; Loop until 0
               ret




;-------------------------------------------------------------------------------
ChkPause:     ; Has the player pressed Pause?
;-------------------------------------------------------------------------------
; This scans the keyboard for the Pause key 'Z'. If it's pressed, a pause is
; implemented by waiting for 'Z' to be pressed again.

               ld      bc,0fefeh   ; B=Keyboard section containing 'Z'
                                   ; C=Keyboard port
               in      a,(c)       ; Scan keyboard
               bit     1,a         ; Bit 1 = 'Z'. Is it pressed?
               ret     nz          ; Return if not

               ; Player has paused the game. Wait until Z is pressed again.

               call    ScnDelay    ; Wait before re-scanning keyboard

L094:          in      a,(c)       ; Re-scan keyboard
               bit     1,a         ; Bit 1 = 'Z'. Is it pressed?
               jr      nz,L094     ; Keep scanning until it is

               ; Player unpaused the game.

               call    ScnDelay    ; Brief delay before returning
               ret




;-------------------------------------------------------------------------------
ScnDelay:      ; Waits a short time
;-------------------------------------------------------------------------------
; Called from ChkPause to insert a delay which gives the player time to release
; the Pause key so one keypress isn't read multiple times.

               ld      hl,7d00h    ; Number of times to loop (32,000)

L095:          dec     hl
               ld      a,l
               or      h
               jr      nz,L095     ; Loop until HL=0
               ret




;-------------------------------------------------------------------------------
; PlayJmp Routines
;-------------------------------------------------------------------------------
; These play the individual notes in the Standing Still, Running, Good & Bad
; Jumps and Falling animations.

PlayJmp1:      ld      hl,0690h    ; Pitch
               ld      de,0003h    ; Duration
               jp      Beep

PlayJmp2:      ld      hl,0584h    ; Pitch
               ld      de,0003h    ; Duration
               jp      Beep

PlayJmp3:      ld      hl,04a3h    ; Pitch
               ld      de,0003h    ; Duration
               jp      Beep

PlayJmp4:      ld      hl,03e6h    ; Pitch
               ld      de,0004h    ; Duration
               jp      Beep

PlayJmp5:      ld      hl,0347h    ; Pitch
               ld      de,0005h    ; Duration
               jp      Beep

PlayJmp6:      ld      hl,02c2h    ; Pitch
               ld      de,0006h    ; Duration
               jp      Beep

PlayJmp7:      ld      hl,0252h    ; Pitch
               ld      de,0008h    ; Duration
               jp      Beep

PlayJmp8:      ld      hl,01f4h    ; Pitch
               ld      de,0009h    ; Duration
               jp      Beep




;-------------------------------------------------------------------------------
PlayShck:      ; Plays the electric shock SFX (when Jack hits head on Jline)
;-------------------------------------------------------------------------------
; The electric shock noise is generated from 512 successive calls to the ROM
; Beep routine using 'random' data from the ROM as input.

               push    ix          ; Save data index
               ld      bc,0200h    ; Set loop counter to 512
               ld      ix,0000h    ; Point to random data in ROM

L096:          ld      l,(ix+00h)  ; Get random byte from ROM..
               ld      a,0fh
               and     l           ; ..and make it 0-15
               ld      l,a
               ld      h,00h       ; Put it in HL (Pitch)
               ld      e,(ix+01h)  ; Get another random byte from ROM..
               ld      a,03h
               and     e           ; ..and make it 0-7
               ld      e,a
               ld      d,00h       ; Put it in DE (Duration)
               push    bc          ; Save counter
               call    Beep        ; Make sound
               pop     bc          ; Retrieve counter
               inc     ix          ; Point to next random number in ROM
               dec     bc
               ld      a,c
               or      b
               jr      nz,L096     ; Repeat 512 times
               pop     ix          ; Reset IX to point to game data
               ret




;-------------------------------------------------------------------------------
PlaySqwk:      ; Plays the squawk-like SFX (when Jack hits Hazard)
;-------------------------------------------------------------------------------
; The squawk noise is generated from 84 successive calls to the ROM Beep routine
; using 'random' data from the ROM as input.

               push    ix          ; Save data index
               ld      b,54h       ; Set loop counter to 84
               ld      ix,0064h    ; Point to random data in ROM

L097:          ld      l,(ix+00h)
               ld      h,00h       ; Put random number into HL (Pitch)
               ld      e,(ix+01h)  ; Put another into DE (Duration)..
               ld      a,07h
               and     e           ; ..but make it between 0-7
               ld      e,a
               ld      d,00h
               push    bc          ; Save counter
               call    Beep        ; Make sound
               pop     bc          ; Retrieve counter
               inc     ix          ; Point to next random number in ROM
               djnz    L097        ; Repeat 84 times
               pop     ix          ; Reset IX to point to game data
               ret




;-------------------------------------------------------------------------------
; PlayStn Routines
;-------------------------------------------------------------------------------
; These play the individual notes in the Stunned animation.

PlayStn1:      ld      hl,0069h    ; Pitch
               ld      de,001ch    ; Duration
               jp      Beep

PlayStn2:      ld      hl,0073h    ; Pitch
               ld      de,0018h    ; Duration
               jp      Beep

PlayStn3:      ld      hl,007dh    ; Pitch
               ld      de,0017h    ; Duration
               jp      Beep

PlayStn4:      ld      hl,0088h    ; Pitch
               ld      de,0014h    ; Duration
               jp      Beep




;-------------------------------------------------------------------------------
BrightOn:      ; Sets the Bright attribute in every screen cell
;-------------------------------------------------------------------------------
               ld      hl,5800h    ; HL points to Display Attributes
               ld      bc,0300h    ; BC=Size of Attributes

L098:          set     6,(hl)      ; Set Bright bit
               inc     hl          ; Point to next Attribute byte
               dec     bc          ; Decrease counter
               ld      a,c
               or      b           ; Is it zero?
               jr      nz,L098     ; Loop until all Attributes changed
               ret




;-------------------------------------------------------------------------------
BrightOff:     ; Turns off the Bright attribute in every screen cell
;-------------------------------------------------------------------------------
               ld      hl,5800h    ; HL points to Display Attributes
               ld      bc,0300h    ; BC=Size of Attributes

L099:          res     6,(hl)      ; Turn off Bright bit
               inc     hl          ; Point to next Attribute byte
               dec     bc          ; Decrease counter
               ld      a,c
               or      b           ; Is it zero?
               jr      nz,L099     ; Loop until all Attributes changed
               ret




;-------------------------------------------------------------------------------
MagScnOn:      ; Sets screen paper colour to magenta
;-------------------------------------------------------------------------------
; This assumes the paper colour is currently white, as it works by turning off
; the Green bit in every Display Attribute byte.

               ld      hl,5800h    ; HL points to Display Attributes
               ld      bc,0300h    ; BC=Size of Attributes

L100:          res     5,(hl)      ; Turn off Paper Green bit
               inc     hl          ; Point to next Attribute byte
               dec     bc          ; Decrease counter
               ld      a,c
               or      b           ; Is it zero?
               jr      nz,L100     ; Loop until all Attributes changed
               ret




;-------------------------------------------------------------------------------
MagScnOff:     ; Returns screen paper colour to white
;-------------------------------------------------------------------------------
; This assumes the paper colour is currently magenta, as it works by turning on
; the Green bit in every Display Attribute byte.

              ld      hl,5800h    ; HL points to Display Attributes
              ld      bc,0300h    ; BC=Size of Attributes

L101:         set     5,(hl)      ; Set Paper Green bit
              inc     hl          ; Point to next Attribute byte
              dec     bc          ; Decrease counter
              ld      a,c
              or      b           ; Is it zero?
              jr      nz,L101     ; Loop until all Attributes changed
              ret




Rhyme1:        ; 'Jumping Jack is quick and bold'
               ; 'With skill his story will unfold'
               db      35h, 1ah, 12h, 15h, 0eh, 13h, 4ch, 35h, 06h, 08h, 50h
               db      0eh, 58h, 16h, 1ah, 0eh, 08h, 50h, 06h, 13h, 49h, 07h
               db      14h, 11h, 0c9h, 02h, 0eh, 19h, 4dh, 18h, 10h, 0eh, 11h
               db      51h, 0dh, 0eh, 58h, 18h, 19h, 14h, 17h, 5eh, 1ch, 0eh
               db      11h, 51h, 1ah, 13h, 0bh, 14h, 11h, 09h




;-------------------------------------------------------------------------------
UpdJkFrm:      ; Update Jack's frame
;-------------------------------------------------------------------------------
; This is called after Jack has been erased. It copies the pre-prepared Next
; Frame data (position, animation, animation frame) into the Current Frame
; variables ready for quick drawing of his next frame.

               ld      a,(ix+08h)
               ld      (ix+2dh),a  ; Update animation

               ld      a,(ix+09h)
               ld      (ix+2eh),a  ; Update position

               ld      a,(ix+0dh)
               ld      (ix+2fh),a  ; Update animation frame
               ret




;-------------------------------------------------------------------------------
PrtInfoTxt:    ; Prints the text 'HI' & 'SC' on InfoLine
;-------------------------------------------------------------------------------
               ld      hl,3e40h    ; HL points to char definition of 'H' in ROM
               ld      de,50d1h    ; DE=Display location to print (AT 22,17)
               ld      bc,0101h    ; 1x1 cell to be printed
               call    PtSprite

               ld      hl,3e48h    ; HL points to char definition of 'I' in ROM
               ld      de,50d2h    ; DE=Display location to print (AT 22,18)
               ld      bc,0101h    ; 1x1 cell to be printed
               call    PtSprite

               ld      hl,3e98h    ; HL points to char definition of 'S' in ROM
               ld      de,50d9h    ; DE=Display location to print (AT 22,25)
               ld      bc,0101h    ; 1x1 cell to be printed
               call    PtSprite

               ld      hl,3e18h    ; HL points to char definition of 'C' in ROM
               ld      de,50dah    ; DE=Display location to print (AT 22,26)
               ld      bc,0101h    ; 1x1 cell to be printed
               call    PtSprite
               ret




;-------------------------------------------------------------------------------
MdInfAts:      ; Modify InfoLine Attributes
;-------------------------------------------------------------------------------
; This is called from DrawJack when Jack is at the bottom of the screen and
; potentially clashing with the magenta ink on the InfoLine.
;
; The attributes for the 2 cells that form Jack's upper half (i.e. those on
; screen line 22 - the InfoLine) are changed to black (when drawing) and back to
; magenta (when erasing).
;
; ENTRY
; A = Jack's position byte

               bit     0,(ix+32h)  ; Test Jack's draw/erase flag
               ld      c,00111011b ; C=Attribs byte (Paper White, Ink Magenta)
               jr      z,L102      ; Continue if erasing
               ld      c,00111000b ; Otherwise Ink Black if drawing

L102:          ld      hl,5ac0h    ; HL points to Attribs for (22,0)
               sub     0e0h        ; Adjust Jack position byte to just leave
                                   ; horizontal cell position (0-30)
               ld      e,a
               ld      d,00h       ; Add to HL, so HL points to Attribs byte for
               add     hl,de       ; Jack's top-left cell
               ld      (hl),c      ; Update Attribs on screen
               inc     hl          ; Target Jack's top-right cell
               ld      (hl),c      ; Update Attribs on screen
               ret




;-------------------------------------------------------------------------------
RotHzrds:      ; Rotates the Hazards GFX data in memory
;-------------------------------------------------------------------------------
; The Hazards GFX data occupies 1920 consecutive bytes in memory (192 bytes per
; Hazard). This routine rotates that memory by 192 bytes so the first Hazard
; becomes the last.
;
; Step by step - the lowest 192 bytes are put in a temporary buffer (it uses
; 5b00h, the 16/48K Spectrum printer buffer), the rest of the data is moved
; down to fill the space and then the original 192 bytes are placed on the top.
;
; EXIT
; BC = Preserved

               push    bc
               ld      hl,GFXHzrds ; HL points to Hazards data
               ld      de,5b00h    ; DE points to Printer buffer
               ld      bc,00c0h    ; BC=192 bytes to move
               ldir                ; Copy 192 bytes to buffer

               ld      de,GFXHzrds ; DE points to Hazards data
               ld      bc,06c0h    ; BC=1728 bytes to move down
               ldir                ; Copy 1728 bytes down to fill space

               ld      hl,5b00h    ; HL points to original 192 bytes in buffer
               ld      de,GFXHzrds+1728 ; DE points to new space at top
               ld      bc,00c0h    ; Copy bytes back from printer buffer
               ldir

               pop     bc
               ret




;-------------------------------------------------------------------------------
GameLost:      ; Plays final SFX and shows Game Over Screen
;-------------------------------------------------------------------------------
; This is called when Jack has lost his final life. It plays the Falling SFX 3
; times then falls through to the Game Over sequence.

               ld      bc,0304h    ; B=3 times to play, C=Falling
               call    PlaySFX




;-------------------------------------------------------------------------------
GameOver:      ; The Game Over sequence
;-------------------------------------------------------------------------------
; This is called if Jack has died, or if the player has just completed the very
; last level (in which case this follows the final Completed Level screen).

               ld      (ix+35h),25 ; Set print speed (used by PrtDelay)
               call    YelScrn
               jr      GmOvScrn




;-------------------------------------------------------------------------------
YelScrn:       ; Clears the screen to yellow and prints Jumping Jack title.
;-------------------------------------------------------------------------------
; This is the basis for either a 'Game Over' or 'Completed Level' screen.

               ld      a,00110001b ; A=Attributes (Paper Yellow, Ink Black)
               call    ClrScreen   ; Clear screen and fill it yellow

               ld      a,06h
               out     (0feh),a    ; Set the Border to yellow

               ; Draw green rectangle to go behind 'JUMPING JACK' text

               ld      bc,0320h    ; B=Rect Height, C=Attributes (Paper Green)
               ld      a,10h       ; A=Rect Width
               ld      hl,5848h    ; HL points to (2,8) in Attributes memory
               call    ColRect     ; Draw green rectangle

               ; Print 'JUMPING JACK' text

               ld      hl,Text1    ; HL points to encrypted chars
               ld      b,0bh       ; 11 encrypted chars to decode
               ld      de,406ah    ; DE points to (3,10) in Display memory
               call    PrtEText
               ret




;-------------------------------------------------------------------------------
GmOvScrn:      ; Draws the 'Game Over' screen & waits for ENTER to be pressed
;-------------------------------------------------------------------------------

               ; Draw cyan rectangle to go behind 'FINAL SCORE' text

               ld      a,16h       ; A=Rect Width
               ld      bc,0528h    ; B=Rect Height, C=Attributes (Paper Cyan)
               ld      hl,5925h    ; HL points to (9,5) in Attributes memory
               call    ColRect     ; Draw cyan rectangle

               ; Print 'FINAL SCORE' text

               ld      hl,Text2    ; HL points to encrypted chars
               ld      b,0ah       ; 10 encrypted chars to decode
               ld      de,4847h    ; DE points to (10,7) in Display memory
               call    PrtEText

               ; Print Score

               ld      de,4854h    ; DE points to (10,20) in Display memory
               call    PtScDgts    ; Prints Score digits at (10,20)

               ; Print 'WITH' text

               ld      hl,Text6    ; HL points to encrypted chars
               ld      de,4888h    ; DE points to (12,8) in Display memory
               ld      b,04h       ; 4 encrypted chars to decode
               call    PrtEText

               ; Print number of Hazards in last level

               ld      de,488dh    ; DE points to (12,13) in Display memory
               ld      a,(ix+0eh)  ; A=Number of Hazards in last level
               call    PtHzDgts

               ; Print 'HAZARDS' or 'HAZARD' text

               ld      hl,Text7    ; HL points to encrypted chars
               ld      b,07h       ; 7 encrypted chars to decode
               ld      a,(ix+0eh)  ; A=Number of Hazards in last level
               cp      01h         ; Was there only 1?
               jr      nz,L103     ; If not, carry on
               dec     b           ; If there was, decrease length of string to
                                   ; be printed so we write 'HAZARD' singular
L103:          ld      de,4891h    ; DE points to (12,17) in Display memory
               call    PrtEText

               ; Have we got a new High Score?

               ld      d,(ix-03h)
               ld      e,(ix-04h)  ; DE=Score at the end of game
               ld      h,(ix+31h)
               ld      l,(ix+30h)  ; HL=Previous High Score
               and     a           ; Clear Carry flag
               sbc     hl,de       ; Is the new score more?
               jr      nc,L104     ; If not, skip the New High message

               ; We have a new High Score

               push    de          ; Save new High Score

               ; Draw flashing magenta rectangle to go behind 'NEW HIGH' text

               ld      bc,039fh    ; B=Rect Height
                                   ; C=Atts (Flash On, Paper Magenta, Ink White)
               ld      a,0ch       ; A=Rect Width
               ld      hl,5a0ah    ; HL points to (16,10) in Attributes memory
               call    ColRect     ; Draw flashing rectangle

               ; Print 'NEW HIGH' text

               ld      hl,Text3    ; HL points to encrypted chars
               ld      b,07h       ; 7 encrypted chars to decode
               ld      de,502ch    ; DE points to (17,12) in Display memory
               call    PrtEText

               pop     de          ; Retrieve new High Score..
               ld      (ix+31h),d
               ld      (ix+30h),e  ; ..and overwite the previous one

L104:          ; Print 'Press ENTER to replay' text

               ld      hl,Text4    ; HL points to encrypted chars
               ld      b,12h       ; 18 encrypted chars to decode
               ld      de,50c5h    ; DE points to (22,5) in Display memory
               call    PrtEText

L105:          ; Wait for ENTER to be pressed

               ld      bc,0bffeh   ; B=Keyboard section containing ENTER
                                   ; C=Keyboard port
               in      a,(c)       ; Scan keyboard
               bit     0,a         ; Bit 0 represents 'ENTER'. Is it pressed?
               jr      nz,L105     ; Loop until it is
               ret




;-------------------------------------------------------------------------------
ColRect:       ; Draws a coloured rectangle by changing the display attributes
;-------------------------------------------------------------------------------
; ENTRY
; HL = Pointer into Atrributes memory for top-left cell of rectangle
;  A = Width of rectangle
;  B = Height of rectangle
;  C = Attributes for rectangle

               push    bc          ; Save Height
               push    hl          ; Save pointer
               ld      b,a         ; B=Width counter

L106:          ld      (hl),c      ; Write desired attribute to memory
               inc     hl          ; Point to next cell along
               djnz    L106        ; Repeat for all cells in this row

               pop     hl          ; Reset counter to first cell in this row
               ld      de,0020h
               add     hl,de       ; Move pointer 32 cells along (1 cell down)
               pop     bc          ; Retrieve Height counter
               djnz    ColRect     ; Repeat for number of rows necessary
               ret




;-------------------------------------------------------------------------------
PrtEText:      ; Prints a string of encrypted text
;-------------------------------------------------------------------------------
; This uses DecptTxt to translate the encrypted chars into character codes but
; does it's own translation of Bits 7 & 6 in the encrypted chars - which signify
; other formatting and characters to insert.
; PtSprite is used to put each character on screen.
;
; ENTRY:
; HL = Pointer to encrypted text
; DE = Pointer into Display memory - where to print
;  B = Length of encrypted text (NB. Not necessarily same as unencrypted length)

               push    bc          ; Save length counter
               push    hl          ; Save pointer to next character
               ld      a,(hl)      ; A=Next encrypted character
               push    af          ; Save a copy
               call    DecptTxt    ; A=Character code-32

               ; 3d00h + (A*8) = Address of character pixel definition in ROM

               ld      hl,3d00h    ; HL points to ROM char set pixel definitions
               and     a           ; Does A=0? (i.e. it's a SPACE character)
               jr      z,L108      ; If so, go straight to printing it
               ld      b,a         ; Otherwise, add 8*A to HL

L107:          push    bc
               ld      bc,0008h
               add     hl,bc       ; HL points to next ROM char pixel definition
               pop     bc
               djnz    L107        ; Keep going until we reach our char

L108:          ; HL = Address of character pixel definition in ROM
               ; DE = Pointer into Display memory - where to print

               push    de          ; Save copy of Display pointer
               ld      bc,0101h    ; 1x1 cell to be printed
               call    PtSprite

               pop     de          ; Retrieve Display pointer
               inc     de          ; Point to next cell for next character
               pop     af          ; Retrieve encrypted char just printed
               call    L109        ; Was there formatting info as well?
               call    PrtDelay    ; Pause briefly
               pop     hl          ; Retrieve pointer to encrypted text
               inc     hl          ; Point to next character for decryption
               pop     bc          ; Retrieve length counter
               djnz    PrtEText    ; Print next character
               ret

L109:          ; Were bits 7 or 6 set in the encrypted character?
               ; Bit 6 means a SPACE should be inserted next.

               ld      bc,0101h    ; Set BC ready for possible call to PtSprite
               and     0c0h        ; Isolate top 2 bits in encrypted char
               ret     z           ; Return if neither are set

               cp      40h         ; Is just bit 6 set? (i.e. print SPACE next)
               jr      nz,L110     ; If not, check for bit 7
               ld      hl,3d00h    ; HL points to ROM pixel definition for SPACE
               push    de          ; Save copy of Display pointer
               call    PtSprite    ; Print a SPACE
               pop     de          ; Retrieve Display pointer
               inc     de          ; Point to next cell for next character
               ret

L110:          ; Bit 7 means print 3 Full Stops next (...)

               cp      80h         ; Is just bit 7 set?
               jr      nz,L112     ; If not, bits 7 AND 6 must be set
               ld      a,03h       ; 3 Full Stops to print

L111:          push    af          ; Save Full Stop counter
               ld      hl,3d70h    ; HL points to ROM pixel def for Full Stop
               push    bc          ; Save 1x1 cell info for PtSprite
               push    de          ; Save copy of Display pointer
               call    PtSprite    ; Print a Full Stop
               call    PrtDelay    ; Pause briefly
               pop     de          ; Retrieve Display pointer
               inc     de          ; Point to next cell for next character
               pop     bc          ; Retrieve 1x1 cell info for PtSprite
               pop     af          ; Retrieve full stop counter
               dec     a
               jr      nz,L111     ; Repeat until 3 are printed
               ret

L112:          ; If both bits 7 & 6 were set, it means re-position the Display
               ; pointer to (18,0).  This is used when printing the second line
               ; of each rhyme.

               ld      de,5040h    ; DE points to (18,0) in Display memory
               ret




;-------------------------------------------------------------------------------
DecptTxt:      ; Decrypts encoded characters
;-------------------------------------------------------------------------------
; This takes an encoded byte of text, and returns the unencoded character's
; offset from SPACE(32) in the Spectrum character set.
; i.e. It returns 32 less than the Spectrum character code for the unencoded
; character.
;
; Encoded bytes contain a mixture of (C)haracter and (F)ormatting information.
;
;   7 6 5 4 3 2 1 0
;   F F C C C C C C
;
; Bits 7 & 6 contain formatting information which is used by PrtEText.
;     Bit 7 means print three full stops (...) next.
;     Bit 6 means print a SPACE next.
;     Bits 7&6 together mean reposition the Display pointer to (18,0)
;
; Bits 5 - 0 hold a number 0-63 which represents a character as follows:

; 00-05 = U-Z (Spectrum character codes 85-90)
; 06-31 = a-z (Spectrum character codes 97-122)
; 32-34 = "#" - "%" (Spectrum character codes 35-37)
;    35 = SPACE (Spectrum character code 32)
; 36-43 = "'" - "." (Spectrum character codes 39-46)
; 44-63 = A-T (Spectrum character codes 65-84)
;
; NB. Of the non-letter codes, the game only makes use of 35(SPACE), 36('),
; 42(-) and 43(.)
;
; ENTRY:
; A = Encrypted character byte
; EXIT:
; A = Spectrum character code-32

               and     3fh         ; Zero bits 7&6 (strip formatting info)

               cp      06h         ; Is it 'U'-'Z'?
               jr      nc,L113     ; If not, test for 'a'-'z'
               add     a,35h       ; If so, decode and return
               ret

L113:          cp      20h         ; Is it 'a'-'z'
               jr      nc,L114     ; If not, test for non-letters
               add     a,3bh       ; If so, decode and return
               ret

L114:          cp      2ch         ; Is it a non-letter character?
               jr      nc,L115     ; If not, it must be 'A'-'T'
               sub     1dh         ; If so, decode
               cp      06h         ; Was it SPACE?
               ret     nz          ; If not, return
               xor     a           ; If it was, decode and return
               ret

               ret                 ; Unused instruction (never reached)

L115:          sub     0bh         ; It's 'A'-'T' - decode and return
               ret




Text1:         ; 'JUMPING JACK'
               db      35h, 00h, 38h, 3bh, 34h, 39h, 72h, 35h, 2ch, 2eh, 36h

Text2:         ; 'FINAL SCORE'
               db      31h, 34h, 39h, 2ch, 77h, 3eh, 2eh, 3ah, 3dh, 30h

Text3:         ; 'NEW HIGH'
               db      39h, 30h, 42h, 33h, 34h, 32h, 33h

Text4:         ; 'Press ENTER to replay'
               db      3bh, 17h, 0ah, 18h, 58h, 30h, 39h, 3fh, 30h, 7dh, 19h
               db      54h, 17h, 0ah, 15h, 11h, 06h, 1eh




;-------------------------------------------------------------------------------
LevlDone:      ; Plays the end of level SFX & calls the Completed Level screen
;-------------------------------------------------------------------------------
               inc     (ix+0eh)    ; Increment Level / No. of Hazards counter

               ; At this point Jack will have just completed a Good Jump Part 1
               ; animation (as part 2 is never played if jumping through the
               ; top Jline). However, the Good Jump SFX will only have played 4
               ; of the 8 notes - so need to complete it.

               ld      b,04h       ; 4 remaining notes to play

L116:          push    bc          ; Save counter
               call    SfxGfx      ; Play next note in sequence
               pop     bc          ; Retrieve counter
               djnz    L116        ; Loop until 4 notes played

               ; Now play the whole Good Jump SFX 3 more times

               ld      bc,0303h    ; B=3 times to play, C=Good Jump
               call    PlaySFX     ; Play it

               ; Launch completed level screen

               ld      (ix+35h),1  ; Set print speed (used by PrtDelay)
               call    YelScrn     ; Prepare screen
               jr      CpLvScrn    ; Show Completed Level screen




;-------------------------------------------------------------------------------
PlaySFX:       ; Plays a complete SFX sequence a number of times
;-------------------------------------------------------------------------------
; This is called when Jack has completed a level or lost the game. It plays a
; complete SFX sequence (Good Jump or Fall) a specified number of times. To play
; each sequence, SfxGfx is called 8 times (once for each note in the sequence).
;
; ENTRY
; B = Number of times to play sequence
; C = SFX to play (Used as a value for IX-08h so 3=Good Jump, 4=Fall)

               push    bc          ; Save sequence counter
               ld      b,08h       ; 8 notes to play in a sequence
               ld      (ix-0ah),0ffh ; Reset SfxGfx frame counter
               ld      (ix-08h),c  ; Set SfxGfx routine to play

L117:          push    bc          ; Save note counter
               call    SfxGfx      ; Play note
               pop     bc          ; Retrieve note counter
               djnz    L117        ; Play 8 notes

               pop     bc          ; Retrieve sequence counter
               djnz    PlaySFX     ; Repeat whole sequence as required
               ret




;-------------------------------------------------------------------------------
CpLvScrn:      ; The 'Completed Level' screen
;-------------------------------------------------------------------------------
; EXIT
; C = Flag set if there are more levels to play

               ld      a,(ix+0eh)  ; A=Number of next level
               cp      15h         ; Has player just completed final level?
               jr      z,CpLvCont  ; Skip text about Next Level if yes..

               ; Draw white rectangle to go behind 'NEXT LEVEL -     HAZARDS'
               ; text

               ld      bc,0339h    ; B=Rect Height
                                   ; C=Attributes (Paper White, Ink Blue)
               ld      a,1ch       ; A=Rect Width
               ld      hl,5902h    ; HL points to (8,2) in Attributes memory
               call    ColRect     ; Draw white rectangle

               ; Print 'NEXT LEVEL -     HAZARD(S)' text

               ld      hl,Text5    ; HL points to encrypted chars
               ld      b,13h       ; 19 encrypted chars to decode
               ld      a,(ix+0eh)  ; A=Number of Hazards in next level
               push    af          ; Save this
               cp      01h         ; Is there 1 Hazard in next level?
               jr      nz,L118     ; If not, carry on
               ld      b,12h       ; Otherwise, decrease length of string to
                                   ; be printed so we write 'HAZARD' singular
L118:          ld      de,4824h    ; DE points to (9,4) in Display memory
               call    PrtEText

               ; Print the number of Hazards digit(s)

               pop     af          ; Retrieve number of Hazards in next level
               ld      de,4831h    ; DE points to (9,17) in Display memory
               call    PtHzDgts
               jr      CpLvCont    ; Continue Completed Level screen




;-------------------------------------------------------------------------------
PtHzDgts:      ; Prints the digits for number of Hazards to the screen
;-------------------------------------------------------------------------------
; ENTRY
; DE = Address in Display memory - where to print
;  A = Number of Hazards

               push    af          ; Save number to print
               push    de          ; Save Display pointer
               cp      0ah         ; Is the number less than 10? (i.e. 1 digit)
               jr      c,L120      ; Jump if yes..

               ; We have a 2-digit number. Start by printing the first digit
               ; which is 1 or 2.

               cp      14h         ; Is the number 20?
               ld      hl,3d88h    ; HL points to ROM pixel definition for '1'
               jr      nz,L119     ; Print this unless A=20. In which case..
               ld      hl,3d90h    ; HL points to ROM pixel definition for '2'

L119:          ld      bc,0101h    ; 1x1 cell sprite to print
               call    PtSprite    ; Print first digit

L120:          ; We've either printed the first digit or there wasn't one - now
               ; print the remaining digit.

               pop     de          ; Retrieve Display pointer
               pop     af          ; Retrieve number to be printed
               inc     de          ; Move Display pointer to next cell along

L121:          sub     0ah         ; Subtract 10 in case it was 2 digits
               jr      nc,L121     ; If it's still zero or above, repeat

               add     a,0ah       ; Now add 10 back, so we have single digit
               call    GetDigDef   ; HL points to ROM digit pixel def
               ld      bc,0101h    ; 1x1 cell sprite to print
               call    PtSprite    ; Print remaining digit
               ret




;-------------------------------------------------------------------------------
CpLvCont:      ; Continuation of the Completed Level screen
;-------------------------------------------------------------------------------
               ld      b,02h       ; Length of delay
               call    CLDelay     ; Pause before displaying rhyme

               ; Print the next line(s) of the rhyme

               ; The lines of the rhyme are stored as encrypted text, scattered
               ; throughout memory.  The locations and lengths of each line are
               ; stored in a table at RhymOffs. For each line of the rhyme, the
               ; table contains a 2-byte address and 1-byte length of encrypted
               ; characters in that line. So:

               ; RhymOffs + (Last Level * 3) = Address of next line of rhyme
               ; RhymOffs + (Last Level * 3) + 2 = Length of encrypted chars

               ld      a,(ix+0eh)  ; A=Number of next level
               dec     a           ; A=Number of last level
               ld      e,a
               rlca
               add     a,e         ; A=A*3
               ld      e,a
               ld      d,00h       ; DE=Offset into RhymOffs table
               ld      hl,RhymOffs
               add     hl,de       ; HL points to 3-byte data in table
               ld      e,(hl)      ; Get address low-byte..
               inc     hl          ; ..and high byte
               ld      d,(hl)      ; DE=Address of next rhyme line chars
               inc     hl
               ld      b,(hl)      ; B=Length of encryted chars
               ex      de,hl       ; HL=Address of next rhyme line chars
               ld      de,5000h    ; DE points to (16,0) in Display memory
               ld      (ix+35h),60 ; Set print speed (used by PrtDelay)
               call    PrtEText    ; Print the next rhyme line(s)

               ; Rhyme printed. Brief pause before continuing.

               ld      b,01h       ; Length of delay
               call    CLDelay     ; Pause before next part of screen

               ; Has the player earned a new life? One new life is awarded
               ; before the start of levels 6, 11 & 16.

               ld      a,(ix+0eh)  ; A=Number of next level
               cp      06h         ; Is player about to start level 6?
               jr      z,L122      ; Jump if yes..
               cp      0bh         ; Is player about to start level 11?
               jr      z,L122      ; Jump if yes..
               cp      10h         ; Is player about to start level 16?
               jr      nz,L123     ; Skip new life section if no..

L122:          ; New life to be awarded

               inc     (ix+0ch)    ; Increment lives counter

               ; Draw flashing magenta rectangle to go behind 'EXTRA LIFE' text

               ld      bc,039fh    ; B=Rect Height
                                   ; C=Atts (Flash On, Paper Magenta, Ink White)
               ld      a,0eh       ; A=Rect Width
               ld      hl,5aa9h    ; HL points to (21,9) in Attributes memory
               call    ColRect     ; Draw flashing rectangle

               ; Print 'EXTRA LIFE' text

               ld      hl,Text8    ; HL points to encrypted chars
               ld      b,09h       ; 9 encrypted chars to decode
               ld      de,50cbh    ; DE points to (22,11) in Display memory
               call    PrtEText

L123:          ; Screen complete. Brief pause before returning.

               ld      b,06h       ; Length of delay




;-------------------------------------------------------------------------------
CLDelay:       ; Generates pauses during Completed Level screen
;-------------------------------------------------------------------------------
; ENTRY:
; B = Length of delay required (It will loop 65535 x this value)
; EXIT
; Carry Flag = 1 if there are more levels to play

               ld      hl,0000h    ; Set HL so loop begins with 0ffffh

L124:          dec     hl
               ld      a,h
               or      l
               jr      nz,L124     ; Loop until HL=0
               djnz    CLDelay     ; Repeat loop B times

               ; Delay done. This next test is only relevant at the end of the
               ; Completed Level screen so CpLvScrn returns with the C flag set
               ; appropriately. This result is ignored during the previous calls
               ; to CLDelay.

               ld      a,(ix+0eh)  ; A=Number of next level to play
               cp      15h         ; Is it 21? (i.e. game is complete)
               ret                 ; Return Carry set if more levels to play




;-------------------------------------------------------------------------------
PrtDelay:      ; Generates a delay
;-------------------------------------------------------------------------------
; This is called from PrtEText to pause between printing individual characters.
; The length of the pause is determined by the value of IX+35.
;
; ENTRY:
; IX+35 = Length of delay required (It will loop approx 256 x this value)
; EXIT:
; HL = Preserved

               push    hl
               ld      h,(ix+35h)  ; Set HL with number of times to loop
                                   ; (L will contain whatever it had previously)
L125:          dec     hl
               ld      a,h
               or      l
               jr      nz,L125     ; Loop until HL=0
               pop     hl
               ret




Text5:         ; 'NEXT LEVEL -     HAZARDS'
               db      39h, 30h, 03h, 7fh, 37h, 30h, 01h, 30h, 77h, 6ah, 63h
               db      63h, 33h, 2ch, 05h, 2ch, 3dh, 2fh, 3eh

Text6:         ; 'WITH'
               db      02h, 34h, 3fh, 33h

Text7:         ; 'HAZARDS'
               db      33h, 2ch, 05h, 2ch, 3dh, 2fh, 3eh

Text8:         ; 'EXTRA LIFE'
               db      30h, 03h, 3fh, 3dh, 6ch, 37h, 34h, 31h, 30h




RhymOffs:      ; DATA - Table containing locations and lengths of each line in
               ; the rhyme.

               dw      Rhyme1      ; Mem address for line 1 data
               db      34h         ; No. of encryted chars in this line

               dw      Rhyme2      ; Mem address for line 2 data
               db      2eh         ; No. of encryted chars in this line

               dw      Rhyme3      ; Mem address for line 3 data
               db      17h         ; No. of encryted chars in this line

               dw      Rhyme4      ; Mem address for line 4 data
               db      16h         ; No. of encryted chars in this line

               dw      Rhyme5      ; Mem address for line 5 data
               db      13h         ; No. of encryted chars in this line

               dw      Rhyme6      ; Mem address for line 6 data
               db      1ch         ; No. of encryted chars in this line

               dw      Rhyme7      ; Mem address for line 7 data
               db      1ch         ; No. of encryted chars in this line

               dw      Rhyme8      ; Mem address for line 8 data
               db      1fh         ; No. of encryted chars in this line

               dw      Rhyme9      ; Mem address for line 9 data
               db      18h         ; No. of encryted chars in this line

               dw      Rhyme10     ; Mem address for line 10 data
               db      14h         ; No. of encryted chars in this line

               dw      Rhyme11     ; Mem address for line 11 data
               db      1bh         ; No. of encryted chars in this line

               dw      Rhyme12     ; Mem address for line 12 data
               db      1eh         ; No. of encryted chars in this line

               dw      Rhyme13     ; Mem address for line 13 data
               db      1fh         ; No. of encryted chars in this line

               dw      Rhyme14     ; Mem address for line 14 data
               db      11h         ; No. of encryted chars in this line

               dw      Rhyme15     ; Mem address for line 15 data
               db      11h         ; No. of encryted chars in this line

               dw      Rhyme16     ; Mem address for line 16 data
               db      20h         ; No. of encryted chars in this line

               dw      Rhyme17     ; Mem address for line 17 data
               db      18h         ; No. of encryted chars in this line

               dw      Rhyme18     ; Mem address for line 18 data
               db      15h         ; No. of encryted chars in this line

               dw      Rhyme19     ; Mem address for line 19 data
               db      11h         ; No. of encryted chars in this line

               dw      Rhyme20     ; Mem address for line 20 data
               db      13h         ; No. of encryted chars in this line

               dw      Rhyme21     ; Mem address for line 21 data
               db      27h         ; No. of encryted chars in this line




;-------------------------------------------------------------------------------
TstJkDrw:      ; Tests if Jack needs to be re-drawn this frame
;-------------------------------------------------------------------------------
; This tests to see if Jack is currently Standing Still, and if so whether the
; next Jack sprite to be drawn is the same as the one on screen. (The Standing
; Still GFX animation only updates every 32 frames, so this saves GameLoop from
; unnecessarily erasing and re-drawing the same Jack sprite 31 out of 32 frames)
;
; EXIT
; Z Flag = 0 No need to re-draw
;        = 1 Need to re-draw

               ld      a,(ix+08h)  ; A= Jack's animation (Next frame)
               add     a,(ix+2dh)  ; Add Jack's animation (Current frame)
               ret     nz          ; Return if not Standing Still - needs redraw

               ; Jack is Standing Still - but is it time for a new sprite?

               ld      a,(ix+0dh)  ; A= Animation frame (Next)
               xor     (ix+2fh)    ; Isolate changed bits from last frame
               and     60h         ; Have bits 6&5 changed (Standing Still
               ret                 ; frame data), Z will be set if they have




Rhyme2:        ; 'THE BALLAD OF JUMPING JACK'
               ; 'A daring explorer named Jack...'
               db      3fh, 33h, 70h, 2dh, 2ch, 37h, 37h, 2ch, 6fh, 3ah, 71h
               db      35h, 00h, 38h, 3bh, 34h, 39h, 72h, 35h, 2ch, 2eh, 0f6h
               db      6ch, 09h, 06h, 17h, 0eh, 13h, 4ch, 0ah, 1dh, 15h, 11h
               db      14h, 17h, 0ah, 57h, 13h, 06h, 12h, 0ah, 49h, 35h, 06h
               db      08h, 90h




;-------------------------------------------------------------------------------
Beep:          ; Calls the ROM Beep routine
;-------------------------------------------------------------------------------
; ENTRY
; HL = Pitch
; DE = Duration

               push    ix          ; Save pointer to game data
               call    ROM_BEEP    ; Call ROM Beep
               di                  ; ROM routine re-enabled the interrupts
               pop     ix          ; Restore data pointer
               ret
;===============================================================================
