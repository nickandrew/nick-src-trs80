/*  openf2.c - Open a file. Print an error message and exit if failure
**	@(#) openf2.c 20 May 90
*/

#include <stdio.h>
#include <stdlib.h>

#include "openf2.h"

extern void fixperm(FILE *);

/* open a file with error message if failure */

FILE *openf2(char *filename)
{
    FILE *pointer;

    pointer = fopen(filename, "r+");

    if (pointer == NULL) {
        fputs("Cannot open ", stderr);
        fputs(filename, stderr);
        fputs("\n", stderr);
        exit(1);
    }

    fixperm(pointer);
    return pointer;
}
