/* ASMUP - convert assembler source to uppercase */
/* Writes to stdout, ignores comments (ie: ";")  */
/* Handles lines longer than 80 chars            */

#include <stdio.h>
#include <ctype.h>

char buf[81], *c, q;

main()
{
    while (fgets(buf, 80, stdin) != NULL) {
        c = buf;
        while (*c) {

            /* ignore the innards of strings etc */
            if (*c == '\'' || *c == '"') {
                q = *c;
                while (*++c != q && *c) ;
                c = (q ? ++c : c);
                continue;
            }

            /* bypass conversion if comment */
            if (*c == ';')
                break;

            if (*c >= 'a' && *c <= 'z')
                *c = toupper(*c);
            ++c;
        }
        fputs(buf, stdout);
    }
}
