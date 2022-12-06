/* pnumb.c : print string & number & string */

#include <stdio.h>
#include <stdlib.h>

char pnbuf[8];

void pnumb(FILE *fp, char *s1, int n, char *s2)
{
    fputs(s1, fp);
    itoa(n, pnbuf);
    fputs(pnbuf, fp);
    fputs(s2, fp);
}
