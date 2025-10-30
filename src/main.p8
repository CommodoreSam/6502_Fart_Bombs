;
; 6502 Fart Bombs
;

%import textio
%import strings
%import floats
%import syslib
%import conv
%zeropage basicsafe

main {
    sub start() {
        ;txt.lowercase();
        game.set_boardsize(30,20,5,3,30)
        game.draw_title()
        game.draw_scoreboard()
        game.draw_playboard()
        game.set_bombs()
        ubyte success = game.play()
    }
}

game {

    ubyte col_count
    ubyte row_count
    ubyte board_topx
    ubyte board_topy
    ubyte col_current
    ubyte row_current
    ubyte x
    ubyte y
    ubyte bombs_total
    ubyte bombs_found
    ubyte bombs_left
    str[25] board_array
    const ubyte board_upperleft = 176
    const ubyte board_upperright = 174
    const ubyte board_lowerleft = 173
    const ubyte board_lowerright = 189
    const ubyte board_upperline = 99
    const ubyte board_lowerline = 99
    const ubyte board_leftline = 98
    const ubyte board_rightline = 98
    const ubyte board_tile_covered = 186 ;will be in reverse or custom character
    const ubyte board_tile_revcovered = 250
    const ubyte board_tile_flag = 33
    const ubyte board_tile_revflag = 161
    const ubyte board_tile_bomb = 42
    const ubyte board_tile_num0 = 48
    const ubyte board_tile_num1 = 49
    const ubyte board_tile_num2 = 50
    const ubyte board_tile_num3 = 51
    const ubyte board_tile_num4 = 52
    const ubyte board_tile_num5 = 53
    const ubyte board_tile_num6 = 54
    const ubyte board_tile_num7 = 55
    const ubyte board_tile_num8 = 56
    const ubyte board_tile_open = 32
    const ubyte border_color = 6
    const ubyte board_bgcolor = 0
    const ubyte board_fgcolor = 7
    const ubyte board_tile_color = 7
    const ubyte board_tile_revcolor = 14
    const ubyte board_tile_flagcolor = 3

    sub draw_title() {
        c64.EXTCOL = border_color
        c64.BGCOL0 = board_bgcolor
        txt.cls()
        txt.color(board_fgcolor)
        txt.plot(board_topx+(col_count / 2 -8),0)
        txt.rvs_on()
        txt.print("6502 fart bombs")
        txt.rvs_off()
    }

    sub draw_scoreboard() {
        txt.plot(board_topx,board_topy - 1)
        txt.print("found: ")
        txt.print_ub(bombs_found)
        txt.print(" left: ")
        txt.print_ub(bombs_left)
    }

   sub set_boardsize(ubyte columns, ubyte rows, ubyte startx, ubyte starty, ubyte bombs) {
        col_count = columns
        row_count = rows
        board_topx = startx
        board_topy = starty
        bombs_total = bombs
    }

    sub set_bombs() {
        ;tell player bombs are being set
        txt.plot(2,board_topy + row_count + 1)
        txt.color(5)
        txt.print("one night when the moon was green...")
        ;place bombs
        bombs_total = (row_count*col_count/.05) as ubyte
        ;calc numb tiles
        sys.wait(200)
        txt.plot(1,board_topy + row_count + 1)
        txt.color(5)
        txt.rvs_on()
        txt.print("wasd")
        txt.rvs_off()
        txt.print("=move ")
        txt.rvs_on()
        txt.print("f")
        txt.rvs_off()
        txt.print("=flag ")
        txt.rvs_on()
        txt.print("space")
        txt.rvs_off()
        txt.print("=uncover ")
        txt.rvs_on()
        txt.print("l")
        txt.rvs_off()
        txt.print("=leave")
    }

    sub cursor_on(ubyte xa, ubyte ya) {
            txt.setclr(board_topx+xa,board_topy+ya,board_tile_revcolor)
    }

    sub cursor_off(ubyte xb, ubyte yb) {
        ubyte current_char = txt.getchr(board_topx+xb,board_topy+yb)
        when current_char {

            board_tile_covered, board_tile_revcovered -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_color)
                return
            }
            board_tile_flag, board_tile_revflag -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_flagcolor)
                return
            }
        }
    }

    sub flag(ubyte xf, ubyte yf) {
        if txt.getchr(board_topx+xf, board_topy+yf) == board_tile_flag or
            txt.getchr(board_topx+xf, board_topy+yf) == board_tile_flag ^ 128 {
            txt.plot(board_topx+xf, board_topy+yf)
            txt.color(board_tile_flagcolor)
            txt.rvs_on()
            txt.chrout(board_tile_covered)
            txt.rvs_off()
        }
        else {
            txt.plot(board_topx+xf, board_topy+yf)
            txt.color(board_tile_flagcolor)
            txt.rvs_on()
            txt.chrout(board_tile_flag)
            txt.rvs_off()
        }
        cursor_on(xf,yf)
    }

    sub draw_playboard(){
        txt.plot(board_topx,board_topy)
        txt.chrout(board_upperleft)
        upperlinepart()
        txt.chrout(board_upperright) ;upperright corner
        txt.plot(board_topx,board_topy+1)
        for y in 2 to row_count - 1 {
            txt.chrout(board_leftline) ;vertical line
            txt.rvs_on()
            midpart()
            txt.rvs_off()
            txt.chrout(board_rightline) ;vertical line
            txt.plot(board_topx,board_topy+y)
        }
        txt.chrout(board_lowerleft) ;lowerleft corner
        lowerlinepart()
        txt.chrout(board_lowerright) ;lowerright corner
    }

    sub upperlinepart() {
            for x in 1 to col_count - 2 {
                txt.chrout(board_upperline) ;horizontal line
            }
        }

    sub lowerlinepart() {
        for x in 1 to col_count - 2 {
            txt.chrout(board_lowerline) ;horizontal line
        }
    }

    sub midpart() {
        for x in 1 to col_count - 2 {
            txt.chrout(board_tile_covered) ;covered character
        }
    }

    sub play() -> ubyte {
        col_current=1
        row_current=1
        cursor_on(col_current,row_current)
        repeat {
            if cbm.STOP2()
                return 0

            ubyte key = cbm.GETIN2()
            when key {
                3, 'l' -> return 0      ; STOP or Q  aborts  (and ESC?)
                'a', 157 -> {       ; cursor left
                    if col_current > 1 {
                        cursor_off(col_current,row_current)
                        col_current--
                        cursor_on(col_current,row_current)
                    }
                }
                'd', 29 -> {        ; cursor right
                    if col_current < (col_count - 2) {
                        cursor_off(col_current,row_current)
                        col_current++
                        cursor_on(col_current,row_current)
                    }
                }
                's', 17 -> {     ; down
                    if row_current < (row_count - 2) {
                        cursor_off(col_current,row_current)
                        row_current++
                        cursor_on(col_current,row_current)
                    }
                }
                'w', 145 -> {    ; up
                    if row_current > 1 {
                        cursor_off(col_current,row_current)
                        row_current--
                        cursor_on(col_current,row_current)
                    }
                }
                'f' -> {    ; flag
                    flag(col_current,row_current)
                }
            }
        }

    }
}

txt {
    %option merge

    sub rvs_on() {
        txt.chrout(18)
    }

    sub rvs_off() {
        txt.chrout(146)
    }
}
