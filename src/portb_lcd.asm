; LCD module byte format:
;   7 - buzzer (active low)
;   6 - LCD power enable/disable (active low)
;   5 - (RS) Register select
;   4 - (E)nable pin
;   3 - Data 7
;   2 - Data 6
;   1 - Data 5
;   0 - Data 4

#ifdef LCD_ENABLE
INIT_LCD: .(
    lda PORTB           ; first check if LCD power is off
    and #%01000000
    beq SKIP            ; skip power cycle if it's on
    lda #$FF            ; lcd only uses bottom 7 bits
    sta PORTB_D         ; set to output
    lda #$80            ; disable buzzer
    sta PORTB           ;  "
    jsr LCD_POWER_DISABLE
    jsr LCD_LONG_DELAY
    jsr LCD_POWER_ENABLE
    jsr LCD_LONG_DELAY
    jsr BEEP
SKIP:
    ldx #$0
    lda #$0
    sta LCDRS
L:  lda INIT_CMDS, x
    beq Q
    jsr SEND_VAL
    inx
    jmp L
Q:  jsr LCD_DELAY
    rts
.)

LCD_PUTC:
; INPUT 
;       A     - byte in
;       LCDRS - register select (0x0 or 0x20)
SEND_VAL:
    pha
    and #$F0
    ror
    ror
    ror
    ror
    ora LCDRS
    jsr SEND_B
    jsr LCD_DELAY
    pla 
    and #$0F
    ora LCDRS
    jsr SEND_B
    jsr LCD_DELAY
    rts
#print LCD_PUTC

; Hardware update - pin 7 now controls the power transistor for the screen
SEND_B: 
    ora PORTB           ; load the current state of PORTB alongside reg A
    and #%11101111      ; disable the E pin if it is still enabled
    sta PORTB
    jsr LCD_DELAY
    eor #%00010000      ; toggle the E pin
    sta PORTB
    jsr LCD_DELAY
    eor #$00010000      ; toggle the E pin
    sta PORTB
    jsr LCD_DELAY
    and #%11000000      ; clear data from bus, preserve pins 7 and 8
    sta PORTB
    jsr LCD_DELAY
    rts

LCD_DELAY: .(
    phy
    ldy #$FF
L:  dey
    bne L
    ply
    rts
.)

LCD_LONG_DELAY: .(
    phx
    phy
    ldy #$FF
    ldx #$FF
L:  dex
    bne L
    dey
    bne L
    ply
    plx
    rts
.)

; Set pin 7 to LOW to enable power (P-channel transistor)
LCD_POWER_ENABLE:
    lda PORTB
    and #%10000000
    sta PORTB
    rts
#print LCD_POWER_ENABLE

; Set pin 7 to HIGH to disable power
LCD_POWER_DISABLE:
    lda PORTB
    and #%10000000
    ora #%01000000
    sta PORTB
    rts
#print LCD_POWER_DISABLE

LCD_CLEAR:
    lda #$0
    sta LCDRS
    lda #$01
    jsr SEND_VAL
    lda #$20
    sta LCDRS
    jsr LCD_LONG_DELAY
    rts
#print LCD_CLEAR

; Set LCD character position to A (register A)
LCD_SET_POSITION: .(
    stz LCDRS
    and #%00111111
    ora #%10000000
    jsr SEND_VAL
    lda #$20
    sta LCDRS
    rts
.)
#print LCD_SET_POSITION

; Set LCD line to line A (in A register)
;   20x4 => 0-3
;   16x2 => 0 and 1 only
LCD_SET_LINE: .(
    phx
    tax
    lda LINE_ADDR, X
    jsr LCD_SET_POSITION
    plx
    rts
.)
#print LCD_SET_LINE


; PRINT String to LCD (null terminated)
; Pass string vector as X (low) and Y (high)
; Example:
;       ldx #<STRING
;       ldy #>STRING
;       jsr LCD_PRINTS
LCD_PRINTS: .(
;    jsr LCD_CLEAR
    lda #$20
    sta LCDRS
    stx LCDPRL
    sty LCDPRH
    ldy #$0
L:  lda (LCDPRL), y
    beq Q
    jsr SEND_VAL
    iny
    cpy #$FF
    beq Q
    jmp L
Q:  rts
.)
#print LCD_PRINTS

LCD_DEBUG: .(
    jsr LCD_CLEAR
    lda #$20
    sta LCDRS
    ldx #$2
L:  lda LINE_IN, x
    inx
    cmp #$0
    beq Q
    jsr SEND_VAL
    jmp L
Q:  jmp MAIN
.)

BEEP: .(
    phx
    phy
    ldx #$FF
    ldy #$05
    lda PORTB
    and #$7F
    sta PORTB
L:  dex
    bne L
    dey
    bne L
    ora #$80
    sta PORTB
    ply
    plx
    rts
.)
#print BEEP

INIT_CMDS:  .byte $02, $28, $0E, $01, $80, $00
LCDMR:      .byte   "Monitor Ready",0
LINE_ADDR:  .byte   $0, $28, $14, $3C
#endif
