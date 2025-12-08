platform {
    ; F256 io mapping save byte
    ubyte map

    ubyte screen_width = 80
    ubyte screen_height = 60
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
    ubyte max_difficulty = 7
    ubyte[7] grid_width = [12,22,30,36,60,76,76]
    ubyte[7] grid_height =[12,20,24,24,50,50,50]
    ubyte[7] grid_density = [11,10,9,8,10,10,9] ;lower number means more bombs
    ubyte[7] grid_mode = [40,40,40,40,80,80,80] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
;    ubyte restore_height = 0                    ; video mode to restore to on exit
;    ubyte restore_bdcolor = 0                   ; save border color
;    ubyte restore_bgcolor = 0                   ; save background color
;    ubyte restore_color = 0                     ; save text color color
    bool sound_on
    bool first_time = true

    sub init() {
        void, screen_width, screen_height = get_screen_mode()
        ubyte menu_offset = platform.screen_width / 2 - 10
        restore_width = 80
    }

    ; cleanup before exit, restoring video mode and/or colors.
    sub cleanup() {
        ; Restore initial screen size
        if restore_width != 0 {
            ; restore video mode
            set_screen_mode(restore_width)
        }
    }

    sub seed() {
        io_map()
        math.rndseed(@($d018)+1, @($d01a)+1)
        io_unmap()
    }

    sub set_screen_mode(ubyte mode) {
        ubyte temp = 0 
        when mode {
            40 -> {
                f256.set_screen_mode(3)
                screen_height=30
            }
            80 -> {
                f256.set_screen_mode(0)
                screen_height=60
            }
            ; do nothing for invalid modes
            else -> {
                txt.print("BOGUS SCREEN MODE")
                repeat {}
            }
        }
        screen_width = mode
        platform.init.menu_offset = screen_width / 2 - 10
    }

    sub get_screen_mode() -> ubyte, ubyte, ubyte {
        return 0,80,60
    }

    bool last_timer = false
    uword last_count = 3500
    sub blink_timer() -> bool {
        io_map()
        ; maybe use the high byte? ($d01b)
        ;bool temp = (@($d01a) >>7) as bool
        bool temp = (@($d01a) >>7) & (@($d01b) >>1) as bool
        io_unmap()
        
        if temp != last_timer {
            last_timer = temp
            last_count+=1
        }
        if last_count > 4000 {
            last_count = 0
            return true
        }
        return false
    }

    inline asmsub io_map() {
        %asm {{
            phy
            ldy  f256.io_ctrl
            sty  p8b_platform.p8v_map
            ldy  #0
            sty  f256.io_ctrl
            ply
        }}
    }

    inline asmsub io_unmap() {
        %asm {{
            phy
            ldy  p8b_platform.p8v_map
            sty  f256.io_ctrl
            ply
        }}
    }

    sub splash_back() {
        ubyte scrc_index
        ubyte scrr_index
        platform.seed()
        for scrc_index in 1 to (screen_width - 2) {
            for scrr_index in 1 to (screen_height - 2) {
                if scrc_index <= (screen_width / 2 - 12) or scrc_index >= screen_width / 2 + 11 {
                    txt.setchr(scrc_index,scrr_index,16)
                    txt.setclr(scrc_index,scrr_index,cbm.COLOR_BLACK|cbm.COLOR_GRAY>>4)
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
    }

    sub sound_start() {

    }

    sub sound_clear() {
        sys.wait(10)
        sound_mute()
    }

    sub sound_flag() {
        sys.wait(10)
        sound_mute()
    }

    sub sound_small_bomb() {
    }

    sub sound_large_bomb() {
    }

    sub sound_lost() {
        sound_large_bomb()
        sys.wait(70)
        sound_mute()
    }

    sub sound_won() {

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
    ; drawing characters
    const ubyte board_upperleft = 169
    const ubyte board_upperright = 170
    const ubyte board_lowerleft = 171
    const ubyte board_lowerright = 172
    const ubyte board_upperline = 173
    const ubyte board_lowerline = 173
    const ubyte board_leftline = 174
    const ubyte board_rightline = 174
    const ubyte board_tile_covered = 227
    const ubyte board_tile_revcovered = 227
    const ubyte board_tile_flag = 33
    const ubyte board_tile_bomb = 42

    ; colors
    const ubyte border_color = cbm.COLOR_BLUE
    const ubyte board_bgcolor = cbm.COLOR_BLACK
    const ubyte board_fgcolor = cbm.COLOR_YELLOW
    const ubyte board_tile_color = cbm.COLOR_YELLOW
    const ubyte board_scorecolor = cbm.COLOR_GREEN
    ; looks better reversed (>>4) but then splash isn't reversed
    const ubyte board_tile_flagcolor = cbm.COLOR_RED
    ; looks better reversed (>>4), but fills splash background
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
    ubyte cursor_char = 'X'
    ubyte difficulty
    uword uncovered

    sub cursor_off(ubyte xb, ubyte yb) {
        ;redraws a tile in right color once cursor leaves or tile is modified by a process
        if txt.getchr(board_topx+xb,board_topy+yb) == cursor_char
            txt.setchr(board_topx+xb,board_topy+yb,current_char)
        when txt.getchr(board_topx+xb,board_topy+yb) {
            board_tile_covered -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_color >> 4)
            }
            ' ' -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_color)
            }
            board_tile_flag -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_flagcolor >> 4)
            }
            '1','2','3','4','5','6','7','8' -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_num_color[txt.getchr(board_topx+xb,board_topy+yb)-48])
            }
        }
    }
}

cbm {
%option merge

    sub STOP2() -> bool {
        return false
    }

    ; Foenix F256K2 colors
    const ubyte COLOR_BLACK = 0 << 4
    const ubyte COLOR_RED = 1 << 4
    const ubyte COLOR_DARK_BLUE = 2 << 4
    const ubyte COLOR_PURPLE = 3 << 4
    const ubyte COLOR_GREEN = 4 << 4
    const ubyte COLOR_DARK_GRAY = 5 << 4
    const ubyte COLOR_DARK_GREY = 5 << 4
    const ubyte COLOR_GRAY = 5 << 4
    const ubyte COLOR_GREY = 5 << 4
    const ubyte COLOR_BLUE = 6 << 4
    const ubyte COLOR_CYAN = 7 << 4
    const ubyte COLOR_BROWN = 8 << 4
    const ubyte COLOR_ORANGE = 9 << 4
    const ubyte COLOR_LIGHT_GRAY = 10 << 4
    const ubyte COLOR_LIGHT_GREY = 10 << 4
    const ubyte COLOR_PINK = 11 << 4
    const ubyte COLOR_LIGHT_GREEN = 12 << 4
    const ubyte COLOR_YELLOW = 13 << 4
    const ubyte COLOR_LIGHT_BLUE = 14 << 4
    const ubyte COLOR_WHITE = 15 << 4
}

