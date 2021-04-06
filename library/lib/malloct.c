/* #(@) malloct.c - 17 Jun 90 - test version of malloc library */

#include <stdio.h>

#define BRKSIZE		1024
#define	PTRSIZE		2

/* Another Small-C shortcoming */
#define unsigned	int

/* A short explanation of the data structure and algorithms.
 * An area returned by malloc() is called a slot. Each slot
 * contains the number of bytes requested, but preceded by
 * an extra pointer to the next slot in memory.
 * '_bottom' and '_top' point to the first/last slot.
 * More memory is asked for using brk() and appended to top.
 * The list of free slots is maintained to keep malloc() fast.
 * '_empty' points the the first free slot. Free slots are
 * linked together by a pointer at the start of the
 * user visible part, so just after the next-slot pointer.
 * Free slots are merged together by free().
 */

extern char *sbrk();
extern int brk();

char *align();

char *_bottom, *_top, *_empty;

int grow(len)
unsigned len;
{
    char *p;

    p = align(_top + len, BRKSIZE);
    if (p < _top || brk(p) != 0)
        return 0;
    snextslot(_top, p);
    snextslot(p, 0);
    free(_top);
    _top = p;
    return 1;
}

char *malloc(size)
unsigned size;
{
    char *prev, *p, *next, *new;
    unsigned len, ntries;

    /* avoid slots less than 2*PTRSIZE */
    if (size == 0)
        size = PTRSIZE;

    for (ntries = 0; ntries < 2; ntries++) {
        if ((len = align(size, PTRSIZE) + PTRSIZE) < 2 * PTRSIZE)
            return 0;           /* overflow */

        if (_bottom == 0) {
            if ((p = sbrk(2 * PTRSIZE)) == -1)
                return 0;
            p = align(p, PTRSIZE);
            /* sbrk amount stops overflow */
            p += PTRSIZE;
            _top = _bottom = p;
            snextslot(p, 0);
        }

        prev = 0;
        for (p = _empty; p != 0; p = nextfree(p)) {
            next = nextslot(p);
            new = p + len;      /* easily overflows!! */
            if (new > next || new <= p) {
                prev = p;
                continue;       /* too small */
            }
            if (new + PTRSIZE < next) {
                /* too big, so split */
                /* + PTRSIZE avoids tiny slots on freelist */
                /* space above next */
                snextslot(new, next);
                snextslot(p, new);
                snextfree(new, nextfree(p));
                snextfree(p, new);
            }
            if (prev)
                snextfree(prev, nextfree(p));
            else
                _empty = nextfree(p);
            return p;
        }

        if (grow(len) == 0)
            break;
    }

    return NULL;
}

char *realloc(oldfix, size)
char *oldfix;
unsigned size;
{
    char *prev, *p, *next, *new;
    unsigned len, n;

    char *old;

    old = oldfix;

    if (size > -2 * PTRSIZE)
        return 0;
    len = align(size, PTRSIZE) + PTRSIZE;
    next = nextslot(old);
    n = (next - old);           /* old length */
    /* Extend old if there is any free space just behind it */
    prev = 0;
    for (p = _empty; p != 0; p = nextfree(p)) {
        if (p > next)
            break;
        if (p == next) {        /* 'next' is a free slot: merge */
            snextslot(old, nextslot(p));
            if (prev)
                snextfree(prev, nextfree(p));
            else
                _empty = nextfree(p);
            next = nextslot(old);
            break;
        }
        prev = p;
    }
    new = old + len;            /* easily overflows!! */

    /* Can we use the old, possibly extended slot? */
    if (new <= next && new >= old) {    /* it does fit */
        if (new + PTRSIZE < next) {     /* too big, so split */
            /* + PTRSIZE avoids tiny slots on free list */

            snextslot(new, next);
            snextslot(old, new);
            free(new);
        }
        return old;
    }

    if ((new = malloc(size)) == NULL)   /* it didn't fit */
        return NULL;
    memcpy(new, old, n);        /* n < size */
    free(old);
    return new;
}

char *calloc(n, size)
unsigned n, size;
{
    char *p, *cp;

    n *= size;
    cp = malloc(n);
    if (cp == 0)
        return 0;
    for (p = cp; n-- != 0;)
        *p++ = '\0';
    return cp;
}

free(pfix)
int *pfix;
{
    char *prev, *next;
    char *p;

    p = pfix;
    prev = 0;
    for (next = _empty; next != 0; next = nextfree(next)) {
        if (p < next)
            break;
        prev = next;
    }

    snextfree(p, next);

    if (prev)
        snextfree(prev, p);
    else
        _empty = p;

    if (next) {
        if (nextslot(p) == next) {
            /* merge p and next */
            snextslot(p, nextslot(next));
            snextfree(p, nextfree(next));
        }
    }

    if (prev) {
        if (nextslot(prev) == p) {
            /* merge prev and p */
            snextslot(prev, nextslot(p));
            snextfree(prev, nextfree(p));
        }
    }
}

#define Align		(((x) + (a - 1)) & ~(int)(a - 1))
#define NextSlot	(* (char **) ((p) - PTRSIZE))
#define NextFree	(* (char **) (p))

/* Align a pointer (x) to a size (a). A is a power of 2. */

align(x, a)
int x;                          /* Just think of it as an int for convenience */
int a;
{
    return (x + (a - 1)) & ~(a - 1);
}

nextslot(p)
char **p;
{
    return (*(p - PTRSIZE));
}

nextfree(p)
char **p;
{
    return *p;
}

snextslot(p, value)
int *p;
int value;
{
    *(p - PTRSIZE) = value;
}

snextfree(p, value)
int *p;
int value;
{
    *p = value;
}

/* end of malloc.c */
