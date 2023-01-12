# vim:noexpandtab:ts=8:sts=8:
LIB_SDCC=../sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBDIR=-L ../sdcc
EXTRALIBS=-l extras.lib -l basicio.lib

all: extras.lib testh2i.cmd

extras.lib: memdump.rel hex_to_int.rel
	sdar r $@ $^

clean:
	rm -f testh2i.{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
	rm -f hex_to_int.{asm,lst,rel,sym}
	rm -f extras.lib
