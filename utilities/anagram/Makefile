# vim:noexpandtab:ts=8:sts=8:
SHELL=/bin/bash

LIB_SDCC=../../library/sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBDIR=-L $(LIB_SDCC)
EXTRALIBS=basicio.lib
PROGRAM=anagram

all: $(PROGRAM).cmd

clean:
	rm -f $(PROGRAM).{asm,cmd,ihx,lk,lst,map,noi,rel,sym}
