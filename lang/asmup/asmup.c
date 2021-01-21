/* ASMUP - convert assembler source to uppercase */
/* Writes to stdout, ignores comments (ie: ";")  */
/* Handles lines longer than 80 chars            */

#include <stdio.h>
#include <ctype.h>

char buf[81], *cp, q;

main()
{
    while (fgets(buf, 80, stdin) != NULL) {
        cp = buf;
        while (*cp) {

            /* ignore the innards of strings etc */
            if (*cp == '\'' || *cp == '"') {
                q = *cp;
                while (*++cp != q && *cp) ;
                cp = (q ? ++cp : cp);
                continue;
            }

            /* bypass conversion if comment */
            if (*cp == ';')
                break;

            if (*cp >= 'a' && *cp <= 'z')
                *cp = toupper(*cp);
            ++cp;
        }
        fputs(buf, stdout);
    }
}
