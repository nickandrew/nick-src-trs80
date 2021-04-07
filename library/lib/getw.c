/* get an integer from a buffer (byte order independent) */

#include "getw.h"

int getw(char *cp)
{
    return (*cp & 255) + ((cp[1] & 255) << 8);
}

/* put an integer into a buffer (byte order independent) */

void putw(char *addr, int word)
{
    *addr++ = (word & 255);
    *addr++ = (word >> 8) & 255;
}
