#define _FRAME_PUSH \
    php         :   \
    pha         :   \
    phx         :   \
    phy        
#define _PUSH_FRAME _FRAME_PUSH

#define _FRAME_PULL \
    ply         :   \
    plx         :   \
    pla         :   \
    plp
#define _PULL_FRAME _FRAME_PULL

#define _PUSHXY \
    phx     :   \
    phy

#define _PULLXY \
    ply     :   \
    plx

#define _NOP4   \
    nop     :   \
    nop     :   \
    nop     :   \
    nop 

#define _ROL4   \
    rol     :   \
    rol     :   \
    rol     :   \
    rol

#define _RESET_STACK    \
    ldx #$FF        :   \
    txs

#define _SHORT_DELAY    \
    .( phx             :   \
    ldx #$FF        :   \
    _SDL: dex       :   \
    cpx #0          :   \
    bne _SDL        :   \
    plx .) 

