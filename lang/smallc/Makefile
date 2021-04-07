OBJ = c0.o c1.o c1a.o c2.o c3.o c4.o c5.o c6.o c7.o c8.o c9.o cx.o
SRCS = c0.c c1.c c1a.c c2.c c3.c c4.c c5.c c6.c c7.c c8.c c9.c cx.c
CFLAGS =

cc80:   $(OBJ)
	cc $(CFLAGS) $(OBJ) -g -o cc80

clean:
	rm $(OBJ)

$(OBJ): cc.h
	gcc -std=c89 -g -c $(SRCS)
