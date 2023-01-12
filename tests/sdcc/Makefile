LIB_SDCC=../../library/sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBDIR=-L ../../library/extras
EXTRALIBS=-l rom.lib -l basicio.lib -l newdos80.lib -l extras.lib

all: fileio.cmd testfget.cmd testtime.cmd

clean:
	rm -f fileio.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
	rm -f testfget.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
	rm -f testtime.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}

.PHONY: all
