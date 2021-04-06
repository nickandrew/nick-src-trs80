/* getuid ... return the userid of the user name
**	Not properly implemented yet
*/

#define	NULL	0

int getuid(s)
char *s;
{
    if (s == NULL)
        return 2;               /* sysop */
    return 16;                  /* nick  */
}
