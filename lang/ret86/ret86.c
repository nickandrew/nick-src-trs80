/*
 * ret86.c: Change RETZ & RETNZ instructions to 8086.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    FILE *fpin, *fpout;
    char line[80];
    int retc = 1;
    if (argc != 3)
        return -1;
    printf("Ret86\n");

    if ((fpin = fopen(argv[1], "r")) == NULL) {
        printf("Ret86: Couldn't open %s\n", argv[1]);
        exit(4);
    }

    if ((fpout = fopen(argv[2], "w")) == NULL) {
        printf("Ret86: Couldn't open %s\n", argv[2]);
        exit(4);
    }

    /*  process  */
    while (1) {
        fgets(line, 80, fpin);
        if (*line == 0)
            break;
        if (strcmp(line, "\tretnz\n")) {
            fputs(line, fpout);
            continue;
        }
        fprintf(fpout, "\tjz\trnz_%d\n", retc);
        fprintf(fpout, "\tret\n");
        fprintf(fpout, "rnz_%d:\n", retc++);
    }
    printf("Ret86: Finished.\n");
    return 0;
}
