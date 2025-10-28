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
        txt.setchr(x,y,txt.getchr(x,y) ^ 128)
    }

    sub draw_playboard(){
        txt.plot(board_topx,board_topy)
        txt.chrout(176) ;upperleft corner
        linepart()
        txt.chrout(174) ;upperright corner
        txt.plot(board_topx,board_topy+1)
        for y in 2 to row_count - 1 {
            txt.chrout(98) ;vertical line
            midpart()
            txt.chrout(98) ;vertical line
            txt.plot(board_topx,board_topy+y)
        }
        txt.chrout(173) ;lowerleft corner
        linepart()
        txt.chrout(189) ;lowerright corner
    }

    sub linepart() {
        for x in 1 to col_count - 2 {
            txt.chrout(99) ;horizontal line
        }
    }

    sub midpart() {
        for x in 1 to col_count - 2 {
            txt.chrout(88) ;covered character
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
