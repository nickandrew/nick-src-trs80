# vim:noexpandtab:ts=8:sts=8:
INCLUDES=-I../../include/sdcc
Z80LIBDIR=-L ~/sdcc/share/sdcc/lib/z80
MYLIBDIR=
EXTRALIBDIR=-L $(MYLIBDIR)
EXTRALIBS=
CRT0=$(MYLIBDIR)/crt0.rel

%.asm %.lst %.map %.noi %.rel %.sym: %.c
	sdcc $(INCLUDES) -mz80 -c $<

%.ihx %.lk: %.rel
	sdcc -mz80 --code-loc 0x5200 --data-loc 0x0000 -o $@ $(Z80LIBDIR) $(EXTRALIBDIR) --no-std-crt0 $(CRT0) $+ $(EXTRALIBS)

# Edit the Intel Hex file to hardcode the program entry address to 0x5200
%.cmd: %.ihx
	sed -e 's/:00000001FF/:00520001AD/' < $< | hex2cmd > $@