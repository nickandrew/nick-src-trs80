/*
 * nedasref/c : Cross-reference Nedas/Edas source code
 * Version 1.0  (C) 1986, Gustav Francois
 * usage: NEDASREF file1 file2 file3 ... filen
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char filename[80];              /* current filename */
char newfile[80];               /* *GET filename    */
short level;                    /* levels deep */
char line[129];                 /* line buffer null term */
char arg1[80];                  /* first argument in line */
char arg2[80];                  /* 2nd argument in line */

void fileproc(char *fname);

void main(int argc, char *argv[])
{
    int i = 0;
    if (argc < 2) {
        printf("Nedasref: Nedas source cross-referencer\n");
        printf("Version:  1.0, dated 02-Aug-86\n");
        printf("Usage:    nedasref file1 file2 ... filen\n");
        printf("Eg:       nedasref kermit/asm\n");
        exit(1);
    }

    level = 0;
    *filename = 0;

    while (--argc)
        fileproc(argv[++i]);

    exit(0);
}

void fileproc(char *fname)
{
    char oldname[80], *cp, *ncp, drive[8];
    const char *ltype;
    unsigned int in_line = 0;
    FILE *fp;

    /* add /ASM extension if necessary (before drive number) */

    cp = fname;
    while (*cp && *cp != '/' && *cp != ':')
        cp++;
    if (*cp == ':') {
        strcpy(drive, cp);
        *cp = 0;
        strcat(fname, "/ASM");
        strcat(fname, drive);
    } else if (*cp != '/')
        strcat(fname, "/ASM");

    strcpy(oldname, filename);
    strcpy(filename, fname);
    ++level;
    printf("Processing %s [level %d]\n", fname, level);

    if ((fp = fopen(fname, "r")) == NULL) {
        printf("nedasref: Can't open %s\n", fname);
        strcpy(filename, oldname);
        --level;
        return;
    }

    while (fgets(line, 128, fp) != NULL) {
        if (*line == 0x1a)
            break;              /* eof ... 1A byte trailer */
        ++in_line;
        cp = line;
        *arg1 = 0;
        *arg2 = 0;

        /* first field */

        if (*cp != ' ' && *cp != '\t' && *cp != '\n' && *cp != 0 && *cp != ';') {
            /* read until ;,:,cr,space,tab */
            ncp = arg1;
            while (*cp != ' ' && *cp != '\t' && *cp != '\n' && *cp != ':' && *cp != ';')
                *ncp++ = *cp++;
            *ncp = 0;
            if (*cp == ':')
                cp++;
        }

        /* jump to second field */
        while (*cp == ' ' || *cp == '\t')
            cp++;

        /* test second field */

        if (*cp != '\n' && *cp != 0 && *cp != ';') {
            /* read until ;,cr,space,tab */
            ncp = arg2;
            while (*cp != ' ' && *cp != '\t' && *cp != '\n' && *cp != ';')
                *ncp++ = *cp++;
            *ncp = 0;
        }

        /* if no "label" field, loop */
        if (*arg1 == 0)
            continue;

        /* test for *command */

        if (*arg1 == '*') {
            if (!strcmp(arg1, "*GET")) {
                fileproc(arg2);
                continue;
            }
        } else {                /* must be a label */
            ltype = "LABEL   ";
            if (!(strcmp(arg2, "DEFL") && strcmp(arg2, "EQU")))
                ltype = "CONSTANT";
            if (!(strcmp(arg2, "DEFB") && strcmp(arg2, "DB")))
                ltype = "BYTE    ";
            if (!(strcmp(arg2, "DEFW") && strcmp(arg2, "DW")))
                ltype = "WORD    ";
            if (!(strcmp(arg2, "DEFM") && strcmp(arg2, "DM")))
                ltype = "MESSAGE ";
            if (!(strcmp(arg2, "DEFS") && strcmp(arg2, "DS")))
                ltype = "DEFS/buf";
            if (*arg2 == 0)
                ltype = "   ??   ";

            printf("%15s [%8s] defined in %14s, line %4d\n", arg1, ltype, filename, in_line);
        }
    }

    fclose(fp);
    strcpy(filename, oldname);
    --level;
}
