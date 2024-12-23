; vim: set ft=asm_ca65 ts=4 sw=4 et:
.include "io.inc"
.include "app.inc"
.include "macro.inc"
.include "ay-3-8910.inc"

NUM_GAPS = 8
LIVES_CHAR = $10

.export start

.autoimport
.globalzp ptr1, ptr2, tmp1

.zeropage
ptr1:   .word 0
ptr2:   .word 0
tmp1:   .byte 0
tmp2:   .byte 0
frame:  .byte 0

.bss

.code

start:
    sei
    ldx #$ff
    tsx
    jsr kbInit
    jsr initAudio

    jsr vdp_g2_init

    lda #<sprite_start
    sta ptr1
    lda #>sprite_start
    sta ptr1+1
    lda #<sprite_end
    sta ptr2
    lda #>sprite_end
    sta ptr2+1
    jsr load_sprite_patterns

    lda #<font_start
    sta ptr1
    lda #>font_start
    sta ptr1+1
    lda #<font_end
    sta ptr2
    lda #>font_end
    sta ptr2+1
    jsr load_font_patterns

    lda #LIVES_CHAR
    ldx #$4e
    jsr vdp_color_char

    stz score
    stz score+1


    cli

attract_mode:
    lda #1
    sta attract_flag

    lda #<jumping_jack
    sta ptr2
    lda #>jumping_jack
    sta ptr2+1
    ldx #10
    ldy #7
    jsr vdp_print_xy

    lda #<by_pd
    sta ptr2
    lda #>by_pd
    sta ptr2+1
    ldx #8
    ldy #10
    jsr vdp_print_xy

    lda #<cc2024
    sta ptr2
    lda #>cc2024
    sta ptr2+1
    ldx #14
    ldy #13
    jsr vdp_print_xy

    lda #<space_to_start
    sta ptr2
    lda #>space_to_start
    sta ptr2+1
    ldx #6
    ldy #16
    jsr vdp_print_xy


new_game:
    lda attract_flag
    bne :+
    jsr vdp_clear_screenbuf
    stz score
    stz score+1

:
    jsr reset_data
    jsr draw_lines

    jsr rnd
    sta gaps_pos+0
    sta gaps_pos+1
    sta gaps_pos+2
    sta gaps_pos+3

    jsr rnd
    sta gaps_pos+4
    sta gaps_pos+5
    sta gaps_pos+6
    sta gaps_pos+7

    jsr update_lives
    jsr update_score

game_loop:
    ; check if in attract mode
    lda attract_flag
    beq :+
    inc seed
    ; check if game over
:   lda game_over_flag
    beq :+
    ; game is over
    jmp attract_mode
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

    ; frame 4/4
    jsr draw_gaps
    jsr move_jack
    inc frame
    jsr animate_jack

    jsr vdp_wait
    jsr vdp_flush
    jsr flush_sprite_attributes

    ; move gaps and player
    ; move gaps
    inc gaps_pos+0
    inc gaps_pos+1
    inc gaps_pos+2
    inc gaps_pos+3
    inc gap_right_offset

    dec gaps_pos+4
    dec gaps_pos+5
    dec gaps_pos+6
    dec gaps_pos+7
    dec gap_left_offset

    jsr test_fall
    bcc @key
    lda #jstate::falling
    sta jstate
    stz j_j_fr
    jmp game_loop
@key:
    lda #0 ; force the neg bit to be clear.
    jsr kbReadAscii
    bcs @key_run
    jmp game_loop
@key_run:
    sta tmp1
    lda jstate
    cmp #jstate::jump_1
    bcc :+
    jmp game_loop
:   lda tmp1
    cmp #'c'
    beq :+
    cmp #'C'
    bne :++
:   lda #jstate::jump_1
    sta jstate
    jmp game_loop
:   cmp #'f'
    beq :+
    cmp #'F'
    bne :++
:   lda jline
    cmp #8
    beq @next
    stz j_j_fr
    lda #jstate::falling
    sta jstate
    jmp game_loop
:   cmp #'a'
    beq :+
    cmp #'A'
    bne :++
:   lda #jstate::left
    sta jstate
    jmp game_loop
:   cmp #'s'
    beq :+
    cmp #'S'
    bne :++
:   lda #jstate::still
    sta jstate
    lda #4
    sta jsprite + sprite::pa    ; switch to still imediately
    stz frame                   ; also reset frame
    jmp game_loop
