LIB_SDCC=../../../library/sdcc
include $(LIB_SDCC)/include.mk

INCLUDES=-I../../../include/sdcc
EXTRALIBDIR=-L ../../../library/sdcc
EXTRALIBS=-l basicio.lib -l newdos80.lib

all: cwiz.cmd wisdom.cmd

clean:
	rm -f cwiz.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
	rm -f wisdom.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}

.PHONY: all
