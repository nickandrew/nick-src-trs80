/* CC library - ctype.c
** Hacked from Alcor 'C' clib/c
** functions, not macros, for when #include <ctype.h> is used
** Last updated: 17-Jul-87
*/

/***********************************************************/
/*                         isalpha                         */
/***********************************************************/

isalpha(c)                      /* return 1 if c is alphabetic */
int c;                          /*    else returns 0       */
{
    if (c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z')
        return 1;
    else
        return 0;
}

/***********************************************************/
/*                         isupper                         */
/***********************************************************/

isupper(c)
int c;
{
    if (c >= 'A' && c <= 'Z')
        return 1;
    else
        return 0;
}

/***********************************************************/
/*                         islower                         */
/***********************************************************/

islower(c)
int c;
{
    if (c >= 'a' && c <= 'z')
        return 1;
    else
        return 0;
}

/***********************************************************/
/*                         isdigit                         */
/***********************************************************/

isdigit(c)
int c;
{
    if (c >= '0' && c <= '9')
        return 1;
    else
        return 0;
}

/***********************************************************/
/*                         isspace                         */
/***********************************************************/

isspace(c)
int c;
{
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
        return 1;
    else
        return 0;
}

/***********************************************************/
/*                         ispunct                         */
/***********************************************************/

/***********************************************************/
/*                         isalnum                         */
/***********************************************************/

/***********************************************************/
/*                         isprint                         */
/***********************************************************/

/***********************************************************/
/*                         iscntrl                         */
/***********************************************************/

/***********************************************************/
/*                         isascii                         */
/***********************************************************/

/***********************************************************/
/*                         toupper                         */
/***********************************************************/

toupper(c)
int c;
{
    if (c >= 'a' && c <= 'z')
        c -= 32;
    return c;
}

/***********************************************************/
/*                         tolower                         */
/***********************************************************/

tolower(c)
int c;
{
    if (c >= 'A' && c <= 'Z')
        c += 32;
    return c;
}
