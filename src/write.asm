; Writes space separated values into memory at (CURL, CURH)
WRITE:
    jsr GETTOKEN
    beq WRITE_END
    jsr BCLR
WRITE_L:
    lda LINE_IN, x
    cmp #SPACE
    beq WRITE_OUT
    cmp #$0
    beq WRITE_OUT
    inx
    jsr CTON
    jsr BADD
    jmp WRITE_L
WRITE_OUT:
    lda B16L
    ldy #$0
    sta (CURL), Y
    lda WORP
    beq WRITE
    inc CURL
    bne WRITE
    inc CURH
    jmp WRITE
WRITE_END:
    jmp MAIN
