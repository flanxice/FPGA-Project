# Project configuration
TARGET=ss
MODULES=draw_map.vhd draw_sprite.vhd map_rom.vhd sw_coll_det.vhd video_sync.vhd game.vhd read_pad.vhd ss.vhd
USERCODE=0x12345678
PART=xc2s300e-ft256-7

OPT_MODE=SPEED
OPT_LEVEL=2

# Flags for XST
XSTFLAGS=-opt_mode $(OPT_MODE) -opt_level $(OPT_LEVEL)

# Define this to suppress console output from the build programs
QUIET=> /dev/null

# Flags for bitgen
#
# Must have this to use JTAG configuration
BGFLAGS=-g StartUpClk:JtagClk

ifdef USERCODE
BGFLAGS+=-g UserID:$(USERCODE)
endif

NGCS=$(MODULES:.vhd=.ngc)

# Build programs
XBIN=~/Xilinx/bin/lin
XST=$(XBIN)/xst
MAP=$(XBIN)/map
PAR=$(XBIN)/par
NGDBUILD=$(XBIN)/ngdbuild
BITGEN=$(XBIN)/bitgen

LANGUAGE=usenglish
export LANGUAGE

.PHONY:		all clean prog
.SECONDARY:

all:		$(TARGET).bit

clean:
		rm -f $(TARGET).bit $(TARGET).ncd $(NGCS)
		rm -f *.bgn *.bld *.drc *.mrp *.ngd *.ngm *.pad *.par *.pcf *.srp *.xpi
		rm -f *_pad.csv *_pad.txt netlist.lst xst_tmp
		rm -rf xst

prog:		all
		xilinx_config $(TARGET).bit

$(TARGET).ngd:	$(NGCS) $(TARGET).ucf
		-$(NGDBUILD) $(TARGET) $(QUIET)
		@if grep -q -E \(WARNING\|ERROR\) $(TARGET).bld; then cat $(TARGET).bld; false; fi

%.bit:		%.ncd
		$(BITGEN) -w $(BGFLAGS) $< $(QUIET)

%.ncd:		%.ngd
		-$(MAP) -pr b -p $(PART) $< -o $@ $(QUIET)
		@if grep -q ERROR $(<:.ngd=.mrp); then cat $(<:.ngd=.mrp); false; fi
		$(PAR) -ol std -w $@ $@ $(QUIET)

%.ngc:		%.vhd
		@echo Synthesizing $<
		@echo run -ifn $< -ifmt VHDL -ofn $@ -ofmt NGC -p $(PART) $(XSTFLAGS) > xst_tmp
		-$(XST) -ifn xst_tmp -ofn $(<:.vhd=.srp) $(QUIET)
		@grep WARNING $(<:.vhd=.srp) || true
		@if grep ERROR $(<:.vhd=.srp); then false; fi
		rm -f xst_tmp

