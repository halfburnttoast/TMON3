RUNCMD:
    ldx #$0
RUNCMD_NC:
    lda LINE_IN, x
    inx
    cmp #SPACE          ; ignore spaces
    beq RUNCMD_NC 
    cmp #XAMC           ; is eXam command?
    beq RUNCMD_EXAM
    cmp #WRIC
    beq RUNCMD_WRITE
    cmp #POKE
    beq RUNCMD_POKE
    cmp #RUNC
    beq RUNCMD_RUN
    cmp #MCHR
    beq RUNCMD_MANIFEST
    cmp #TCHR
    beq RUNCMD_COPY
    cmp #CCHR
    beq RUNCMD_CLS
    cmp #STRC
    beq RUNCMD_SDCARD
    cmp #ZCHR
    beq RUNCMD_CLEARMEM
#ifdef IRQ_ENABLE
    cmp #INTC
    beq RUNCMD_INT
#endif
#ifdef DEBUG_ENABLE
    cmp #DBGC           ; debug command
    beq RUNCMD_DBG
#endif
#ifdef LCD_ENABLE
    cmp #LCDC
    beq RUNCMD_LDBG
#endif
    jsr NEWLINE
    lda #ERRC           ; if character not found, reset
    _CHAROUT
    jmp MAIN 
RUNCMD_EXAM:
    jmp EXAM
#ifdef DEBUG_ENABLE
RUNCMD_DBG:
    jmp DEBUG
#endif
#ifdef LCD_ENABLE
RUNCMD_LDBG:
    jmp LCD_DEBUG
#endif
RUNCMD_WRITE:
    lda #$1
    sta WORP
    jmp WRITE
RUNCMD_POKE:
    lda #$0
    sta WORP
    jmp WRITE
RUNCMD_RUN:
#ifdef LCD_ENABLE
    jsr LCD_CLEAR
#endif
    jmp (CURL)
#ifdef IRQ_ENABLE
RUNCMD_INT:
    jmp ISR_TEST_SETUP
#endif
RUNCMD_MANIFEST:
    ldx #$00
    ldy #$FF
    jsr PRINTS
    jmp MAIN
RUNCMD_CLS:
    jmp CLEAR_TERM
#ifdef SD_DRIVE_ENABLE
RUNCMD_SDCARD:
    jmp SD_MONITOR
#endif
RUNCMD_COPY:
    jmp MON_MEM_COPY
RUNCMD_CLEARMEM:
    jmp MEM_CLEAR
