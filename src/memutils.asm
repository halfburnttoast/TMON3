
; reuse zero-page variables
CPY_SRCL    = XAML
CPY_SRCH    = XAMH
CPY_DESTL   = IDXL
CPY_DESTH   = IDXH
CPY_LIML    = PRL
CPY_LIMH    = PRH
#print CPY_SRCL   
#print CPY_SRCH   
#print CPY_DESTL  
#print CPY_DESTH  
#print CPY_LIML   
#print CPY_LIMH   

; monitor API
; <START> <END> <DEST>
MON_MEM_COPY: .(
    inx
    jsr NEWLINE
    jsr GETTOKEN
    beq ERR
    jsr EXAM_ARG_FETCH
    lda B16L
    sta CPY_SRCL
    lda B16H
    sta CPY_SRCH
    jsr GETTOKEN
    beq ERR
    jsr EXAM_ARG_FETCH
    lda B16L
    sta CPY_LIML
    lda B16H
    sta CPY_LIMH
    jsr GETTOKEN
    beq ERR
    jsr EXAM_ARG_FETCH
    lda B16L
    sta CPY_DESTL
    lda B16H
    sta CPY_DESTH
    jsr MEM_CPY
    bra Q
ERR:ldx #<ERRS
    ldy #>ERRS
    jsr PRINTS
Q:  jmp MON_RETURN
ERRS:   .byte   "MISSING ARGS",0
.)


; external functions
MEM_CPY: .(
    phy
    ldy #$0
L:  lda #'.'
    sta CHAROUT
    lda (CPY_SRCL), y
    sta (CPY_DESTL), y
    jsr CPY_CHECKEND    ; returns 1 if CPY_SRC and CPY_DEST match
    bne END 
    inc CPY_SRCL
    bne NCS
    inc CPY_SRCH
NCS:inc CPY_DESTL
    bne NCD
    inc CPY_DESTH
NCD:bra L
END:ply
    rts
.)

; clears (zeros out) all RAM, this must cause a system reset
MEM_CLEAR: .(
    LOWP    = $0
    HIGHP   = $1
    jsr NEWLINE
    ldx #<CONFIRMS
    ldy #>CONFIRMS
    jsr PRINTS
GC: lda CHARIN
    beq GC
    cmp #'Y'
    bne ABORT
    jsr NEWLINE
    lda #$FF
    sta LOWP
    lda #$7F
    sta HIGHP
    ldy #$0
L:  clc
    lda #$0
    sta (LOWP), y
    sec
    lda LOWP
    sbc #$1
    sta LOWP
    bcs L
    lda #'.'
    sta CHAROUT
    lda HIGHP
    sec
    sbc #$1
    sta HIGHP
    bcs L
END:jmp TMON3_RESET
ABORT:
    jmp MON_RETURN
CONFIRMS:   .byte   "ZERO ALL RAM (Y/N)?",0
.)

; internal functions
; Returns 1 if match
CPY_CHECKEND: .(
    lda CPY_SRCL
    cmp CPY_LIML
    bne NE
    lda CPY_SRCH
    cmp CPY_LIMH
    bne NE
    lda #$1
    rts
NE: lda #$0
    rts
.)








