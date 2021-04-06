/*
 * pktlook1.c : Look at the contents of a packet
 */

#include <stdio.h>

FILE *in;

char pkthdr[58];
char msghdr[14];
char datef[21];
char fromstr[100], tostr[100], subjstr[100];

int i, n, c;
int orignode, destnode, orignet, destnet;
int month, pktver;

char *months[24];               /* should be 12 */

char digits[] = "0123456789abcdef";


main(argc, argv)
int argc;
char **argv;
{
    initm();
    if (argc == 1) {
        fputs("Usage: pktlook [files ...]\n", stderr);
        exit(1);
    }

    while (--argc)
        look(*++argv);
}

look(file)
char *file;
{
    if ((in = fopen(file, "r")) == NULL) {
        outstr(0, stderr, "\nPktlook: cannot open ", file, "\n");
        return;
    }

    outstr(0, stdout, "\nContents of  ", file, "\n\n");

    dopkthdr();
    while (domsg())
        pause();
    fclose(in);
}

dopkthdr()
{
    n = fread(pkthdr, 1, 58, in);
    if (n != 58) {
        outnum(stdout, "Bad packet header, length ", n, "\n");
        outstr(0, stdout, "Hex dump follows:\n\n");
        hexdump(pkthdr, n);
        exit(1);
    }

    orignode = getf(pkthdr, 0);
    destnode = getf(pkthdr, 2);
    orignet = getf(pkthdr, 20);
    destnet = getf(pkthdr, 22);
    month = getf(pkthdr, 6);
    pktver = getf(pkthdr, 18);

    fputs("Packet is from ", stdout);
    pnn(orignet, orignode);
    fputs(" to ", stdout);
    pnn(destnet, destnode);
    fputs("\n", stdout);

    outnum(stdout, "Date: ", getf(pkthdr, 8), " ");
    if (month < 0 || month > 11)
        fputs("???????? ", stdout);
    else
        fputs(months[month], stdout);
    outnum(stdout, " ", getf(pkthdr, 4), "\n");

    if (pktver != 2)
        outnum(stdout, "Packet version = ", pktver, " !\n");

    fputs("Fill area contents:\n\n", stdout);
    hexdump(pkthdr + 24, 34);
}

outnum(fp, str1, num, str2)
FILE *fp;
char *str1, *str2;
int num;
{
    char string[8];
    itoa(num, string);
    fputs(str1, fp);
    fputs(string, fp);
    fputs(str2, fp);
}

/* VARARGS */
outstr(lastarg)
char *lastarg;
{
    char **argp;
    FILE *fp;

    argp = &lastarg;
    while (*argp)
        ++argp;
    --argp;
    fp = *argp--;
    do {
        fputs(*argp, fp);
    } while ((argp--) != &lastarg);
}

hexdump(cp, num)
char *cp;
int num;
{
    int addr;

    addr = 0;
    if (num == 0)
        return;

    while (num) {
        puthexc(addr >> 8, "");
        puthexc(addr & 0xff, " ");
        puthexl(cp, num);
        putcharl(cp, num);
        fixnum(&cp, &num);
        addr += 16;
    }
    fputs("\n", stdout);
}

puthexc(c, str)
int c;
char *str;
{
    c &= 0xff;
    fputc(digits[c >> 4], stdout);
    fputc(digits[c & 0x0f], stdout);
    fputs(str, stdout);
}

puthexl(cp, num)
char *cp;
int num;
{
    int i;

    i = 16;

    while (i--) {
        if (num > 0)
            puthexc(*cp++, "");
        else
            fputs("  ", stdout);
        --num;
        if (!(i & 1))
            putchar(' ');
    }
    fputs("  ", stdout);
}

putcharl(cp, num)
char *cp;
int num;
{
    int n, i;
    char c;

    i = 16;

    while (i--) {
        if (num > 0) {
            c = *cp++;
            if (c < 32 || c > 126)
                putchar('.');
            else
                putchar(c);
        } else
            putchar(' ');
        --num;
    }
    putchar('\n');
}

fixnum(cpp, nump)
char **cpp;
int *nump;
{
    int i;
    if (*nump > 15)
        i = 16;
    else
        i = *nump;
    *cpp += i;
    *nump -= i;
}

domsg()
{
    n = fread(msghdr, 1, 14, in);
    if (getf(msghdr, 0) == 0)
        return 0;
    if (n != 14) {
        outnum(stdout, "Bad message header length ", n, "\n");
        return 0;
    }

    pktver = getf(msghdr, 0);
    orignode = getf(msghdr, 2);
    destnode = getf(msghdr, 4);
    orignet = getf(msghdr, 6);
    destnet = getf(msghdr, 8);

    if (pktver != 2)
        outnum(stdout, "Packet version = ", pktver, " !\n");
    fputs("\nMessage is from ", stdout);
    pnn(orignet, orignode);
    fputs(" to ", stdout);
    pnn(destnet, destnode);
    fputs("\n", stdout);

    if (!orignode || !orignet || !destnode || !destnet) {
        fputs("Zero fields illegal!\n", stdout);
        exit(1);
    }

    n = fread(datef, 1, 20, in);
    if (n != 20) {
        outnum(stdout, "Short date field length ", n, "\n");
        return 0;
    }

    fputs("Attribute, Cost and Date fields:\n", stdout);
    hexdump(msghdr + 10, 4);
    hexdump(datef, 20);

    ignore(4);
    return 1;
}

ignore(n)
int n;
{
    while (n--) {
        while (((c = getc(in)) & 0xff) > 0) ;
    }
}

initm()
{
    months[0] = "January";
    months[1] = "February";
    months[2] = "March";
    months[3] = "April";
    months[4] = "May";
    months[5] = "June";
    months[6] = "July";
    months[7] = "August";
    months[8] = "September";
    months[9] = "October";
    months[10] = "November";
    months[11] = "December";
}

int getf(buf, off)
char *buf;
int off;
{
    char *place;
    int a, b;
    place = buf + off;
    a = *place & 0xff;
    b = *++place & 0xff;
    return a + (b << 8);
}

pnn(net, node)
int net, node;
{
    char string[8];
    itoa(net, string);
    fputs(string, stdout);
    itoa(node, string);
    putchar('/');
    fputs(string, stdout);
}

pause()
{
    putchar('?');
    while (getchar() != ' ') ;
}
