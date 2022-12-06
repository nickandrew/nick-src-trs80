/* packctl.c : Read the packdis.ctl file
** @(#) packctl.c 20 May 90
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include "openf2.h"

#define EXTERN extern
#include "packctl.h"

/* read the packdis.ctl file
** Format is:
**  Conference name		Type		Topic-code
**  AUST_XENIX			0 (fidonet)	xx (hex)
**  COMP.OS.MINIX		1 (acsnet)	xx (hex)
*/

void read_control(void)
{
    char line[80];              /* a scratch line */
    char *cp;

    ctrl_p = openf2(CONTROL);
    confs = 0;
    confptr = conftab;

    while (fgets(line, 79, ctrl_p) != NULL) {
        cp = line;
        confpos[confs] = confptr;
        while (*cp && !isspace(*cp)) {
            *confptr++ = *cp++;
        }
        *confptr++ = 0;

        while (isspace(*cp))
            ++cp;

        switch (*cp++) {
        case '0':
            conftyp[confs] = E_FIDONET;
            break;
        case '1':
            conftyp[confs] = E_ACSNET;
            break;
        default:
            fputs("Error in packdis.ctl file\n", stderr);
            exit(2);
        }

        while (isspace(*cp))
            ++cp;

        if (readhex2(cp, &conftop[confs])) {
            fputs("Error in packdis.ctl!\n", stderr);
            exit(2);
        }

        confcnt[confs] = 0;

        if (++confs == MAXCONFS) {
            fputs("Conference table full\n", stderr);
            break;
        }
    }

    fclose(ctrl_p);
}

/* read 2 hex digits and set an integer */

int readhex2(char *cp, int *ip)
{
    int n, m;

    if (*cp >= 'a' && *cp <= 'f')
        *cp &= 0x5f;
    if (*cp < '0' || *cp > 'F' || (*cp > '9' && *cp < 'A'))
        return 1;
    n = (*cp - '0');
    if (n > 9)
        n -= 7;
    ++cp;
    if (*cp >= 'a' && *cp <= 'f')
        *cp &= 0x5f;
    if (*cp < '0' || *cp > 'F' || (*cp > '9' && *cp < 'A'))
        return 1;
    m = (*cp - '0');
    if (m > 9)
        m -= 7;
    *ip = n * 16 + m;
    return 0;
}

/* end of packctl.c */
