%import textio

platform {

    ubyte screen_width = txt.DEFAULT_WIDTH
    ubyte screen_height = txt.DEFAULT_HEIGHT
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

    ubyte[3] grid_width = [12,18,22]
    ubyte[3] grid_height =[12,16,16]
    ubyte[3] grid_startx = [4,2,0]
    ubyte[3] grid_starty = [3,3,3]
    ubyte[3] grid_density = [11,10,9] ;lower number means more bombs

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
