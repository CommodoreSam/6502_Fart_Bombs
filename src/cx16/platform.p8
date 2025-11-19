platform {

    ubyte screen_size = 40

    sub init() {
        cx16.set_screen_mode(3) ;screen 40x30 no border
        ;cx16.VERA_DC_BORDER = 6
    }

    sub seed() {
        ubyte temp1,temp2,temp3 = cx16.entropy_get()
        math.rndseed(mkword(temp1,temp2),temp3 as uword)
    }

    bool last_timer = false
    sub blink_timer() -> bool {
        bool temp = ((cbm.RDTIM16() as ubyte & %00100000) == 0) as bool
        if temp != last_timer {
            last_timer = temp
            return true
        }
        return false
    }

}