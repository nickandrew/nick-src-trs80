/*  packdis4 ... Low level routines for packdis
**	@(#) packdis4.c: 20 May 90
*/

#include <stdio.h>

#include "openf2.h"

#define EXTERN extern
#include "packdis.h"
#include "packctl.h"
#include "zeta.h"

#ifdef	REALC
#define LONG	long
#else
#define LONG	int
#endif

/*  fixfn : Change first char of name & extension to alpha */

fixfn(cp)
char *cp;
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

getfn(cp1, cp2)
char *cp1, *cp2;
{
    cp1 += 2;
    while (*cp1 && *cp1 != '\n')
        *cp2++ = *cp1++;
    *cp2 = 0;
}

/* commence ... check if string s is at the start of string l, and
**	return the pointer to l just after s ends.
*/

char *commence(l, s)
char *l, *s;
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

fixstr(cp)
char *cp;
{
    while (*cp) {
        if (*cp < ' ' || *cp > 0x7e)
            *cp = ' ';
        ++cp;
    }
}

/* zero the 3 bytes of a file rba position */

zeropos(cp)
char cp[];
{
    cp[0] = cp[1] = cp[2] = 0;
}

/* numstr ... write a number into a string & return eos */

char *numstr(cp, num)
char *cp;
int num;
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

int isspace(c)
int c;
{
    return (c == ' ' || (c >= 9 && c <= 13));
}

#endif

/* end of packdis4.c */
