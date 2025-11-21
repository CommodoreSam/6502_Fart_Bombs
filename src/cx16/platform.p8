platform {

    ubyte screen_width = 40
    ubyte screen_height = 30
    ubyte grid_width = 30
    ubyte grid_height = 19
    ubyte grid_startx = 5
    ubyte grid_starty = 3

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

cbm {
%option merge

    ; C64 colors
    const ubyte COLOR_BLACK = 0
    const ubyte COLOR_WHITE = 1
    const ubyte COLOR_RED = 2
    const ubyte COLOR_CYAN = 3
    const ubyte COLOR_PURPLE = 4
    const ubyte COLOR_GREEN = 5
    const ubyte COLOR_BLUE = 6
    const ubyte COLOR_YELLOW = 7
    const ubyte COLOR_ORANGE = 8
    const ubyte COLOR_BROWN = 9
    const ubyte COLOR_PINK = 10
    const ubyte COLOR_DARK_GRAY = 11
    const ubyte COLOR_DARK_GREY = 11
    const ubyte COLOR_GRAY = 12
    const ubyte COLOR_GREY = 12
    const ubyte COLOR_LIGHT_GREEN = 13
    const ubyte COLOR_LIGHT_BLUE = 14
    const ubyte COLOR_LIGHT_GRAY = 15
    const ubyte COLOR_LIGHT_GREY = 15
}