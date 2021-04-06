/*
 * asmclean.c: Cleans up /ASM files
 * (C) 1986, Nick.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char line[200], lineout[200];
FILE *fpin, *fpout;

int getlin();
void putlin();
void clean();

void main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("Usage: asmclean.c infile.asm outfile.asm\n");
        exit(4);
    }

    fpin = fopen(argv[1], "r");
    fpout = fopen(argv[2], "w");
    if (fpin == NULL || fpout == NULL) {
        printf("Couldn't open files\n");
        exit(0);
    }

    printf("Files opened OK \n");
    while (1) {
        if (getlin() != 0)
            break;
        putchar('.');
        clean();
        putlin();
    }
    putc(0x1a, fpout);
    exit(0);
}

int getlin()
{
    int c;
    char *cp;

    cp = line;
    if ((c = getc(fpin)) == EOF)
        return 1;
    if (c == 0)
        return 1;
    while (c != '\n') {
        *(cp++) = (char) c;
        c = getc(fpin);
    }
    *(cp++) = 0;
    return 0;
}

void putlin()
{
    char *cp;
    cp = lineout;
    while (*cp) {
        putc(*(cp++), fpout);
    }
    putc('\n', fpout);
}

void clean()
{
    /* leave a line beginning with a comment alone */
    char *cp;
    int apos, tpos;
    apos = 0;
    tpos = 0;
    cp = line;
    while (*cp == ' ' || *cp == '\t')
        cp++;
    if (*cp == 0) {
        /* null line... preface with ; */
        strcpy(lineout, ";");
        return;
    }

    if (*cp == ';') {           /* line contains only a comment. Asis. */
        strcpy(lineout, line);
        return;
    }

    /* if line has a label ... */
    if (cp == line) {
        /* copy label removing colon */
        while (*cp && *cp != ':' && *cp != ' ' && *cp != '\t' && *cp != ';') {
            tpos++;
            lineout[apos++] = *(cp++);
        }
        if (*cp == ':')
            cp++;
    }

    while (*cp == ' ' || *cp == '\t')
        cp++;
    if (*cp != 0) {
        lineout[apos++] = '\t';
        tpos = (tpos + 8) & 0xF8;
    }

    /* copy opcode field if any */
    while (*cp && *cp != ' ' && *cp != '\t' && *cp != ';') {
        tpos++;
        lineout[apos++] = *(cp++);
    }

    while (*cp == ' ' || *cp == '\t')
        cp++;
    if (*cp != 0) {
        lineout[apos++] = '\t';
        tpos = (tpos + 8) & 0xF8;
    }

    /* copy operand field if any */
    while (*cp && *cp != ' ' && *cp != '\t' && *cp != ';') {
        if (*cp == '\'') {
            while (1) {
                tpos++;
                lineout[apos++] = *(cp++);
                if (*cp == 0 || *cp == '\'')
                    break;
            }
            if (*cp == '\'') {
                tpos++;
                lineout[apos++] = *(cp++);
            }
        } else {
            tpos++;
            lineout[apos++] = *(cp++);
        }
    }

    while (*cp == ' ' || *cp == '\t')
        cp++;
    if (*cp == 0) {
        lineout[apos++] = 0;
        return;
    }

    if (*cp != ';') {
        lineout[apos++] = 0;
        printf("Invalid line... %s\n", line);
        return;
    }

    /* else it is a semicolon */

    while (tpos < 32) {
        tpos = (tpos + 8) & 0xF8;
        lineout[apos++] = '\t';
    }

    while (*cp) {
        tpos++;
        lineout[apos++] = *(cp++);
    }

    lineout[apos++] = 0;
    /* done */
}
