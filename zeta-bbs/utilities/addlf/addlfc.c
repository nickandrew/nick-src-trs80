/* addlfc.c
** Converts a text file to have CRLF endings
**
**  0x0a -> 0x0d 0x0a
*/

#include <stdio.h>

FILE *fi, *fo;

void write_eol(void)
{
    int ch;

    putc(0x0d, fo);
    ch = getc(fi);
    if (ch == EOF || ch == 0x0a) {
        ch = 0x0a;
    } else {
        putc(0x0a, fo);
    }

    putc(ch, fo);
}

int main(int argc, char *argv[])
{
    int c;

    if (argc != 3) {
        printf("Usage: ADDLF filein fileout\n");
        return 2;
    }

    if ((fi = fopen(argv[1], "r")) == NULL) {
        printf("Can't open %s\n", argv[1]);
        return 2;
    }

    if ((fo = fopen(argv[2], "w")) == NULL) {
        printf("Can't open %s\n", argv[2]);
        return 2;
    }

    while ((c = getc(fi)) != EOF) {
        if (c == '\n')
            write_eol();
        putc(c, fo);
    }

    fclose(fi);
    fclose(fo);
    return 0;
}
