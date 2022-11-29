/*
 * strchr - find first occurrence of a character in a string
 */

#include <stdio.h>
#include <string.h>

char *strchr(const char *s, int charwanted)
{
    const char *scan;

    /*
     * The odd placement of the two tests is so NUL is findable.
     */
    for (scan = s; *scan != charwanted;)        /* ++ moved down for opt. */
        if (*scan++ == '\0')
            return (NULL);
    return scan;
}
