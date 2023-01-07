# vim:noexpandtab:ts=8:sts=8:
LIB_SDCC=../../library/sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBS=-l basicio.lib

all: border.cmd getchar.cmd

clean:
	rm -f border.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
	rm -f getchar.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
