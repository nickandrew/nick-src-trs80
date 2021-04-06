#include <stdio.h>

#define YES 1
#define NO  0
#define ERROR   -1
#define MASK    127

main(argc, argv)
int argc;
char *argv[];
{
    int c, inword;
    FILE *fp;
    int nl, nw, nc;
    char s[20];

    if (argc != 2) {
        fputs("Usage: wc filename\n", stdout);
        exit();
    }
    if ((fp = fopen(argv[1], "r")) == NULL) {
        fputs("wc: cannot open input file\n", stdout);
        exit();
    }
    inword = NO;
    nl = nw = nc = 0;
    while ((c = (getc(fp))) != EOF) {
        ++nc;
        c = (c & MASK);
        if (c == '\n')
            ++nl;
        if (c == ' ' || c == '\r' || c == '\t' || c == '\n')
            inword = NO;
        else if (inword == NO) {
            inword = YES;
            ++nw;
        }
    }
    fputs("Number of lines = ", stdout);
    itoa(nl, s);
    strcat(s, "\n");
    fputs(s, stdout);

    fputs("Number of words = ", stdout);
    itoa(nw, s);
    strcat(s, "\n");
    fputs(s, stdout);

    fputs("Number of chars = ", stdout);
    itoa(nc, s);
    strcat(s, "\n");
    fputs(s, stdout);
}
