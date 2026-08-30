%output raw
%launcher none
%address $8009
%option romable
%option no_sysinit


;
; Cartridge launcher
;

%zeropage basicsafe

main {
    %asm {{
            *= $8000
            .addr prog8_program_start
            .addr p8b_main.p8s_nmi
            .byte $c3, $c2, $cd, $38, $30
            *= $8017    ; after above plus startup code

    }}
    sub start() {
        sys.memcopy(&l_prog_start, $0801, &l_prog_end-&l_prog_start)
        %asm {{
            jsr  cbm.IOINIT
            jsr  cbm.RAMTAS
            jsr  cbm.RESTOR
            jsr  cbm.CINT
            jmp  $0817
        }}
    }

    asmsub nmi() {
        %asm {{
            rti
        }}
    }
l_prog_start:
%asmbinary "build/6502fb-c64.prg", 2
l_prog_end:
}

