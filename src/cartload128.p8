%output raw
%launcher none
%address $8014
%option romable
%option no_sysinit


;
; Cartridge launcher for C128
;

%zeropage basicsafe

main {
    %asm {{
            *= $8000
            jmp  _entry                ; cold start vector
            jmp  _entry                ; warm start vector
            .byte $ff                  ; autostart flag
            .byte $43, $42, $4d        ; CBM
        _entry:
            sei                         ; immediately disable interrupts
            cld                         ; clear decimal mode
            lda  #%00001010             ; TODO: figure out correct config for cartridges
            sta  c128.MMUCR             ; configure MMU
            ldx #$ff
            txs                         ; clear stack
            *= $8022

    }}
    sub start() {
        sys.memcopy(&l_prog_start, $1c01, &l_prog_end-&l_prog_start)
        %asm {{
            ; don't touch external function rom as we are running from there.
            ; the normal ram init_system will configure the MMU
            jsr  cbm.IOINIT
            jsr  cbm.RAMTAS
            jsr  cbm.RESTOR
            jsr  cbm.CINT
            jmp  $1C17  ; normal Prog8 entry point (the SYS value)
        }}
    }
l_prog_start:
%asmbinary "build/6502fb-c128.prg", 2
l_prog_end:
}

