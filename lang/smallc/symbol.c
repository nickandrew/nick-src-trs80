/*   Small-C Compiler - symbol table functions
**
*/

#include <stdio.h>
#include <stdlib.h>

#include "cc.h"

/* Return a 16-bit hash of a symbol name */

hash(sname)
char *sname;
{

    xi = 0;

    while (xc = *sname++)
        xi = (xi << 1) + xc;

    return (xi);
}

/*
**      search for symbol match
**
**      on return cptr points to slot found or empty slot
*/

search(sname, buf, len, end, max, off)
char *sname, *buf, *end;
int len, max, off;
{

    cptr = cptr2 = buf + ((hash(sname) % (max - 1)) * len);

    while (*cptr != 0) {
        if (astreq(sname, cptr + off, NAMEMAX))
            return (1);

        if ((cptr = cptr + len) >= end)
            cptr = buf;

        if (cptr == cptr2) {
            cptr = NULL;
            return 0;
        }
    }

    return (0);
}

char *findglb(sname)
char *sname;
{

    if (search(sname, STARTGLB, SYMMAX, ENDGLB, NUMGLBS, NAME))
        return (cptr);

    return NULL;
}

char *findloc(sname)
char *sname;
{

    cptr = locptr;

    while (cptr > STARTLOC) {
        cptr = cptr - SYMMAX;

        if (astreq(sname, cptr + NAME, NAMEMAX))
            return (cptr);

    }

    return NULL;
}

char *addsym(sname, tarray, type, value, lgptrptr, class)
char *sname;
char tarray[];
int type;
int value;
char **lgptrptr;
int class;
{
    int i;
    char *s;

    if (lgptrptr == &glbptr) {
        if (cptr2 = findglb(sname)) {
            fprintf(stderr, "Addsym: %s already a global\n", sname);
            return (cptr2);
        }

        if (cptr == 0) {
            error("global symbol table overflow");
            return 0;
        }
    } else {
        if (locptr > (ENDLOC - SYMMAX)) {
            error("local symbol table overflow");
            exit(1);
        }

        if (*lgptrptr != locptr)
            fprintf(stderr, "Addsym: illegal lgptrptr\n");
        cptr = locptr;
    }

    for (i = 0; i < HIER_LEN; ++i) {
        cptr[IDENT + i] = tarray[i];
    }
    cptr[TYPE] = type;
    cptr[CLASS] = class;
    putint(value, cptr + OFFSET, OFFSIZE);
    cptr3 = cptr2 = cptr + NAME;

    while (an(*sname))
        *cptr2++ = *sname++;

    *cptr2 = 0;                 /* null terminate in symtab */
    if (lgptrptr == &locptr) {
        locptr = cptr + SYMMAX;
    }

    return cptr;
}

char *nextsym(entry)
char *entry;
{

    entry = entry + SYMMAX;

    return (entry);
}

/* dumpsym ... dump the symbol table */
dumpsym(flag)
int flag;
{
    FILE *st;
    char *cp;

    if (flag == 1) {
        char x;
        scanf(" %c", &x);
        if (x != 'y')
            return;
    }

    if ((st = fopen("symloc", "w")) == NULL)
        return;

    cp = STARTLOC;

    while (cp < ENDLOC)
        fputc(*(cp++), st);
    fclose(st);
    if ((st = fopen("symglb", "w")) == NULL)
        return;
    cp = STARTGLB;

    while (cp < ENDGLB)
        fputc(*(cp++), st);
    fclose(st);
}
