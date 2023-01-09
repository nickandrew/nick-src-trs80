LIB_SDCC=../../library/sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBS=-l rom.lib -l basicio.lib -l newdos80.lib

all: wc.cmd

clean:
	rm -f wc.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}

.PHONY: all
