
/* 
 * wisdom         by --Rosko!--    26-8-87
 *
 * Reads a 'wisdom' randomly from the file 'wisdom.txt' in my
 * home directory. The number and position of all wisdoms is in
 * a file called 'wisdom.inx'. See associated program 'cwiz' to
 * create wisdom.inx
 */

#define   WIZFILE "wisdom.txt"
#define   WIZINDEX "wisdom.inx"
#define   MAX    100    /* maximum length of line */

#include  <stdio.h>

extern char *tickptr;
char string[MAX];
FILE   *winx,*fp;
int    maxwiz,wiznum,rba;

main ()
{
    FILE *fopen();

    if ((fp = fopen(WIZFILE, "r")) == NULL) {
        fputs ("\nCan't open wisdom file.\n", stderr);
        exit(1);
    }
    if ((winx=fopen(WIZINDEX,"r"))==NULL) {
        fputs("\nCan't open wisdom index.\n",stderr);
        exit(1);
    }

    maxwiz = getint();
    srand (*tickptr);
    /* 0 to maxwiz-1 */
    wiznum = rand() % maxwiz;

/*  itoa(wiznum,string);
    fputs(string,stdout);
    fputs(":\n",stdout);
*/
    fputs("\n",stdout);

    while (wiznum-- >= 0) {
        rba = getint();
    }

    fseek(fp,rba,0);

    fgets (string, MAX, fp);
    do {
        fputs (string, stdout);
        fgets (string, MAX, fp);
    } while (string[0] == ' ' || string[0] == '\t');

    fputs("\n",stdout);
    exit(0);
}

int     getint()
{
    int  c;
    c = fgetc(winx);
    return (fgetc(winx) << 8) + c;
}

