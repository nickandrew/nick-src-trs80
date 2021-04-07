CFLAGS=-std=c89 -Wall

BINARIES=latest llstest main
all:	$(BINARIES)

clean:
	rm -f $(BINARIES) *.o

# Binaries
latest:	latest.o lls.o
llstest:	llstest.o lls.o
main:	main.o compiler.o interp.o lls.o la.o errors.o

# Sources
compiler.o:	compiler.c compiler.h errors.h goals.h la.h lls.h opcodes.h
errors.o:	errors.c errors.h lls.h
interp.o:	interp.c interp.h compiler.h la.h opcodes.h
la.o:	la.c errors.h la.h lls.h
latest.o:	latest.c la.h lls.h
lls.o:	lls.c errors.h lls.h
llstest.o:	llstest.c lls.h
main.o:	main.c compiler.h interp.h la.h lls.h main.h
