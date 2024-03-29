/*  packdis4 ... Low level routines for packdis
**	@(#) packdis4.c: 20 May 90
*/

#include <stdio.h>
#include <stdlib.h>

#include "openf2.h"

#define EXTERN extern
#include "packdis.h"
#include "packctl.h"
#include "zeta.h"

/*  fixfn : Change first char of name & extension to alpha */

void fixfn(char *cp)
{

    if (*cp >= '0' && *cp <= '9')
        *cp += 0x11;

    while (*cp && *cp != SEP)
        ++cp;

    if (*cp == SEP) {
        ++cp;
        if (*cp >= '0' && *cp <= '9')
            *cp += 0x11;
    }
}

/* getfn ... get a filename string from a PACKETS/INFILES type file */

void getfn(char *cp1, char *cp2)
{
    cp1 += 2;
    while (*cp1 && *cp1 != '\n')
        *cp2++ = *cp1++;
    *cp2 = 0;
}

/* commence ... check if string s is at the start of string l, and
**	return the pointer to l just after s ends.
*/

char *commence(char *l, char *s)
{
    while ((*l == *s) && *s) {
        ++l;
        ++s;
    }
    if (*s == '\0')
        return l;
    return NULL;
}

/* fixstr ... remove non-printing characters */

void fixstr(char *cp)
{
    while (*cp) {
        if (*cp < ' ' || *cp > 0x7e)
            *cp = ' ';
        ++cp;
    }
}

/* zero the 3 bytes of a file rba position */

void zeropos(char cp[3])
{
    cp[0] = cp[1] = cp[2] = 0;
}

/* numstr ... write a number into a string & return eos */

char *numstr(char *cp, int num)
{
#ifdef	REALC
    sprintf(cp, "%d", num);
#else
    itoa(num, cp);
#endif
    while (*cp)
        ++cp;
    return cp;
}

#ifdef	REALC

/* isspace ... quick hack! */

int isspace(int c)
{
    return (c == ' ' || (c >= 9 && c <= 13));
}

#endif

/* end of packdis4.c */
