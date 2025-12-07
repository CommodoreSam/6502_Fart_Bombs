platform {

    ubyte screen_width = 40
    ubyte screen_height = 25
    const ubyte title_width = 40
    ubyte[40] row0
    ubyte[40] row1
    ubyte[40] row2
    ubyte[40] row3
    ubyte[40] row4
    ubyte[40] row5
    ubyte[40] row6
    ubyte[40] row7
    ubyte[40] row8
    ubyte[40] row9
    ubyte[40] row10
    ubyte[40] row11
    ubyte[40] row12
    ubyte[40] row13
    ubyte[40] row14
    ubyte[40] row15
    ubyte[40] row16
    ubyte[40] row17
    ubyte[40] row18
    ubyte[40] row19
    ubyte[40] row20
    ubyte[40] row21
    ubyte[40] row22
    ubyte[40] row23
    ubyte[40] row24
    uword[25] bomb_array = [row0, row1, row2, row3, row4, row5, row6, row7, row8, row9, row10,
                            row11, row12, row13, row14, row15, row16, row17, row18, row19, row20,
                            row21, row22, row23, row24]
    ubyte max_difficulty = 5
    ubyte[5] grid_width = [12,24,30,36,36]
    ubyte[5] grid_height =[12,15,19,19,19]
    ubyte[5] grid_density = [11,10,8,8,7] ;lower number means more bombs
    ubyte[7] grid_mode = [40,40,40,40,80,80,80] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
    ubyte restore_height = 0                    ; video mode to restore to on exit
    ubyte restore_bdcolor = 0                   ; save border color
    ubyte restore_bgcolor = 0                   ; save background color
    ubyte restore_color = 0                     ; save text color color

    sub cleanup() {

    }

    sub set_screen_mode(ubyte mode) {

    }

    sub get_screen_mode() -> ubyte, ubyte, ubyte {
    return 0,0,0
    }


    sub init() {
        ubyte menu_offset = platform.screen_width / 2 - 10
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

    sub sound_mute() {

    }

    sub sound_start() {

    }

    sub sound_clear() {

    }

    sub sound_flag() {

    }

    sub sound_small_bomb() {

    }

    sub sound_large_bomb() {

    }

    sub sound_lost() {

    }

    sub sound_won() {

    }

}

game {
%option merge
    alias bomb_array = platform.bomb_array
    alias menu_offset = platform.init.menu_offset
    uword bombs_total
    uword bombs_found
    uword bombs_left
    ubyte col_count
    ubyte row_count
    ubyte board_topx
    ubyte board_topy
    ubyte col_current
    ubyte row_current
    ubyte x
    ubyte y
    const ubyte board_upperleft = 176
    const ubyte board_upperright = 174
    const ubyte board_lowerleft = 173
    const ubyte board_lowerright = 189
    const ubyte board_upperline = 192
    const ubyte board_lowerline = 192
    const ubyte board_leftline = 221
    const ubyte board_rightline = 221
    const ubyte board_tile_covered = 250
    const ubyte board_tile_revcovered = 186
    const ubyte board_tile_flag = 33
    const ubyte board_tile_bomb = 42
    const ubyte border_color = cbm.COLOR_BLUE
    const ubyte board_bgcolor = cbm.COLOR_BLACK
    const ubyte board_fgcolor = cbm.COLOR_YELLOW
    const ubyte board_tile_color = cbm.COLOR_YELLOW
    const ubyte board_scorecolor = cbm.COLOR_GREEN
    const ubyte board_tile_flagcolor = cbm.COLOR_RED
    const ubyte board_tile_bombcolor = cbm.COLOR_RED
    ubyte[] board_tile_num = [' ','1','2','3','4','5','6','7','8']
    ubyte[] board_tile_num_color = [board_bgcolor,
                                    cbm.COLOR_WHITE,
                                    cbm.COLOR_GREEN,
                                    cbm.COLOR_PURPLE,
                                    cbm.COLOR_CYAN,
                                    cbm.COLOR_YELLOW,
                                    cbm.COLOR_BLUE,
                                    cbm.COLOR_LIGHT_BLUE,
                                    cbm.COLOR_PINK]
    ubyte current_char
    ubyte cursor_char = sc:'x'
    ubyte difficulty
    uword uncovered
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