:   cmp #'d'
    beq :+
    cmp #'D'
    bne :++
:   lda #jstate::right
    sta jstate
    jmp game_loop
:   cmp #' '
    bne @next
    lda attract_flag
    beq :+
    stz attract_flag
    jmp new_game
:   jmp do_jump
@next:
    jmp game_loop

do_jump:
    ldy jline
    dey
    bmi @exit
    lda jsprite + sprite::xp
    lsr
    lsr
    lsr
    tax
    jsr get_xy_gap  ; above jack
    sta jprev
    jsr test_gap
    bcs @good
    lda jprev
    dec             ; one to the left
    jsr test_gap
    bcc @crash
@good:
    lda #jstate::jump_1
    sta jstate
    stz j_j_fr
    jmp game_loop
@crash:
    lda #jstate::crash
    sta jstate
    stz j_j_fr
    lda #$26
    sta vdp_reg
    lda #$87
    sta vdp_reg
    jsr sfx_crash
@exit:
    jmp game_loop

animate_jack:
    lda attract_flag
    beq :+
    rts
:   lda jstate
    asl         ; multiply by 2
    tax
    jmp (animate_frame_jump,x)
animate_frame_jump:
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
; only animate jack when he is standing still every 16 frames.
animate_jack_still:
    stz j_j_fr
    lda frame
    cmp #$20
    bne :+
    jsr sfx_still
    lda j_s_fr
    inc
    asl
    asl
    sta jsprite + sprite::pa
    inc j_s_fr
    lda j_s_fr
    and #$03
    sta j_s_fr
    stz frame
:   rts
animate_jack_left:
    lda frame
    and #1
    bne :+
    lda j_r_fr
    and #3
    asl
    asl
    clc
    adc #36
    sta jsprite + sprite::pa
    inc j_r_fr
:   rts
animate_jack_right:
    lda frame
    and #1
    bne :+
    lda j_r_fr
    and #3
    asl
    asl
    clc
    adc #20
    sta jsprite + sprite::pa
    inc j_r_fr
:   rts
animate_jack_jump_good_1:
    lda j_j_fr
    and #3
    asl
    asl
    clc
    adc #52
    sta jsprite + sprite::pa
    inc j_j_fr
    lda j_j_fr
    cmp #4
    bne :+
    lda #jstate::jump_2
    sta jstate
    stz j_j_fr
    jsr sfx_jump
:   rts
animate_jack_jump_good_2:
    inc j_j_fr
    lda j_j_fr
    cmp #4
    bne :+
    lda #jstate::jump_3
    sta jstate
    stz j_j_fr
    jsr sfx_jump
:   rts
animate_jack_jump_good_3:
    inc j_j_fr
    lda j_j_fr
    cmp #4
    bne :+
    lda #jstate::still
    sta jstate
    lda #4
    sta jsprite + sprite::pa    ; switch to still imediately
    stz frame
    stz j_j_fr
    jsr sfx_jump
    dec jline
    jsr update_score
    lda jline
    beq win
    jsr do_new_gap
:   rts

win:
    lda #<you_win
    sta ptr2
    lda #>you_win
    sta ptr2 + 1
    ldx #8
    ldy #2
    jsr vdp_print_xy
    jmp attract_mode

animate_jack_falling:
    lda frame
    and #3
    bne :+
    jsr sfx_fall
:   lda #68
    sta jsprite + sprite::pa
    inc j_j_fr
    lda j_j_fr
    cmp #12
    bne :+
    lda #jstate::stun
    sta jstate
    stz j_j_fr
    lda #84
    sta jsprite + sprite::pa
    lda #16
    sta stun_ctr
    lda jline
    cmp #8
    bcs :+
    inc jline
    lda jline
    cmp #8
    bne :+
    dec lives
    jmp update_lives
:   rts

animate_jack_crash:
    lda frame
    and #1
    bne :+
    lda j_j_fr
    and #3
    asl
    asl
    clc
    adc #100
    sta jsprite + sprite::pa
    inc j_j_fr
    lda j_j_fr
    cmp #4
    bne :+
    lda #jstate::crash_fall
    sta jstate
    lda #84
    sta jsprite + sprite::pa
    stz frame
    stz j_j_fr
    lda #$2B
    sta vdp_reg
    lda #$87
    sta vdp_reg
    jsr sfx_silence
