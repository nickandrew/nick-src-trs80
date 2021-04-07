/*       Languages & Processors
**
**       errors.c - Some error handling routines
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/


#include <stdio.h>              /* Standard IO functions */

#include "errors.h"             /* Anything necessary for errors */
#include "lls.h"

int     errorfound = 0;

extern  FILE *f_list;

void error(const char *msg)
{
    /* print an error message */

    int i;
    ++errorfound;

    /* tab out to the position of the error */

    i = linepos + 3;
    while (i-- > 0)
        fputc(' ', f_list);

    fputs("|\n", f_list);
    fputs(msg, f_list);
    fputc('\n', f_list);
}
