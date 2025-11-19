;
; 6502 Fart Bombs
;

%import textio
%import strings
%import math
%import syslib
%import conv
%import platform
%zeropage basicsafe

main {
    sub start() {
        platform.init()
        do {
            ubyte status=0
            game.set_boardsize(30,19,5,3)
            game.draw_splash()
            game.draw_title()
            game.draw_scoreboard()
            game.draw_playboard()
            game.set_bombs()
            game.set_numbtiles()
            game.draw_menu()
            status = game.play()
        } until status == 0

    }
}

game {
    ubyte bombs_total
    ubyte bombs_found
    ubyte bombs_left
    ubyte col_count
    ubyte row_count
    ubyte board_topx
    ubyte board_topy
    ubyte col_current
    ubyte row_current
    ubyte x
    ubyte y
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
    uword[23] bomb_array = [row0, row1, row2, row3, row4, row5, row6, row7, row8, row9, row10, row11, row12, row13, row14, row15, row16, row17, row18, row19, row20, row21, row22]
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
    const ubyte border_color = 6
    const ubyte board_bgcolor = 0
    const ubyte board_fgcolor = 7
    const ubyte board_tile_color = 7
    const ubyte board_scorecolor = 5
    const ubyte board_tile_revcolor = 14
    const ubyte board_tile_flagcolor = 2
    const ubyte board_tile_bombcolor = 9
    ubyte[] board_tile_num = [' ','1','2','3','4','5','6','7','8']
    ubyte[] board_tile_num_color = [board_bgcolor,1,13,4,8,7,3,15,10]
    ubyte current_char
    ubyte cursor_char = 102
;    ubyte blink_timer = 0
;    ubyte blink_state = 0

   sub set_boardsize(ubyte columns, ubyte rows, ubyte startx, ubyte starty) {
        ;sets the main board size variables
        ;board variables always include borders
        col_count = columns
        row_count = rows
        board_topx = startx
        board_topy = starty
    }

    sub draw_splash() {
        ubyte exit_title = 'n'
        txt.color(board_fgcolor)
        txt.cls()
        txt.rvs_on()
        txt.plot(8,1)
        txt.print("                        ")
        txt.plot(8,2)
        txt.print("                        ")
        txt.plot(8,3)
        txt.print("    6502 fart b*mbs!    ")
        txt.plot(8,4)
        txt.print("                        ")
        txt.plot(8,5)
        txt.print("                        ")
        txt.rvs_off()
        txt.plot(8,7)
        txt.print("    by @commodoresam")
        txt.plot(8,8)
        txt.print("    & andrew gillham")
        txt.plot(8,10)
        txt.print("     v1.2025.11.19")
        txt.rvs_on()
        txt.plot(1,12)
        txt.print(" object ")
        txt.rvs_off()
        txt.plot(1,13)
        txt.color(board_scorecolor)
        txt.print("place a flag over every fart bomb")
        txt.plot(1,14)
        txt.print("without blowing yourself up.")
        txt.rvs_on()
        txt.color(board_fgcolor)
        txt.plot(1,15)
        txt.print(" game play ")
        txt.rvs_off()
        txt.plot(1,17)
        txt.color(board_scorecolor)
        txt.print("* move around using ")
        txt.rvs_on()
        txt.color(board_fgcolor)
        txt.print("wasd")
        txt.rvs_off()
        txt.color(board_scorecolor)
        txt.print(" or ")
        txt.rvs_on()
        txt.color(board_fgcolor)
        txt.print("arrow keys")
        txt.rvs_off()
        txt.plot(1,18)
        txt.color(board_scorecolor)
        txt.print("* press ")
        txt.rvs_on()
        txt.color(board_fgcolor)
        txt.print("space")
        txt.rvs_off()
        txt.color(board_scorecolor)
        txt.print(" to uncover a tile")
        txt.plot(1,19)
        txt.print("* when you uncover a number, that's")
        txt.plot(1,20)
        txt.print("  how many farts adjacent to it")
        txt.rvs_off()
        txt.plot(1,21)
        txt.print("* use ")
        txt.rvs_on()
        txt.color(board_fgcolor)
        txt.print("f")
        txt.rvs_off()
        txt.color(board_scorecolor)
        txt.print(" to place a ")
        txt.rvs_on()
        txt.color(board_tile_flagcolor)
        txt.print("!")
        txt.rvs_off()
        txt.color(board_scorecolor)
        txt.print(" flag over the fart bomb")
        txt.plot(1,22)
        txt.print("* uncover a fart bomb ")
        txt.color(board_tile_bombcolor)
        txt.print("*")
        txt.color(board_scorecolor)
        txt.print(" and you die!")
        txt.plot(1,24)
        txt.print("press space to continue...")
        do {
            exit_title = cbm.GETIN2()
        } until exit_title == ' '
    }

    sub draw_title() {
        ;This inits the main game counts at start and play agains
        bombs_total=0
        bombs_found=0
        bombs_left=0
        txt.cls()
        txt.color(board_fgcolor)
        txt.plot(board_topx+(col_count / 2 -9),0)
        txt.rvs_on()
        txt.print(" 6502 fart bombs ")
        txt.rvs_off()
    }

    sub draw_scoreboard() {
        ;updates score board with each change
        txt.color(board_scorecolor)
        txt.plot(board_topx + 1,board_topy - 1)
        txt.print("found: ")
        txt.print_ub(bombs_found)
        txt.print(" left: ")
        txt.print_ub(bombs_left)
        txt.print("     ")
    }

    sub draw_playboard() {
        ;draws the initial board, borders and covered tiles
        txt.color(board_fgcolor)
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
        ;playboard top border
        for x in 1 to col_count - 2 {
            txt.chrout(board_upperline) ;horizontal line
        }
    }

    sub lowerlinepart() {
        ;playboard bottom border
        for x in 1 to col_count - 2 {
            txt.chrout(board_lowerline) ;horizontal line
        }
    }

    sub midpart() {
        ;playboard middle tiles
        for x in 1 to col_count - 2 {
            txt.chrout(board_tile_revcovered) ;covered character
        }
    }

    sub set_bombs() {
        ;tell player bombs are being set
        txt.plot(5,board_topy + row_count + 1)
        txt.color(board_scorecolor)
        txt.print("gas pressure is rising...")
        ;place bombs
        bombs_total = bomb_rand()
        bombs_left=bombs_total
        game.draw_scoreboard()
        ;calc numb tiles
    }

    sub bomb_rand() -> ubyte {
        ;creates bombs
        ;iterates through the hidden bomb_array
        ;and randomly assigns a space or bomb tile
        ubyte total=0
        ubyte col_index
        ubyte row_index
        platform.seed()
        for col_index in (board_topx + 1) to (board_topx + col_count - 2) {
            for row_index in (board_topy + 1) to (board_topy + row_count - 2) {
                ;randomly pick a number in range, when value is 4 it is a bomb.
                ;increase or decrease bomb count by adjusting range
                if math.randrange(10) == 4 {
                    set_value(col_index,row_index,board_tile_bomb)
                    total++
                } else {
                    set_value(col_index,row_index,' ')
                }
            }
        }
        return total
    }

    sub set_numbtiles() {
        ;after bombs and spaces have been applied, this process counts how many bombs are around each tile
        ;and assigns number to tile
        ubyte num_around=0
        ubyte col_index
        ubyte row_index
        for col_index in (board_topx + 1) to (board_topx + col_count - 2) {
            for row_index in (board_topy + 1) to (board_topy + row_count - 2) {
                ;pick check for bombs around each tile and assign numtile
                if is_bomb(col_index,row_index) == 0 {
                    num_around = is_bomb(col_index-1,row_index-1) + is_bomb(col_index-1,row_index) + is_bomb(col_index-1,row_index+1) + is_bomb(col_index,row_index-1) + is_bomb(col_index,row_index+1) + is_bomb(col_index+1,row_index-1) + is_bomb(col_index+1,row_index) + is_bomb(col_index+1,row_index+1)
                    set_value(col_index,row_index,board_tile_num[num_around])
                }
                num_around=0
            }
        }
    }

    sub draw_menu() {
        txt.plot(5,board_topy + row_count + 1)
        txt.print("                          ")
        txt.plot(board_topx+1,board_topy + row_count)
        txt.color(board_scorecolor)
        txt.rvs_on()
        txt.print("wasd")
        txt.rvs_off()
        txt.print("=move    ")
        txt.rvs_on()
        txt.print("f")
        txt.rvs_off()
        txt.print("=flag ")
        txt.plot(board_topx+5,board_topy + row_count+1)
        txt.rvs_on()
        txt.print("space")
        txt.rvs_off()
        txt.print("=uncover ")
        txt.plot(board_topx+1,board_topy + row_count+2)
        txt.rvs_on()
        txt.print("l")
        txt.rvs_off()
        txt.print("=leave          ")
        txt.rvs_on()
        txt.print("n")
        txt.rvs_off()
        txt.print("=new game")
    }

    sub play() -> ubyte {
        ;actual game play code
        ;constantly waiting on key press and managing user input
        ;starts with cursor in first tile
        ubyte again_answer
        col_current=1
        row_current=1
        ;turn repeat key on
        @(650) = 128
        cursor_on(col_current,row_current)
        repeat {
            if platform.blink_timer() {
                game.blink_char(col_current,row_current)
        }
            if cbm.STOP2()
                return 0

            ubyte key = cbm.GETIN2()
            when key {
                'l' -> {                                ;quit/leave
                    again_answer = play_again('q')
                    if again_answer == 'y'
                        return 0
                    else
                        draw_menu()
                }
                'n' -> {                                ;new game
                    again_answer = play_again('n')
                    if again_answer == 'y'
                        return 1
                    else
                        draw_menu()
                }
                'a', 157 -> {                           ;cursor left a or arrow
                    if col_current > 1 {
                        cursor_off(col_current,row_current)
                        col_current--
                        cursor_on(col_current,row_current)
                    }
                }
                'd', 29 -> {                            ;cursor right d or arrow
                    if col_current < (col_count - 2) {
                        cursor_off(col_current,row_current)
                        col_current++
                        cursor_on(col_current,row_current)
                    }
                }
                's', 17 -> {                            ;down s or arrow
                    if row_current < (row_count - 2) {
                        cursor_off(col_current,row_current)
                        row_current++
                        cursor_on(col_current,row_current)
                    }
                }
                'w', 145 -> {                           ;up w or arrow
                    if row_current > 1 {
                        cursor_off(col_current,row_current)
                        row_current--
                        cursor_on(col_current,row_current)
                    }
                }
                '*' -> {                                ;show bombs for testing purposes (not on menu)
                    show_bombs()
                }
                'f' -> {                                ;flag and if result is all found call play again with win value
                    ubyte complete = flag(col_current,row_current)
                    if complete == 'y' {
                        again_answer = play_again('w')
                        if again_answer == 'y'
                            return 1
                        else
                            return 0
                    }
                }
                ' ' -> {                                ;uncover tile and bomb is hit call play again with lose value
                    ubyte under = uncover(col_current,row_current)
                    cursor_on(col_current,row_current)
                    if under == 32      ;space or reverse space meaning everything around is not bomb
                        uncover_around(col_current,row_current)
                    if under == 42 {    ;you hit a bomb dummy
                        again_answer = play_again('l')
                        if again_answer == 'y'
                            return 1
                        else
                            return 0
                    }
                }
            }
        }

    }

    sub uncover(ubyte xf, ubyte yf) -> ubyte {
        ;reveals the bomb_array tile and also sends that back to the calling process for further processing
        ubyte under_char = 0
        if txt.getchr(board_topx+xf, board_topy+yf) == board_tile_covered or
            txt.getchr(board_topx+xf, board_topy+yf) == cursor_char {
            under_char = get_value(board_topx+xf, board_topy+yf)
            txt.setchr(board_topx+xf, board_topy+yf, under_char)
            cursor_off(xf,yf)
        }
        return under_char
    }

    sub uncover_around(ubyte xe, ubyte ye) {
        ;uncovers tiles round a value (should only run when a space was uncovered previously)
        void uncover(xe-1,ye-1)
        void uncover(xe-1,ye)
        void uncover(xe-1,ye+1)
        void uncover(xe,ye-1)
        void uncover(xe,ye+1)
        void uncover(xe+1,ye-1)
        void uncover(xe+1,ye)
        void uncover(xe+1,ye+1)

    }

    sub flag(ubyte xf, ubyte yf) -> ubyte {
        ;flags or deflags and updates scoreboard numbers
        ;flag is only allowed on a covered tile and when bombs left >= 0
        ;deflag only if a flag
        ;when at bombs left at 0 check to see if all actually found
        ubyte complete='n'
        if txt.getchr(board_topx+xf,board_topy+yf) == cursor_char
            txt.setchr(board_topx+xf,board_topy+yf,current_char)
        ubyte testchr = txt.getchr(board_topx+xf, board_topy+yf)
        if testchr == board_tile_flag ^ 128 {
            txt.plot(board_topx+xf, board_topy+yf)
            txt.color(board_tile_flagcolor)
            txt.rvs_on()
            txt.chrout(board_tile_covered)
            txt.rvs_off()
            bombs_left++
            bombs_found--
        }
        else {
            if bombs_left ==0 or testchr!= board_tile_covered
                return complete
            txt.plot(board_topx+xf, board_topy+yf)
            txt.color(board_tile_flagcolor)
            txt.rvs_on()
            txt.chrout(board_tile_flag)
            txt.rvs_off()
            bombs_left--
            bombs_found++
        }
        draw_scoreboard()
        cursor_on(xf,yf)
        if bombs_left == 0
            complete=check_bombs()
        return complete
    }

    sub check_bombs() -> ubyte {
        ;runs when bomb left is at zero and returns Y if all found
        ubyte col_index
        ubyte row_index
        ubyte bomb_matches=0
        for col_index in (board_topx + 1) to (board_topx + col_count - 2) {
            for row_index in (board_topy + 1) to (board_topy + row_count - 2) {
                ubyte isit = is_bomb (col_index,row_index)
                if isit == 1 {
                    if txt.getchr(col_index, row_index) == board_tile_flag or
                        txt.getchr(col_index,row_index) == board_tile_flag ^ 128 {
                        bomb_matches++
                    }
                }
            }
        }
        if bomb_matches == bombs_total
            return 'y'
        else
            return 'n'
    }

    sub show_bombs() {
        ; shows all bombs at loss
        ubyte col_index
        ubyte row_index
        for col_index in (board_topx + 1) to (board_topx + col_count - 2) {
            for row_index in (board_topy + 1) to (board_topy + row_count - 2) {
                ubyte isit = is_bomb (col_index,row_index)
                if isit == 1 {
                    txt.plot(col_index,row_index)
                    txt.color(board_tile_bombcolor)
                    txt.chrout('*')
                }
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
        ;checks if a bomb exits in bomb_array at position
        if get_value(col,row) == '*'
            return 1
        else
            return 0
    }

    sub cursor_on(ubyte xa, ubyte ya) {
        ;shows the cursor at the specified tile
        if txt.getchr(board_topx+xa,board_topy+ya) != cursor_char
            current_char = txt.getchr(board_topx+xa,board_topy+ya)
    }

    sub blink_char(ubyte xz, ubyte yz) {
        if txt.getchr(board_topx+xz,board_topy+yz) != cursor_char
            txt.setchr(board_topx+xz,board_topy+yz,cursor_char)
        else
            txt.setchr(board_topx+xz,board_topy+yz,current_char)
    }

    sub cursor_off(ubyte xb, ubyte yb) {
        ;redraws a tile in right color once cursor leaves or tile is modified by a process
        if txt.getchr(board_topx+xb,board_topy+yb) == cursor_char
            txt.setchr(board_topx+xb,board_topy+yb,current_char)
        when txt.getchr(board_topx+xb,board_topy+yb) {
            board_tile_covered, ' ' -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_color)
            }
            board_tile_flag -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_flagcolor)
            }
            '1','2','3','4','5','6','7','8' -> {
                txt.setclr(board_topx+xb,board_topy+yb,board_tile_num_color[txt.getchr(board_topx+xb,board_topy+yb)-48])
            }
        }
    }


    sub play_again(ubyte reason) -> ubyte {
        ;anytime a choice to play again happens win, lose, quit/leave
        ;returns the again answer
        ubyte again = 'x'
        txt.plot(1,board_topy + row_count)
        txt.color(5)
        txt.print("                                     ")
        txt.plot(1,board_topy + row_count + 1)
        when reason {
            'l' -> {
                txt.print("boom! you lose... play again (y/n)?   ")
                show_bombs()
            }
            'w' -> txt.print("awesome, you won!!! play again (y/n)? ")
            'n' -> txt.print("        new game (y/n)?               ")
            'q' -> txt.print("        leave game (y/n)?             ")
        }
        txt.plot(1,board_topy + row_count + 2)
        txt.print("                                     ")
        do {
            again = cbm.GETIN2()
        } until again == 'y' or again == 'n'
        return again
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

