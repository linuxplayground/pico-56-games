; vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
; Pico-56-Jumping Jack Main Game
;
; Copyright (c) 2024 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/linuxplayground/pico-56-games


.include "io.inc"
.include "app.inc"
.include "macro.inc"
.include "ay-3-8910.inc"

LIVES_CHAR = $10

.enum jstate
    still   = 0
    left    = 1
    right   = 2
    jump_1  = 3
    jump_2  = 4
    jump_3  = 5
    falling = 6
    crash   = 7
    crash_fall = 8
    stun    = 9
.endenum

.struct sprite
    yp .byte                ; Y position
    xp .byte                ; X position
    pa .byte                ; pattern name
    co .byte                ; early clock bit
.endstruct

.export start               ; required by boot vectors

.autoimport

.globalzp ptr1, ptr2        ; These two pointers are used by the VDP library.

.zeropage
ptr1:   .word 0             ; pointers
ptr2:   .word 0
tmp1:   .byte 0             ; temporary variables
tmp2:   .byte 0
frame:  .byte 0             ; frame counter

.bss
; there is no uninitialised data.

.code

; =============================================================================
;               GAME SETUP, NEW GAME AND  ATTRACT MODE
; =============================================================================
; resets all game data for a new game.
reset_data:
    stz gap_count           ; Number of gaps on the screen.
    stz gap_left_offset     ; offset that's always decremented when gaps move
    stz gap_right_offset    ; offset that's always incremented when gaps move
    stz gap                 ; current gap used in loops while drawing gaps
    stz jprev               ; variable used in test gap routines
    stz jstate              ; variable holding Jack's current state
    stz frame               ; reset the global frame counter
    stz j_s_fr              ; still animation sequence frame counter
    stz j_r_fr              ; run animation sequence frame counter
    stz j_j_fr              ; jump (and fall) animation frame counter
    stz stun_ctr            ; stun timeout counter
    stz run_note_toggle     ; used to toggle between high and low notes while
                            ; running
    stz game_over_flag      ; is the game over, 1 = yes, 0 = now
    lda #8
    sta jline               ; current line Jack is standing on.  8 = bottom.
    lda #$ff                ; jump note counter starts at 0xFF
    sta jump_note_ctr       ; counter is pre-incremented in sfx_jump routine.
    lda #4                  ; start with 5 lives.  0-4
    sta lives
    lda #(192-16)           ; Jack starts centered on bottom of screen.
    sta jsprite + sprite::yp
    lda #128
    sta jsprite + sprite::xp
    lda #4
    sta jsprite + sprite::pa; Jack initial frame is still.
    lda #1
    sta jsprite + sprite::co; early clockbit is set.
    rts

; draw the lives remaining icons on the bottom left of the screen.  This routine
; always decrements the number of lives remaining after drawing them.
update_lives:
    ldx #20
    lda #' '
    ldy #23
:
    jsr vdp_char_xy
    dex
    bpl :-

    ldx lives
    lda #LIVES_CHAR
    ldy #23
:   jsr vdp_char_xy
    dex
    bpl :-
    lda lives               ; check if number of lives is now zero.  If so then
    bpl :+                  ; game over.
    lda #1
    sta game_over_flag
:   rts

; Use the CPU BCD mode to add 5 to the score each time the routine is called.
; Also write the new score by printing the hex characters in the BCD score
; variable to the screen.
update_score:
    sed                     ; enable Decimal mode
    clc                     ; add 5 to the score.
    lda score + 0
    adc #5
    sta score + 0
    lda score + 1
    adc #0
    sta score + 1
    cld                     ; disable decimal mode.
    ;
    ; now print the updated score
    lda #28                 ; score starts at column 28 on the screen
    sta tmp1
    ldx #1                  ; first print the high byte of the scrore
:
    phx                     ; save index
    lda score,x             ; load the byte and call prbyte (prints hex byte)
    jsr @prbyte
    plx                     ; restore X
    dex                     ; decrement and loop if X >= 0
    bpl :-
    rts
@prbyte:
    pha                     ; save the byte
    lsr                     ; isolate the high nibble by shifting it to the
    lsr                     ; 4 times.
    lsr
    lsr
    jsr @prhex              ; print it
    pla                     ; restore the byte
@prhex:                     ; print a nibble
    and #$0F                ; isoalte the nibble.
    ora #$B0                ; this routine comes from WOZMON
    cmp #$BA
    bcc @echo
    adc #$06
@echo:                      ; write the characater into the frame buffer.
    pha
    and #$7F
    ldx tmp1
    ldy #23
    jsr vdp_char_xy
    inc tmp1
    pla
    rts

exit:
    rts


; Random number generator.
; black magic - link on internet is lost to me now.
rnd:
     lda seed
     beq doEor
     asl
     beq noEor ;if the input was $80, skip the EOR
     bcc noEor
doEor:
    eor #$1d
noEor:
    sta seed
    rts


start:
    sei                     ; disable interrupts during initial setup
    ldx #$ff                ; set stack pointer to known location.  Asissts with
    tsx                     ; debugging
    jsr kbInit              ; init the keyboard library
    jsr initAudio           ; init audio features.

    jsr vdp_g2_init         ; Init the VDP and set up for graphics mode.  See
                            ; lib/vdp.s for detailed description of the mode used.
    lda #<sprite_start      ; Load sprite data
    sta ptr1
    lda #>sprite_start
    sta ptr1+1
    lda #<sprite_end
    sta ptr2
    lda #>sprite_end
    sta ptr2+1
    jsr vdp_load_sprite_patterns

    lda #<font_start        ; load tile data (font and tiles)
    sta ptr1
    lda #>font_start
    sta ptr1+1
    lda #<font_end
    sta ptr2
    lda #>font_end
    sta ptr2+1
    jsr vdp_load_font_patterns

    lda #$6e                ; set all tile colors to RED on LIGHT GREY
    jsr vdp_setup_colortable

    lda #LIVES_CHAR         ; set the LIVES character to Blue.
    ldx #$4e
    jsr vdp_color_char

    stz score               ; init score to 0
    stz score+1

    cli                     ; ready to enable interrupts now.

    ; fall through
