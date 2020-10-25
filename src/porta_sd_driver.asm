#ifdef SD_DRIVE_ENABLE

#define _BEGIN_SD_CMD   \
    lda #MOSI        :  \
    sta PORTA
#define _END_SD_CMD     \
    lda #MOSI | N_CS :  \
    sta PORTA

SD_WAIT_LIMIT   = $A0

; Variables used
;D_PRL       = $F6 
;D_PRH       = $F7 
;D_BLK0      = $F8 
;D_BLK1      = $F9 
;D_BLK2      = $FA 
;D_BLK3      = $FB 
;D_DBL       = $FC 
;D_DBH       = $FD 
SD_BLK0 = D_BLK0
SD_BLK1 = D_BLK1
SD_BLK2 = D_BLK2
SD_BLK3 = D_BLK3
SD_DATABUFFERL = D_DBL
SD_DATABUFFERH = D_DBH
#print SD_BLK0
#print SD_BLK1
#print SD_BLK2
#print SD_BLK3
#print SD_DATABUFFERL
#print SD_DATABUFFERH

; Data buffer
DATA_BUFFER = $7D00
SD_DATA_BUFFER = DATA_BUFFER
#print SD_DATA_BUFFER

; porta pin mapping
N_CS    = $01
SCK     = $02
MOSI    = $04
MISO    = $08



; Monitor routines
SD_MONITOR: .(
    jsr NEWLINE
NC: lda LINE_IN, x
    inx
    cmp #SPACE
    beq NC
    cmp #"I"
    beq SDM_INIT
    cmp #"S"
    beq SDM_SEEK
    cmp #"L"
    beq SDM_LOAD
    cmp #"W"
    beq SDM_WRITE
    cmp #"N"
    beq SDM_INC
    jmp END
SDM_INIT:
    jsr SD_DRIVE_INIT
    jmp END
SDM_LOAD:
    jsr SD_SET_DATABUFFER
    beq L_NO_ARG
    jsr SD_READ_BLOCK_TO
    jmp END
L_NO_ARG:
    jsr SD_READ_BLOCK
    jmp END
SDM_WRITE:
    jsr SD_SET_DATABUFFER
    beq W_NO_ARG
    jsr SD_WRITE_BLOCK_FROM
    jmp END
W_NO_ARG:
    jsr SD_WRITE_BLOCK
    jmp END
SDM_INC:
    jsr SD_BUFFER_INC
    jmp END
SDM_SEEK:
    jsr SD_DRIVE_SEEK
END:jmp MON_RETURN
.)

SD_SET_DATABUFFER: .(
    phx
CHECK:                  ; Check if there are any arguments in line
    lda LINE_IN, x
    beq NO_ARG
    cmp #SPACE
    bne ARG_FOUND
    inx
    jmp CHECK
ARG_FOUND:
    plx
    jsr GETTOKEN
    jsr EXAM_ARG_FETCH  ; borrow this function to get parameter
    lda B16L
    sta D_DBL
    lda B16H
    sta D_DBH
    lda #$1
    jmp END
NO_ARG:
    plx
    lda #$0
END:rts
.)

SD_DRIVE_SEEK: .(
    phx
CHECK:                  ; Check if there are any arguments in line
    lda LINE_IN, x
    beq NO_ARG
    cmp #SPACE
    bne ARG_FOUND
    inx
    jmp CHECK
ARG_FOUND:
    plx
    stz SD_BLK0
    stz SD_BLK1
    stz SD_BLK2
    stz SD_BLK3
L:  jsr GETTOKEN
    cmp #$0         ; if end of arguments 
    beq END
    lda SD_BLK2     ; shift sector address over one byte
    sta SD_BLK3
    lda SD_BLK1
    sta SD_BLK2
    lda SD_BLK0
    sta SD_BLK1
    jsr EXAM_ARG_FETCH  ; borrow this function to get parameter
    lda B16L
    sta SD_BLK0
    jmp L
NO_ARG:
    ldx #$4
L2:
    dex
    lda SD_BLK0, x
    jsr BTOA
    sta CHAROUT
    sty CHAROUT
    lda #' '
    sta CHAROUT
    cpx #$0
    bne L2
    plx                 ; pull from top of file
END:rts
.)




; Public API
SD_WRITE_BLOCK: 
    lda #<DATA_BUFFER
    sta D_DBL
    lda #>DATA_BUFFER
    sta D_DBH
