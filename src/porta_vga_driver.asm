#ifdef VGA_ENABLE
VGA_INIT: .(
    lda #$FF
    sta PORTA_D
    rts
.)
#print VGA_INIT

VGA_DELAY: .(
    phy
    ldy #$1F
L:  dey
    bne L
    ply
    rts
.)

VGA_CHAROUT: .(
    cmp #$0A
    beq E
    sta PORTA
    ora #$80
    jsr VGA_DELAY
    sta PORTA
    jsr VGA_DELAY
E:  rts
.)
#print VGA_CHAROUT

VGA_CLEAR: .(
    pha
    phy
    ldy #40
    lda #$0D
L:  jsr VGA_CHAROUT
    dey
    bne L
    ply
    pla
    rts
.)
#print VGA_CLEAR
#endif
