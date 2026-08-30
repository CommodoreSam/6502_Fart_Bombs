%import input
%import input_keyboard
%import input_joystick
%import input_snes_petscii
%import input_platform

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
    bool sound_on
    bool first_time = true

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
    uword last_scan
    ; index of gamepad selector is the input device we use
    ; NOTE: we can't use GETIN2 *and* keyboard joystick input
    ; or we get double events. (so input_keyboard commented out above)
    alias active_input = game.last_gamepad
    sub input_scan() -> ubyte {
        ubyte key = cbm.GETIN2()
        when key {
            'l' -> return game.EVENT_LEAVE_GAME
            136 -> return game.EVENT_CONFIG
            'n', 13 -> return game.EVENT_NEW_GAME
            'a', 157 -> return game.EVENT_LEFT
            'd', 29 -> return game.EVENT_RIGHT
            's', 17 -> return game.EVENT_DOWN
            'w', 145 -> return game.EVENT_UP
            'f' -> return game.EVENT_FLAG
            ' ' -> return game.EVENT_UNCOVER
        }
        uword snes = input.get(active_input)
        if snes == last_scan return game.EVENT_NONE
        last_scan = snes
        if (snes & input.BUTTON_A) == 0 {                                   ; fire pressed
            if ((snes & input.DPAD_UP) == 0) and ((snes & input.DPAD_DOWN) == 0) return game.EVENT_NONE
            if (snes & input.DPAD_UP) == 0 return game.EVENT_UNCOVER
            if (snes & input.DPAD_DOWN) == 0 return game.EVENT_FLAG
            if (snes & input.DPAD_LEFT) == 0 return game.EVENT_LEAVE_GAME
            if (snes & input.DPAD_RIGHT) == 0 return game.EVENT_NEW_GAME
        } else {                                                            ; normal
            if ((snes & input.DPAD_UP) == 0) and ((snes & input.DPAD_DOWN) == 0) return game.EVENT_NONE
            if (snes & input.DPAD_UP) == 0 return game.EVENT_UP
            if (snes & input.DPAD_DOWN) == 0 return game.EVENT_DOWN
            if (snes & input.DPAD_LEFT) == 0 return game.EVENT_LEFT
            if (snes & input.DPAD_RIGHT) == 0 return game.EVENT_RIGHT
            if (snes & input.BUTTON_B) == 0 return game.EVENT_FLAG
            if (snes & input.BUTTON_X) == 0 return game.EVENT_UNCOVER
        }
        return game.EVENT_NONE
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
        sys.wait(70)
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


    ;
    ; This overrides (monkey-patches) the one in main.p8
    ;
    sub askyesno() -> ubyte {
        bool done = false
        str yes = "yes"
        str no = "no "
        uword[2] @nosplit yesnotext = [no, yes] ; match boolean to index (0=false, 1=true)

        ; ends up in ram
        ^^Selector yesno = memory("yesno", sizeof(Selector), 1)
        yesno.index = 1
        yesno.num = 2
        yesno.column = 21
        yesno.row = board_topy + row_count + 1
        yesno.width = 3
        yesno.active = true
        yesno.choices = &yesnotext

        ; draw the selector first
        selector(yesno, game.EVENT_NONE)

        ; scan input
        ; these are events in the *menu* not gameplay so
        ; might seem slightly confusing. :)
        do {
          when platform.input_scan() {
              game.EVENT_LEFT -> {
                  selector(yesno, game.EVENT_LEFT)
              }
              game.EVENT_RIGHT -> {
                  selector(yesno, game.EVENT_RIGHT)
              }
              ; accept any button press to return answer.
              EVENT_FLAG, EVENT_NEW_GAME, EVENT_UNCOVER -> {
                  done = true
              }
          }
        } until done
        ; return whether it was yes or no.
        ; this and the play_again() caller should probably
        ; switch to returning a bool true/false.
        if yesno.index == 1 {
            return 'y'
        }
        return 'n'
    }

    ; shows help / object of the game
    sub draw_help() {
        txt.cls()
        platform.splash_back()
        txt.rvs_on()
        txt.plot(menu_offset+1,2)
        txt.print(" object ")
        txt.rvs_off()
        txt.plot(menu_offset+1,3)
        txt.color(board_scorecolor)
        txt.print("-clear tiles.")
        txt.plot(menu_offset+1,4)
        txt.print("-flag bomb tiles.")
        txt.plot(menu_offset+1,5)
        txt.print("-number tiles")
        txt.plot(menu_offset+1,6)
        txt.print(" show bombs next")
        txt.plot(menu_offset+1,7)
        txt.print(" to that tile.")
        txt.plot(menu_offset+1,8)
        txt.print("-don't hit a b*mb!")
        txt.color(board_fgcolor)
        txt.plot(menu_offset+1,10)
        txt.rvs_on()
        txt.print(" gamepad control ")
        txt.rvs_off()
        txt.plot(menu_offset+1,12)
        txt.color(board_scorecolor)
        txt.print("move:")
        txt.plot(menu_offset+9,12)
        txt.color(board_fgcolor)
        txt.chrout(10)
        txt.rvs_on()
        txt.print("dpad")
        txt.rvs_off()
        txt.plot(menu_offset+1,13)
        txt.color(board_scorecolor)
        txt.print("uncover:")
        txt.color(board_fgcolor)
        txt.plot(menu_offset+9,13)
        txt.chrout(10)
        txt.rvs_on()
        txt.print("b")
        txt.rvs_off()
        txt.color(board_scorecolor)
        txt.plot(menu_offset+1,14)
        txt.print("flag:")
        txt.plot(menu_offset+9,14)
        txt.color(board_fgcolor)
        txt.chrout(10)
        txt.rvs_on()
        txt.print("a")
        txt.rvs_off()

        txt.plot(menu_offset+1,15)
        txt.color(board_scorecolor)
        txt.print("mark b*mbs to win")
        txt.color(board_tile_flagcolor)
        txt.chrout(game.board_tile_flag)

        txt.plot(menu_offset+2,17)
        txt.color(board_fgcolor)
        txt.print("press ")
        txt.color(board_tile_flagcolor)
        txt.print("c")
        txt.color(board_fgcolor)
        txt.print(" for ")
        txt.color(board_scorecolor)
        txt.print("menu")
        txt.color(board_fgcolor)

        ; wait for specific button (C)
        while platform.input_scan() != game.EVENT_LEAVE_GAME {}
    }

    sub draw_splash() {
        bool done = false
        difficulty=0
        do {
            txt.cls()
            platform.splash_back()
            ubyte exit_title = 'n'
            txt.color(board_fgcolor)
            txt.rvs_on()
            txt.plot(menu_offset+1,1)
            txt.print("                  ")
            txt.plot(menu_offset+1,2)
            txt.print(" 6502 fart b*mbs! ")
            txt.plot(menu_offset+1,3)
            txt.print("      v2.3        ")
            txt.plot(menu_offset+1,4)
            txt.print("                  ")
            txt.rvs_off()
            txt.plot(menu_offset,6)
            txt.print("  by @commodoresam")
            txt.plot(menu_offset,7)
            txt.print("  & andrew gillham")

            txt.plot(menu_offset+2,15)
            txt.color(board_fgcolor)
            txt.print("press ")
            txt.color(board_tile_flagcolor)
            txt.print("s")
            txt.color(board_fgcolor)
            txt.print(" or ")
            txt.color(board_tile_flagcolor)
            txt.print("start")
            txt.color(board_fgcolor)

            txt.plot(menu_offset+2,17)
            txt.color(board_fgcolor)
            txt.print("press ")
            txt.color(board_tile_flagcolor)
            txt.print("c")
            txt.color(board_fgcolor)
            txt.print(" for ")
            txt.color(board_scorecolor)
            txt.print("help")
            txt.color(board_fgcolor)

            ; call new selector handling
            ; use 255 as a signal to show help.
            difficulty = title_menu()
            if difficulty == 255 {
                game.draw_help()
            } else {
                done = true
            }
        } until done
    }

    ; track last selection so each
    ; time we hit the menu we don't have to reconfigure.
    ubyte last_level
    ubyte last_gamepad
    ; we should draw the front menu and scan for input
    ; if the input is dpad we see if it is up/down/left/right
    ; and what that does for our menu.
    ; should we have a menu struct or just per selector struct?
    sub title_menu() -> ubyte {
        bool done = false
        const ubyte level_choices = platform.max_difficulty
        str level1 = "level 01"
        str level2 = "level 02"
        str level3 = "level 03"
        str level4 = "level 04"
        str level5 = "level 05"
        ; zero terminated probably a waste of bytes as we should known size.
        uword[5] @nosplit leveltext = [level1, level2, level3, level4, level5]

;        str gamepad1 = "controller 1"
;        str gamepad2 = "controller 2"
;        uword[2] @nosplit gamepadtext = [gamepad1, gamepad2]

        ; set to maximum possible controllers. (8 for now)
        uword[8] @nosplit gamepadtext
        ubyte i
        ubyte dev_count = input.count()
        ^^input.Device tmp_device
        for i in 0 to dev_count - 1 {
            tmp_device = input.getdev(i)
            gamepadtext[i] = tmp_device.name
        }

        ; ends up in rom
;        ^^Selector levels = ^^Selector: [ 5, 4, 10, 8, leveltext ]
;        ^^Selector gamepads = ^^Selector: [ 2, 4, 12, 12, gamepadtext ]

        ; ends up in ram
        ^^Selector levels = memory("levels", sizeof(Selector), 1)
        levels.index = last_level
        levels.num = 5
        levels.column = 13
        levels.row = 10
        levels.width = 8
        levels.active = true
        levels.choices = &leveltext

        ^^Selector gamepads = memory("gamepads", sizeof(Selector), 1)
        gamepads.index = last_gamepad
        gamepads.num = dev_count
        gamepads.column = 10
        gamepads.row = 12
        gamepads.width = 21
        gamepads.active = false
        gamepads.choices = &gamepadtext

        ^^Selector temp

        ; "contains non constant elements"
;        uword[] selector_array = [levels, gamepads]
        ; this ends up in ram.
        uword[2] selector_array
        selector_array[0] = levels
        selector_array[1] = gamepads
        ubyte active_selector = 0

        ; initial draw of two selectors

        selector(levels, game.EVENT_NONE)
        selector(gamepads, game.EVENT_NONE)

        ; scan input
        ; these are events in the *menu* not gameplay so
        ; might seem slightly confusing. :)
        do {
            ; this is used to seed rnd(), varies by user input delay
;            platform.prngcnt++
          when platform.input_scan() {
              game.EVENT_UP -> {
                  if active_selector > 0 {
                    ; deactivate old selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = false
                    selector(temp, game.EVENT_NONE)

                    active_selector--

                    ; activate new selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = true
                    selector(temp, game.EVENT_NONE)
                  }
              }
              game.EVENT_DOWN -> {
                  if active_selector < 1 {
                    ; deactivate old selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = false
                    selector(temp, game.EVENT_NONE)

                    active_selector++

                    ; activate new selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = true
                    selector(temp, game.EVENT_NONE)
                  }
              }
              game.EVENT_LEFT -> {
                  selector(selector_array[active_selector], game.EVENT_LEFT)
              }
              game.EVENT_RIGHT -> {
                  ; pass to active selector
                  selector(selector_array[active_selector], game.EVENT_RIGHT)
              }
              game.EVENT_NEW_GAME -> {
                  ; pressed START, so play game
                  done = true
              }
              game.EVENT_LEAVE_GAME -> {
                  ; pressed button C ("help" in menu), call help
                  return 255    ; signal we want the help screen.
              }
          }
          ; debug
        } until done
        ; keep track of menu selections.
        last_level = levels.index
        last_gamepad = gamepads.index
        ; return difficulty level (0 based)
        return levels.index
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
