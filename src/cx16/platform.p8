platform {

    ubyte screen_width = 80
    ubyte screen_height = 60
    ubyte[80] row0
    ubyte[80] row1
    ubyte[80] row2
    ubyte[80] row3
    ubyte[80] row4
    ubyte[80] row5
    ubyte[80] row6
    ubyte[80] row7
    ubyte[80] row8
    ubyte[80] row9
    ubyte[80] row10
    ubyte[80] row11
    ubyte[80] row12
    ubyte[80] row13
    ubyte[80] row14
    ubyte[80] row15
    ubyte[80] row16
    ubyte[80] row17
    ubyte[80] row18
    ubyte[80] row19
    ubyte[80] row20
    ubyte[80] row21
    ubyte[80] row22
    ubyte[80] row23
    ubyte[80] row24
    ubyte[80] row25
    ubyte[80] row26
    ubyte[80] row27
    ubyte[80] row28
    ubyte[80] row29
    ubyte[80] row30
    ubyte[80] row31
    ubyte[80] row32
    ubyte[80] row33
    ubyte[80] row34
    ubyte[80] row35
    ubyte[80] row36
    ubyte[80] row37
    ubyte[80] row38
    ubyte[80] row39
    ubyte[80] row40
    ubyte[80] row41
    ubyte[80] row42
    ubyte[80] row43
    ubyte[80] row44
    ubyte[80] row45
    ubyte[80] row46
    ubyte[80] row47
    ubyte[80] row48
    ubyte[80] row49
    ubyte[80] row50
    ubyte[80] row51
    ubyte[80] row52
    ubyte[80] row53
    ubyte[80] row54
    ubyte[80] row55
    ubyte[80] row56
    ubyte[80] row57
    ubyte[80] row58
    ubyte[80] row59
    uword[60] bomb_array = [row0, row1, row2, row3, row4, row5, row6, row7, row8, row9, row10,
                            row11, row12, row13, row14, row15, row16, row17, row18, row19, row20,
                            row21, row22, row23, row24, row25, row26, row27, row28, row29, row30,
                            row31, row32, row33, row34, row35, row36, row37, row38, row39, row40,
                            row41, row42, row43, row44, row45, row46, row47, row48, row49, row50,
                            row51, row52, row53, row54, row55, row56, row57, row58, row59]
    ubyte[3] grid_width = [12,22,36]
    ubyte[3] grid_height =[12,20,24]
    ubyte[3] grid_startx = [14,9,2]
    ubyte[3] grid_starty = [3,3,3]
    ubyte[3] grid_density = [11,10,8] ;lower number means more bombs

    sub init() {
        void, screen_width, screen_height = cx16.get_screen_mode()
        ubyte menu_offset = platform.screen_width / 2 - 10
        ;cx16.set_screen_mode(3) ;screen 40x30 no border
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

    sub splash_back() {
        ubyte scrc_index
        ubyte scrr_index
        platform.seed()
        for scrc_index in 1 to (screen_width - 2) {
            for scrr_index in 1 to (screen_height - 2) {
                if scrc_index <= (screen_width / 2 - 12) or scrc_index >= screen_width / 2 + 11 {
                    txt.setchr(scrc_index,scrr_index,102)
                    txt.setclr(scrc_index,scrr_index,cbm.COLOR_GREY)
                }
            }
        }
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