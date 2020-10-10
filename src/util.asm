// requires two, consecutive zero-page variables 
//  B16L,B16H

; Shift a nibble onto B16L, B16H
BADD: .(
    ldy #$4
L:  asl B16L
    rol B16H
    dey
    bne L
    ora B16L
    sta B16L
    rts
.)
#print BADD

; Clears B16L, B16H
BCLR:
    lda #$0
    sta B16L
    sta B16H
    rts
#print BCLR

; Convert ASCII hex character in register A to nibble
; Returns A
CTON: .(
    sec
    sbc #$30
    cmp #$0A
    bcc E
    sec
    sbc #$07
    clc
E:  rts
.)
#print CTON

; convert binary number in A to two hex ascii characters
BTOA:
    pha
    and #$0F
    jsr NTOC
    tay
    pla
    and #$F0
    ror
    ror
    ror
    ror
    jsr NTOC
    rts
#print BTOA
    
; convert nibble in A to ascii character, returns A
NTOC: .(
    cmp #$0A
    bcc S
    clc
    adc #$07
S:  adc #$30
    rts
.)
#print NTOC

;copy contents of B16 to CUR
BTOCUR:
    pha
    lda B16L
    sta CURL
    lda B16H
    sta CURH
    rts


CLEAR_TERM: .(
    ldx #80
L:  jsr NEWLINE
    dex
    bne L
    jmp MAIN
.)
#print CLEAR_TERM


; Convert binary (hex) number to a decimal string
; INPUT     NUM_CONV_HEX - Value to be converted
; OUTPUT    (Variable number of) Ascii characters stored in stack (null terminated)
HEX_2_DECS: .(
    stx XSTORE
    pla                 ; store return pointer from stack for relocation
    sta PTR_SL
    pla
    sta PTR_SH
    ldy #$0
    lda #$0
    pha
L:
    lda NUM_CONV_HEX
    beq Z
    ldx #$A
    jsr DIV
    sta NUM_CONV_HEX
    txa
    jsr NTOC
    pha
    iny
    cpy #$3
    beq E
    jmp L
Z:
    cpy #$0
    bne E
    lda #$30
    pha
E:
    ldx XSTORE
    lda PTR_SH          ; relocate return pointer
    pha
    lda PTR_SL
    pha
    rts
.)
#print HEX_2_DECS
#print NUM_CONV_HEX


; Multiply A by X times
; Returns A
MULT:
    cmp #$0
    beq MULT_RETURN
    sta MATHTEMP
    lda #$0
    cpx #$0
    beq MULT_RETURN
    clc    
MULT_LOOP:
    dex
    bmi MULT_RETURN
    adc MATHTEMP
    jmp MULT_LOOP
MULT_RETURN:
    rts
#print MULT

; Divide A by X
; Returns A (quot) and X (rem)
DIV:
    phy
    ldy #$0
    stx MATHTEMP
    sec
DIV_LOOP:
    cmp MATHTEMP
    bcc DIV_END
    sbc MATHTEMP
    iny
    jmp DIV_LOOP
DIV_END:
    tax
    tya
    ply
    rts
#print DIV
