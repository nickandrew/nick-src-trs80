/* @(#) sbrk.c 17 Jun 90 - Implement the sbrk(incr) system call */

extern	char	*brksize;

char	*sbrk(incr)
int	incr;
{
	char	*newsize,
		*oldsize;

	oldsize = brksize;
	newsize = brksize + incr;

	/* Does the address space wrap around? */
	if (incr > 0 && newsize < oldsize || incr < 0 && newsize > oldsize)
		return -1;

	if (brk(newsize) == 0)
		return oldsize;
	else
		return -1;
}

/* end of sbrk.c */
