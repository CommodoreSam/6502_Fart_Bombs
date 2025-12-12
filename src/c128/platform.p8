platform {

    ubyte screen_width = 40
    ubyte screen_height = 25
    const ubyte title_width = 40
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
    bool sound_on
    bool first_time = true
    ß

    sub cleanup() {

    }

    sub set_screen_mode(ubyte mode) {

    }

    sub get_screen_mode() -> ubyte, ubyte, ubyte {
    return 0,0,0
    }


    sub init() {
        ubyte menu_offset = platform.screen_width / 2 - 10
        c64.EXTCOL = game.border_color
        c64.BGCOL0 = game.board_bgcolor
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
        math.rndseed(peekw($a1)+1,peekw($d012)+1)
    }

    sub splash_back() {
        ubyte scrc_index
        ubyte scrr_index
        platform.seed()
        for scrc_index in 1 to (screen_width - 2) {
            for scrr_index in 1 to (screen_height - 2) {
                if scrc_index <= 8 or scrc_index >= 31 {
                    txt.setchr(scrc_index,scrr_index,102)
                    txt.setclr(scrc_index,scrr_index,cbm.COLOR_GREY)
                }
            }
        }
    }

    sub sound_init() {
        if first_time
            sound_on = true
        first_time=false
    }

    sub sound_toggle() {
        if sound_on
            sound_on = false
        else
            sound_on = true
    }

    sub sound_mute() {
        c64.MVOL = 0
    }

    sub sound_start() {

    }

    sub sound_clear() {
        c64.MVOL = 5
        c64.AD1 = %00100010
        c64.SR1 = %00000000
        c64.FREQ1 = 15600
        c64.CR1 = %10000000
        c64.CR1 = %10000001
        sys.wait(10)
        sound_mute()
    }

    sub sound_flag() {
        c64.MVOL = 8
        c64.AD1 = %01010111
        c64.SR1 = %00000000
        c64.FREQ1 = 5500
        c64.CR1 = %00010000
        c64.CR1 = %00010001
        sys.wait(10)
        sound_mute()
    }

    sub sound_small_bomb() {
        c64.MVOL = 10
        c64.AD1 = %01100110
        c64.SR1 = %00000000
        c64.FREQ1 = 1600
        c64.CR1 = %10000000
        c64.CR1 = %10000001
        sys.wait(math.randrange(4))
    }

    sub sound_large_bomb() {
        c64.MVOL = 15
        c64.AD1 = %01101010
        c64.SR1 = %00000000
        c64.FREQ1 = 2600
        c64.CR1 = %10000000
        c64.CR1 = %10000001
    }

    sub sound_won() {
        const ubyte waveform = %0001       ; triangle
        c64.AD1 = %00011010
        c64.SR1 = %00000000
        c64.AD2 = %00011010
        c64.SR2 = %00000000
        c64.MVOL = 15
        uword note
        for note in notes {
            ubyte note1 = lsb(note)
            ubyte note2 = msb(note)
            c64.FREQ1 = music_freq_table[note1]    ; set lo+hi freq of voice 1
            c64.FREQ2 = music_freq_table[note2]    ; set lo+hi freq of voice 2

            ; retrigger voice 1 and 2 ADSR
            c64.CR1 = waveform <<4 | 0
            c64.CR2 = waveform <<4 | 0
            c64.CR1 = waveform <<4 | 1
            c64.CR2 = waveform <<4 | 1
            sys.wait(8)
        }
    }

    uword[] notes = [
        $1622, $1d26, $2229, $252e, $1424, $1f27, $2029, $2730,
        $122a, $122c, $1e2e, $1231, $202c, $3337, $212d, $3135,
        $1622, $162e, $161d, $1624, $1420, $1430, $1424, $1420,
        $1622, $162e, $161d, $1624, $1e2a, $1e3a, $1e2e, $1e2a,
        $142c, $142c, $141b, $1422, $1c28, $1c38, $1c2c, $1c28,
        $111d, $292d, $111f, $292e, $0f27, $0f27, $1633, $1627
    ]


    uword[] music_freq_table = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        732, 778, 826, 876, 928, 978, 1042, 1100, 1170, 1238, 1312, 1390, 1464, 1556,
        1652, 1752, 1856, 1956, 2084, 2200, 2340, 2476, 2624, 2780, 2928, 3112, 3304,
        3504, 3712, 3912, 4168, 4400, 4680, 4952, 5248, 5560, 5856, 6224, 6608, 7008,
        7424, 7824, 8336, 8800, 9360, 9904, 10496, 11120, 11712
    ]

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