:   rts
animate_jack_crash_fall:
    lda frame
    and #1
    bne :+
    lda j_j_fr
    and #3
    asl
    asl
    clc
    adc #84
    sta jsprite + sprite::pa
    inc j_j_fr
    lda j_j_fr
    cmp #4
    bne :+
    lda #jstate::stun
    sta jstate
    lda #84
    sta jsprite + sprite::pa
    stz frame
    lda #32
    sta stun_ctr
:   rts
animate_jack_stun:
    jsr sfx_stun
    lda frame
    and #1
    bne :+
    lda stun_ctr
    and #3
    asl
    asl
    clc
    adc #84
    sta jsprite + sprite::pa
    dec stun_ctr
    lda stun_ctr
    bne :+
    lda #jstate::still
    sta jstate
    lda #4
    sta jsprite + sprite::pa    ; switch to still imediately
    stz frame
:   rts

move_jack:
    lda attract_flag
    beq :+
    rts
:   lda jstate
    asl         ; multiply by 2
    bne :+      ; we don't move if state is 0 = still
    rts
:   tax
    jmp (move_jack_jump,x)
move_jack_jump:
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

move_jack_still:
    jmp sfx_still
move_jack_left:
    dec jsprite + sprite::xp
    dec jsprite + sprite::xp
    jmp sfx_run
move_jack_right:
    inc jsprite + sprite::xp
    inc jsprite + sprite::xp
    jmp sfx_run
move_jack_jump_good_123:
    dec jsprite + sprite::yp
    dec jsprite + sprite::yp
    rts
move_jack_falling:
    inc jsprite + sprite::yp
    inc jsprite + sprite::yp
    rts
move_jack_crash:
    dec jsprite + sprite::yp
    dec jsprite + sprite::yp
    rts
move_jack_crash_fall:
    inc jsprite + sprite::yp
    inc jsprite + sprite::yp
    rts
move_jack_stun:
    rts

test_fall:
    lda jstate
    cmp #jstate::stun
    beq :+
    cmp #jstate::jump_1
    bcc :+
    clc
    rts
:   ldy jline
    cpy #8
    bne :+
    clc
    rts
:   lda jsprite + sprite::xp
    lsr
    lsr
    lsr
    tax
    jsr get_xy_gap  ; Jack's feet
    sta jprev
    jsr test_gap
    bcs :+
    lda jprev
    dec             ; one to the left
    jsr test_gap
:   rts             ; CARRY SET then falling, CARRY CLEAR then not falling

; Tests if gap position in A matches any of the current gap positions.
; CC on no match
; CS on match
test_gap:
    ldx #7
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

; Convert XY to gap location so it can be compared with all gaps
; INPUT X, Y location of sprite
; RETURN A = LLLXXXXX location of tile.
get_xy_gap:
    tya     ; y is a char position 0-23
    asl     ; < 1
    asl     ; < 2
    asl     ; < 3
    asl     ; < 4
    asl     ; shift into LLL position
    sta tmp1
    txa     ; x is char position 0-31
    ora tmp1
    rts

; Converts GAP to XY coordinates
; INPUT: A = Gap in LLLXXXXX system
; OUTPUT: X, Y
get_gap_xy:
    pha
    lsr
    lsr
    lsr
    lsr
    lsr     ; A >> 5
    sta tmp1
    asl     ; x 2
    clc
    adc tmp1 ; + 1 (Line number x 3)
    tay
    pla
    and #$1F ; X is okay as is.
    tax
    rts

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
    jsr vdp_xy_to_ptr
    ldy #31
    lda #1
:   sta (ptr1),y
    dey
    bpl :-
    rts

new_gap:
    lda gap_count
    cmp #8
    beq :+
    inc gap_count
    ldy gap_count
    lda #<gaps_pos
    sta ptr1
    lda #>gaps_pos
    sta ptr1+1
    jsr rnd
    sta (ptr1),y
:
    rts

do_new_gap:
    lda gap_count       ; if gap_count == 8 then no more gaps to add
    cmp #8
    beq @exit
    inc gap_count       ; increment gap count
    ldy gap_count       ; save gap count into y for indirect offset
    ldx gap_left_offset
    cpy #4              ; if y >= 4 then use left offset
    bcs :+
    ldx gap_right_offset ; else use right offset
