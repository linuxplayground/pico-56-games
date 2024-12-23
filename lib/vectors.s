; vim: set ft=asm_ca65 ts=4 sw=4 et:vdp

.include "io.inc"

.export _vdp_sync, _vdp_status

.autoimport

.segment "DATA"

_vdp_status: .byte 0
_vdp_sync:   .byte 0

TMS9918_IRQ      = 1      ; /INT
KB_IRQ           = 2      ; RES1
TMS9918_IRQ_BIT  = (1 << (TMS9918_IRQ - 1))
KB_IRQ_BIT       = (1 << (KB_IRQ - 1))
INT_CTRL_ADDRESS = $7fdf

.autoimport

.code
nmi:
    rti

irq_handler:
    pha
    phx
    phy
    cld

    lda INT_CTRL_ADDRESS
    bit #TMS9918_IRQ_BIT
    beq :+
    lda vdp_reg
    sta _vdp_status
    lda #$80
    sta _vdp_sync
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

.segment "VECTORS"
    .addr nmi
    .addr start
    .addr irq_handler

