GETLINE: .(
    _PUSH_FRAME
GLN:
    jsr NEWLINE
    lda #PROMPT
    _CHAROUT
    ldx #$0             ; reset character offset
GETLINE_GETC:
    lda CHARIN          ; get character from IO
    beq GETLINE_GETC    ;   if no character, loop
    cmp #ESC            ; is ESCAPE key?
    beq GLN             ;   scrap entire line
    cmp #CR             ; is ENTER key?
    beq GETLINE_E       ;   return
    cmp #BS             ; is backspace?
    beq GETLINE_BS
    cmp #$5F            ; backspace may be mapped to this for some reason
    beq GETLINE_BS
    sta LINE_IN, x      ; store character in buffer
    _CHAROUT            ; echo character back to IO
    inx
    cpx #$0             ; character overflow?
    beq GLN             ;   scrap entire line
    jmp GETLINE_GETC    ; get next character 
GETLINE_BS:
    cpx #$0
    beq GLN
    dex
#ifndef ANSI_ENABLE
    lda #ULIC
#endif
    _CHAROUT
    jmp GETLINE_GETC
GETLINE_E:
    lda #$0
    sta LINE_IN, x      ; null terminate line
    _PULL_FRAME
    rts
.)
#print GETLINE
