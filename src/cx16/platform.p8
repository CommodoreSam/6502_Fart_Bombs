platform {

    ubyte screen_size = 40

    sub init() {
        cx16.set_screen_mode(3) ;screen 40x30 no border
        ;cx16.VERA_DC_BORDER = 6
    }

    sub seed() {
        math.rndseed(peekw($a1)+1,peekw(cx16.VERA_SCANLINE_L)+1)
    }

}