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
    ubyte max_difficulty = 7
    ubyte[7] grid_width = [12,24,30,36,60,76,76]
    ubyte[7] grid_height =[12,15,19,19,19,19,19]
    ubyte[7] grid_density = [11,10,8,8,8,8,7]   ;lower number means more bombs
    ubyte[7] grid_mode = [40,40,40,40,80,80,80] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
    ubyte restore_height = 0                    ; video mode to restore to on exit
    ubyte restore_bdcolor = 0                   ; save border color
    ubyte restore_bgcolor = 0                   ; save background color
    ubyte restore_color = 0                     ; save text color color
    bool sound_on

    sub init() {
        screen_width, screen_height = cbm.SCREEN()
        ; adjust from zero relative
        screen_width++
        screen_height++

        ;ubyte menu_offset = platform.screen_width / 2 - 10
        ubyte menu_offset = title_width / 2 - 10
        restore_width = screen_width
        restore_height = screen_height
        restore_bdcolor = mega65.EXTCOL
        restore_bgcolor = mega65.BGCOL0
        ;restore_color = cbm.COLOR  ; TODO: need to find this or read color ram.

        ; set game colors
        mega65.EXTCOL = game.border_color
        mega65.BGCOL0 = game.board_bgcolor

        ; change to 40x25 mode
        ;set_screen_mode(40)

    }

    ; cleanup before exit, restoring video mode and/or colors.
    sub cleanup() {
        ; Restore initial screen size
        if restore_width != 0 {
            ; restore video mode
            set_screen_mode(restore_width)
        }
        mega65.EXTCOL = restore_bdcolor
        mega65.BGCOL0 = restore_bgcolor
        ;txt.color(restore_color)
    }

    sub set_screen_mode(ubyte mode) {
        when mode {
            40 -> {
                ; use "Escape + 4" to change screen size
                txt.chrout(27)
                txt.chrout('4')
            }

            80 -> {
                ; use "Escape + 8" to change screen size
                txt.chrout(27)
                txt.chrout('8')
            }
            ; do nothing for invalid modes
            else -> {
                txt.print("BOGUS SCREEN MODE")
                repeat {}
            }
        }
        screen_width = mode
        screen_height = 25
        platform.init.menu_offset = screen_width / 2 - 10
    }

    sub get_screen_mode() -> ubyte, ubyte, ubyte {
        return 0,0,0
    }

    bool last_timer = false
    ubyte last_count = 0
    sub blink_timer() -> bool {
        bool temp = (mega65.RASTER >>7) as bool

        if temp != last_timer {
            last_timer = temp
            last_count+=1
        }
        if last_count > 60 {
            last_count = 0
            return true
        }
        return false
    }

    sub seed() {
        math.rndseed(cbm.RDTIM16()+1,mega65.RASTER+1)
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

    sub sound_init() {
        sound_on = false
    }

    sub sound_toggle() {

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