; Display the game area and move the 2 gaps around the screen.  Display welcome
; text
attract_mode:
    lda #1                  ; while attract_flag is 1, the game will not accept user
                            ; input other than to press space.
    sta attract_flag

    lda #<jumping_jack      ; Write "Jumping Jack" text.
    sta ptr2
    lda #>jumping_jack
    sta ptr2+1
    ldx #10
    ldy #7
    jsr vdp_print_xy

    lda #<by_pd             ; Write "By Productiondave" text.
    sta ptr2
    lda #>by_pd
    sta ptr2+1
    ldx #8
    ldy #10
    jsr vdp_print_xy

    lda #<cc2024            ; Write "Copyright 2024" text.
    sta ptr2
    lda #>cc2024
    sta ptr2+1
    ldx #14
    ldy #13
    jsr vdp_print_xy

    lda #<space_to_start    ; Write "Press SPACE to start" text.
    sta ptr2
    lda #>space_to_start
    sta ptr2+1
    ldx #6
    ldy #16
    jsr vdp_print_xy

    ; fall through
; Starts a new game, by resetting all the game variables.
new_game:
    lda attract_flag        ; if in attract mode, we do not reset the screen
    bne :+                  ; and score
    jsr vdp_clear_screenbuf ; clear the framebuffer
    stz score               ; reset score
    stz score+1

:
    jsr reset_data          ; initialise all game variables except for score.
    jsr draw_lines          ; draw the lines based on their Y offsets.

    jsr rnd                 ; find random location for first right moving gap
    sta gaps_pos+0
    sta gaps_pos+1
    sta gaps_pos+2
    sta gaps_pos+3

    jsr rnd                 ; find random location for second left moving gap
    sta gaps_pos+4
    sta gaps_pos+5
    sta gaps_pos+6
    sta gaps_pos+7

    jsr update_lives        ; show the lives on thes screen.
    jsr update_score        ; show the score on the screen.

    ; fall through
; =============================================================================
;               MAIN GAME LOOP
; =============================================================================

; This is where the magic happens.  Jumping Jack is one large state machine.
; Each state determins what will happen to jack next.
; -----------------------------------------------------------------------------
game_loop:
    ; check if in attract mode
    lda attract_flag        ; if we are in attract mode, keep incrementing the
    beq :+                  ; seed so that the random number generator returns
    inc seed                ; something a bit more random when the game starts.
    ; check if game over
:   lda game_over_flag      ; Is the game OVER?
    beq :+
    ; game is over
    jmp attract_mode        ; Yes, go back to attract  mode.


; The main gameloop draws 4 frames of animation per iteration.  Player input and
; gap positions are processed AFTER drawing the 4th frame.  Jack's position on
; the screen is adjusted every frame.

; The game timing is synced to the VDP vertical refresh rate by calls to
; `vdp_wait` prior to flushing the framebuffer to VRAM.  This is also when the
; sprite attributes are flushed to VRAM.

; For details of how the main routines here work, please read the comments at
; the routine definitions.

; Frames 1, 2 and 3 are all identical.
:   ; frame 1/4
    jsr draw_gaps
    jsr move_jack
    inc frame
    jsr animate_jack

    jsr vdp_wait
    jsr vdp_flush
    jsr flush_sprite_attributes

    ; frame 2/4
    jsr draw_gaps
    jsr move_jack
    inc frame
    jsr animate_jack

    jsr vdp_wait
    jsr vdp_flush
    jsr flush_sprite_attributes

    ; frame 3/4
    jsr draw_gaps
    jsr move_jack
    inc frame
    jsr animate_jack

    jsr vdp_wait
    jsr vdp_flush
    jsr flush_sprite_attributes

    ; Frame 4 is the same as 1, 2, and 3 to begin with but then the game state
    ; is recalculated and user input processed.

    ; frame 4/4
    jsr draw_gaps
    jsr move_jack
    inc frame
    jsr animate_jack

    jsr vdp_wait
    jsr vdp_flush
    jsr flush_sprite_attributes

    ; move gaps and player

    ; move right moving gaps by 1 tile.
    inc gaps_pos+0
    inc gaps_pos+1
    inc gaps_pos+2
    inc gaps_pos+3
    inc gap_right_offset    ; increment the right moving gap offset.

    ; move left moving gaps by 1 tile.
    dec gaps_pos+4
    dec gaps_pos+5
    dec gaps_pos+6
    dec gaps_pos+7
    dec gap_left_offset     ; decrement the left moving gap offset.

    jsr test_fall           ; does jack need to fall through a gap?
    bcc key                ; if no, proceed to user input
    lda #jstate::falling    ; set jack state to falling
    sta jstate
    stz j_j_fr              ; reset jack animation frame to 0
    jmp game_loop           ; loop

; =============================================================================
;               PROCESS KEYBOARD INPUT
; =============================================================================

key:
    lda #0                  ; Due to a bug in the keybard library, force the neg bit to be clear.
    jsr kbReadAscii         ; read the ascii value of the last keypress.
    bcs @process_key        ; if a valid key was pressed, proceed to processing
    jmp game_loop           ; the key else, loop.
@process_key:
    sta tmp1                ; save the key pressed.
    lda jstate              ; check if jack is still or running.
    cmp #jstate::jump_1     ; if he is, then proceed to processing key
    bcc :+                  ; else
    jmp game_loop           ; loop
:   lda tmp1                ; restore key pressed
:   cmp #'a'                ; Was key a or A ?
    beq :+
    cmp #'A'
    bne :++                 ; NO? Check for s or S.
:   lda #jstate::left       ; YES? set state to running left.
    sta jstate
    jmp game_loop           ; loop
:   cmp #'s'                ; check for s or S
    beq :+
    cmp #'S'
    bne :++                 ; NO? Check for d or D.
