// requires:
//      GETTOKEN
//      prints.asm
//      util.asm

EXAM: .(
    lda #$0
    sta EXAM_CNT
    jsr GETTOKEN        ; skip preceding spaces
    bne EX1
    jmp EXAM_NO_RANGE
EX1:                    ; get first exam argument
    jsr EXAM_ARG_FETCH
    lda B16L
    sta CURL
    sta IDXL
    lda B16H
    sta CURH
    sta IDXH
EX2:                    ; get second argument
    jsr GETTOKEN
    cmp #$0
    beq EXAM_NO_RANGE   ; if no second argument
    jsr EXAM_ARG_FETCH
    lda B16L
    sta XAML
    lda B16H
    sta XAMH
    jmp EXAM_BEGIN
EXAM_NO_RANGE:
    lda CURL
    sta XAML
    sta IDXL
    lda CURH
    sta XAMH
    sta IDXH
EXAM_BEGIN:
    ldx #$0
EXAM_PCURA:
    jsr NEWLINE
    lda IDXH
    jsr BTOA
    _CHAROUT
    tya
    _CHAROUT
    lda IDXL
    jsr BTOA
    _CHAROUT
    tya
    _CHAROUT
    lda #COLC
    _CHAROUT
    lda #SPACE
    _CHAROUT
EXAM_LOOP:
    lda (IDXL, X)
    jsr BTOA
    _CHAROUT
    tya
    _CHAROUT
    lda #SPACE
    _CHAROUT
    jsr EXAM_CHECK_END
    bne EXAM_END
    inc EXAM_CNT
    bne ENXT
    jsr EXAM_WAIT
ENXT:
    inc IDXL
    bne EXAM_LOOP_SKIPH     ; don't increment IDXH if IDXL hasn't rolled over
    inc IDXH
EXAM_LOOP_SKIPH: 
    lda IDXL
    and #$07
    beq EXAM_PCURA
    jmp EXAM_LOOP
.)
EXAM_END:
    _RESET_STACK
    jmp MAIN 

    

EXAM_WAIT: .(
    _PUSH_FRAME
    jsr NEWLINE
    ldx #<EXAM_CONTINUE
    ldy #>EXAM_CONTINUE
    jsr PRINTS
L:  lda CHARIN
    beq L
    cmp #'C'
    beq CONT
    cmp #'Q'
    beq END
CONT:
    _PULL_FRAME
    rts
END:
    jmp EXAM_END
.)


; check if IDXL/H == XAML/H
; return A = 1 if true
; return A = 0 if false
EXAM_CHECK_END: .(
    clc
    lda IDXL
    cmp XAML
    bne FALSE
    lda IDXH
    cmp XAMH
    bne FALSE
    jmp TRUE
FALSE:
    lda #$0
    rts
TRUE:
    lda #$1
    rts
.)


EXAM_ARG_FETCH: .(
    jsr BCLR
L:  lda LINE_IN, x
    cmp #SPACE
    beq E
    cmp #$0
    beq E
    jsr CTON
    jsr BADD
    inx
    jmp L
E:  rts
.)

EXAM_CONTINUE:
    .byte  "C - CONTINUE | Q - QUIT",0
