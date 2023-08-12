LIB_SDCC=../../library/sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBS=-l basicio.lib -l newdos80.lib

all: gettok.cmd toknum.cmd

clean:
	rm -f gettok.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
	rm -f toknum.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}

.PHONY: all
