/* #(@) malloct.c - 17 Jun 90 - test version of malloc library */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BRKSIZE		1024
#define	PTRSIZE		2

#define Align(x,a) (((x) + (a - 1)) & ~(int)(a - 1))
#define NextSlot	(* (char **) ((p) - PTRSIZE))
#define NextFree	(* (char **) (p))

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

// Functions defined in this file
unsigned int align(char *x, int a);
char *nextslot(char **p);
char *nextfree(char **p);
void snextslot(char **p, char *value);
void snextfree(char **p, char *value);

char *_bottom, *_top, *_empty;

int grow(unsigned int len)
{
    char *p;

    p = (char *) align(_top + len, BRKSIZE);
    if (p < _top || brk(p) != 0)
        return 0;
    snextslot(_top, p);
    snextslot(p, 0);
    free(_top);
    _top = p;
    return 1;
}

void *malloc(size_t size)
{
    char *prev, *p, *next, *new;
    unsigned len, ntries;

    /* avoid slots less than 2*PTRSIZE */
    if (size == 0)
        size = PTRSIZE;

    for (ntries = 0; ntries < 2; ntries++) {
        if ((len = Align(size, PTRSIZE) + PTRSIZE) < 2 * PTRSIZE)
            return 0;           /* overflow */

        if (_bottom == 0) {
            if ((p = sbrk(2 * PTRSIZE)) == (char *) -1)
                return 0;
            p = (char *) align(p, PTRSIZE);
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

void *realloc(char *oldfix, size_t size)
{
    char *prev, *p, *next, *new;
    unsigned len, n;

    char *old;

    old = oldfix;

    if (size > -2 * PTRSIZE)
        return 0;
    len = Align(size, PTRSIZE) + PTRSIZE;
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

void *calloc(size_t n, size_t size)
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

void free(void *pfix)
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

/* Align a pointer (x) to a size (a). A is a power of 2. */

unsigned int align(char *x, int a)
{
    return ((int)x + (a - 1)) & ~(a - 1);
}

char *nextslot(char **p)
{
    return (*(p - PTRSIZE));
}

char *nextfree(char **p)
{
    return *p;
}

void snextslot(char **p, char *value)
{
    *(p - PTRSIZE) = value;
}

void snextfree(char **p, char *value)
{
    *p = value;
}

/* end of malloc.c */
