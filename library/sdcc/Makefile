# vim:noexpandtab:ts=8:sts=8:

all: newdos80.lib crt0.rel

crt0.rel: crt0.s
	sdasz80 -l -o crt0.s

newdos80.lib: $(patsubst %.c,%.rel,$(wildcard dos_*.c))
	sdar r newdos80.lib $?

# Edit the Intel Hex file to hardcode the program entry address to 0x5200
%.cmd: %.ihx
	sed -e 's/:00000001FF/:00520001AD/' < $< | hex2cmd > $@

%.lst %.rel: %.c
	sdcc -I../../include/sdcc -mz80 -c $<
