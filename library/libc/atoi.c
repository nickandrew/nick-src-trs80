/*
** atoi.c: Hacked from Alcor's CLIB/C
*/

#include <string.h>

extern int isdigit(char);
extern int isspace(char);

/* decode an integer */
int _atoi(char **ptr)               /* pointer to addr of 1st digit */
{
    int n;
    n = 0;

    while (isdigit(**ptr))
        n = 10 * n + *(*ptr)++ - '0';
    return n;
}

void _itoa(unsigned int n, char **bufptr, int base)          /* integer encode routine */
/* int n;                          unsigned integer */
/* char **bufptr;                  pointer to the buffer pointer */
/* int base;                       number base */
{
    if (n < base) {
        if (n < 10)
            *(*bufptr)++ = n + '0';
        else
            *(*bufptr)++ = n + 55;
        return;
    }
    _itoa(n / base, bufptr, base);
    _itoa(n % base, bufptr, base);
}

int atoi(const char *s)                         /* decode an integer */
{
    int n;
    int sflag;

    n = 0;
    sflag = 0;
    while (isspace(*s))
        ++s;
    if (*s == '+' || *s == '-')
        if (*(s++) == '-')
            ++sflag;
    if (sflag) {
      return -_atoi(&s);
    } else {
      return _atoi(&s);
    }
}

char *itoa(int n, char *s)
{
    char *buf;

    buf = s;
    if (n < 0) {
        if (n == -32768) {
            strcpy(s, "-32768");
            return s;
        }
        *buf++ = '-';
        n = -n;
    }
    _itoa(n, &buf, 10);
    *buf = '\0';
    return s;
}
