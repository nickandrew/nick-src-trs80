LIB_SDCC=../../../library/sdcc
include $(LIB_SDCC)/include.mk

INCLUDES=-I../../../include/sdcc
EXTRALIBDIR=-L ../../../library/sdcc -L ../../../library/zeta
EXTRALIBS=-l basicio.lib -l newdos80.lib -l zeta.lib -l rom.lib

all: survey.cmd

clean:
	rm -f survey.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}

.PHONY: all
