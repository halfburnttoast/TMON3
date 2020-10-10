// if LCD_ENABLE is defined, this module uses lcd.asm

#ifdef IRQ_ENABLE
ISR_TEST_SETUP:
    ; load test IRQ vector
    lda #<MON_ISR
    sta ISR
    lda #>MON_ISR
    sta ISR + 1
    
    ; enable CA1 interrupt
    lda #$C0
    sta PORTA_D
    lda #$82
    sta VIAIER

    ; enable interrupts
    ldx #<IRQEN
    ldy #>IRQEN
    jsr PRINTS
    lda PORTA
    cli
    lda #$80
    sta PORTA
    jmp MAIN

MON_ISR: .(
    _PUSH_FRAME
    sta PORTA
    lda VIAIFR
    pha
    lda PORTA
    and #$3F
    pha
    lda #$40
    sta PORTA
    jsr LCD_CLEAR
    ldx #<IRQS
    ldy #>IRQS
    jsr LCD_PRINTS
    ldx #$2
L:  pla
    jsr BTOA
    jsr SEND_VAL
    tya
    jsr SEND_VAL
    lda #SPACE
    jsr SEND_VAL
    dex
    bne L
    lda #$80
    sta PORTA
    _PULL_FRAME
    rti
.)
#endif
    
IRQS:  .byte    "IRQ PA: ",0
IRQEN: .byte    LF,CR,"Test interrupt enabled",LF,CR,0
#endif
