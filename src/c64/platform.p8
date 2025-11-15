platform {

    sub init() {
        c64.EXTCOL = game.border_color
        c64.BGCOL0 = game.board_bgcolor
    }

    sub seed() {
        math.rndseed(peekw($a1)+1,peekw($d012)+1)
    }
}