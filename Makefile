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

PCC=prog8c
PCCARGSBASE=-asmlist -out build
PCCARGSDIRS=-srcdirs src:input$(SEP)src
PCCARGSC64=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)c64:input$(SEP)src$(SEP)c64 -target c64
PCCARGSX16=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)cx16 -target cx16
PCCARGSP32=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)pet32 -target pet32
PCCARGS128=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)c128 -target c128
PCCARGSVIC=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)vic20 -target config$(SEP)vic20plus8.properties
PCCARGS264=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)plus4 -target config$(SEP)plus4.properties
PCCARGSM65=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)mega65 -target config$(SEP)mega65.properties
PCCARGSF256=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)f256 -target config$(SEP)f256.properties
PCCARGSGTC=$(PCCARGSBASE) $(PCCARGSDIRS):src$(SEP)gametank:input$(SEP)src$(SEP)gametank -varsgolden -slabsgolden -target config$(SEP)gametank.properties

PROGS	= build/6502fb-c64.prg build/6502fb-cx16.prg build/6502fb-pet32.prg build/6502fb-c128.prg build/6502fb-vic20.prg build/6502fb-plus4.prg build/6502fb-mega65.prg build/6502fb-gametank.gtr

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

build/6502fb-mega65.prg: $(SRCS) src/mega65/platform.p8
	$(PCC) $(PCCARGSM65) $<
	mv build/main.prg build/6502fb-mega65.prg

build/6502fb-f256.pgz: src/main_other.p8 src/main.p8 src/f256/platform.p8
	$(PCC) $(PCCARGSF256) $<
	mv build/main_other.bin build/6502fb-f256.pgz

build/6502fb-gametank.gtr: src/main_rom.p8 src/main.p8 src/gametank/platform.p8
	$(PCC) $(PCCARGSGTC) $<
	truncate -s 2m $@
	dd if=build/main_rom.bin of=$@ bs=16K seek=127 conv=notrunc

build/cartload64.bin: src/cartload64.p8 build/6502fb-c64.prg
	$(PCC) $(PCCARGSC64) -varshigh 1 -slabshigh 1 $<
	truncate -s 16k $@

build/6502fb-c64.crt: build/cartload64.bin
	cartconv -t normal -i $< -o $@

build/cartload128.bin: src/cartload128.p8 build/6502fb-c128.prg
	$(PCC) $(PCCARGS128) -varsgolden -slabsgolden $<
	truncate -s 16k $@

build/6502fb-c128.crt: build/cartload128.bin
	cartconv -t c128 -l 0x8000 -i $< -o $@

clean:
	$(RM) build$(SEP)*

disk:
	c1541 -format $(DISKNAME),52 $(DISKTYPE) $(DISK)
	c1541 -attach $(DISK) -write build/6502fb-c64.prg 6502fb-c64,p

emu-c64:	build/6502fb-c64.prg
	$(EMU) -autostartprgmode 1 build/6502fb-c64.prg

emu-c64-cart:	build/6502fb-c64.crt
	$(EMU) $<

emu-cx16:	build/6502fb-cx16.prg
	x16emu -scale 2 -run -prg build/6502fb-cx16.prg

emu-pet32:	build/6502fb-pet32.prg
	xpet -model 4032 -autostartprgmode 1 build/6502fb-pet32.prg

emu-c128:	build/6502fb-c128.prg
	x128 -autostartprgmode 1 build/6502fb-c128.prg

emu-c128-cart:	build/6502fb-c128.crt
	x128 $<

emu-vic20:	build/6502fb-vic20.prg
	xvic -model vic20ntsc -memory 8k -autostartprgmode 1 build/6502fb-vic20.prg

emu-plus4:	build/6502fb-plus4.prg
	xplus4 -default -model plus4ntsc -autostartprgmode 1 build/6502fb-plus4.prg

emu-mega65:	build/6502fb-mega65.prg
	xmega65 -model 5 -besure -videostd 1 -prgmode 65 -prg build/6502fb-mega65.prg

emu-f256:	build/6502fb-f256.pgz
	env MTOOLSRC=../f256/mtools.rc mcopy -n -o build/6502fb-f256.pgz p:6502fb.pgz
	(cd ../f256 && ./f256 f256k -sound none -window -resolution 1440x900 -harddisk ./sdcard.img)

emu-gametank:	build/6502fb-gametank.gtr
	GameTankEmulator $<

push-to-c64u:	build/6502fb-c64.prg
	c64u runners run-prg-upload build/6502fb-c64.prg

flash-gametank:	build/6502fb-gametank.gtr
	echo Run this: gtld load $<

#
# end-of-file
#
