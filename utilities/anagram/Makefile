# vim:noexpandtab:ts=8:sts=8:
SHELL=/bin/bash
include include.mk

MYLIBDIR=../../library/sdcc
EXTRALIBS=-l basicio.lib
PROGRAM=anagram

all: $(PROGRAM).cmd

clean:
	rm -f $(PROGRAM).{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