:   lda #jstate::still      ; set state to still
    sta jstate
    lda #4                  ; set jack animation frame to start of still
    sta jsprite + sprite::pa ; animation immediately.
    stz frame               ; also reset frame to zero.
    jmp game_loop           ; loop
:   cmp #'d'                ; Check for d or D.
    beq :+
    cmp #'D'
    bne :++                 ; NO? Check for SPACE
:   lda #jstate::right      ; set jack state to running right.
    sta jstate
    jmp game_loop           ; loop
:   cmp #' '                ; Check for SPACE
    bne @next               ; NO? loop.
    lda attract_flag        ; Were we in attract mode?
    beq :+                  ; NO? proceed to process jump.
    stz attract_flag        ; YES? Reset attract flag and jump to new
    jmp new_game            ; game.
:   jmp do_jump             ; process jump
@next:
    jmp game_loop           ; loop

; The DO Jump routine checks the line above jack for a valid gap to jump
; through.  Valid gaps are the one directly above the Jack sprite measured from
; the left most pixel of the sprite.  The gap to the LEFT of that one is also
; checked.  If a valid gap is found, then Jack's state is set to good_jump_1.
; If no valid gap is found, jack's state is set to jump_crash.  After all that,
; the jump animation frame counter is set to zero.
do_jump:
    ldy jline               ; Y is the line number jack is standing on.
    dey                     ; Y is now the line number above jack
    bmi @exit               ; if Y < 0 then we somehow failed to win..
    lda jsprite + sprite::xp ; Get Jack's X prite position.
    lsr                     ; divide by 8.
    lsr
    lsr
    tax                     ; save to X
    jsr get_xy_gap          ; Y = Line to test, X = location on line, get
                            ; gap-coordinate from XY in format LLLXXXXX format.
    sta jprev               ; save it.
    jsr test_gap            ; test if this value matches any of the gaps.
    bcs @good               ; if matched, then good jump.
    lda jprev               ; restore saved gap-coordinate location of Jack.
    dec                     ; one to the left
    jsr test_gap            ; test gap
    bcc @crash              ; if not good, then crash.
@good:
    lda #jstate::jump_1     ; set Jack state to phase one of a good jump.
    sta jstate
    stz j_j_fr              ; reset jump animation frame counter.
    jmp game_loop           ; loop
@crash:
    lda #jstate::crash      ; set jack state to crash
    sta jstate
    stz j_j_fr              ; reset jump animation frame counter.
    lda #$26                ; set the border color to RED
    sta vdp_reg
    lda #$87
    sta vdp_reg
    jsr sfx_crash           ; call the crash sound effect.
@exit:
    jmp game_loop           ; loop

; =============================================================================
;               ANIMATION SEQUENCES
; =============================================================================

; Use the current state of jack to jump to the correct animation routine for
; that state.  This is done on the 6502 by using the absolute indexed indirect
; jump addressing mode.  `jmp (address, x)` where X is an offset into a table of
; pointers.
animate_jack:
    lda attract_flag        ; if we are in attract mode, just return.  Jack is
    beq :+                  ; not animated during attract mode.
    rts
:   lda jstate              ; load the state and multiply it by 2.
    asl
    tax                     ; save to X register for offset.
    jmp (animate_frame_jump_table,x) ; jump to routine.
; table of animation routine addresses used by the animate_jack routine.
animate_frame_jump_table:
    .addr animate_jack_still
    .addr animate_jack_left
    .addr animate_jack_right
    .addr animate_jack_jump_good_1
    .addr animate_jack_jump_good_2
    .addr animate_jack_jump_good_3
    .addr animate_jack_falling
    .addr animate_jack_crash
    .addr animate_jack_crash_fall
    .addr animate_jack_stun

; The still animation is updated every 32 frames.  The 
animate_jack_still:
    stz j_j_fr              ; make sure the jump frame is set to zero.
    lda frame               ; Is the current frame counter equal to 32?
    cmp #$20
    bne :+                  ; NO? Return
    jsr sfx_still           ; play the still sound effect.
    lda j_s_fr              ; use the still animation frame counter to
    inc                     ; find the sprite pattern to apply.
    asl                     ; multiply by 4
    asl
    sta jsprite + sprite::pa ; save to Jack's sprite pattern attribute.
    inc j_s_fr              ; increment the still frame counter.
    lda j_s_fr              ; mod 4
    and #$03
    sta j_s_fr              ; save
    stz frame               ; reset frame to zero so we can count to 32 again.
:   rts

; the left animation and right animations are very simlilar except that they
; have different sprite patterns.  Jack's run animations are only processed
; every second frame.
animate_jack_left:
    lda frame               ; load the frame
    and #1                  ; test for even number?
    bne :+                  ; NOT Even? return
    lda j_r_fr              ; laod the run frame animation counter
    and #3                  ; mod 4
    asl                     ; multiply by 4
    asl
    clc                     ; add to the start of the left run animation sprites.
    adc #36
    sta jsprite + sprite::pa ; set jack sprite pattern attribute
    inc j_r_fr              ; increment run animation frame counter
:   rts

; the left animation and right animations are very simlilar except that they
; have different sprite patterns.  Jack's run animations are only processed
; every second frame.
animate_jack_right:
    lda frame               ; load the frame
    and #1                  ; test for even number?
    bne :+                  ; NOT Even? return
    lda j_r_fr              ; laod the run frame animation counter
    and #3                  ; mod 4
    asl                     ; multiply by 4
    asl
    clc                     ; add to the start of the right run animation sprites.
    adc #20
    sta jsprite + sprite::pa ; set jack spreite pattern attribute
    inc j_r_fr              ; increment run animation frame counter
:   rts

