# makefile for Zeta C library ...

all:	atoi.asm bunfunc.asm cinit.asm ctype.asm doserr.asm \
fwrite.asm \
getopt.asm getuid.asm getw.asm index.asm msgfunc.asm openf2.asm \
pnumb.asm rand.asm sbrk.asm seekto.asm strchr.asm strcmp.asm \
strlen.asm wild.asm

atoi.asm: atoi.c
	scc atoi.c >atoi.asm

bunfunc.asm: bunfunc.c
	scc bunfunc.c >bunfunc.asm

cinit.asm: cinit.c
	scc cinit.c >cinit.asm

ctype.asm: ctype.c
	scc ctype.c >ctype.asm

doserr.asm: doserr.c
	scc doserr.c >doserr.asm

fwrite.asm: fwrite.c
	scc fwrite.c >fwrite.asm

getopt.asm: getopt.c
	scc getopt.c >getopt.asm

getuid.asm: getuid.c
	scc getuid.c >getuid.asm

getw.asm: getw.c
	scc getw.c >getw.asm

index.asm: index.c
	scc index.c >index.asm

msgfunc.asm: msgfunc.c
	scc msgfunc.c >msgfunc.asm

openf2.asm: openf2.c
	scc openf2.c >openf2.asm

pnumb.asm: pnumb.c
	scc pnumb.c >pnumb.asm

rand.asm: rand.c
	scc rand.c >rand.asm

sbrk.asm: sbrk.c
	scc sbrk.c >sbrk.asm

seekto.asm: seekto.c
	scc seekto.c >seekto.asm

strchr.asm: strchr.c
	scc strchr.c >strchr.asm

strcmp.asm: strcmp.c
	scc strcmp.c >strcmp.asm

strlen.asm: strlen.c
	scc strlen.c >strlen.asm

wild.asm: wild.c
	scc wild.c >wild.asm

floppy:
	totrs <arcsubs.asm | doswrite a arcsubs.asm
	totrs <asctime.asm | doswrite a asctime.asm
	totrs <atoi.asm | doswrite a atoi.asm
	totrs <bb7func.asm | doswrite a bb7func.asm
	totrs <bunfunc.asm | doswrite a bunfunc.asm
	totrs <call.asm | doswrite a call.asm
	totrs <ccc.asm | doswrite a ccc.asm
	totrs <chksysop.asm | doswrite a chksysop.asm
	totrs <cinit.asm | doswrite a cinit.asm
	totrs <ctype.asm | doswrite a ctype.asm
	totrs <debug.asm | doswrite a debug.asm
	totrs <debugf.asm | doswrite a debugf.asm
	totrs <doserr.asm | doswrite a doserr.asm
	totrs <fread.asm | doswrite a fread.asm
	totrs <ftell.asm | doswrite a ftell.asm
	totrs <fwrite.asm | doswrite a fwrite.asm
	totrs <getopt.asm | doswrite a getopt.asm
	totrs <gettime.asm | doswrite a gettime.asm
	totrs <getuid.asm | doswrite a getuid.asm
	totrs <getuname.asm | doswrite a getuname.asm
	totrs <getw.asm | doswrite a getw.asm
	totrs <index.asm | doswrite a index.asm
	totrs <libc.asm | doswrite a libc.asm
	totrs <libcz.asm | doswrite a libcz.asm
	totrs <libcz1.asm | doswrite a libcz1.asm
	totrs <malloc.asm | doswrite a malloc.asm
	totrs <msgfunc.asm | doswrite a msgfunc.asm
	totrs <openf2.asm | doswrite a openf2.asm
	totrs <pnumb.asm | doswrite a pnumb.asm
	totrs <rand.asm | doswrite a rand.asm
	totrs <raw.asm | doswrite a raw.asm
	totrs <reada.asm | doswrite a reada.asm
	totrs <savepos.asm | doswrite a savepos.asm
	totrs <sbrk.asm | doswrite a sbrk.asm
	totrs <seekto.asm | doswrite a seekto.asm
	totrs <strchr.asm | doswrite a strchr.asm
	totrs <strcmp.asm | doswrite a strcmp.asm
	totrs <strlen.asm | doswrite a strlen.asm
	totrs <system.asm | doswrite a system.asm
	totrs <unlink.asm | doswrite a unlink.asm
	totrs <userfunc.asm | doswrite a userfunc.asm
	totrs <wild.asm | doswrite a wild.asm

source:
	totrs <atoi.c | doswrite a atoi.c
	totrs <bunfunc.c | doswrite a bunfunc.c
	totrs <cinit.c | doswrite a cinit.c
	totrs <ctype.c | doswrite a ctype.c
	totrs <doserr.c | doswrite a doserr.c
	totrs <fwrite.c | doswrite a fwrite.c
	totrs <getopt.c | doswrite a getopt.c
	totrs <getuid.c | doswrite a getuid.c
	totrs <getw.c | doswrite a getw.c
	totrs <index.c | doswrite a index.c
	totrs <makefile | doswrite a makefile
	totrs <msgfunc.c | doswrite a msgfunc.c
	totrs <openf2.c | doswrite a openf2.c
	totrs <pnumb.c | doswrite a pnumb.c
	totrs <rand.c | doswrite a rand.c
	totrs <sbrk.c | doswrite a sbrk.c
	totrs <seekto.c | doswrite a seekto.c
	totrs <stdio.h | doswrite a stdio.h
	totrs <strchr.c | doswrite a strchr.c
	totrs <strcmp.c | doswrite a strcmp.c
	totrs <strlen.c | doswrite a strlen.c
	totrs <wild.c | doswrite a wild.c

# end of makefile
