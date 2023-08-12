/* @(#) sbrk.c 17 Jun 90 - Implement the sbrk(incr) system call */

extern char *brkaddr;
extern int brk(void *newaddr);

void *sbrk(int incr)
{
    char *newaddr, *oldaddr;

    if (incr == 0) {
        return brkaddr;
    }

    oldaddr = brkaddr;
    newaddr = brkaddr + incr;

    /* Would the address wrap around ? */
    if (incr > 0 && newaddr < oldaddr || incr < 0 && newaddr > oldaddr)
        return (void *) -1;

    if (brk(newaddr) == 0)
        return oldaddr;
    else
        return (void *) -1;
}

/* end of sbrk.c */