; A good jump animation requires that jack move 24 pixels vertically.  This is 3
; sets of 4 frames at 2 pixels per frame.  The 3 good jump animation sequences
; are very simlar.  The first one has a 4 frame animation, but good jump 2 and
; good jump 3 are static.
animate_jack_jump_good_1:
    lda j_j_fr              ; find the mod 4 of the jump animation frame
    and #3                  ; counter.
    asl
    asl
    clc
    adc #52                 ; add it to the jump animation sprite.
    sta jsprite + sprite::pa ; set the sprite pattern attribute
    inc j_j_fr              ; increment the jump animation frame counter.
    lda j_j_fr              ; if the jump animation frame counter is 4 then
    cmp #4                  ; switch state to good jump 2.
    bne :+                  ; else return
    lda #jstate::jump_2     ; set state to good jump 2 and reset the jump
    sta jstate              ; animation frame counter.
    stz j_j_fr
    jsr sfx_jump            ; call the jump sound effect.
:   rts

; same as jump good 1 except the pattern table is not set.  Just check for end
; of sequence.
animate_jack_jump_good_2:
    inc j_j_fr              ; increment jump animation frame counter
    lda j_j_fr              ; check if 4 and set to state to good jump 3
    cmp #4
    bne :+                  ; else return
    lda #jstate::jump_3     ; set jack state to good jump 3
    sta jstate
    stz j_j_fr
    jsr sfx_jump
:   rts

; same as jump good 2 except that at the end of the sequence jack state is set
; to still.
animate_jack_jump_good_3:
    inc j_j_fr              ; increment jump animation frame attribute
    lda j_j_fr              ; check if 4 and set state to still
    cmp #4
    bne :+                  ; else return
    lda #jstate::still      ; set state to still
    sta jstate
    lda #4                  ; set the jack sprite pattern attribute to the
    sta jsprite + sprite::pa ; first still pattern.
    stz frame               ; reset the frame counter
    stz j_j_fr              ; reset the jump frame counter
    jsr sfx_jump            ; call the jump sound effect for the last time.
    dec jline               ; decement the line jack is standing on
    jsr update_score        ; update the score
    lda jline               ; check if the line jack is standing on is 0
    beq win                 ; YES, jack has reached the top.
    jsr do_new_gap          ; NO, call the new gap routine.
:   rts

; Jack has reached the top
win:
    lda #<you_win           ; write the "You Win" message
    sta ptr2
    lda #>you_win
    sta ptr2 + 1
    ldx #8
    ldy #2
    jsr vdp_print_xy
    jmp attract_mode        ; jump to attract mode

; Jack falling has very little to it.  He falls for 12 frames (24 pixels) and
; the fall sound effect is called once every 4 frames.
; This routine re-uses the jump animation frame counter.
animate_jack_falling:
    lda frame               ; find the mod 4 of the frame counter
    and #3
    bne :+                  ; if not zero then skip sound effect
    jsr sfx_fall            ; call fall sound effect
:   lda #68                 ; set jack sprite pattern attribute to falling
    sta jsprite + sprite::pa
    inc j_j_fr              ; increment the jump animation frame counter
    lda j_j_fr              ; test for 12?
    cmp #12
    bne :+                  ; NO? skip switching to stun
    lda #jstate::stun       ; YES? set state to stunn.
    sta jstate
    stz j_j_fr              ; reset jump animation frame counter.
    lda #84                 ; set sprite pattern attribute to first frame of
    sta jsprite + sprite::pa ; stun animation.
    lda #16                 ; set stun counter to 16.
    sta stun_ctr
    lda jline               ; check current line jack is standing on.
    cmp #8                  ; if 8 skip updateing current line jack is stood on
    bcs :+                  ; because he is already at the bottom.
    inc jline               ; increment the line jack is stood on.
    lda jline               ; check if new value is 8? if so, then jack looses
    cmp #8                  ; a life
    bne :+
    dec lives
    jmp update_lives        ; if Jack has lost a life, update the lives
                            ; remaining.
:   rts

; The crash animation is done in 3 parts.
; - Crash animation.  Jack is moving up at this stage but his animation shows
; him hitting his head and rotating to a horizontal position.
; - Crash fall animation, jack has the stunned animation and is falling down.
; - Stunned animation.  Jack ramins stunned until the stun counter runs out.
animate_jack_crash:
    lda frame               ; Jack crash animations are only updated every
    and #1                  ; second frame.
    bne :+                  ; if not even frame, return
    lda j_j_fr              ; find the mod 4 of the jump animation frame counter
    and #3
    asl                     ; multiply by 4
    asl
    clc
    adc #100                ; add to first pattern of crash animation.
    sta jsprite + sprite::pa ; set jack sprite pattern attribute
    inc j_j_fr              ; increment jump animation frame counter.
    lda j_j_fr
    cmp #4                  ; if not 4
    bne :+                  ; then return
    lda #jstate::crash_fall ; else set state to crash fall
    sta jstate
    lda #84                 ; set sprite pattern attribute to first frame of
    sta jsprite + sprite::pa ; crash fall sequence.
    stz frame               ; reset frame counter.
    stz j_j_fr              ; ret jump animation frame counter.
    lda #$2B                ; set the border color back to light yellow
    sta vdp_reg
    lda #$87
    sta vdp_reg
    jsr sfx_silence         ; turn off the crash sound effect.
:   rts

; jack is falling back down after bumping his head.  This animation only updates
; every second frame.  Once 4 frames of animation are complete, Jack will be
; stunned until the stun counter runs out.
animate_jack_crash_fall:
    lda frame               ; Jack crash animations are only updated every
    and #1                  ; second frame.
    bne :+                  ; if not even frame, return
    lda j_j_fr              ; find the mod 4 of the jump animation frame counter
    and #3
    asl                     ; multiply by 4
    asl
    clc
    adc #84                 ; add to first pattern of fall animation.
    sta jsprite + sprite::pa
    inc j_j_fr              ; inrement the jump frame counter
    lda j_j_fr
    cmp #4                  ; if not 4
    bne :+                  ; then return
    lda #jstate::stun       ; Set jack state to stun.
    sta jstate
    lda #84                 ; set jack sprite pattern attribute to first frame
    sta jsprite + sprite::pa ; of stun animation sequence.
    stz frame               ; reset frame counter.
    lda #32                 ; set stun counter to 32.
    sta stun_ctr
:   rts

