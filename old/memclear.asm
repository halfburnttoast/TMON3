CRL = $0
CRH = $1
CRHB = $02
CRHE = $7F
CLEAR_RAM:
.(
    jsr NEWLINE
    ldx #<CLEAR_RAM_STRING
    ldy #>CLEAR_RAM_STRING
    jsr PRINTS
    lda #$0
    sta CRL
    lda #CRHB
    sta CRH
    lda #$0
    ldy #$0
L:  sta (CRL), y
    inc CRL
    bne L
    lda CRH
    cmp #CRHE
    beq E
    lda #"."
    sta CHAROUT
    lda #$0
    inc CRH
    jmp L
E:
    jmp $C000
.)


CLEAR_RAM_STRING:
    .byte "Clearing RAM",LF,CR,0
