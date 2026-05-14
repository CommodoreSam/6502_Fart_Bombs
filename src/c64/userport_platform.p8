;
; read/write User Port pins / bits
;
platform {

    sub init() {
        ;c64.EXTCOL = 0
        ;c64.BGCOL0 = 0
        ;userport.init(%10101010)
    }
}

userport {
%option merge
%option ignore_unused

    ;
    ; pin definitions
    ;
    const ubyte PIN_C       = %00000001
    const ubyte PIN_D       = %00000010
    const ubyte PIN_E       = %00000100
    const ubyte PIN_F       = %00001000
    const ubyte PIN_H       = %00010000
    const ubyte PIN_J       = %00100000
    const ubyte PIN_K       = %01000000
    const ubyte PIN_L       = %10000000

    ;
    ; called from the common init() for target
    ; specific initialization.
    ;
    sub init_platform() {
    }

    ;
    ; read a byte from the user port register
    ;
    inline asmsub get() -> ubyte @A {
        %asm {{
            lda  c64.CIA2PRB
        }}
    }
    ;
    ; write a byte to the user port register
    ;
    inline asmsub set(ubyte pins @A) {
        %asm {{
            sta  c64.CIA2PRB
        }}
    }

    ;
    ; read a byte from the user port data direction register
    ;
    inline asmsub getd() -> ubyte @A {
        %asm {{
            php
            sei
            lda  c64.CIA2DDRB
            plp
        }}
    }

    ;
    ; write a byte to the user port data direction register
    ;
    inline asmsub setd(ubyte pins @A) {
        %asm {{
            php
            sei
            sta  c64.CIA2DDRB
            plp
        }}
    }
}