; The animation for for stunned Jack only udpates once every second frame and
; continues until the animation counter runs out.
animate_jack_stun:
    jsr sfx_stun            ; play the stunned sound effect
    lda frame               ; check if current frame is an even number?
    and #1
    bne :+                  ; NO? return
    lda stun_ctr            ; load the stun acounter
    and #3                  ; and find mod 4
    asl                     ; multiply by 4
    asl
    clc                     ; add to first sprite pattern for stun animation
    adc #84                 ; sequence
    sta jsprite + sprite::pa ; set jack sprite pattern attribute
    dec stun_ctr            ; decrement the stun counter
    lda stun_ctr            ; test for zero
    bne :+                  ; NOT zero, return
    lda #jstate::still      ; set jack state to still
    sta jstate
    lda #4                  ; set jack sprite pattern attribute to first frame
    sta jsprite + sprite::pa ; of still animation.
    stz frame               ; reset frame counter.
:   rts

; =============================================================================
;               JACK MOVEMENT
; =============================================================================

; Like the animation processing, the movement processing works off a jump table
; and the current jack state.
move_jack:
    lda attract_flag        ; Jack does not move when attract mode is on.
    beq :+
    rts
:   lda jstate              ; get the current jack state
    asl                     ; multiply by 2
    bne :+                  ; we don't move if state is 0 = still
    rts
:   tax                     ; copy to X for jump table offset
    jmp (move_jack_jump_table,x)

move_jack_jump_table:
    .addr move_jack_still
    .addr move_jack_left
    .addr move_jack_right
    .addr move_jack_jump_good_123
    .addr move_jack_jump_good_123
    .addr move_jack_jump_good_123
    .addr move_jack_falling
    .addr move_jack_crash
    .addr move_jack_crash_fall
    .addr move_jack_stun

; Jack doesnt move
; return from still sound effect routine.
move_jack_still:
    jmp sfx_still

; move jack sprite left by 2 pixels.
; return from run sound effect routine.
move_jack_left:
    dec jsprite + sprite::xp
    dec jsprite + sprite::xp
    jmp sfx_run

; move jack sprite right by 2 pixels.
; return from run sound effect routine.
move_jack_right:
    inc jsprite + sprite::xp
    inc jsprite + sprite::xp
    jmp sfx_run

; move jack sprite up 2 pixels
move_jack_jump_good_123:
    dec jsprite + sprite::yp
    dec jsprite + sprite::yp
    rts

; move jack down 2 pixels
move_jack_falling:
    inc jsprite + sprite::yp
    inc jsprite + sprite::yp
    rts

; move jack up 2 pixels
move_jack_crash:
    dec jsprite + sprite::yp
    dec jsprite + sprite::yp
    rts

; move jack down 2 pixels
move_jack_crash_fall:
    inc jsprite + sprite::yp
    inc jsprite + sprite::yp
    rts

; jack does not move while stunned.
move_jack_stun:
    rts

; =============================================================================
;               GAP DETECTION
; =============================================================================

; Check if tile beneath jack is a gap.
; INPUT: VOID
; OUTPUT: CARRY SET if gap found, CARRY CLEAR if no gap found.
test_fall:
    lda jstate              ; if jack is stunned, he can fall.
    cmp #jstate::stun
    beq :+
    cmp #jstate::jump_1     ; if jack is jumping or higher, he can not fall.
    bcc :+
    clc
    rts
:   ldy jline               ; check if jack is on line 8, if so he is at the
    cpy #8                  ; bottom and can not fall.
    bne :+
    clc
    rts
:   lda jsprite + sprite::xp ; find jack's X position
    lsr                     ; divide by 8
    lsr
    lsr
    tax                     ; X = X location
    jsr get_xy_gap          ; Y = Line, get the gap-cordinate of Jack's feet.
    sta jprev               ; save it
    jsr test_gap            ; test if gap matched
    bcs :+                  ; YES, return with carry still set.
    lda jprev               ; restore Jack gap-coordinate
    dec                     ; one to the left
    jsr test_gap
:   rts                     ; CARRY SET then falling, CARRY CLEAR then not falling

; Tests if gap position in A matches any of the current gap positions.
; INPUT: A is the gap-coordinate to match
; OUTPUT: CARRY CLEAR on no match
;         CARRY SET on match
test_gap:
    ldx #7                  ; test for match across all 8 gaps
@L0:
    cmp gaps_pos,x
    beq @match
    dex
    bpl @L0
    clc
    rts
@match:
    sec
    rts

; =============================================================================
;               FRAMEBUFFER DRAWING
; =============================================================================

; Draw the lines into the frame buffer
draw_lines:
    ldy #0
    jsr draw_line
    ldy #3
    jsr draw_line
    ldy #6
    jsr draw_line
    ldy #9
    jsr draw_line
    ldy #12
    jsr draw_line
    ldy #15
    jsr draw_line
    ldy #18
    jsr draw_line
    ldy #21
    ; fall through
draw_line:
    ldx #0
    jsr vdp_xy_to_ptr       ; convert XY coordinates to a pointer into the
    ldy #31                 ; frame buffer
    lda #1                  ; pattern #1 is the pattern with first two rows of
:   sta (ptr1),y            ; pixels filled in.
    dey                     ; copy this pattern 32 times into the buffer
    bpl :-
    rts


; Flush the sprite attributes to the VDP by setting up the pointer and jumping
; to the vdp_flush_sprite_attributes routine.
flush_sprite_attributes:
    lda #<jsprite
    sta ptr1
    lda #>jsprite
    sta ptr1+1
    jmp vdp_flush_sprite_attributes

; =============================================================================
;               GAP MANAGEMENT AND PROCESSING
; =============================================================================

; Convert XY to gap location so it can be compared with all gaps
; INPUT X, Y location of sprite
; RETURN A = LLLXXXXX location of tile.
get_xy_gap:
    tya                     ; y is a char position 0-23
    asl                     ; < 1
    asl                     ; < 2
    asl                     ; < 3
    asl                     ; < 4
    asl                     ; shift into LLL position
    sta tmp1
    txa                     ; x is char position 0-31
    ora tmp1
    rts

