;
; 6502 Fart Bombs
;

%import textio
%import strings
%import math
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
    uword[25] bomb_array = [row0, row1, row2, row3, row4, row5, row6, row7, row8, row9, row10, row11, row12, row13, row14, row15, row16, row17, row18, row19, row20, row21, row22, row23, row24]
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
    ubyte[] board_tile_num = [' ','1','2','3','4','5','6','7','8']
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
        txt.plot(8,4)
        txt.rvs_on()
        txt.print("                        ")
        txt.plot(8,5)
        txt.print("     6502 fart bombs    ")
        txt.plot(8,6)
        txt.print("                        ")
        txt.plot(8,7)
        txt.print("      @commodoresam     ")
        txt.plot(8,8)
        txt.print("          2025          ")
        txt.plot(8,9)
        txt.print("                        ")
        sys.wait(150)
        txt.cls()
        txt.color(board_fgcolor)
        txt.plot(board_topx+(col_count / 2 -9),0)
        txt.rvs_on()
        txt.print(" 6502 fart bombs ")
        txt.rvs_off()
    }

    sub draw_scoreboard() {
        txt.plot(board_topx + 1,board_topy - 1)
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
        txt.plot(5,board_topy + row_count + 1)
        txt.color(5)
        txt.print("gas pressure is rising...")
        ;place bombs
        bombs_total = bomb_rand()
        bombs_left=bombs_total
        game.draw_scoreboard()
        sys.wait(200)
        ;calc numb tiles
        set_numbtiles()
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

    sub bomb_rand() -> ubyte {
        ubyte total=0
        ubyte col_index
        ubyte row_index
        for col_index in (board_topx + 1) to (board_topx + col_count - 2) {
            for row_index in (board_topy + 1) to (board_topy + row_count - 2) {
                ;pick random number between 0 and 5 equates to 4 its a bomb
                if math.randrange(7) == 4 {
                    set_value(col_index,row_index,board_tile_bomb)
                    total++
                    ;txt.plot(col_index,row_index)
                    ;txt.chrout(board_tile_bomb)
                    }
            }
        }
        return total
    }

    sub set_numbtiles() {
        ubyte num_around=0
        ubyte col_index
        ubyte row_index
        for col_index in (board_topx + 1) to (board_topx + col_count - 2) {
            for row_index in (board_topy + 1) to (board_topy + row_count - 2) {
                ;pick check for bombs around each tile and assign numtile
                if is_bomb(col_index,row_index) == 0 {
                    num_around = is_bomb(col_index-1,row_index-1) + is_bomb(col_index-1,row_index) + is_bomb(col_index-1,row_index+1) + is_bomb(col_index,row_index-1) + is_bomb(col_index,row_index+1) + is_bomb(col_index+1,row_index-1) + is_bomb(col_index+1,row_index) + is_bomb(col_index+1,row_index+1)
                    set_value(col_index,row_index,board_tile_num[num_around])
                    ;txt.plot(col_index,row_index)
                    ;txt.chrout(board_tile_num[num_around])
                }
                num_around=0
            }
        }

    }

    sub set_value(ubyte col, ubyte row, ubyte value) {
        ;set a single value in the bomb_array
        uword temp
        temp = bomb_array[row]
        temp[col] = value
        bomb_array[row] = temp
    }

    sub get_value(ubyte col, ubyte row) -> ubyte {
        ;get a single value in the bomb_array
        uword temp
        temp = bomb_array[row]
        return temp[col]
    }

    sub is_bomb(ubyte col, ubyte row) -> ubyte {
        if get_value(col,row) == '*'
            return 1
        else
            return 0
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
        @(650) = 128
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
