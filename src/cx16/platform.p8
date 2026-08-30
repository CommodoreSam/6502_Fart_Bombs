%import psg

platform {

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
    ubyte max_difficulty = 4
    ubyte[7] grid_width = [12,22,30,36,60,76,76]
    ubyte[7] grid_height =[12,20,24,24,50,50,50]
    ubyte[7] grid_density = [11,10,9,8,10,10,9] ;lower number means more bombs
    ubyte[7] grid_mode = [40,40,40,40,80,80,80] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
    ubyte restore_height = 0                    ; video mode to restore to on exit
    ubyte restore_bdcolor = 0                   ; save border color
    ubyte restore_bgcolor = 0                   ; save background color
    ubyte restore_color = 0                     ; save text color color
    bool sound_on

    sub cleanup() {
        ; Restore initial screen size
        if restore_width != 0 {
            ; restore video mode
            set_screen_mode(restore_width)
        }
    }

    sub set_screen_mode(ubyte mode) {
        when mode {
            40 -> {
                cx16.set_screen_mode(3)
                screen_height = 30
            }

            80 -> {
                cx16.set_screen_mode(0)
                screen_height = 60
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
    return 0,0,0
    }


    sub init() {
        void, screen_width, screen_height = cx16.get_screen_mode()
        ubyte menu_offset = platform.screen_width / 2 - 10
        restore_width = screen_width
        if screen_width == 80 and screen_height == 60
            max_difficulty = 7
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

        sub input_scan() -> ubyte {
            ubyte key = cbm.GETIN2()
            when key {
                'l' -> return game.EVENT_LEAVE_GAME
                136 -> return game.EVENT_CONFIG
                'n' -> return game.EVENT_NEW_GAME
                'a', 157 -> return game.EVENT_LEFT
                'd', 29 -> return game.EVENT_RIGHT
                's', 17 -> return game.EVENT_DOWN
                'w', 145 -> return game.EVENT_UP
                'f' -> return game.EVENT_FLAG
                ' ' -> return game.EVENT_UNCOVER
            }
            return game.EVENT_NONE
        }

sub sound_init() {
        sound_on = true
        cx16.vpoke(1, $f9c2, %00111111)     ; volume max, no channels
        psg.silent()
        cx16.enable_irq_handlers(true)
        cx16.set_vsync_irq_handler(&psg.envelopes_irq)
    }

    sub sound_toggle() {
        if sound_on
            sound_on = false
        else
            sound_on = true
    }

    sub sound_mute() {
        psg.silent()
    }

    sub sound_clear() {
        ; soft click/"tschk" sound
        psg.freq(0, 15600)
        psg.voice(0, psg.LEFT | psg.RIGHT, 32, psg.NOISE, 0)
        psg.envelope(0, 32, 200, 1, 100)
        sys.wait(5)
        sound_mute()
    }

    sub sound_flag() {
        psg.freq(2, 1500)
        psg.voice(2, psg.LEFT | psg.RIGHT, 32, psg.TRIANGLE, 0)
        psg.envelope(2, 40, 100, 6, 10)
        sys.wait(5)
        sound_mute()
    }

    sub sound_small_bomb() {
        psg.freq(3, 1400)
        psg.voice(3, psg.LEFT | psg.RIGHT, 63, psg.NOISE, 0)
        psg.envelope(3, 63, 100, 8, 10)
        sys.wait(math.randrange(4))
    }

    sub sound_large_bomb() {
        ; big explosion
        psg.freq(4, 2500)
        psg.voice(4, psg.LEFT | psg.RIGHT, 63, psg.NOISE, 0)
        psg.envelope(4, 63, 100, 20, 10)
        sys.wait(70)
    }

    sub sound_won() {
        psg.silent()
        psg.voice(0, psg.LEFT, 63, psg.TRIANGLE, 0)
        psg.voice(1, psg.RIGHT, 63, psg.TRIANGLE, 0)
        cx16.enable_irq_handlers(true)
        cx16.set_vsync_irq_handler(&psg.envelopes_irq)

        uword note
        for note in notes {
            ubyte note0 = lsb(note)
            ubyte note1 = msb(note)
            psg.freq(0, vera_freqs[note0])
            psg.freq(1, vera_freqs[note1])
            psg.envelope(0, 63, 255, 0, 6)
            psg.envelope(1, 63, 255, 0, 6)
            sys.wait(10)
        }

        psg.silent()
        cx16.disable_irq_handlers()

    }


    ; details about the boulderdash music can be found here:
    ; https://www.elmerproductions.com/sp/peterb/sounds.html#Theme%20tune

    uword[] notes = [
        $1622, $1d26, $2229, $252e, $1424, $1f27, $2029, $2730,
        $122a, $122c, $1e2e, $1231, $202c, $3337, $212d, $3135,
        $1622, $162e, $161d, $1624, $1420, $1430, $1424, $1420,
        $1622, $162e, $161d, $1624, $1e2a, $1e3a, $1e2e, $1e2a,
        $142e, $142e, $142e, $142e, $202e, $202e, $142e, $142e]

    uword[] vera_freqs = [
        0,0,0,0,0,0,0,0,0,0,   ; first 10 notes are not used
        120, 127, 135, 143, 152, 160, 170, 180, 191, 203,
        215, 227, 240, 255, 270, 287, 304, 320, 341, 360,
        383, 405, 429, 455, 479, 509, 541, 573, 607, 640,
        682, 720, 766, 810, 859, 910, 958, 1019, 1082, 1147,
        1215, 1280, 1364, 1440, 1532, 1621, 1718, 1820, 1917]
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
    const bool reverse_covered_tile = true
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