; Converts GAP to XY coordinates
; INPUT: A = Gap in LLLXXXXX system
; OUTPUT: X, Y
get_gap_xy:
    pha                     ; Save A
    lsr                     ; shift LLL to the beginning LSB position in A
    lsr
    lsr
    lsr
    lsr
    sta tmp1                ; save to tmp1
    asl                     ; multiply by 3 by first multiplybing by 2 and then
    clc                     ; adding what was saved to tmp1
    adc tmp1
    tay                     ; Y is now the Y coordinate (0-23)
    pla                     ; restore A
    and #$1F                ; mask off XXXXX
    tax                     ; X is now X coordinate (0-31)
    rts

; A new gap is created by moving one of the existing gaps that are still drawn
; on top of each other to a new random location.  The gap coordinate system
; (LLLXXXXX) means that any value of A between 0 and 255 will land somewhere in
; one of the lines.  To try to keep the new gaps from overwriting the old ones,
; we add the gap left (or right) offset to the random number generated.  It's
; not perfect and with some thought I think this can be improved.
do_new_gap:
    lda gap_count           ; if gap_count == 8 then no more gaps to add
    cmp #8
    beq @exit
    inc gap_count           ; increment gap count
    ldy gap_count           ; save gap count into y for indirect offset
    ldx gap_left_offset
    cpy #4                  ; if y >= 4 then use left offset
    bcs :+
    ldx gap_right_offset    ; else use right offset
:
    stx tmp1                ; save the offset into tmp1 for adding later
    lda #<gaps_pos          ; get the ptr to the gaps table
    sta ptr1
    lda #>gaps_pos
    sta ptr1+1
    jsr rnd                 ; random number
    and #$fc                ; make multiple of 4
    clc
    adc tmp1                ; add to offset - this should prevent overlap
    sta (ptr1),y            ; update the gap position indexed by y.
@exit:
    rts

; the gap tile to draw at the gap positions is determined by the frame counter
; mod 4.  We use a small jump table to handle the correct routine for drawing
; the gaps based on which frame mod 4 we are in.
draw_gaps:
    lda frame
    and #3
    asl                     ; multiply by 2
    tax
    jmp (gaps_frame_jump_table,x)
gaps_frame_jump_table:
    .addr gaps_F0           ; +0 (Frame 0)
    .addr gaps_F1           ; +4 (Frame 1)
    .addr gaps_F2           ; +8 (Frame 2)
    .addr gaps_F3           ; +12 (Frame 3)

; In this instance the gap is perfectly positioned between tiles.  There are no
; partial tiles in use.
gaps_F0:
    lda #7                  ; there are 8 gaps to draw
    sta gap
@gaploop:                   ; for each gap do.
    ; draw the outside cells
    ldx gap
    lda gaps_pos,x
    dec
    jsr get_gap_xy          ; CELL 0
    lda #1
    jsr vdp_char_xy

    ldx gap
    lda gaps_pos,x
    clc
    adc #3
    jsr get_gap_xy          ; CELL 4
    lda #1
    jsr vdp_char_xy

    ; draw the middle cells
    ldx gap
    lda gaps_pos,x
    pha
    jsr get_gap_xy          ; CELL 1
    lda #5
    jsr vdp_char_xy
    pla
    inc
    pha
    jsr get_gap_xy          ; CELL 2
    lda #5
    jsr vdp_char_xy
    pla
    inc
    jsr get_gap_xy          ; CELL 3
    lda #5
    jsr vdp_char_xy

    ; gaploop
    dec gap
    bpl @gaploop            ; end loop
    rts


; Frames 1, 2 and 3 are all the same except for which tiles are used to draw the
; boundries of the gap.
gaps_F1:
    lda #4
    sta gap_frame_data + 0  ;11000000b      ; Cell 1 (Right-moving gaps)
    lda #6
    sta gap_frame_data + 1  ;00000011b      ; Cell 3 (Left-moving gaps)
    lda #8
    sta gap_frame_data + 2  ;00111111b      ; Cell 4 (Right-moving gaps)
    lda #2
    sta gap_frame_data + 3  ;11111100b      ; Cell 0 (Left-moving gaps)

    jmp gaps_F123

gaps_F2:
    lda #3
    sta gap_frame_data + 0  ;11110000b      ; Cell 1 (Right-moving gaps)
    lda #7
    sta gap_frame_data + 1  ;00001111b      ; Cell 3 (Left-moving gaps)
    lda #7
    sta gap_frame_data + 2  ;00001111b      ; Cell 4 (Right-moving gaps)
    lda #3
    sta gap_frame_data + 3  ;11110000b      ; Cell 0 (Left-moving gaps)
    jmp gaps_F123

gaps_F3:
    lda #2
    sta gap_frame_data + 0  ;11111100b      ; Cell 1 (Right-moving gaps)
    lda #8
    sta gap_frame_data + 1  ;00111111b      ; Cell 3 (Left-moving gaps)
    lda #6
    sta gap_frame_data + 2  ;00000011b      ; Cell 4 (Right-moving gaps)
    lda #4
    sta gap_frame_data + 3  ;11000000b      ; Cell 0 (Left-moving gaps)

    ; fall through

; This routine draws the boundaries of the gaps defined in the above routines.
; It also has to account for when gaps are moving over each other.
;
; *** NOTE: I am not altogether sure about these comments.  The original source
;           code is probably easier to understand.  The functions are sort of
;           similar except that the gap_and_update routine is different.
gaps_F123:
    ; draw cell 1 in gaps 0-3 (right down gaps)
    lda #3                                  ; start at 4th gap and move down
    sta gap
@right_moving_gaps_cell_1:
    ldx gap                                 ; gap index
    lda gaps_pos,x                          ; A is the gap position at index X
    jsr get_gap_xy                          ; convert to XY coordinates
    lda gap_frame_data+0                    ; Get the tile from gap frame data
    jsr vdp_char_xy                         ; for cell 0 and write to frame buf.
    dec gap                                 ; next gap
    bpl @right_moving_gaps_cell_1           ; loop while >= 0

    ; Draw Cell 3 in gaps 4-7 (the Left/Up gaps)
    lda #7                                  ; start at last gap and move down
    sta gap
