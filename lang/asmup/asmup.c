/* ASMUP - convert assembler source to uppercase */
/* Writes to stdout, ignores comments (ie: ";")  */
/* Handles lines longer than 80 chars            */

#include <ctype.h>
#include <stdio.h>

char buf[81], c, *cp, q;

int main(void)
{
    while (fgets(buf, 80, stdin) != NULL) {
        cp = buf;

        while (*cp) {

            /* ignore the innards of strings etc */
            if (*cp == '\'' || *cp == '"') {
                q = *cp;
                while (*++cp != q && *cp) ;
                cp = cp + 1;
                continue;
            }

            /* bypass conversion for rest of line if comment */
            c = *cp;
            if (c == ';')
                break;

            if (c >= 'a' && c <= 'z')
                *cp = toupper(c);

            ++cp;
        }

        fputs(buf, stdout);
    }

    return 0;
}
