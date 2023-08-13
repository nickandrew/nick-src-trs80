/* rearrange current CATALOG/ZMS format so names at start */

#include <stdio.h>
#include <stdlib.h>

int readin(void);
void writeout(void);
void rearr(void);
void scopy(char *cpi, char *cpo, int len);

char linein[100], lineout[100];
FILE *fpin, *fpout;

int main(void)
{
    fpin = fopen("catalog/zms:2", "r");
    fpout = fopen("catalog/new:1", "w");

    if (fpin == NULL || fpout == NULL)
        return 2;

    while (readin()) {
        rearr();
        writeout();
    }

    fclose(fpin);
    fclose(fpout);
    return 0;
}

int readin(void)
{
    int i, c;
    char *cp;
    i = 0;
    cp = linein;
    c = getc(fpin);
    while (c != EOF && i < 99 && c != '\n') {
        i++;
        *(cp++) = c;
        if (c == '\n')
            break;
        c = getc(fpin);
    }

    if (c == '\n')
        *(cp++) = 0;
    if (i > 99)
        printf("Line too long ... truncated\n");

    return (c != EOF);
}

void writeout(void)
{
    char *cp;
    cp = lineout;
    while (*cp)
        putc(*(cp++), fpout);
}

void rearr(void)
{
    int i;
    char *cpi, *cpo;
    for (i = 0; i < 100; i++)
        lineout[i] = ' ';
    scopy(linein + 16, lineout, 12);
    scopy(linein + 6, lineout + 13, 9);
    scopy(linein, lineout + 23, 5);
    cpi = linein + 29;
    cpo = lineout + 29;
    while (*cpi)
        *(cpo++) = (*(cpi++));
    *(cpo++) = '\n';
    *(cpo++) = 0;
}

void scopy(char *cpi, char *cpo, int len)
{
    int i;
    for (i = 0; i < len; i++)
        *(cpo++) = (*(cpi++));
}
