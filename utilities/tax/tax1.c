/* tax1 : rearrange the raw input into a form more suitable
 *        for ppk1.
 */

#include <stdio.h>
#define COLUMNS 6

FILE *fpin, *fpout;
int i;
char table[18][10];
/*
char *wordy[18] ={"5","6","7","9a","11","12","12p","13","14",
	"15","15a","16","17","18","19","20","21","22"};
*/
char *wordy[COLUMNS] = { "p", "s", "b", "m", "i", "l" };

char instr[80], outstr[80];
char *cp, *ccp, *scp;
char code[4], value[7];

main(argc, argv)
int argc;
char *argv[];
{
    if (argc != 3) {
        printf("usage: %s inputfile outputfile\n", *argv);
        exit(1);
    }

    fpin = fopen(argv[1], "r");
    fpout = fopen(argv[2], "w");
    if (fpin == NULL || fpout == NULL) {
        printf("tax1: can't open both files\n");
        exit(1);
    }

    while (fgets(instr, 80, fpin) != NULL) {
        cp = instr;
        scp = outstr;
        while (*cp != ' ')
            *scp++ = *cp++;
        *scp++ = ':';
        space(&cp);
        while (*cp != ' ')
            *scp++ = *cp++;
        *scp++ = ':';
        *scp++ = 0;
        space(&cp);
        /* clear table entries */
        for (i = 0; i < COLUMNS; i++) {
            table[i][0] = 0;
        }
        while (*cp != '\n') {
            ccp = code;
            while (*cp != ' ')
                *ccp++ = *cp++;
            *ccp = 0;
            ccp = value;
            space(&cp);
            while (*cp != ' ' && *cp != '\n')
                *ccp++ = *cp++;
            *ccp = 0;
            space(&cp);
            /* put into table */
            for (i = 0; i < COLUMNS && strcmp(code, wordy[i]); i++) ;
            if (i == COLUMNS) {
                printf("code,value: '%s' '%s'\n", code, value);
                printf("Bad column reference: %s\n", instr);
            } else
                strcpy(table[i], value);
        }
        for (i = 0; i < COLUMNS; i++) {
            strcat(outstr, table[i]);
            strcat(outstr, ":");
        }
        fputs(outstr, fpout);
        putc('\n', fpout);
    }
    printf("End of program\n");
}

space(charptr)
char *charptr;
{
    while (*cp == ' ')
        cp++;
}