SD_WRITE_BLOCK_FROM: .(
    _BEGIN_SD_CMD
    phx
    ldx #5
T:  jsr READ_BYTE
    cmp #$0
    bne READY
    jsr DELAY
    dex
    cpx #0
    bne T
    plx             ; will only run on fail
    jmp WRITE_FAIL
READY:
    plx             ; pull from retry loop above

    ; send WRITE_BLOCK (CMD24)
    lda #$58
    jsr SD_SEND_BYTE
    lda D_BLK3
    jsr SD_SEND_BYTE
    lda D_BLK2
    jsr SD_SEND_BYTE
    lda D_BLK1
    jsr SD_SEND_BYTE
    lda D_BLK0
    jsr SD_SEND_BYTE
    lda #$1
    jsr SD_SEND_BYTE

    ; wait for response
    jsr WAIT_READY
    cmp #$0
    beq BEGIN_COPY
WF: jsr BTOA
    sta CHAROUT
    sty CHAROUT
    lda #' '
    sta CHAROUT
    jsr NEWLINE
    jmp WRITE_FAIL
BEGIN_COPY:
    ldx #$0
    ldy #$2
    lda #$FE                    ; send start token
    jsr SD_SEND_BYTE
COPY_LOOP
    jsr DELAY
    _PUSHXY
    ldy #$0
    lda (D_DBL), y
    jsr SD_SEND_BYTE
    _PULLXY
    clc
    lda D_DBL
    adc #$1
    sta D_DBL
    bcc NO_CARRY
    inc D_DBH
    clc
NO_CARRY:
    dex
    bne COPY_LOOP
    dey
    bne COPY_LOOP
    lda #$FF
    jsr SD_SEND_BYTE                       ; fake CRC (required)
    jsr SD_SEND_BYTE
    jsr WAIT_READY
L:  jsr READ_BYTE                       ; wait for busy flag to end
    cmp #$0
    beq L
    _END_SD_CMD
    rts
WRITE_FAIL:
    ldx #<FAILS
    ldy #>FAILS
    jsr PRINTS
    _END_SD_CMD
    rts
FAILS:  .byte   "DRIVE WRITE FAIL",0    
.)
#print SD_WRITE_BLOCK
#print SD_WRITE_BLOCK_FROM


SD_READ_BLOCK:
    lda #<DATA_BUFFER
    sta D_DBL
    lda #>DATA_BUFFER
    sta D_DBH 
SD_READ_BLOCK_TO: .(            ; call if using custom databuffer location
    _BEGIN_SD_CMD

    ; send READ_SINGLE_BLOCK
    lda #$51            ; CMD 17
    jsr SD_SEND_BYTE
    lda D_BLK3
    jsr SD_SEND_BYTE
    lda D_BLK2
    jsr SD_SEND_BYTE
    lda D_BLK1
    jsr SD_SEND_BYTE
    lda D_BLK0
    jsr SD_SEND_BYTE
    lda #$1
    jsr SD_SEND_BYTE

    ; wait for response
    jsr WAIT_READY
    cmp #$0
    beq BEGIN_COPY
RF: jsr BTOA
    sta CHAROUT
    sty CHAROUT
    lda #' '
    sta CHAROUT
    jmp READ_FAIL
BEGIN_COPY:
    jsr WAIT_READY      ; wait for return token
    cmp #$FE
    bne RF
    ldx #$0
    ldy #$2
COPY_LOOP:
    _PUSHXY
    ldy #$0
    jsr READ_BYTE
    sta (D_DBL), y
    _PULLXY
    clc
    lda D_DBL
    adc #$1
    sta D_DBL
    bcc NO_CARRY
    inc D_DBH
    clc
NO_CARRY:
    dex
    bne COPY_LOOP
    dey 
    bne COPY_LOOP
    jsr READ_BYTE
    _END_SD_CMD
    rts
READ_FAIL:
    ldx #<FAILS
    ldy #>FAILS
    jsr PRINTS
    _END_SD_CMD
    jmp MON_RETURN 
FAILS:  .byte   "DRIVE READ FAIL",0    
.)
#print SD_READ_BLOCK
#print SD_READ_BLOCK_TO


