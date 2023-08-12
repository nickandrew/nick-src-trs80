/*
**   Pkthack1.c : Split a big packet into several packets
**   Ver 1.1  28-Dec-87
*/

#include <stdio.h>
#include <stdlib.h>

FILE *in, *out;

char file1[] = "small00.pkt";

char pkthdr[58];
char msghdr[12];
int length, number = 0;
int c, d, maxsize = 20000;
char *bp, *wp;

extern char buffer[];

extern int readmh(void);
extern void copyfield(void);
extern void copymsg(void);
extern void flushout(void);
extern void makefile(void);

int main(int argc, char *argv[])
{
    if (argc < 3) {
        fputs("Usage: pkthack infile.pkt [bytes]\n", stderr);
        exit(1);
    }

    if ((in = fopen(argv[1], "r")) == NULL) {
        fputs("pkthack: cannot open input file\n", stderr);
        exit(2);
    }

    if (argc == 3)
        maxsize = atoi(argv[2]);

    if (fread(pkthdr, 1, 58, in) != 58) {
        fputs("pkthack: cannot read packet header\n", stderr);
        exit(3);
    }

    length = 0;
    bp = buffer;
    makefile();

    while (readmh()) {
        if (length > maxsize)
            makefile();
        copymsg();
    }

    flushout();
    fclose(out);
    fclose(in);

    fputs("pkthack: done\n", stderr);
    return 0;
}

void makefile(void)
{

    if (out != NULL) {
        flushout();
        fclose(out);
    }

    if (++number > 99) {
        fputs("pkthack: too many output files!\n", stderr);
        exit(1);
    }

    file1[5] = (number / 10) + '0';
    file1[6] = (number % 10) + '0';

    fputs(file1, stderr);
    fputs("\n", stderr);

    if ((out = fopen(file1, "w")) == NULL) {
        fputs("pkthack: cannot open output file\n", stderr);
        exit(4);
    }

    for (wp = pkthdr; wp < pkthdr + 58; ++wp)
        *bp++ = *wp;

    length = 58;
}

int readmh(void)
{

    c = getc(in);
    d = getc(in);

    if (c == 0 && d == 0)
        return 0;

    if (fread(msghdr, 1, 12, in) != 12) {
        fputs("pkthack: Short message header\n", stderr);
        return 0;
    }

    if (c == 2 && d == 0)
        return 1;

    fputs("pkthack: Invalid message header type\n", stderr);
    return 0;
}

void copymsg(void)
{

    *bp++ = 2;
    *bp++ = 0;
    for (wp = msghdr; wp < msghdr + 12; ++wp)
        *bp++ = *wp;

    length += 14;

    copyfield();                /* date */
    copyfield();                /* to   */
    copyfield();                /* from */
    copyfield();                /* subj */
    copyfield();                /* mesg */
}

void copyfield(void)
{
    c = getc(in);
    while (c != EOF && c != 0) {
        *bp++ = c;
        c = getc(in);
        ++length;
    }

    if (c == 0) {
        *bp++ = 0;
        ++length;
    }
}

void flushout(void)
{
    *bp++ = 0;
    *bp++ = 0;

    wp = buffer;

    while (wp < bp)
        fputc(*wp++, out);

    bp = buffer;
    length = 0;
}
