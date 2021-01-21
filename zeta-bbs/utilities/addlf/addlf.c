/* addlf.c: add linefeeds after CR. */

#include <stdio.h>
#include <stdlib.h>

main(argc, argv)
int argc;
char **argv;
{
    FILE *fi, *fo;
    char c;

    if (argc != 3) {
        printf("Usage: ADDLF filein fileout\n");
        exit(4);
    }

    if ((fi = fopen(argv[1], "r")) == NULL) {
        printf("Can't open %s\n", argv[1]);
        exit(4);
    }

    if ((fo = fopen(argv[2], "w")) == NULL) {
        printf("Can't open %s\n", argv[2]);
        exit(4);
    }

    while ((c = getc(fi)) != EOF) {
        if (c == '\n')
            putc(0x0d, fo);
        c = getc(fi);
        if (c == EOF || c == 0x0a) {
            c = 0x0a;
        } else
            putc(0x0a, fo);
        putc(c, fo);
    }

    fclose(fi);
    fclose(fo);
    exit(0);
}
