#include "src/ascii_const.h"
#include "src/macros.h"

; Build Options
//#define RAM_LOAD
#define DEBUG_ENABLE
#define IRQ_ENABLE
#define LCD_ENABLE
//#define VGA_ENABLE
#define ANSI_ENABLE
#define SD_DRIVE_ENABLE

#ifndef RAM_LOAD
* = $C000
#else
* = $3100
#endif

#ifdef VGA_ENABLE
#define _CHAROUT    sta CHAROUT : jsr VGA_CHAROUT
#else
#define _CHAROUT    sta CHAROUT
#endif

; System Constants
CHAROUT = $8001	; Character output port
CHARIN  = $8002 ; Character input port
RANDOM  = $8003
PORTA   = $8044
PORTA_D = $804C
PORTB   = $8040
PORTB_D = $8048
VIAIFR  = $8074
VIAIER  = $8078
ISR     = $00FE
#print CHAROUT
#print CHARIN
#print RANDOM
#print PORTA
#print PORTA_D
#print PORTB
#print PORTB_D
#print VIAIER
#print VIAIFR
#PRINT ISR

; Variables
LINE_IN     = $0200      ; Command line input 0x0200 - 0x02FF
;TOKEN_BUFF  = $0300      ; Token buffer       0x0300 - 0x03FF
B16L        = $E0        ; required by util.asm
B16H        = $E1        ; required by util.asm
PRL         = $E2        ; required by prints.asm
PRH         = $E3        ; required by prints.asm
READC_IDX   = $E4
LINE_IN_IDX = $E5
CURL        = $E6        ; current system memory address L
CURH        = $E7        ; current system memory address H
XAML        = $E8        ; required for exam.asm
XAMH        = $E9        ; required for exam.asm
IDXL        = $EA        ; required for exam.asm
IDXH        = $EB        ; required for exam.asm
WORP        = $EC        ; flag for WRITE or POKE command (WRITE == 1) (POKE == 0)
LCDRS       = $ED        ; required for portb_lcd.asm
LCDPRL      = $EE        ; required for portb_lcd.asm
LCDPRH      = $EF        ; required for portb_lcd.asm
EXAM_CNT    = $F0
MATHTEMP    = $F1        ; used by MULT and DIV in util.asm
NUM_CONV_HEX= $F2        ; used by HEX_2_DECS in util.asm
XSTORE      = $F3        ; used by HEX_2_DECS in util.asm
PTR_SL      = $F4        ; pointer store, used by util.asm
PTR_SH      = $F5        ;  "
D_PRL       = $F6        ; Used by porta_sd_driver.asm
D_PRH       = $F7        ; Used by porta_sd_driver.asm
D_BLK0      = $F8        ; Used by porta_sd_driver.asm
D_BLK1      = $F9        ; Used by porta_sd_driver.asm
D_BLK2      = $FA        ; Used by porta_sd_driver.asm
D_BLK3      = $FB        ; Used by porta_sd_driver.asm
D_DBL       = $FC        ; Used by porta_sd_driver.asm
D_DBH       = $FD        ; Used by porta_sd_driver.asm
; FE, FF reserved for ISR pointer

; Main entry point
TMON3_RESET:
INIT:
    sei                 ; disable IRQ
    lda #$00            ; reset IRQ/BRK vector to monitor start
    sta ISR             ;  otherwise calls to BRK will crash
    lda #$C0            ;  "
    sta ISR + 1         ;  "
TMON3_MAIN:
    _RESET_STACK
    cld
    clc
#ifdef VGA_ENABLE
    jsr VGA_INIT
#endif
#ifdef LCD_ENABLE
    jsr INIT_LCD
    jsr LCD_CLEAR
    ldx #<LCDMR
    ldy #>LCDMR
    jsr LCD_PRINTS
#endif
    ldx #<TITLE
    ldy #>TITLE
    jsr PRINTS
MAIN:
MON_RETURN:
    lda #$0
    sta LINE_IN_IDX
    jsr GETLINE
    jmp RUNCMD
    jmp MAIN
#print TMON3_RESET
#print TMON3_MAIN


ISR_ENTRY:
    jmp (ISR)
#print ISR_ENTRY


TITLE: .byte    LF,CR,"TPC65 - TMONv3.6",0


// includes 
#include "src/monisr_test.asm"
#include "src/prints.asm"
#include "src/portb_lcd.asm"
#include "src/util.asm"
#include "src/exam.asm"
#include "src/debug.asm"
#include "src/getline.asm"
#include "src/write.asm"
#include "src/runcmd.asm"
#include "src/gettoken.asm"
#include "src/porta_vga_driver.asm"
#include "src/porta_sd_driver.asm"
#include "src/memutils.asm"
#include "src/console.asm"
