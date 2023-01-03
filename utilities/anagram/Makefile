# vim:noexpandtab:ts=8:sts=8:
SHELL=/bin/bash
D=../../library/sdcc

include $(D)/include.mk

MYLIBDIR=$(D)
EXTRALIBS=-l basicio.lib
PROGRAM=anagram

all: $(PROGRAM).cmd

clean:
	rm -f $(PROGRAM).{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
