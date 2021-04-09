/* Merge.c: Merge two files columnwise.
 * Ported off the Crappywell L/66 'merge.b'
 * (Substantial changes required)
 * Current version for Trs-80 Alcor 'C' Compiler.
 * Nick Andrew.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STRLENGTH 180
int tabs = 0;

void rdline(char string[], FILE *unit);
void wrline(FILE *unit, const char *string1, const char *string2, int column);
int max3str(const char *str1, const char *str2, const char *str3);
int strlenp(const char *string);

int main(int argc, char *argv[])
{
    char *lastl1, *currl1, *nextl1;
    char *lastl2, *currl2, *nextl2, *temp;
    FILE *unit1, *unit2, *unit3;
    int column;

    if (argc < 5) {
        printf("Usage: merge [-t] infile infile outfile column\n");
        return 1;
    }

    argv++;
    while (--argc > 4) {
        if (argv[0][0] == '-' && argv[0][1] == 't' ) {
            tabs = 1;
            argv++;
        }
    }

    column = atoi(argv[3]);     /* Get merging column */
    if (tabs)
        column = ((column + 8) % 8);    /* adjust for tabs */

    unit1 = fopen(argv[0], "r");        /* Open all files  */
    unit2 = fopen(argv[1], "r");
    unit3 = fopen(argv[2], "w");

    if (unit1 == NULL || unit2 == NULL || unit3 == NULL) {
        printf("merge: can't open files!\n");
        return 2;
    }

    lastl1 = calloc(STRLENGTH, sizeof(char));
    currl1 = calloc(STRLENGTH, sizeof(char));
    nextl1 = calloc(STRLENGTH, sizeof(char));
    lastl2 = calloc(STRLENGTH, sizeof(char));
    currl2 = calloc(STRLENGTH, sizeof(char));
    nextl2 = calloc(STRLENGTH, sizeof(char));
    (*lastl1) = (*lastl2) = 0;  /* set to null strings */
    rdline(currl1, unit1);      /* Read current & next */
    rdline(currl2, unit2);
    rdline(nextl1, unit1);
    rdline(nextl2, unit2);

    /* while not both eof */
    while (!((*currl1 == 0) && (*currl2 == 0))) {
        if ((max3str(currl1, lastl1, nextl1) >= column) || (strlen(currl2) == 0))
            fprintf(unit3, "%s", currl1);
        else {
            wrline(unit3, currl1, currl2, column);
            temp = lastl2;
            lastl2 = currl2;
            currl2 = nextl2;
            nextl2 = temp;
            rdline(nextl2, unit2);
        }
        temp = lastl1;
        lastl1 = currl1;
        currl1 = nextl1;
        nextl1 = temp;
        rdline(nextl1, unit1);
    }

    return 0;
}

void rdline(char string[], FILE *unit)
{
    int chars = 0;
    int c;
    /* MUST be int for Alcor C - nearest I can
     * work out is that char --> int casting
     * does not involve sign extension. Silly!
     */

    if ((c = getc(unit)) == EOF)
        c = 0;
    while (c) {
        string[chars++] = c;
        if (c == '\n')
            break;
        if ((c = getc(unit)) == EOF)
            c = 0;
        if (chars > STRLENGTH)
            printf("Length exceeded %d\n", c);
    }
    string[chars] = 0;
}


void wrline(FILE *unit, const char *string1, const char *string2, int column)
{
    int i;
    if (*string2 == 0)
        fprintf(unit, "%s", string1);
    else {
        for (i = 0; i < strlen(string1) - 1; i++)
            putc(string1[i], unit);
        for (i = 1; i < (column - strlenp(string1)); i++)
            putc(' ', unit);
        fprintf(unit, "%s", string2);
    }
}

int max3str(const char *str1, const char *str2, const char *str3)
{
    int s1, s2, s3, m1, m2;
    s1 = strlenp(str1);
    s2 = strlenp(str2);
    s3 = strlenp(str3);
    m1 = (s1 > s2 ? s1 : s2);
    m2 = (s2 > s3 ? s2 : s3);
    return (m1 > m2 ? m1 : m2);
}

/* Get string length taking tabs into account */
int strlenp(const char *string)
{
    int i = 0, col = 0;
    while (string[i])
        if (string[i++] == '\t')
            col += (8 - (col % 8));
        else
            col++;

    return col;
}
