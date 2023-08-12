# vim:noexpandtab:ts=8:sts=8:
SHELL=/bin/bash
D=../../library/sdcc

include $(D)/include.mk

MYLIBDIR=$(D)
EXTRALIBS=-l basicio.lib

all:
	$(MAKE) PROGRAM=getchar getchar.cmd
	$(MAKE) PROGRAM=border border.cmd

clean:
	$(MAKE) PROGRAM=getchar _clean
	$(MAKE) PROGRAM=border _clean

_clean:
	rm -f $(PROGRAM).{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
