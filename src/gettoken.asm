
; Gets the next token in LINE_IN buffer.
; Sets LINE_IN_IDX and X to the next available character
; Ignores spaces 
; RETURNS 1 on next token found
;         0 on end of line (null terminated)
GETTOKEN:
;   ldx LINE_IN_IDX
GETTOKEN_L:
    lda LINE_IN, x
    beq GETTOKEN_EOL    ; if null found, return end of line
    cmp #SPACE
    bne GETTOKEN_RET    ; return if we're already on next char
    inx
    jmp GETTOKEN_L      ; if it is a space, continue to next char
GETTOKEN_EOL:
    lda #$0
    rts
GETTOKEN_RET:
    stx LINE_IN_IDX
    lda #$1
    rts
#print GETTOKEN
