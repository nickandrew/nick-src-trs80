# vim:noexpandtab:ts=8:sts=8:
SHELL=/bin/bash

Z80LIBDIR=-L ~/sdcc/share/sdcc/lib/z80
EXTRALIBDIR=-L .
CRT0=--no-std-crt0 crt0.rel

all: crt0.rel

clean:
	rm -f crt0.rel *.cmd *.ihx

crt0.rel: crt0.s
	sdasz80 -l -o crt0.s

# Edit the Intel Hex file to hardcode the program entry address to 0x5200
%.cmd: %.ihx
	sed -e 's/:00000001FF/:00520001AD/' < $< | hex2cmd > $@

%.lst %.rel: %.c
	sdcc -I../../include/sdcc -mz80 -c $<
