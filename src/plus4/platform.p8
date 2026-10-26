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
    ;temporary labels for controls
    str[6] input_direction = ["wasd","up/dn/lt/rt","up/dn/lt/rt","up/dn/ly/ry","up/dn/lt/rt","up/dn/lt/rt"]
    str[6] input_flag = ["f","fire+dn","fire+dn","a","a","a"]
    str[6] input_uncover = ["u","fire+up","fire+up","b","b","b"]
    str[6] input_new = ["n","fire+rt","fire+rt","x","x","x"]
    str[6] input_help = ["c","c","c","c","c","c"]
    str[6] input_start = ["a","fire/a","fire/a","fire/a","fire/a","fire/a"]

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
    uword last_scan
    ; index of gamepad selector is the input device we use
    ; NOTE: we can't use GETIN2 *and* keyboard joystick input
    ; or we get double events. (so input_keyboard commented out above)
    bool last_dpad_up
    bool last_dpad_down
    bool last_dpad_left
    bool last_dpad_right
    bool last_button_a
    bool fire_overload
    alias active_input = game.last_gamepad
    sub input_scan(bool scan_all) -> ubyte {
        ubyte key = cbm.GETIN2()
        uword snes
        when key {
            136 -> return game.EVENT_CONFIG
            'n', 13 -> return game.EVENT_NEW_GAME
            'a', 157 -> return game.EVENT_LEFT
            'd', 29 -> return game.EVENT_RIGHT
            's', 17 -> return game.EVENT_DOWN
            'w', 145 -> return game.EVENT_UP
            'f' -> return game.EVENT_FLAG
            'c' -> return game.EVENT_HELP
            ' ' -> return game.EVENT_UNCOVER
        }
        if scan_all {
            input.scan_all()

            if input.dpad_up != last_dpad_up and input.dpad_up == true {
                last_dpad_up = input.dpad_up
                return game.EVENT_UP
            }
            if input.dpad_down != last_dpad_down and input.dpad_down == true {
                last_dpad_down = input.dpad_down
                return game.EVENT_DOWN
            }
            if input.dpad_left != last_dpad_left and input.dpad_left == true {
                last_dpad_left = input.dpad_left
                return game.EVENT_LEFT
            }
            if input.dpad_right != last_dpad_right and input.dpad_right == true {
                last_dpad_right = input.dpad_right
                return game.EVENT_RIGHT
            }
            if input.button_a != last_button_a and input.button_a == true {
                last_button_a = input.button_a
                return game.EVENT_FLAG
            }
            last_dpad_up = input.dpad_up
            last_dpad_down = input.dpad_down
            last_dpad_left = input.dpad_left
            last_dpad_right = input.dpad_right
            last_button_a = input.button_a
            return game.EVENT_NONE
        } else {
            snes = input.get(active_input)
        }
        if snes == last_scan return game.EVENT_NONE
        last_scan = snes
        if fire_overload {
            if (snes & input.BUTTON_A) == 0 {                                   ; fire pressed
                if ((snes & input.DPAD_UP) == 0) and ((snes & input.DPAD_DOWN) == 0) return game.EVENT_NONE
                if (snes & input.DPAD_UP) == 0 return game.EVENT_UNCOVER
                if (snes & input.DPAD_DOWN) == 0 return game.EVENT_FLAG
                if (snes & input.DPAD_RIGHT) == 0 return game.EVENT_NEW_GAME
            }
            if (snes & input.BUTTON_B) == 0 return game.EVENT_FLAG
            if (snes & input.BUTTON_X) == 0 return game.EVENT_UNCOVER
        } else {                                                            ; normal
            if ((snes & input.DPAD_UP) == 0) and ((snes & input.DPAD_DOWN) == 0) return game.EVENT_NEW_GAME
            if (snes & input.BUTTON_A) == 0 return game.EVENT_FLAG
            if (snes & input.BUTTON_B) == 0 return game.EVENT_UNCOVER
            if (snes & input.BUTTON_X) == 0 return game.EVENT_NEW_GAME
        }
        if (snes & input.DPAD_UP) == 0 return game.EVENT_UP
        if (snes & input.DPAD_DOWN) == 0 return game.EVENT_DOWN
        if (snes & input.DPAD_LEFT) == 0 return game.EVENT_LEFT
        if (snes & input.DPAD_RIGHT) == 0 return game.EVENT_RIGHT
        return game.EVENT_NONE
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
          when platform.input_scan(false) {
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
        txt.plot(menu_offset+1,1)
        txt.print(" help ")
        txt.rvs_off()
        txt.plot(menu_offset+1,3)
        txt.color(board_scorecolor)
        txt.print("object:")
        txt.plot(menu_offset+1,4)
        txt.color(board_scorecolor)
        txt.print("-clear tiles.")
        txt.plot(menu_offset+1,5)
        txt.print("-flag bomb tiles.")
        txt.plot(menu_offset+1,6)
        txt.print("-number tiles")
        txt.plot(menu_offset+1,7)
        txt.print(" show bombs next")
        txt.plot(menu_offset+1,8)
        txt.print(" to that tile.")
        txt.plot(menu_offset+1,9)
        txt.print("-don't hit a b*mb!")
        txt.color(board_fgcolor)
        txt.plot(menu_offset+1,11)
        txt.rvs_on()
        txt.print(" game control ")
        txt.rvs_off()
        txt.plot(menu_offset+1,12)
        txt.color(board_scorecolor)
        txt.print("use ")
        txt.print(game.title_menu.gamepadtext[game.last_gamepad])
        txt.plot(menu_offset+1,13)
        txt.print("move:")
        txt.plot(menu_offset+9,13)
        txt.color(board_fgcolor)
        txt.chrout(10)
        txt.rvs_on()
        txt.print(platform.input_direction[platform.active_input])
        txt.rvs_off()
        txt.plot(menu_offset+1,14)
        txt.color(board_scorecolor)
        txt.print("uncover:")
        txt.color(board_fgcolor)
        txt.plot(menu_offset+9,14)
        txt.chrout(10)
        txt.rvs_on()
        txt.print(platform.input_uncover[platform.active_input])
        txt.rvs_off()
        txt.color(board_scorecolor)
        txt.plot(menu_offset+1,15)
        txt.print("flag:")
        txt.plot(menu_offset+9,15)
        txt.color(board_fgcolor)
        txt.chrout(10)
        txt.rvs_on()
        txt.print(platform.input_flag[platform.active_input])
        txt.rvs_off()
        txt.plot(menu_offset+1,16)
        txt.color(board_scorecolor)
        txt.print("mark b*mbs to win")
        txt.color(board_tile_flagcolor)
        txt.chrout(game.board_tile_flag)
        txt.plot(menu_offset+1,18)
        txt.color(board_fgcolor)
        txt.print("exit help ")
        txt.color(board_tile_flagcolor)
        txt.print(platform.input_help[platform.active_input])
        txt.color(board_fgcolor)

        ; wait for input
        while platform.input_scan(true) == game.EVENT_NONE {}
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
            txt.print("      v2.4        ")
            txt.plot(menu_offset+1,4)
            txt.print("                  ")
            txt.rvs_off()
            txt.plot(menu_offset,6)
            txt.print("  by @commodoresam")
            txt.plot(menu_offset,7)
            txt.print("  & andrew gillham")

            ubyte menu_offset_add = ((platform.screen_width - (strings.length(platform.input_start[platform.active_input]) + 9)) / 2) - menu_offset
            txt.plot(menu_offset+menu_offset_add,15)
            txt.color(board_tile_flagcolor)
            txt.print(platform.input_start[platform.active_input])
            txt.color(board_fgcolor)
            txt.print(" to ")
            txt.color(board_tile_flagcolor)
            txt.print("start")
            txt.color(board_fgcolor)

            menu_offset_add = ((platform.screen_width - (strings.length(platform.input_help[platform.active_input]) + 17)) / 2) - menu_offset
            txt.plot(menu_offset+menu_offset_add,17)
            txt.color(board_tile_flagcolor)
            txt.print(platform.input_help[platform.active_input])
            txt.color(board_fgcolor)
            txt.print(" for ")
            txt.color(board_tile_flagcolor)
            txt.print("control help")
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
        str level6 = "level 06"
        str level7 = "level 07"
        ; zero terminated probably a waste of bytes as we should known size.
        uword[7] @nosplit leveltext = [level1, level2, level3, level4, level5, level6, level7]
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
        levels.num = platform.max_difficulty
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
            last_gamepad = gamepads.index
            when platform.input_scan(true) {
                EVENT_UP -> {
                    if active_selector > 0 {
                    ; deactivate old selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = false
                    selector(temp, EVENT_NONE)

                    active_selector--

                    ; activate new selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = true
                    selector(temp, EVENT_NONE)
                  }
              }
              EVENT_DOWN -> {
                  if active_selector < 1 {
                    ; deactivate old selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = false
                    selector(temp, EVENT_NONE)

                    active_selector++

                    ; activate new selector & redraw it
                    temp = selector_array[active_selector]
                    temp.active = true
                    selector(temp, EVENT_NONE)
                  }
              }
              EVENT_LEFT -> {
                  selector(selector_array[active_selector], EVENT_LEFT)
              }
              EVENT_RIGHT -> {
                  ; pass to active selector
                  selector(selector_array[active_selector], EVENT_RIGHT)
              }
              EVENT_NEW_GAME, EVENT_FLAG, EVENT_UNCOVER -> {
                  ; pressed START, so play game
                  done = true
              }
              EVENT_HELP -> {
                  ; pressed button C ("help" in menu), call help
                  return 255    ; signal we want the help screen.
              }
          }
          ; debug
        } until done
        ; keep track of menu selections.
        last_level = levels.index
;        ^^input.Device tmp_device
        tmp_device = input.getdev(gamepads.index)
        if (tmp_device.buttons < 2) {
            platform.fire_overload = true
        } else {
            platform.fire_overload = false
        }
        ; return difficulty level (0 based)
        return levels.index
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