:
    stx tmp1            ; save the offset into tmp1 for adding later
    lda #<gaps_pos      ; get the ptr to the gaps table
    sta ptr1
    lda #>gaps_pos
    sta ptr1+1
    jsr rnd             ; random number
    and #$fc            ; make multiple of 4
    clc
    adc tmp1            ; add to offset - this should prevent overlap
    sta (ptr1),y        ; update the gap position indexed by y.
@exit:
    rts

draw_gaps:
    lda frame
    and #3
    asl         ; multiply by 2
    tax
    jmp (gaps_frame_jump,x)
gaps_frame_jump:
    .addr gaps_F0      ; +0 (Frame 0)
    .addr gaps_F1      ; +4 (Frame 1)
    .addr gaps_F2      ; +8 (Frame 2)
    .addr gaps_F3      ; +12 (Frame 3)

gaps_F0:
    lda #(NUM_GAPS-1)
    sta gap
@gaploop:
    ; draw the outsides
    ldx gap
    lda gaps_pos,x
    dec
    jsr get_gap_xy      ; CELL 0
    lda #1
    jsr vdp_char_xy

    ldx gap
    lda gaps_pos,x
    clc
    adc #3
    jsr get_gap_xy      ; CELL 4
    lda #1
    jsr vdp_char_xy

    ; draw the middle gaps
    ldx gap
    lda gaps_pos,x
    pha
    jsr get_gap_xy      ; CELL 1
    lda #5
    jsr vdp_char_xy
    pla
    inc
    pha
    jsr get_gap_xy      ; CELL 2
    lda #5
    jsr vdp_char_xy
    pla
    inc
    jsr get_gap_xy      ; CELL 3
    lda #5
    jsr vdp_char_xy

    ; gaploop
    dec gap
    bpl @gaploop
    rts

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
gaps_F123:
    ; draw cell 1 in gaps 0-3 (right down gaps)
    lda #3
    sta gap
@right_moving_gaps_cell_1:
    ldx gap
    lda gaps_pos,x
    jsr get_gap_xy
    lda gap_frame_data+0
    jsr vdp_char_xy
    dec gap
    bpl @right_moving_gaps_cell_1

    ; Draw Cell 3 in gaps 4-7 (the Left/Up gaps)
    lda #7
    sta gap
@left_moving_gaps_cell_3:
    ldx gap
    lda gaps_pos,x
    inc
    inc
    jsr get_gap_xy
    lda gap_frame_data+1
    jsr vdp_char_xy
    dec gap
    lda gap
    cmp #3
    bne @left_moving_gaps_cell_3

    ; Draw gaps 0-3 (the Right/Down gaps)
    ; For each, AND the desired contents of cells 1 & 4 with what's
    ; already on the screen to allow for overlapping left-moving
    ; gaps.
    lda #3
    sta gap
@right_moving_gaps_14:
    lda gap_frame_data+0
    sta tmp2
    ldx gap
    lda gaps_pos,x          ; point to cell 1
    jsr gap_and_update

    lda gap_frame_data+2
    sta tmp2
    ldx gap
    lda gaps_pos,x
    clc
    adc #3                  ; point to cell 4
    jsr gap_and_update

    ldx gap
    lda gaps_pos,x
    inc                     ; point to cell 2
    jsr get_gap_xy
    lda #5                  ; empty gap
    jsr vdp_char_xy

    ldx gap
    lda gaps_pos,x
    inc
    inc                     ; point to cell 3
    jsr get_gap_xy
    lda #5                  ; empty gap
    jsr vdp_char_xy

    dec gap
    bpl @right_moving_gaps_14

    ; Draw gaps 4-7 (the Left/Up gaps)
    ; For each, AND the desired contents of cells 0 & 3 with what's
    ; already on the screen to allow for overlapping right-moving
    ; gaps.
    lda #7
    sta gap
@left_moving_gaps_03:
    lda gap_frame_data+1
    sta tmp2
    ldx gap
    lda gaps_pos,x
    inc
    inc                     ; point to cell 3
    jsr gap_and_update

    lda gap_frame_data+3
    sta tmp2
    ldx gap
    lda gaps_pos,x
    dec                     ; point to cell 0
    jsr gap_and_update

    ldx gap
    lda gaps_pos,x          ; point to cell 1
    jsr get_gap_xy
    lda #5                  ; empty gap
    jsr vdp_char_xy

    ldx gap
    lda gaps_pos,x
    inc                     ; point to cell 2
    jsr get_gap_xy
    lda #5                  ; empty gap
    jsr vdp_char_xy

    dec gap
    lda gap
    cmp #3
    bne @left_moving_gaps_03
    rts