; Initialize SD card for read/write
SD_DRIVE_INIT: .(
    ldx #<INITS
    ldy #>INITS
    jsr PRINTS
    lda #N_CS | SCK | MOSI      ; set PORTA pins to output
    sta PORTA_D
    lda #MOSI | N_CS
    sta PORTA
    ldx #$80
L:  eor #SCK
    sta PORTA
    eor #SCK
    sta PORTA
    dex
    bne L
    lda #MOSI
    sta PORTA
    jsr CMD_0                   ; GO_IDLE_STATE
    jsr CMD_8                   ; SEND_IF_COND
    cmp #$0
    beq FAIL
L2:                             ; this may need to be sent several times
    jsr CMD_55                  ; APP_CMD
    jsr CMD_41                  ; SD_SEND_OP_COND
    cmp #$0
    beq SUCCESS
    jsr DELAY
    jmp L2
SUCCESS:
    ldx #<READYS
    ldy #>READYS
    jsr PRINTS
    _END_SD_CMD
    rts
FAIL:
    ldx #<IFAILS
    ldy #>IFAILS
    jsr PRINTS
    _END_SD_CMD
    rts
INITS:  .byte   "DRIVE INIT",LF,CR,0
READYS: .byte   "DRIVE READY",LF,CR,0
IFAILS:  .byte   "DRIVE INIT FAIL",LF,CR,0
.)
#print SD_DRIVE_INIT

SD_BUFFER_INC: .(
    phx
    ldx #$0
L:  clc
    lda SD_BLK0, x
    adc #$1
    sta SD_BLK0, x
    bcc Q
    inx
    bra L
Q:  plx 
    clc
    rts
.)
#print SD_BUFFER_INC


; Internal routines
SEND_CMD: .(
    sty D_PRH
    stx D_PRL
    ldx #$6
    ldy #$0
L:  lda (D_PRL), y
    jsr SD_SEND_BYTE 
    iny
    dex
    bne L
    rts
.) 

SD_SEND_BYTE: .(
    phx
    phy
    ldx #$8
L:  asl
    tay
    lda #$0
    sta PORTA
    bcc OUT
    ora #MOSI
OUT:sta PORTA
    eor #SCK
    sta PORTA
    tya
    dex
    bne L
    lda #MOSI
    sta PORTA
    ply
    plx
    rts
.)    


DELAY: .(
    phx
    ldx #$FF
L:  dex
    bne L
    plx
    rts
.)


; read byte, return in A
READ_BYTE: .(
    phx
    phy
    clc
    ldx #$8                         ; index
    ldy #$0                         ; result
    lda #MOSI                       ; MOSI needs to be held high
    sta PORTA
L:  lda PORTA
    eor #SCK    
    sta PORTA                       ; SCK HIGH
    _NOP4
    lda PORTA
    and #MISO
    clc
    beq ZERO
    sec
ZERO:
    tya
    rol
    tay
    lda PORTA       
    eor #SCK
    sta PORTA                       ; SCK low
    _NOP4
    dex
    bne L
    tya
    ply
    plx
    rts
.)


; SD_SEND_OP_COND
CMD_41: .(
    _PUSHXY
    ldx #<CMD41B
    ldy #>CMD41B
    jsr SEND_CMD
    jsr WAIT_READY
    _PULLXY
    rts
.)

; APP_CMD
CMD_55: .(
    _PUSHXY
    ldx #<CMD55B
    ldy #>CMD55B
    jsr SEND_CMD
    jsr WAIT_READY
    _PULLXY
    rts
.)

; GO_IDLE_STATE
CMD_0: .(
    _PUSHXY
    ldx #<CMD0B
    ldy #>CMD0B
    jsr SEND_CMD
    jsr WAIT_READY
    _PULLXY
    rts
.)

; SEND_IF_COND
CMD_8: .(
    _PUSHXY
    ldx #<CMD8B
    ldy #>CMD8B
    jsr SEND_CMD
    jsr WAIT_READY
    jsr READ_BYTE               ; ignore return arguments
    jsr READ_BYTE   
    jsr READ_BYTE
    jsr READ_BYTE
    cmp #$0
    bne SUCCESS
    lda #$0
    bra Q
SUCCESS:
    lda #$FF
Q:  _PULLXY
    rts
.)

; wait until SD card is ready (returns non-0xFF value)
WAIT_READY: .(
    phx
    ldx #SD_WAIT_LIMIT
LOOP:
    jsr DELAY
    jsr READ_BYTE
    cmp #$FF
    bne Q
    dex
    cpx #$0
    beq TIMEOUT
    jmp LOOP
Q:
    plx
    rts
TIMEOUT:
    jsr NEWLINE
    ldx #<TOS
    ldy #>TOS
    jsr PRINTS
    bra Q
TOS:    .byte   "SD WAIT_READY TIMEOUT",0
.)


CMD0B:  .byte   $40,$00,$00,$00,$00,$95
CMD8B:  .byte   $48,$00,$00,$01,$AA,$87
CMD55B: .byte   $77,$00,$00,$00,$00,$01
CMD41B: .byte   $69,$40,$00,$00,$00,$01
DONES:  .byte   "DONE",LF,CR,0
#endif - SD_DRIVE_ENABLE
