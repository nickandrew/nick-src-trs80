/* @(#) sbrk.c 17 Jun 90 - Implement the sbrk(incr) system call */

extern void *brksize;
extern int brk(void *newsize);

void *sbrk(int incr)
{
    void *newsize, *oldsize;

    if (incr == 0) {
        return brksize;
    }

    oldsize = brksize;
    newsize = brksize + incr;

    /* Would the address wrap around ? */
    if (incr > 0 && newsize < oldsize || incr < 0 && newsize > oldsize)
        return (void *) -1;

    if (brk(newsize) == 0)
        return oldsize;
    else
        return (void *) -1;
}

/* end of sbrk.c */
