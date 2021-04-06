/* @(#) fileno/c : Return integer file descriptor */
#include <stdio.h>
int fileno(fp)
FILE *fp;
{
    return (fp->fd);
}
