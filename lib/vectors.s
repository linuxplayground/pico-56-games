; vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
; PICO-56 Interrupts and vectors
;
; Copyright (c) 2024 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/linuxplayground/pico-56-games


.include "io.inc"

.export vdp_sync, vdp_status

.autoimport

.segment "DATA"

vdp_status: .byte 0
vdp_sync:   .byte 0

; PICO-56 Interrupt IDs and Bits
TMS9918_IRQ      = 1      ; /INT
KB_IRQ           = 2      ; RES1
TMS9918_IRQ_BIT  = (1 << (TMS9918_IRQ - 1))
KB_IRQ_BIT       = (1 << (KB_IRQ - 1))
INT_CTRL_ADDRESS = $7fdf

.autoimport

.code
; NMI not used
nmi:
    rti

; Standard IRQ handler.  This checks for VDP VSYNC interrupt and keyboard
; interrupt.
;
; The VSYNC interrupt sets the vdp_status variable and sets the MSB of the
; vdp_sync variable.
irq_handler:
    pha
    phx
    phy
    cld

    lda INT_CTRL_ADDRESS
    bit #TMS9918_IRQ_BIT
    beq :+
    lda vdp_reg
    sta vdp_status
    lda #$80
    sta vdp_sync
    ;bra @exit
:
    bit #KB_IRQ_BIT
    beq :+
    jsr kbIntHandler
:
@exit:
    ply
    plx
    pla
    rti

; Standard 6502 boot vectors
.segment "VECTORS"
    .addr nmi
    .addr start
    .addr irq_handler

