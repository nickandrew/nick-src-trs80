/* pnumb.c : print string & number & string */

#include <stdio.h>

char pnbuf[8];

pnumb(fp, s1, n, s2)
FILE *fp;
char *s1, *s2;
int n;
{
    fputs(s1, fp);
    itoa(n, pnbuf);
    fputs(pnbuf, fp);
    fputs(s2, fp);
}
