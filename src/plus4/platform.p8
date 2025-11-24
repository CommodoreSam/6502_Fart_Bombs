platform {

    ubyte screen_width = 40
    ubyte screen_height = 25
    ubyte[3] grid_width = [12,24,36]
    ubyte[3] grid_height =[12,15,19]
    ubyte[3] grid_startx = [14,8,2]
    ubyte[3] grid_starty = [3,3,3]
    ubyte[3] grid_density = [11,10,9] ;lower number means more bombs

    sub init() {
        plus4.LUMACHROMABRD = plus4.color_table[game.border_color & 15]
        plus4.LUMACHROMABK0 = game.board_bgcolor
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
        math.rndseed(peekw(cbm.TIME_MID),peekw(plus4.RSTL8))
    }

    sub splash_back() {
        ubyte scrc_index
        ubyte scrr_index
        platform.seed()
        for scrc_index in 1 to (screen_width - 2) {
            for scrr_index in 1 to (screen_height - 2) {
                if scrc_index <= 8 or scrc_index >= 31 {
                    txt.setchr(scrc_index,scrr_index,102)
                    txt.setclr2(scrc_index,scrr_index,cbm.LUMA_COLOR_GRAY)
                }
            }
        }
    }

}

cbm {
%option merge

    ; Plus/4 color numbers, no luminance
    const ubyte COLOR_BLACK = 0
    const ubyte COLOR_WHITE = 1
    const ubyte COLOR_RED = 2
    const ubyte COLOR_CYAN = 3
    const ubyte COLOR_PURPLE = 4
    ;const ubyte COLOR_GREEN = 5
    const ubyte COLOR_GREEN = 10 ;light green matches 64's green
    const ubyte COLOR_BLUE = 6
    const ubyte COLOR_YELLOW = 7
    const ubyte COLOR_ORANGE = 8
    const ubyte COLOR_BROWN = 9
    const ubyte COLOR_YELLOW_GREEN = 10
    const ubyte COLOR_PINK = 11
    const ubyte COLOR_BLUE_GREEN = 12
    const ubyte COLOR_LIGHT_BLUE = 13
    const ubyte COLOR_DARK_BLUE = 14
    const ubyte COLOR_LIGHT_GREEN = 15

    ; Plus/4 colors with luminance 
    const ubyte LUMA_COLOR_BLACK = $10
    const ubyte LUMA_COLOR_GRAY = $51
    const ubyte LUMA_COLOR_GREY = $51
    const ubyte LUMA_COLOR_LIGHT_GRAY = $61
    const ubyte LUMA_COLOR_LIGHT_GREY = $61
    const ubyte LUMA_COLOR_WHITE = $71
    const ubyte LUMA_COLOR_RED = $32
    const ubyte LUMA_COLOR_CYAN = $63
    const ubyte LUMA_COLOR_PURPLE = $44
    const ubyte LUMA_COLOR_GREEN = $35
    const ubyte LUMA_COLOR_BLUE = $46
    const ubyte LUMA_COLOR_YELLOW = $77
    const ubyte LUMA_COLOR_ORANGE = $48
    const ubyte LUMA_COLOR_BROWN = $29
    const ubyte LUMA_COLOR_YELLOW_GREEN = $5a
    const ubyte LUMA_COLOR_PINK = $6b
    const ubyte LUMA_COLOR_BLUE_GREEN = $5c
    const ubyte LUMA_COLOR_LIGHT_BLUE = $6d
    const ubyte LUMA_COLOR_DARK_BLUE = $2e
    const ubyte LUMA_COLOR_LIGHT_GREEN = $5f
}
