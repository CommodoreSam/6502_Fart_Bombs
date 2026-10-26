%import input
%import input_keyboard
%import input_joystick
%import input_snes_petscii
%import input_platform

platform {

    ubyte screen_width = txt.DEFAULT_WIDTH
    ubyte screen_height = txt.DEFAULT_HEIGHT
    const ubyte title_width = 20
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
    ubyte max_difficulty = 6
    ubyte[] grid_width = [12,18,22,22,22,22]
    ubyte[] grid_height =[12,16,16,16,16,16]
    ubyte[] grid_density = [10,9,8,7,6,5] ;lower number means more bombs
    ubyte[] grid_mode = [40,40,40,40,40,40] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
    ubyte restore_height = 0                    ; video mode to restore to on exit
    ubyte restore_bdcolor = 0                   ; save border color
    ubyte restore_bgcolor = 0                   ; save background color
    ubyte restore_color = 0                     ; save text color color
    bool sound_on
    const uword voice1 = 36874
    const uword voice2 = 36875
    const uword voice3 = 36876
    const uword voice4 = 36877
    const uword volume = 36878
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
        cbm.bdcol(game.border_color)
        cbm.bgcol(game.board_bgcolor)

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
        math.rndseed(peekw(cbm.TIME_MID)+1,peekw(vic20.VICCR4)+1)
    }

    sub splash_back() {
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
        sound_on = true
    }

    sub sound_toggle() {
        if sound_on
            sound_on = false
        else
            sound_on = true
    }

    sub sound_mute() {
        @(volume)=0
        @(voice1)=0
        @(voice2)=0
        @(voice3)=0
        @(voice4)=0
    }

    sub sound_start() {

    }

    sub sound_clear() {
        ubyte value
        @(volume)=5
        for value in 1 to 140
            @(voice4)=value
            sys.wait(5)
        sound_mute()
    }

    sub sound_flag() {
        ubyte value
        @(volume)=5
        for value in 150 to 160
            @(voice3)=value
            sys.wait(2)
        sound_mute()
    }

    sub sound_small_bomb() {
        @(volume)=8
        @(voice3)=100
        sys.wait(1)
        @(voice3)=200
        sys.wait(1)
        @(voice3)=0
    }

    sub sound_large_bomb() {
        ubyte value
        @(volume)=15
        for value in 250 to 140 step -1
            @(voice4)=value
        sys.wait(70)
    }

    sub sound_won() {
        @(volume)=15
        ubyte[] notes_array = [232,10,225,10,227,10,228,10,230,10,232,10,232,20,
                               230,10,228,10,227,10,225,10,223,10,225,10,225,20,
                               232,10,225,10,227,10,228,10,230,10,232,10,232,20,
                               230,10,228,10,227,10,225,10,223,10,225,10,223,30,
                               225,10,227,10,228,10,230,10,232,20,
                               230,10,228,10,227,10,225,20,
                               223,10,225,10,227,10,228,10,230,10,232,10,230,10,228,10,
                               227,20,225,10,223,20,
                               232,10,232,10,230,10,228,10,227,10,225,10,223,20,
                               225,10,227,10,228,10,230,10,232,30,
                               230,10,228,10,227,10,225,10,223,10,225,10,223,40]
        ubyte note
        for note in 0 to ((sizeof(notes_array)/2) - 1) step 2 {
            @(voice2)=notes_array[note]
            sys.wait(notes_array[note+1])
        }
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
        levels.column = 4
        levels.row = 10
        levels.width = 8
        levels.active = true
        levels.choices = &leveltext

        ^^Selector gamepads = memory("gamepads", sizeof(Selector), 1)
        gamepads.index = last_gamepad
        gamepads.num = dev_count
        gamepads.column = 1
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
