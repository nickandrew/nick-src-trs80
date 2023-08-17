# vim:noexpandtab:ts=8:sts=8:
LIB_SDCC=../sdcc
include $(LIB_SDCC)/include.mk

EXTRALIBDIR=-L ../sdcc
EXTRALIBS=-l extras.lib -l basicio.lib

all: zeta.lib

zeta.lib: getuname.rel
	sdar r $@ $^

clean:
	rm -f zeta.lib
