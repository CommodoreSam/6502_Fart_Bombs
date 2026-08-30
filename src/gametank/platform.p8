%import gametank
%import input
%import input_gamepad
%import input_platform
;%import input_keyboard

platform {

    ubyte screen_width = 24
    ubyte screen_height = 20
    const ubyte title_width = 20
    ubyte[24] row0
    ubyte[24] row1
    ubyte[24] row2
    ubyte[24] row3
    ubyte[24] row4
    ubyte[24] row5
    ubyte[24] row6
    ubyte[24] row7
    ubyte[24] row8
    ubyte[24] row9
    ubyte[24] row10
    ubyte[24] row11
    ubyte[24] row12
    ubyte[24] row13
    ubyte[24] row14
    ubyte[24] row15
    ubyte[24] row16
    ubyte[24] row17
    ubyte[24] row18
    ubyte[24] row19
    uword[20] bomb_array
    ubyte max_difficulty = 5
    ubyte[5] grid_width = [10,12,14,16,22]
    ubyte[5] grid_height =[10,12,12,12,14]
    ubyte[5] grid_density = [10,10,8,8,7] ;lower number means more bombs
    ubyte[7] grid_mode = [40,40,40,40,40,40,40] ;screen mode for this difficulty level
    ubyte restore_width = 0                     ; video mode to restore to on exit
    ubyte restore_height = 0                    ; video mode to restore to on exit
    ubyte restore_bdcolor = 0                   ; save border color
    ubyte restore_bgcolor = 0                   ; save background color
    ubyte restore_color = 0                     ; save text color color
    bool sound_on
    bool first_time = true

    sub cleanup() {
        ; so the exit message looks ok.
        txt.plot(0,3)
    }

    sub set_screen_mode(ubyte mode) {

    }

    sub get_screen_mode() -> ubyte, ubyte, ubyte {
    return 0,0,0
    }

    sub init() {
        ubyte menu_offset = platform.screen_width / 2 - 10

        ; initialize / show logo
        gametank.sdk_init()

        ; initialized here to keep in ram not rom.
        bomb_array[0] = &row0
        bomb_array[1] = &row1
        bomb_array[2] = &row2
        bomb_array[3] = &row3
        bomb_array[4] = &row4
        bomb_array[5] = &row5
        bomb_array[6] = &row6
        bomb_array[7] = &row7
        bomb_array[8] = &row8
        bomb_array[9] = &row9
        bomb_array[10] = &row10
        bomb_array[11] = &row11
        bomb_array[12] = &row12
        bomb_array[13] = &row13
        bomb_array[14] = &row14
        bomb_array[15] = &row15
        bomb_array[16] = &row16
        bomb_array[17] = &row17
        bomb_array[18] = &row18
        bomb_array[19] = &row19
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

    ; incremented in input busy loops
    uword prngcnt
    bool seeded = false
    sub seed() {
        ; only seed once
        if seeded {
            return
        }
        seeded = true
        if prngcnt == 0 {
            prngcnt++
        }
        math.rndseed_rom(prngcnt, peekw(cbm.TIME_LO)|$1137)
    }

    sub splash_back() {
        ubyte scrc_index
        ubyte scrr_index
        for scrc_index in 0 to 23 {
            for scrr_index in 0 to 19 {
                if scrc_index == 0 or scrc_index == 22 {
                    txt.setcc(scrc_index,scrr_index,14, cbm.COLOR_DARK_GRAY)
                }
                if scrc_index == 1 or scrc_index == 23 {
                    txt.setcc(scrc_index,scrr_index,15, cbm.COLOR_DARK_GRAY)
                }
            }
        }
    }

    uword last_scan
    ubyte active_input
    sub input_scan() -> ubyte {
        uword snes = input.get(active_input) ; gamepad port 1
        if snes == last_scan return game.EVENT_NONE
        last_scan = snes

        ; probably should order by frequency of use...
        if (snes & input.DPAD_UP) == 0 return game.EVENT_UP
        if (snes & input.DPAD_DOWN) == 0 return game.EVENT_DOWN
        if (snes & input.DPAD_LEFT) == 0 return game.EVENT_LEFT
        if (snes & input.DPAD_RIGHT) == 0 return game.EVENT_RIGHT
        if (snes & input.BUTTON_A) == 0 return game.EVENT_FLAG
        if (snes & input.BUTTON_B) == 0 return game.EVENT_UNCOVER
        if (snes & input.BUTTON_X) == 0 return game.EVENT_LEAVE_GAME
        if (snes & input.BUTTON_START) == 0 return game.EVENT_NEW_GAME
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
    const ubyte board_upperleft = 1
    const ubyte board_upperright = 2
    const ubyte board_lowerleft = 3
    const ubyte board_lowerright = 4
    const ubyte board_upperline = 5
    const ubyte board_lowerline = 6
    const ubyte board_leftline = 7
    const ubyte board_rightline = 8
    const ubyte board_tile_covered = 9
    const ubyte board_tile_revcovered = 9
    const ubyte board_tile_flag = 11
    const ubyte board_tile_bomb = 12
    const ubyte border_color = cbm.COLOR_BLUE
    const ubyte board_bgcolor = cbm.COLOR_BLACK
    const ubyte board_fgcolor = cbm.COLOR_YELLOW
    const ubyte board_tile_color = cbm.COLOR_YELLOW
    const ubyte board_scorecolor = cbm.COLOR_GREEN
    const ubyte board_tile_flagcolor = cbm.COLOR_RED
    const ubyte board_tile_bombcolor = cbm.COLOR_RED
    const bool reverse_covered_tile = false
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
    ubyte cursor_char = 13
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
        yesno.column = 13
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
              game.EVENT_FLAG, game.EVENT_NEW_GAME -> {
                  ; pressed button A or START return answer.
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

    sub draw_menu() {
        txt.plot(menu_offset,board_topy + row_count + 1)
        txt.print("                    ")
        txt.plot(menu_offset+1,board_topy + row_count)
        txt.color(board_scorecolor)
        txt.chrout(10)
        txt.rvs_on()
        txt.print("a")
        txt.rvs_off()
        txt.print("=flag")
        txt.color(board_tile_flagcolor)
        txt.chrout(11)
        txt.color(board_scorecolor)
        txt.chrout(10)
        txt.rvs_on()
        txt.print("b")
        txt.rvs_off()
        txt.print("=clear")
        txt.color(board_tile_flagcolor)
        txt.chrout(12)
        txt.color(board_scorecolor)
        txt.plot(menu_offset+1+2,board_topy + row_count+1)
        txt.chrout(10)
        txt.rvs_on()
        txt.print("s")
        txt.rvs_off()
        txt.print("=pause menu")
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

    ;
    ; NOTE: keep in platform.
    ; replace main one to move title down one line
    ; to keep out of the overscan area.
    ;
    sub draw_title() {
        ;This inits the main game counts at start and play agains
        bombs_total=0
        bombs_found=0
        bombs_left=0
        txt.cls()
        platform.splash_back()
        txt.color(board_fgcolor)
        txt.plot(menu_offset,1) ; leave top line (row 0) blank
        txt.rvs_on()
        txt.print("  6502 fart b*mbs!  ")
        txt.rvs_off()
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

        str gamepad1 = "controller 1"
        str gamepad2 = "controller 2"
        uword[2] @nosplit gamepadtext = [gamepad1, gamepad2]

        ; ends up in rom
;        ^^Selector levels = ^^Selector: [ 5, 4, 10, 8, leveltext ]
;        ^^Selector gamepads = ^^Selector: [ 2, 4, 12, 12, gamepadtext ]

        ; ends up in ram
        ^^Selector levels = memory("levels", sizeof(Selector), 1)
        levels.index = last_level
        levels.num = 5
        levels.column = 5
        levels.row = 10
        levels.width = 8
        levels.active = true
        levels.choices = &leveltext

        ^^Selector gamepads = memory("gamepads", sizeof(Selector), 1)
        gamepads.index = last_gamepad
        gamepads.num = 2
        gamepads.column = 3
        gamepads.row = 12
        gamepads.width = 12
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
            platform.prngcnt++
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
                  last_level = levels.index
                  last_gamepad = gamepads.index
              }
              game.EVENT_RIGHT -> {
                  ; pass to active selector
                  selector(selector_array[active_selector], game.EVENT_RIGHT)
                  last_level = levels.index
                  last_gamepad = gamepads.index
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
        ; return difficulty level (0 based)
        return levels.index
    }

}

cbm {
%option merge
    ; Approximately C64 colors

    const ubyte YELLOW  = 0 << 5
    const ubyte ORANGE  = 1 << 5
    const ubyte RED     = 2 << 5
    const ubyte MAGENTA = 3 << 5
    const ubyte VIOLET  = 4 << 5
    const ubyte BLUE    = 5 << 5
    const ubyte CYAN    = 6 << 5
    const ubyte GREEN   = 7 << 5

    ; showing actual components
    const ubyte COLOR_BLACK = 0 | %00000000 | %00000000
    const ubyte COLOR_WHITE = 0 | %00000000 | %00000111
    ;const ubyte COLOR_RED = RED | %00011000 | %00000001
    const ubyte COLOR_RED = RED | %00011000 | %00000010 ; closer to C64
    const ubyte COLOR_CYAN = CYAN | %00011000 | %00000111
    ;const ubyte COLOR_PURPLE = MAGENTA | %00011000 | %00000001
    const ubyte COLOR_PURPLE = MAGENTA | %00011000 | %00000100 ; closer to C64
    ;const ubyte COLOR_GREEN = GREEN | %00011000 | %00000100
    const ubyte COLOR_GREEN = GREEN | %00011000 | %00000101 ; closer to C64
    ;const ubyte COLOR_BLUE = BLUE | %00011000 | %00000010
    ;const ubyte COLOR_BLUE = VIOLET | %00010000 | %00000010 ; closer to C64 (PAL?)
    const ubyte COLOR_BLUE = BLUE | %00011000 | %00000010 ; closer to C64
    ;const ubyte COLOR_YELLOW = YELLOW | %00011000 | %00000111
    const ubyte COLOR_YELLOW = YELLOW | %00010000 | %00000111 ; closer to C64
    const ubyte COLOR_ORANGE = ORANGE | %00011000 | %00000100
    ;const ubyte COLOR_BROWN = ORANGE | %00010000 | %00000001
    const ubyte COLOR_BROWN = ORANGE | %00010000 | %00000011 ; closer to C64
    ;const ubyte COLOR_PINK = RED | %00011000 | %00000110
    const ubyte COLOR_PINK = RED | %00011000 | %00000101 ; closer to C64
    ;const ubyte COLOR_DARK_GRAY = 0 | %00000000 | %00000010
    ;const ubyte COLOR_DARK_GREY = 0 | %00000000 | %00000010
    const ubyte COLOR_DARK_GRAY = 0 | %00000000 | %00000011 ; closer to C64
    const ubyte COLOR_DARK_GREY = 0 | %00000000 | %00000011 ; closer to C64
    ;const ubyte COLOR_GREY = 0 | %00000000 | %00000100
    ;const ubyte COLOR_GRAY = 0 | %00000000 | %00000100
    const ubyte COLOR_GREY = 0 | %00000000 | %00000101 ; closer to C64
    const ubyte COLOR_GRAY = 0 | %00000000 | %00000101 ; closer to C64
    ;const ubyte COLOR_LIGHT_GREEN = GREEN | %00011000 | %00000110
    const ubyte COLOR_LIGHT_GREEN = GREEN | %00011000 | %00000111 ; closer to C64
    ;const ubyte COLOR_LIGHT_BLUE = BLUE | %00011000 | %00000101
    const ubyte COLOR_LIGHT_BLUE = VIOLET | %00010000 | %00000101 ; closer to C64
    const ubyte COLOR_LIGHT_GREY = 0 | %00000000 | %00000110
    const ubyte COLOR_LIGHT_GRAY = 0 | %00000000 | %00000110

;
; this is currently used by the leave / new game Y/N code.
;
inline asmsub GETIN2() clobbers(X,Y) -> ubyte @A {
    ; -- just like GETIN, but omits the carry flag result value.
    ;    just for convenience because GETIN is so often used to just read keyboard input,
    ;    where you don't have to deal with a potential error status
    %asm {{
        phx
        phy
        lda  gametank.GAMEPAD2  ; causes *other* controller to reset select line
        lda  gametank.GAMEPAD1  ; read 1st set of buttons
        ldx  gametank.GAMEPAD1  ; read 2nd set of buttons
        ; check for dpad/buttons
        tay ; stash 1st byte
        txa ; move 2nd byte
        and  #%00000001         ; dpad_right
        bne  +
        lda  #'d'
        jmp  _done
+       txa
        and  #%00000010         ; dpad_left
        bne  +
        lda  #'a'
        jmp  _done
+       txa
        and  #%00000100         ; dpad_down
        bne  +
        lda  #'s'
        jmp  _done
+       txa
        and  #%00001000         ; dpad_up
        bne  +
        lda  #'w'
        jmp  _done
+       txa
        and  #%00010000         ; button_x (gamepad B)
        bne  +
        lda  #'n'
        jmp  _done
+       txa
        and  #%00100000         ; button_c (gamepad C)
        bne  +
        lda  #'*'
        jmp  _done
+       tya  ; get 1st byte
        and  #%00010000         ; button_z (1st byte) (gamepad A)
        bne  +
        lda  #'y'
        jmp  _done
+       tya
        and  #%00100000         ; button_enter (1st byte)
        bne  +
        lda  #'5'
        jmp  _done
+       lda  #0
_done   nop
        pha
        ;lda  #10
        lda  #7
        ldy  #0
        jsr  sys.wait
        pla
        ply
        plx
    }}
}

}
