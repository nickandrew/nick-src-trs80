# vim:noexpandtab:ts=8:sts=8:

all: basicio.lib newdos80.lib crt0.rel echo.cmd

clean:
	rm -f basicio.lib newdos80.lib crt0.rel *.cmd *.ihx

basicio.lib: argparse.rel putchar.rel
	sdar r $@ $?

newdos80.lib: $(patsubst %.c,%.rel,$(wildcard dos_*.c))
	sdar r newdos80.lib $?

crt0.rel: crt0.s
	sdasz80 -l -o crt0.s

echo.ihx: echo.rel basicio.lib
	sdcc -mz80 --code-loc 0x5200 -o $@ --lib-path /home/nick-trs80/GIT/nick-src-trs80/library/sdcc -l basicio echo.rel

helloworld.ihx: helloworld.rel basicio.lib
	sdcc -mz80 --code-loc 0x5200 -o $@ --lib-path /home/nick-trs80/GIT/nick-src-trs80/library/sdcc -l basicio helloworld.rel

# Edit the Intel Hex file to hardcode the program entry address to 0x5200
%.cmd: %.ihx
	sed -e 's/:00000001FF/:00520001AD/' < $< | hex2cmd > $@

%.lst %.rel: %.c
	sdcc -I../../include/sdcc -mz80 -c $<
