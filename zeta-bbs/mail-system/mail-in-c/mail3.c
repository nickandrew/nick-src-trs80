/*
**  mail3.c:  Setrange and Getrange
*/

#include <stdio.h>

#define EXTERN       extern
#include "mail.h"

int     setrange(cp,def)
char    *cp;
int     def;
{
    int     i;
    while (*cp && *cp!='.' && *cp!='$' &&
           *cp!='*' && ((*cp<'0') || (*cp>'9'))) ++cp;
    rangecp = cp;
    rangen = 0;
    if (*rangecp==0) {
        if (def=='.') ranges = rangef = dot;
        else {
            ranges = 1;
            rangef = totmail;
        }
        return 0;
    }
    if (getr(rangecp)) return 1;
    return 0;
}

int     getrange() {
    if (rangen==0) return rangen=ranges;
    ++rangen;
    if (rangen <= rangef) return rangen;
    if (getr(rangecp)) return 0;
    return rangen=ranges;
}

int     getr(cp)
char    *cp;
{
    ranges = rangef = 0;
    while (*rangecp==' ') ++rangecp;
    if (*rangecp==0) return 1;
    rangecp = cp = geti(cp);
    if ((ranges>rangef) || (ranges<1) || (rangef>totmail)) {
        std_out("Invalid range specified\n");
        return 1;
    }
    return 0;
}

int     geti(cp)
char    *cp;
{
    int     n;
    n = 0;
    while (*cp==' ') ++cp;
    switch (*cp++) {
        case '.': ranges = dot;
                  break;
        case '*': ranges = 1;
                  rangef = totmail;
                  return cp;
        case '$': ranges = totmail;
                  break;
        default:
            --cp;
            while ((*cp>='0') && (*cp<='9')) {
                n = (n*10) + (*cp++ - '0');
            }
            ranges = n;
    }
    if (*cp!='-') {
        rangef = ranges;
        return cp;
    }
    ++cp;
    switch (*cp++) {
        case '.': rangef = dot;
                  break;
        case '*': rangef = totmail;
                  return cp;
        case '$': rangef = totmail;
                  break;
        default:
            --cp;
            n = 0;
            while ((*cp>='0') && (*cp<='9')) {
                n = (n*10) + (*cp++ - '0');
            }
            rangef = n;
    }
    return cp;
}

