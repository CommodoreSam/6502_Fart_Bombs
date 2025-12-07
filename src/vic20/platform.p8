%import textio

platform {

    ubyte screen_width = txt.DEFAULT_WIDTH
    ubyte screen_height = txt.DEFAULT_HEIGHT
    const ubyte title_width = 40
    ubyte[22] row0
    ubyte[22] row1
    ubyte[22] row2
    ubyte[22] row3
    ubyte[22] row4
    ubyte[22] row5
    ubyte[22] row6
    ubyte[22] row7
    ubyte[22] row8
    ubyte[22] row9
    ubyte[22] row10
    ubyte[22] row11
    ubyte[22] row12
    ubyte[22] row13
    ubyte[22] row14
    ubyte[22] row15
    ubyte[22] row16
    ubyte[22] row17
    ubyte[22] row18
    ubyte[22] row19
    ubyte[22] row20
    ubyte[22] row21
    ubyte[22] row22
    uword[23] bomb_array = [row0, row1, row2, row3, row4, row5, row6, row7, row8, row9, row10,
                            row11, row12, row13, row14, row15, row16, row17, row18, row19, row20,
                            row21, row22]
    ubyte max_difficulty = 5
    ubyte[5] grid_width = [12,18,22,22,22]
    ubyte[5] grid_height =[12,16,16,16,16]
    ubyte[5] grid_density = [11,10,9,8,7] ;lower number means more bombs
    ubyte[7] grid_mode = [40,40,40,40,80,80,80] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
    ubyte restore_height = 0                    ; video mode to restore to on exit
    ubyte restore_bdcolor = 0                   ; save border color
    ubyte restore_bgcolor = 0                   ; save background color
    ubyte restore_color = 0                     ; save text color color
    bool sound_on


    sub cleanup() {

    }

    sub set_screen_mode(ubyte mode) {

    }

    sub get_screen_mode() -> ubyte, ubyte, ubyte {
    return 0,0,0
    }


    sub init() {
        ubyte menu_offset = platform.screen_width / 2 - 10
        cbm.bdcol(game.border_color)
        cbm.bgcol(game.board_bgcolor)
    }

    sub seed() {
        math.rndseed(peekw(cbm.TIME_MID)+1,peekw(vic20.VICCR4)+1)
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

    sub splash_back() {
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

    ; VIC-20 colors
    ; border only does first 8 (3 bits)
    const ubyte COLOR_BLACK = 0
    const ubyte COLOR_WHITE = 1
    const ubyte COLOR_RED = 2
    const ubyte COLOR_CYAN = 3
    const ubyte COLOR_PURPLE = 4
    const ubyte COLOR_GREEN = 5
    const ubyte COLOR_BLUE = 6
    const ubyte COLOR_YELLOW = 7
    const ubyte COLOR_ORANGE = 8
    const ubyte COLOR_LIGHT_ORANGE = 9
    const ubyte COLOR_PINK = 10
    const ubyte COLOR_LIGHT_CYAN = 11
    const ubyte COLOR_LIGHT_PURPLE = 12
    const ubyte COLOR_LIGHT_GREEN = 13
    const ubyte COLOR_LIGHT_BLUE = 14
    const ubyte COLOR_LIGHT_YELLOW = 15

    ;
    ; the ora/and makes sure we don't keep any of the
    ; upper 4 bits currently in the register
    ;
    inline asmsub bgcol(ubyte color @Y) {
        %asm {{
            pha
            lda P8ZP_SCRATCH_B1
            pha
            tya
            ; shift lower nibble to upper nibble
            asl
            asl
            asl
            asl
            ; save upper nibble
            sta P8ZP_SCRATCH_B1
            lda $900f
            ; clear the upper nibble of current contents of $900f
            and #%00001111
            ; combine upper and lower nibbles
            ora P8ZP_SCRATCH_B1
            ; store back
            sta $900f
            ; restore
            pla
            sta P8ZP_SCRATCH_B1
            pla
        }}
    }

    inline asmsub bdcol(ubyte color @Y) {
        %asm {{
            lda P8ZP_SCRATCH_B1
            pha
            tya
            ; mask off just the 3 bits we want to change
            and #%00000111
            sta P8ZP_SCRATCH_B1
            lda $900f
            and #%11111000
            ora P8ZP_SCRATCH_B1
            sta $900f
            pla
            sta P8ZP_SCRATCH_B1
        }}
    }
}
