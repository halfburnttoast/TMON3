#ifdef DEBUG_ENABLE
DEBUG:
    jsr NEWLINE
    ldx #$0
DEBUG_L:
    jsr GETTOKEN
    cmp #$0
    beq DEBUG_END
DNC:lda LINE_IN, x
    inx
    stx LINE_IN_IDX
    cmp #SPACE
    beq DEBUG_NEXT
    cmp #$0
    beq DEBUG_END
    _CHAROUT
    jmp DNC
DEBUG_END:
    jmp MAIN
DEBUG_NEXT:
    jsr NEWLINE
    jmp DEBUG_L
#endif


