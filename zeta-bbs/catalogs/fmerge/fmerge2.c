/* fmerge2:
 *  merge sorted CATALOG/ZMS and FILELIST/ZMS
 *               (f1)            (f2)
 *  into FILELIST/NEW
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 255

/* abcdefgh/xyz 22-Dec-86 A B C description.....    */
/* 0....+....1....+....2....+....3.....+....4....5. */

/* abcdefgh/xyz 22-Dec-86 Disk1234 Description..... */
/* 0....+....1....+....2....+....3.....+....4....5. */

int scmp(char *cp1, char *cp2, int len);
void scpy(char *cpo, char *cpi);

char line1[MAX];
char line2[MAX];
char lineout[MAX];
FILE *f1in, *f2in, *fout;
int eof1, eof2;

int main()
{
    f1in = fopen("catalog/zms", "r");
    f2in = fopen("filelist/zms", "r");
    fout = fopen("filelist/new:1", "w");
    if (f1in == NULL || f2in == NULL || fout == NULL)
        exit(2);

    eof1 = (fgets(line1, MAX, f1in) == 0);      /* catalog/zms */
    eof2 = (fgets(line2, MAX, f2in) == 0);      /* filelist/zms */

    while (!eof2) {

        while (!eof1 & (scmp(line1, line2, 12) < 0)) {
            eof1 = (fgets(line1, MAX, f1in) == 0);      /* catalog/zms */
        }

        if (!eof1 & !scmp(line1, line2, 12)) {
            /* they're equal so fix the description */
            scpy(line2 + 31, line1 + 28);
        }

        fputs(line2, fout);
        eof2 = (fgets(line2, MAX, f2in) == 0);  /* filelist/zms */
    }

    fclose(f2in);
    fclose(f2in);
    fclose(fout);
    return 0;
}



int scmp(char *cp1, char *cp2, int len)
{
    int i = 0;
    while (i < len) {
        if (*cp1 != *cp2)
            return (*cp1 - *cp2);
        cp1++;
        cp2++;
        i++;
    }
    return 0;
}

void scpy(char *cpo, char *cpi)
{
    while (*cpi != 0) {
        *(cpo++) = *(cpi++);
    }
    *cpo = 0;
}
