# vim:noexpandtab:ts=8:sts=8:
SHELL=/bin/bash

Z80LIBDIR=-L ~/sdcc/share/sdcc/lib/z80
EXTRALIBDIR=-L .
CRT0=--no-std-crt0 crt0.rel

all: basicio.lib newdos80.lib crt0.rel echo.cmd hworld.cmd testhw.cmd testargp.cmd

clean:
	rm -f basicio.lib newdos80.lib crt0.rel *.cmd *.ihx

basicio.lib: argparse.rel hardware_id.rel putchar.rel getchar.rel soft_time.rel
	sdar r $@ $^

newdos80.lib: $(patsubst %.c,%.rel,$(wildcard dos_*.c))
	sdar r newdos80.lib $^

crt0.rel: crt0.s
	sdasz80 -l -o crt0.s

echo.ihx: echo.rel basicio.lib crt0.rel
	sdcc -mz80 --code-loc 0x5200 -o $@ $(Z80LIBDIR) $(EXTRALIBDIR) $(CRT0) -l basicio echo.rel

hworld.ihx: hworld.rel basicio.lib crt0.rel
	sdcc -mz80 --code-loc 0x5200 -o $@ $(Z80LIBDIR) $(EXTRALIBDIR) $(CRT0) -l basicio hworld.rel

testhw.ihx: testhw.rel basicio.lib newdos80.lib hardware_id.rel crt0.rel
	sdcc -mz80 --code-loc 0x5200 -o $@ $(Z80LIBDIR) $(EXTRALIBDIR) $(CRT0) -l newdos80 -l basicio testhw.rel

test_argparse.ihx: test_argparse.rel basicio.lib newdos80.lib crt0.rel
	sdcc -mz80 --code-loc 0x5200 -o $@ $(Z80LIBDIR) $(EXTRALIBDIR) $(CRT0) -l basicio -l newdos80 test_argparse.rel

testargp.cmd: test_argparse.ihx
	sed -e 's/:00000001FF/:00520001AD/' < $< | hex2cmd > $@

# Edit the Intel Hex file to hardcode the program entry address to 0x5200
%.cmd: %.ihx
	sed -e 's/:00000001FF/:00520001AD/' < $< | hex2cmd > $@

%.lst %.rel: %.c
	sdcc -I../../include/sdcc -mz80 -c $<
