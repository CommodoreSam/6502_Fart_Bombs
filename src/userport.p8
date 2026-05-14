;
; Simple library to read / write from the User Port.
;
%import userport_platform
userport {
%option no_symbol_prefixing, ignore_unused
%option force_output

    ;
    ; pin definitions
    ;
    const ubyte LOW         = 0
    const ubyte HIGH        = 1
    const ubyte INPUT       = 0
    const ubyte OUTPUT      = 1

    ; default User Port pin states (FIXME)
    const ubyte PINDIR   = %11111111     ; (set/high ==output) pin direction test
    const ubyte PINSTATE = %11111111     ; (set/high == logic high) pins all high

    ; requested pin directions (default should probably be all in) (but this is a test)
    ubyte pindir     = PINDIR
    ; default read mask to all input pins
    ubyte readmask   = ~PINDIR
    ; default write mask to all output pins (aka pin direction byte)
    ubyte writemask  = PINDIR

    ;
    ; call once to set pins for direciton and read/write masks
    ;
    sub init(ubyte pins) {
        pindir = pins
        readmask = ~pins
        writemask = pins
    }

    ;
    ; set pin direction
    ;
    sub pinmode(ubyte pin, ubyte mode) {
        if mode == HIGH {
            ; set pin bit to 1
            pindir = (pindir & ~pin) | pin
        } else {
            ; set pin bit to 0
            pindir = pindir & ~pin
        }
        setd(pindir)
    }

    sub pinread(ubyte pin) -> ubyte {
        setd(pindir)
        if (get() & pin) as bool
            return HIGH
        return LOW
    }

    sub pinwrite(ubyte pin, ubyte level) {
        setd(pindir)
        if level == HIGH
            set((get() & ~pin) | pin)
        else
            set(get() & ~pin)
    }

    ;
    ;
    ;
    sub mode(ubyte pins) {

        ; set pin direction mirror
        pindir = (pindir & ~pins) | pins
        readmask = ~pindir
        writemask = pindir

        ; set data direction pins
        setd((getd() & ~pindir) | pindir)
    }
    ;
    ; returns current pin state, ignoring outputs
    ;
    sub read() -> ubyte {
        ; set data direction pins
        setd((getd() & ~pindir) | pindir)

        ; read pin state / mask wanted pins, return it
        return (get() & readmask)
    }

    ;
    ; sets output pins, masking input pins to zero.
    ;
    sub write(ubyte pins) {
        ; set data direction pins
        setd((getd() & ~pindir) | pindir)

        ; mask only output pin values and write it
        set(pins & writemask)
    }
}
