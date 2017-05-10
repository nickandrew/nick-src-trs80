/*
** atoi.c: Hacked from Alcor's CLIB/C
*/


_atoi(ptr)                  /* decode an integer */
char    **ptr;              /* pointer to addr of 1st digit */
{
    int     n;
    int     isdigit();
    n = 0;

    while (isdigit(*(*ptr))) n = 10 * n + *(*ptr)++ - '0';
    return n;
}

_itoa(n, bufptr, base)     /* integer encode routine */
int         n;             /* unsigned integer */
char        **bufptr;      /* pointer to the buffer pointer */
int         base;          /* number base */
{
    if (n < base) {
        if (n < 10)
            *(*bufptr)++ = n + '0';
        else
            *(*bufptr)++ = n + 55;
        return;
    }
    _itoa(n/base, bufptr, base);
    _itoa(n%base, bufptr, base);
}

atoi(s)                       /* decode an integer */
char    *s;                   /* pointer to integer string */
{
    int     n;
    int     sflag;
    int     isspace();
    int     _atoi();

    n = 0;
    sflag = 0;
    while (isspace(*s)) ++s;
    if (*s == '+' || *s == '-')
        if (*s++ == '-') ++sflag;
    return _atoi(&s);
}

itoa(n, s)
int     n;
char    *s;
{
    int _itoa();
    if (n < 0) {
       if (n == -32768) {
          strcpy(s, "-32768");
          return;
       }
       *s++ = '-';
       n = -n;
    }
    _itoa(n, &s, 10);
    *s = '\0';
}

