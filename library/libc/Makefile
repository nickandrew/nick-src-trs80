include ../sdcc/include.mk

INCLUDES+=-I../sdcc

all: libc.lib

libc.lib: $(patsubst %.c,%.rel,$(wildcard *.c))
	sdar r libc.lib $?
