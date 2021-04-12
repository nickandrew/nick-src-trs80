include ../sdcc/include.mk

all: libc.lib

libc.lib: $(patsubst %.c,%.rel,$(wildcard *.c))
	sdar r libc.lib $?
