;
; 6502 Fart Bombs
;

%import textio
%import strings
%zeropage basicsafe

main {
    sub start() {
        ;txt.lowercase();
        game.set_boardsize(30,20,5,3)
        game.draw_title()
        game.draw_scoreboard()
        game.draw_playboard()
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
    ubyte found
    ubyte left
    ubyte board_upperleft = 176
    ubyte board_upperright = 174
    ubyte board_lowerleft = 173
    ubyte board_lowerright = 189
    ubyte board_upperline = 99
    ubyte board_lowerline = 99
    ubyte board_leftline = 98
    ubyte board_rightline = 98
    ubyte board_tile_covered = 186 ;will be in reverse or custom character
    ubyte board_tile_flag = 33
    ubyte board_tile_bomb = 42
    ubyte board_tile_num0 = 48
    ubyte board_tile_num1 = 49
    ubyte board_tile_num2 = 50
    ubyte board_tile_num3 = 51
    ubyte board_tile_num4 = 52
    ubyte board_tile_num5 = 53
    ubyte board_tile_num6 = 54
    ubyte board_tile_num7 = 55
    ubyte board_tile_num8 = 56

    sub draw_title() {
        txt.plot(board_topx+(col_count / 2 -8),0)
        txt.rvs_on()
        txt.print("6502 fart bombs")
        txt.rvs_off()
    }

    sub draw_scoreboard() {
        txt.plot(board_topx,board_topy - 1)
        txt.print("found: ")
        txt.print_ub(found)
        txt.print(" left: ")
        txt.print_ub(left)
    }

   sub set_boardsize(ubyte columns, ubyte rows, ubyte startx, ubyte starty) {
        col_count = columns
        row_count = rows
        board_topx = startx
        board_topy = starty
    }

    sub invert_char(ubyte x, ubyte y){
        txt.setchr(board_topx+x,board_topy+y,txt.getchr(board_topx+x,board_topy+y) ^ 128)
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
        invert_char(col_current,row_current)
        repeat {
            if cbm.STOP2()
                return 0

            ubyte key = cbm.GETIN2()
            when key {
                3, 27, 'q' -> return 0      ; STOP or Q  aborts  (and ESC?)
                '\n',' ' -> {
                    return 0
                }
                '[', 157 -> {       ; cursor left
                    if col_current > 1 {
                        invert_char(col_current,row_current)
                        col_current--
                        invert_char(col_current,row_current)
                    }
                }
                ']', 29 -> {        ; cursor right
                    if col_current < (col_count - 2) {
                        invert_char(col_current,row_current)
                        col_current++
                        invert_char(col_current,row_current)
                    }
                }
                17 -> {     ; down
                    if row_current < (row_count - 2) {
                        invert_char(col_current,row_current)
                        row_current++
                        invert_char(col_current,row_current)
                    }
                }
                145 -> {    ; up
                    if row_current > 1 {
                        invert_char(col_current,row_current)
                        row_current--
                        invert_char(col_current,row_current)
                    }
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
