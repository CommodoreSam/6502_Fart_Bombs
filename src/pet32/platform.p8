platform {

    ubyte screen_width = 40
    ubyte screen_height = 25
    ubyte grid_width = 30
    ubyte grid_height = 19
    ubyte grid_startx = 5
    ubyte grid_starty = 3

   sub init() {
    }

    bool last_timer = false
    sub blink_timer() -> bool {
        bool temp = ((cbm.TIME_LO & %00100000) == 0) as bool
        if temp != last_timer {
            last_timer = temp
            return true
        }
        return false
    }

    sub seed() {
        math.rndseed(mkword(cbm.TIME_MID, cbm.TIME_LO),peekw($e844))
    }
}