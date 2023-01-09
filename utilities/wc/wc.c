#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YES 1
#define NO  0
#define MASK    127

int main(int argc, char *argv[])
{
    int c, inword;
    FILE *fp;
    int nl, nw, nc;

    if (argc != 2) {
        fputs("Usage: wc filename\n", stdout);
        return 2;
    }

    if ((fp = fopen(argv[1], "r")) == NULL) {
        fputs("wc: cannot open input file\n", stdout);
        return 2;
    }

    inword = NO;
    nl = nw = nc = 0;
    while ((c = (fgetc(fp))) != EOF) {
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

    fprintf(stdout, "Number of lines = %d\n", nl);
    fprintf(stdout, "Number of words = %d\n", nw);
    fprintf(stdout, "Number of chars = %d\n", nc);

    return 0;
}
