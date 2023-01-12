/* 
 * wisdom         by --Rosko!--    26-8-87
 *
 * Reads a 'wisdom' randomly from the file 'wisdom.txt' in my
 * home directory. The number and position of all wisdoms is in
 * a file called 'wisdom.inx'. See associated program 'cwiz' to
 * create wisdom.inx
 */

#define   WIZFILE "wisdom/txt"
#define   WIZINDEX "wisdom/inx"
#define   MAX    100            /* maximum length of line */
#define   MAX_WISDOMS   1000

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

char string[MAX];
FILE *winx, *fp;
int maxwiz, wiznum;
long rba;
long rbas[MAX_WISDOMS];

int getlong(long *lp)
{
    union {
      char c[4];
      long l;
    } rv;

    int c;
    int i = 0;
    for (int i = 0; i < 4; ++i) {
      c = fgetc(winx);
      if (c == EOF) {
        return EOF;
      }
      rv.c[i] = c & 0xff;
    }

    *lp = rv.l;
    return 0;
}

int main(void)
{
    if ((fp = fopen(WIZFILE, "r")) == NULL) {
        fprintf(stderr, "Can't open %s for read\n", WIZFILE);
        return 1;
    }
    if ((winx = fopen(WIZINDEX, "r")) == NULL) {
        fprintf(stderr, "Can't open %s for read\n", WIZINDEX);
        return 1;
    }

    // The first long in the file is now ignored
    if (getlong(&maxwiz) < 0) {
        fprintf(stderr, "Index file %s is empty.\n", WIZINDEX);
        return 2;
    }

    int i;
    for (i = 0; i < MAX_WISDOMS; ++i) {
      if (getlong(&rbas[i]) < 0) {
        // Reached end of file
        break;
      }
    }

    // The number of wizards is the number read from the file
    maxwiz = i;

    srand((int) time(0));

    /* 0 to maxwiz-1 */
    wiznum = rand() % maxwiz;

    fputs("\n", stdout);

    rba = rbas[wiznum];
    fseek(fp, rba, 0);

    if (fgets(string, MAX, fp) == NULL) {
      fprintf(stderr, "EOF on %s\n", WIZFILE);
      return 3;
    }

    do {
        fputs(string, stdout);
        fgets(string, MAX, fp);
    } while (string[0] == ' ' || string[0] == '\t');

    fputs("\n", stdout);
    return 0;
}
