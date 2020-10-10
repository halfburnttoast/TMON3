#ifdef ANSI_ENABLE
; Move cursor to position (reg X, reg Y)
CONSOLE_MOVE_CURSOR: .(
    sty NUM_CONV_HEX
    jsr HEX_2_DECS
    stx NUM_CONV_HEX
    jsr HEX_2_DECS
    ldx #$0 
PL: lda CP, x
    beq E
    inx 
    cmp #'n'
    beq SL
    sta CHAROUT
    jmp PL
SL: pla 
    beq PL
    sta CHAROUT
    jmp SL
E:  rts 
.)
#print CONSOLE_MOVE_CURSOR


CONSOLE_CLS: .(
    phx 
    pha 
    ldx #80 
    lda #$0A
L:  sta CHAROUT
    dex 
    bne L
    pla 
    plx 
    rts 
.)
#print CONSOLE_CLS

CP:             .byte $1B, $5B, "n;nH",0

#endif