@left_moving_gaps_cell_3:
    ldx gap                                 ; gap index
    lda gaps_pos,x                          ; A is the gap position at index X
    inc                                     ; Add 2 for cell 3
    inc
    jsr get_gap_xy                          ; convert to XY coordinates
    lda gap_frame_data+1                    ; get the tile from gap frame data
    jsr vdp_char_xy                         ; for cell 3 and write to frame buf.
    dec gap                                 ; next gap
    lda gap                                 ; loop while > 3
    cmp #3
    bne @left_moving_gaps_cell_3

    ; Draw gaps 0-3 (the Right/Down gaps)
    ; For each, AND the desired contents of cells 1 & 4 with what's
    ; already on the screen to allow for overlapping left-moving
    ; gaps.
    lda #3                                  ; start with gap 3 and move down
    sta gap
@right_moving_gaps_14:
    lda gap_frame_data+0                    ; get the desired tile pattern for
    sta tmp2                                ; cell 1 and store
    ldx gap                                 ; set up gap pos index
    lda gaps_pos,x                          ; merge with cell 1
    jsr gap_and_update                      ; call the routine that merges the
                                            ; new cell with the one already in
                                            ; the frame buffer at that location.

    lda gap_frame_data+2                    ; Repeat for cell 4
    sta tmp2
    ldx gap
    lda gaps_pos,x
    clc
    adc #3                                  ; merge with cell 3
    jsr gap_and_update

    ldx gap                                 ; cell 2 is empty
    lda gaps_pos,x
    inc
    jsr get_gap_xy
    lda #5                                  ; empty tile
    jsr vdp_char_xy

    ldx gap                                 ; cell 3 is empty
    lda gaps_pos,x
    inc
    inc
    jsr get_gap_xy
    lda #5                                  ; empty tile
    jsr vdp_char_xy

    dec gap
    bpl @right_moving_gaps_14

    ; Draw gaps 4-7 (the Left/Up gaps)
    ; For each, AND the desired contents of cells 0 & 3 with what's
    ; already on the screen to allow for overlapping right-moving
    ; gaps.
    lda #7                                  ; start with the last gap and move
    sta gap                                 ; down
@left_moving_gaps_03:
    lda gap_frame_data+1                    ; get the desired tile pattern for
    sta tmp2                                ; cell 3
    ldx gap                                 ; gap position index
    lda gaps_pos,x                          ; merge with cell 3
    inc
    inc
    jsr gap_and_update                      ; call the routine that merges the
                                            ; new cell with the one already in
                                            ; the frame buffer at that location.
    lda gap_frame_data+3                    ; repeat for cell 4
    sta tmp2
    ldx gap
    lda gaps_pos,x
    dec                                     ; merge with cell 0.
    jsr gap_and_update

    ldx gap
    lda gaps_pos,x                          ; point to cell 1
    jsr get_gap_xy
    lda #5                                  ; empty tile
    jsr vdp_char_xy

    ldx gap
    lda gaps_pos,x
    inc                                     ; point to cell 2
    jsr get_gap_xy
    lda #5                                  ; empty tile
    jsr vdp_char_xy

    dec gap
    lda gap
    cmp #3
    bne @left_moving_gaps_03
    rts

; Given a cell position in gap-coordinates read the data in the frame buffer at
; that location and using a lookup table select the appropriate tile pattern
; that combine them together.  The lookup table is given in the RODATA section
; below.  It was precomputed on a sheet of paper and meticulously transcribed
; into the 6502 byte array you see.
;
; INPUT: A Cell position
;        tmp2 desired pattern
; OUTPUT: VOID
gap_and_update:
    pha                                 ; save cell position
    jsr get_gap_xy                      ; convert gap-coordinates to XY coords
    jsr vdp_read_char_xy                ; A is the value at XY
    asl                                 ; multiply by 2 for lookup table
    tax                                 ; convert to index
    lda gap_and_idx+0,x                 ; copy the data at the index into ptr2
    sta ptr2 + 0                        ; ptr2 will be a pointer to the table we
    lda gap_and_idx+1,x                 ; we need to perform that actual lookup.
    sta ptr2 + 1
    ldy tmp2                            ; desired pattern in Y
    dey                                 ; lookup tables are zerobased.
    lda (ptr2),y                        ; read the value from the table at the
    sta tmp2                            ; index of the desired pattern (tmp2)
    pla                                 ; restore the cell position
    jsr get_gap_xy                      ; convert to XY coords again.
    lda tmp2                            ; recover the new pattern
    jsr vdp_char_xy                     ; write to the frame buffer.
    rts

; =============================================================================
;               AUDIO ROUTINES - DUAL AY-3-8910
; =============================================================================

initAudio:
    aySetVolume AY_PSG0, AY_CHC, $00    ; set volume on PSG0, CHAN C to 0
    aySetEnvShape AY_PSG0,AY_ENV_SHAPE_FADE_OUT ; Envelope control
    ayWrite AY_PSG0, AY_ENABLES, $FB    ; enable PSG0 CHAN C Notes

    aySetVolume AY_PSG1, AY_CHC, $00    ; set volume on PSG1, CHAN C to 0
    ayWrite AY_PSG1, AY_ENABLES, $DF    ; noise on CHC, PSG1
    rts

