/* getuid ... return the userid of the user name
**	Not properly implemented yet
*/

#ifndef NULL
#define	NULL	(void *)0
#endif

int getuid(char *s)
char *s;
{
    if (s == NULL)
        return 2;               /* sysop */
    return 16;                  /* nick  */
}
