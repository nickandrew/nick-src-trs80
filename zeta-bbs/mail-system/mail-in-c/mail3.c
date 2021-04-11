/*
**  mail3.c:  Setrange and Getrange
*/

#include <stdio.h>

#define EXTERN       extern
#include "mail.h"

static   int      ranges, rangef, rangen;
static   char     *rangecp;

static int getr(char *cp);
static char *geti(char *cp);

int setrange(char *cp, int def)
{
    while (*cp && *cp != '.' && *cp != '$' && *cp != '*' && ((*cp < '0') || (*cp > '9')))
        ++cp;
    rangecp = cp;
    rangen = 0;
    if (*rangecp == 0) {
        if (def == '.')
            ranges = rangef = dot;
        else {
            ranges = 1;
            rangef = totmail;
        }
        return 0;
    }
    if (getr(rangecp))
        return 1;
    return 0;
}

/* getrange(): Increment and return the next message number from the range being processed.
**
** Statics used:
**   ranges = first message in range
**   rangef = last message in range
**   rangen = current message (returned)
**   rangecp = pointer to next range to parse
** Returns 0 if no more messages.
*/

int getrange(void)
{
    if (rangen == 0)
        return rangen = ranges;

    ++rangen;
    if (rangen <= rangef)
        return rangen;

    if (getr(rangecp))
        return 0;

    return rangen = ranges;
}

static int getr(char *cp)
{
    ranges = rangef = 0;
    while (*rangecp == ' ')
        ++rangecp;
    if (*rangecp == 0)
        return 1;
    rangecp = cp = geti(cp);
    if ((ranges > rangef) || (ranges < 1) || (rangef > totmail)) {
        std_out("Invalid range specified\n");
        return 1;
    }
    return 0;
}

/* geti(): Parse an message number and/or range of messages.
**
** Valid inputs:
**   Leading blanks are skipped
**   '.'
**   '*' means all messages (ranges=1; rangef=totmail)
**   '$' (ranges=totmail; rangef unchanged?)
**   [0-9]+ (ranges=n; rangef=n)
**   [0-9]+ '-' (ranges=n; rangef=n)
**   Next input can be '.' (rangef = current), '*' (rangef=totmail), '$' (rangef=totmail)
**   Or a number
**
**
** Returns:
**   Pointer to input string beyond the range.
** Output in globals:
**   ranges = first message number
**   rangef = last message number
*/

static char *geti(char *cp)
{
    int n;
    n = 0;
    while (*cp == ' ')
        ++cp;

    switch (*cp++) {
    case '.':
        ranges = dot;
        break;
    case '*':
        ranges = 1;
        rangef = totmail;
        return cp;
    case '$':
        ranges = totmail;
        break;
    default:
        --cp;
        while ((*cp >= '0') && (*cp <= '9')) {
            n = (n * 10) + (*cp++ - '0');
        }
        ranges = n;
    }
    if (*cp != '-') {
        rangef = ranges;
        return cp;
    }
    ++cp;
    switch (*cp++) {
    case '.':
        rangef = dot;
        break;
    case '*':
        rangef = totmail;
        return cp;
    case '$':
        rangef = totmail;
        break;
    default:
        --cp;
        n = 0;
        while ((*cp >= '0') && (*cp <= '9')) {
            n = (n * 10) + (*cp++ - '0');
        }
        rangef = n;
    }
    return cp;
}
