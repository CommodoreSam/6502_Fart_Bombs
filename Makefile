#
# Simple Makefile for a Prog8 program.
#

# Cross-platform commands
ifeq ($(OS),Windows_NT)
    CLEAN = del /Q build\*
    CP = copy
    RM = del /Q
    MD = mkdir
    SEP = \\
else
    CLEAN = rm -f build/*
    CP = cp -p
    RM = rm -f
    MD = mkdir -p
    SEP = /
endif

# disk image settings
DISKTYPE=d64
DISKNAME=6502fb
DISK=build/$(DISKNAME).$(DISKTYPE)

# Emulator settings
EMU_CMD=x64sc
EMU_BASE=-default -keymap 1 -model ntsc
EMU_DISK08=-8 $(DISK) -drive8type 1542
#EMU_DISK10=-fs10 build -device10 1 -iecdevice10 -virtualdev10
EMU_DISK10=
EMU_CART=
EMU_DISK=$(EMU_DISK08) $(EMU_DISK10)
EMU_DOS=
EMU_KERNAL=
EMU_REUSIZE=512
EMU_REU=-reu -reusize $(EMU_REUSIZE)
EMU=$(EMU_CMD) $(EMU_BASE) $(EMU_KERNAL) $(EMU_DISK) $(EMU_DOS) $(EMU_REU)

PCC=prog8c-beta
PCCARGSC64=-srcdirs src:src/c64 -asmlist -target c64 -out build
PCCARGSX16=-srcdirs src:src/cx16 -asmlist -target cx16 -out build
PCCARGSP32=-srcdirs src:src/pet32 -asmlist -target pet32 -out build
PCCARGS128=-srcdirs src:src/c128 -asmlist -target c128 -out build
PCCARGSVIC=-srcdirs src:src/vic20 -asmlist -target config/vic20plus3.properties -out build
PCCARGS264=-srcdirs src:src/plus4 -asmlist -target config/plus4.properties -out build

PROGS	= build/6502fb-c64.prg build/6502fb-cx16.prg build/6502fb-pet32.prg build/6502fb-c128.prg build/6502fb-vic20.prg build/6502fb-plus4.prg

SRCS	= src/main.p8

all: build $(PROGS)

build:
	$(MD) build

build/6502fb-c64.prg: $(SRCS) src/c64/platform.p8
	$(PCC) $(PCCARGSC64) $<
	mv build/main.prg build/6502fb-c64.prg

build/6502fb-cx16.prg: $(SRCS) src/cx16/platform.p8
	$(PCC) $(PCCARGSX16) $<
	mv build/main.prg build/6502fb-cx16.prg

build/6502fb-pet32.prg: $(SRCS) src/pet32/platform.p8
	$(PCC) $(PCCARGSP32) $<
	mv build/main.prg build/6502fb-pet32.prg

build/6502fb-c128.prg: $(SRCS) src/c128/platform.p8
	$(PCC) $(PCCARGS128) $<
	mv build/main.prg build/6502fb-c128.prg

build/6502fb-vic20.prg: $(SRCS) src/vic20/platform.p8
	$(PCC) $(PCCARGSVIC) $<
	mv build/main.prg build/6502fb-vic20.prg

build/6502fb-plus4.prg: $(SRCS) src/plus4/platform.p8
	$(PCC) $(PCCARGS264) $<
	mv build/main.prg build/6502fb-plus4.prg

clean:
	$(RM) build$(SEP)*

disk:
	c1541 -format $(DISKNAME),52 $(DISKTYPE) $(DISK)
	c1541 -attach $(DISK) -write build/6502fb-c64.prg 6502fb,p

emu:	all disk
	$(EMU) -autostartprgmode 1 build/6502fb-c64.prg

emu-x16:	all
	x16emu -scale 2 -run -prg build/6502fb-cx16.prg

emu-p32:	all
	xpet -model 4032 -autostartprgmode 1 build/6502fb-pet32.prg

emu-c128:	all
	x128 -autostartprgmode 1 build/6502fb-c128.prg

emu-vic20:	all
	xvic -model vic20ntsc -memory 3k -autostartprgmode 1 build/6502fb-vic20.prg

emu-plus4:	all
	xplus4 -default -model plus4ntsc -autostartprgmode 1 build/6502fb-plus4.prg


#
# end-of-file
#
