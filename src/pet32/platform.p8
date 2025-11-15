platform {

    ubyte screen_size = 40

    sub init() {
    }

    sub seed() {
        math.rndseed(peekw($a1)+1,peekw($d012)+1)
    }
}