; -----------------------------------------------------------------------------
; Play a note from the notes tables
; INPUT: A is index into notes tables
; OUTPUT: VOID
; -----------------------------------------------------------------------------
play_note:
    pha                                 ; save note index

    lda #0                              ; reset tone to 0
    ayWriteA AY_PSG0, AY_CHC_TONE_L
    ayWriteA AY_PSG0, AY_CHC_TONE_H

    plx                                 ; restore index into X

    lda notesL, x                       ; get the low byte of the note
    ayWriteA AY_PSG0, AY_CHC_TONE_L     ; write to PSG0, CHAN C Note L
    lda notesH, x                       ; get the high byte of the note
    ayWriteA AY_PSG0, AY_CHC_TONE_H     ; write to PSG0, CHAN C Note H
    aySetVolumeEnvelope AY_PSG0, AY_CHC ; set the volume envelope
    aySetEnvShape AY_PSG0,AY_ENV_SHAPE_FADE_OUT; set fade out
    aySetEnvelopePeriod AY_PSG0, 600    ; set duration

    rts

; play still sound effect based on still animation frame counter
sfx_still:
    ldx j_s_fr
    lda run_notes,x
    jmp play_note

; play run sound effect (which is an alternating high and low pitched beep)
; based on the current frame.  We only play run sounds every 16th frame
sfx_run:
    lda frame
    and #7
    bne @exit
    ldx run_note_toggle
    beq :+
    dec run_note_toggle
    bra :++
:   inc run_note_toggle
:   lda run_notes,x
    jmp play_note
@exit:
    rts

; play jump notes indexed by jump_note_ctr.  This routine is called once at the
; end of each phase of a good jump.  So 3 excalting beeps are heard.
sfx_jump:
    inc jump_note_ctr
    ldx jump_note_ctr
    cpx #2
    bne :+
    lda #$ff
    sta jump_note_ctr
:
    lda jump_notes,x
    jmp play_note
    rts

; play fall notes indexed by jump_note_ctr.  This routine is called once every 4
; frames of falling.  So 3 de-escalating beeps are heard.
sfx_fall:
    inc jump_note_ctr
    ldx jump_note_ctr
    cpx #2
    bne :+
    lda #$ff
    sta jump_note_ctr
:
    lda fall_notes,x
    jmp play_note
    rts

; Turn on the noise.
sfx_crash:
    lda #$1f
    ayWrite AY_PSG0, AY_CHC_AMPL, $00
    ayWrite AY_PSG1, AY_NOISE_GEN, 11
    ayWrite AY_PSG1, AY_CHC_AMPL, $0f
    rts

; silence everything.
sfx_silence:
    ayWrite AY_PSG0, AY_CHC_AMPL, $00
    ayWrite AY_PSG1, AY_CHC_AMPL, $00
    rts

; The stun sound effect is a short, high pitched beep played every 4th frame
; until the stun counter runs out.
sfx_stun:
    lda frame
    and #3
    bne :+
    lda #4
    jmp play_note
:   rts

.segment "DATA"
gaps_pos:
    .byte $00   ; right down
    .byte $00   ; right down
    .byte $00   ; right down
    .byte $00   ; right down

    .byte $00   ; left up
    .byte $00   ; left up
    .byte $00   ; left up
    .byte $00   ; left up

gap_frame_data:
    .byte 0     ; Cell 1 (Right-moving gaps)
    .byte 0     ; Cell 3 (Left-moving gaps)
    .byte 0     ; Cell 4 (Right-moving gaps)
    .byte 0     ; Cell 0 (Left-moving gaps)

seed:               .byte 0 ; initial seed for random number gen.
gap_count:          .byte 0
gap_left_offset:    .byte 0
gap_right_offset:   .byte 0

gap:    .byte 0
jline:  .byte 8
jprev:  .byte 0
jstate: .byte jstate::still
j_s_fr: .byte 0     ; frame counter for when jack is standing still.
j_r_fr: .byte 0     ; frame counter for when jack is running.
j_j_fr: .byte 0     ; frame counter for when jack is jumping.
stun_ctr:.byte 0    ; counter for stunn time.
run_note_toggle: .byte 0 ; alternating note toggle
jump_note_ctr:  .byte $ff  ; counter of notes for jumping and falling.
attract_flag: .byte 1
lives:  .byte 4
game_over_flag: .byte 0


jsprite: .tag sprite
.byte $d0      ; end of sprites marker

score:  .res 3, 0   ; score in BCD format, takes up 3 bytes

.rodata
; strings
space_to_start: .asciiz "Press SPACE to Start"
you_win:        .asciiz "You Win!"
jumping_jack:   .asciiz "Jumping Jack"
by_pd:          .asciiz "By Productiondave"
cc2024:         .asciiz "2024"

jump_notes: .byte 1, 2, 3
fall_notes: .byte 3, 1, 4
run_notes:  .byte 1, 2, 1, 2

gap_and_idx:
    .word 0
    .addr gap_ones
    .addr gap_twos
    .addr gap_threes
    .addr gap_fours
    .addr gap_fives
    .addr gap_sixes
    .addr gap_sevens
    .addr gap_eights
    .addr gap_nines
    .addr gap_tens
gap_ones:
    .byte 1,2,3,4,5,6,7,8
gap_twos:
    .byte 2,2,3,4,5,5,9,10
gap_threes:
    .byte 3,3,3,4,5,6,5,9
gap_fours:
    .byte 4,4,4,4,5,10,4,5
gap_fives:
    .byte 5,5,5,5,5,5,5,5
gap_sixes:
    .byte 6,5,6,10,5,6,6,6
gap_sevens:
    .byte 7,9,5,4,5,6,7,7
gap_eights:
    .byte 8,10,9,5,5,6,7,8
gap_nines:
    .byte 5,5,5,5,5,5,5,5
gap_tens:
    .byte 5,5,5,5,5,5,5,5

; AUDIO DATA
; ----------
notesL:
    .byte 0     ; 0
    .lobytes NOTE_FREQ_FS4
    .lobytes NOTE_FREQ_FS6
    .lobytes NOTE_FREQ_FS8
    .lobytes NOTE_FREQ_FS2
notesH:
    .byte 0
    .hibytes NOTE_FREQ_FS4
    .hibytes NOTE_FREQ_FS6
    .hibytes NOTE_FREQ_FS8
    .hibytes NOTE_FREQ_FS2


font_start:
    .include "font.s"
font_end:

sprite_start:
.include "sprites.s"
sprite_end:
