#include <stdio.h>

fwrite(ptr, size, count, file)
int  size, count;
char *ptr;
FILE *file;
{
    int  s,ndone;

    ndone = 0;
    if (size)
        while ( ndone!=count ) {
            s = size;
            do {
                putc(*ptr++, file);
/*              if (ferror(file))
                    return ndone;
*/          } while (--s);
            ++ndone;
        }
    return ndone;
}