; INPUT: A Cell position
;        tmp2 desired pattern
gap_and_update:
    pha         ; save cell position
    jsr get_gap_xy
    jsr vdp_read_char_xy
    asl         ; x 2
    tax
    lda gap_and_idx+0,x
    sta ptr2 + 0
    lda gap_and_idx+1,x
    sta ptr2 + 1
    ldy tmp2    ; desired pattern in Y
    dey
    lda (ptr2),y
    sta tmp2    ; save new pattern
    pla
    jsr get_gap_xy
    lda tmp2
    jsr vdp_char_xy
    rts

flush_sprite_attributes:
    lda #<SPRITEATTRIBUTETABLE
    ldx #>SPRITEATTRIBUTETABLE
    jsr set_write_address

    lda #<jsprite
    sta ptr1
    lda #>jsprite
    sta ptr1+1
    ldy #0
@L1:
    lda (ptr1),y
    cmp #$D0
    beq @EXIT
    sta vdp_ram
    iny
    bpl @L1
@EXIT:
    rts

reset_data:
    stz gap_count
    stz gap_left_offset
    stz gap_right_offset
    stz line
    stz gap
    stz jprev
    stz jstate
    stz frame
    stz j_s_fr
    stz j_r_fr
    stz j_j_fr
    stz stun_ctr
    stz run_note_toggle
    stz game_over_flag
    lda #8
    sta jline
    lda #$ff
    sta jump_note_ctr
    lda #4
    sta lives
    lda #(192-16)
    sta jsprite + sprite::yp
    lda #128
    sta jsprite + sprite::xp
    lda #4
    sta jsprite + sprite::pa
    lda #1
    sta jsprite + sprite::co

    rts

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

; -----------------------------------------------------------------------------
; Play a note from the notes tables
; Inputs:
;   A = index into notes tables
; -----------------------------------------------------------------------------
initAudio:
    aySetVolume AY_PSG0, AY_CHC, $00
    aySetEnvShape AY_PSG0,AY_ENV_SHAPE_FADE_OUT
    ayWrite AY_PSG0, AY_ENABLES, $F8

    aySetVolume AY_PSG1, AY_CHC, $00
    ayWrite AY_PSG1, AY_ENABLES, $DF    ; noise on CHC, PSG1
    rts

play_note:
    pha

    lda #0
    ayWriteA AY_PSG0, AY_CHC_TONE_L
    ayWriteA AY_PSG0, AY_CHC_TONE_H

    plx

    lda notesL, x
    ayWriteA AY_PSG0, AY_CHC_TONE_L
    lda notesH, x
    ayWriteA AY_PSG0, AY_CHC_TONE_H
    aySetVolumeEnvelope AY_PSG0, AY_CHC
    aySetEnvShape AY_PSG0,AY_ENV_SHAPE_FADE_OUT
    aySetEnvelopePeriod AY_PSG0, 600

    rts

sfx_still:
    ldx j_s_fr
    lda run_notes,x
    jmp play_note

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

sfx_crash:
    lda #$1f
    ayWrite AY_PSG0, AY_CHC_AMPL, $00
    ayWrite AY_PSG1, AY_NOISE_GEN, 11
    ayWrite AY_PSG1, AY_CHC_AMPL, $0f
    rts

sfx_silence:
    ayWrite AY_PSG0, AY_CHC_AMPL, $00
    ayWrite AY_PSG1, AY_CHC_AMPL, $00
    rts

sfx_stun:
    lda frame
    and #3
    bne :+
    lda #4
    jmp play_note
:   rts

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
    lda lives
    bpl :+
    lda #1
    sta game_over_flag
:   rts

update_score:
    sed
    clc
    lda score + 0
    adc #5
    sta score + 0
    lda score + 1
    adc #0
    sta score + 1
    cld
    ;
    ; now print the updated score
    lda #28
    sta tmp1
    ldx #1
:
    phx
    lda score,x
    jsr @prbyte
    plx
    dex
    bpl :-
    rts
@prbyte:
    pha
    lsr
    lsr
    lsr
    lsr
    jsr @prhex
    pla
@prhex:
    and #$0F
    ora #$B0
    cmp #$BA
    bcc @echo
    adc #$06
@echo:
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

line:   .byte 0
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
