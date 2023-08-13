/* Zetasource
** Readnews program
** active.c
** Routines to manipulate the ACTIVE file
*/

#include <stdio.h>
#include <stdlib.h>
#include "readnews.h"

char *blanks(char *x);

/*
** readgrp() ... Read active line, return 0 if eof
*/

int readgrp(void)
{
    char *cp, *cp2;
    if (fgets(line, 80, active) == NULL)
        return 0;
    highgrp = atoi(line);
    cp = blanks(line + 4);
    access = *cp++;
    cp = blanks(cp);
    expiry = atoi(cp);
    while (*cp != ' ')
        ++cp;
    cp = blanks(cp);
    grptype = *cp;
    while (*cp != ' ')
        ++cp;
    cp = blanks(cp);
    cp2 = grpname;
    while (*cp != '\n')
        *cp2++ = *cp++;
    *cp2 = '\0';
    return 1;
}

char *blanks(char *x)
{
    while (*x == ' ')
        ++x;
    return x;
}
