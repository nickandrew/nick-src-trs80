LIB_SDCC=../../../library/sdcc
include $(LIB_SDCC)/include.mk

INCLUDES=-I../../../include/sdcc
EXTRALIBDIR=-L ../../../library/sdcc
EXTRALIBS=-l rom.lib -l basicio.lib -l newdos80.lib

all: more1.cmd

clean:
	rm -f more1.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}

.PHONY: all
