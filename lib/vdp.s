; vim: set ft=asm_ca65 ts=4 sw=4 et:vdp

.include "io.inc"
.include "app.inc"
.include "macro.inc"

.export vdp_g2_init, vdp_clear_screenbuf, vdp_wait, vdp_flush
.export vdp_screenbuf, vdp_xy_to_ptr, vdp_print_xy, vdp_char_xy
.export vdp_read_char_xy, vdp_color_char, set_write_address, set_read_address
.export load_font_patterns, load_sprite_patterns

.autoimport

.globalzp ptr1, ptr2

.zeropage

.bss
.align $100
vdp_screenbuf: .res $300

.code

vdp_xy_to_ptr:
    pha
    lda #<vdp_screenbuf
    sta ptr1
    lda #>vdp_screenbuf
    sta ptr1+1

    tya
    div8
    clc
    adc ptr1+1
    sta ptr1+1
    tya
    and  #$07
    mul32
    sta ptr1
@add_x:
    clc
    txa
    adc ptr1
    sta ptr1
    lda #0
    adc ptr1+1
    sta ptr1+1
@return:
    pla
    rts

vdp_char_xy:
    jsr vdp_xy_to_ptr
    sta (ptr1)
    rts

vdp_read_char_xy:
    jsr vdp_xy_to_ptr
    lda (ptr1)
    rts

; string pointer in ptr2
vdp_print_xy:
    jsr vdp_xy_to_ptr
    ldy #0
:   lda (ptr2),y
    beq :+
    sta (ptr1),y
    iny
    bra :-
:   rts

vdp_g2_init:
    jsr clear_vram
    lda #<g2_regs
    ldx #>g2_regs
    jsr init_regs
    lda #$6e
    jsr setup_colortable
    jsr vdp_clear_screenbuf
    jsr init_sprite_attributes
    rts

clear_vram:
    lda #0
    ldx #0
    jsr set_write_address
    lda #0
    ldy #0
    ldx #$3F
:   sta vdp_ram
    iny
    bne :-
    dex
    bne :-
    rts

; INPUT: A = character
;        X = color
vdp_color_char:
    phx
    asl
    asl
    asl     ; x 8
    sta ptr1+0
    lda #<COLORTABLE
    clc
    adc ptr1+0
    sta ptr1+0
    lda #>COLORTABLE
    adc #0
    sta ptr1+1
    lda ptr1+0
    ldx ptr1+1
    jsr set_write_address
    plx
    .repeat 8
        stx vdp_ram
    .endrepeat
    rts


vdp_wait:
    lda _vdp_sync
    cmp #$80
    bne vdp_wait
    stz _vdp_sync
    rts

vdp_flush:
    lda #<NAMETABLE
    ldx #>NAMETABLE
    jsr set_write_address
    lda #<vdp_screenbuf
    sta ptr1
    lda #>vdp_screenbuf
    sta ptr1 + 1
    ldy #0
    ldx #3
:   lda (ptr1),y
    sta vdp_ram
    iny
    bne :-
    inc ptr1+1
    dex
    bne :-
    rts

vdp_clear_screenbuf:
    lda #<vdp_screenbuf
    sta ptr1
    lda #>vdp_screenbuf
    sta ptr1 + 1
    ldy #0
    ldx #4
    lda #' '
:   sta (ptr1),y
    iny
    bne :-
    inc ptr1+1
    dex
    bne :-
    rts

setup_colortable:
    tay
    lda #<COLORTABLE
    ldx #>COLORTABLE
    jsr set_write_address
    tya
    ldy #0
    ldx #4
:   sta vdp_ram
    iny
    bne :-
    dex
    bne :-
    rts

init_regs:
    sta ptr1
    stx ptr1+1
    ldy #0
:   lda (ptr1),y
    sta vdp_reg
    tya
    ora #$80
    sta vdp_reg
    iny
    cpy #8
    bne :-
    rts

set_write_address:
    sta vdp_reg
    txa
    ora #$40
    sta vdp_reg
    rts

set_read_address:
    sta vdp_reg
    stx vdp_reg
    rts

load_font_patterns:
    lda #<PATTERNTABLE
    ldx #>PATTERNTABLE
    jsr set_write_address
    ; fall through
    ; fall through
copy_ptr1_to_ptr2:
    ldy #0
:   lda (ptr1),y
    sta vdp_ram
    lda ptr1
    clc
    adc #1
    sta ptr1
    lda #0
    adc ptr1+1
    sta ptr1+1
    cmp ptr2+1
    bne :-
    lda ptr1
    cmp ptr2
    bne :-
    rts

; INPUT: ptr1 ptr to start of sprite pattern data
;        ptr2 ptr to end of sprite pattern data
load_sprite_patterns:
    lda #<SPRITEPATTERNTABLE
    ldx #>SPRITEPATTERNTABLE
    jsr set_write_address
    jmp copy_ptr1_to_ptr2

; Init all sprites to disabled.
init_sprite_attributes:
    lda #<SPRITEATTRIBUTETABLE
    ldx #>SPRITEATTRIBUTETABLE
    jsr set_write_address
    ldx #32
@L1:
    lda #$D0
    sta vdp_ram
    stz vdp_ram
    stz vdp_ram
    stz vdp_ram
    dex
    bne @L1
    rts

.rodata
g2_regs:
    .byte $02
    .byte $e2
    .byte $0e
    .byte $9f
    .byte $00
    .byte $76
    .byte $03
    .byte $2b
    
