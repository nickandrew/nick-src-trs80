/*
**      Small-C compiler ... type declaration parser
*/

#include <stdio.h>
#include "cc.h"

#define ENDTYPE 0
#define PTR     10
#define OPENBR  11

declparse(tarray, kptr, unbound, chkglb, class)
char tarray[];
int *kptr, unbound, chkglb, class;

{
    int k, l, r, ar, realfunc;
    int arrays[HIER_LEN];
    char left[8], *ptr, *findglb();

    l = r = realfunc = ar = 0;
    k = 1;

    for (;;) {
        if (l == 8)
            error("Declaration too complex");
        if (match("*")) {
            left[l++] = PTR;
        } else if (match("(")) {
            left[l++] = OPENBR;
        } else
            break;
    }

    if (symname(ssname, YES) == 0) {
        fprintf(stderr, "declparse: %s\n", ssname);
        illname();
    }

    for (;;) {
        if (r == HIER_LEN)
            error("Declaration too complex");
        if (match("[")) {
            k = needsub();
            tarray[r++] = ARRAY;
            arrays[ar++] = k;
        } else if (match("(")) {
            tarray[r++] = FUNCTION;
            if (class == EXTERNAL || class == AUTOMATIC || tarray[0] != FUNCTION        /* as in ptr to func */
                || realfunc) {
                if (match(")") == 0)
                    error("Cannot specify params here");
            } else {
                getformals();
                realfunc = 1;   /* a non-external function */
            }

        } else if (l == 0) {
            break;              /* May be followed by formal parameter */
            /* declarations if a "real function". If not, */
            /* then it must be end of statement           */

        } else if (left[l - 1] == PTR) {
            tarray[r++] = POINTER;
            --l;
        } else if (match(")")) {
            --l;                /* left[l-1] MUST BE a openbr. */
        } else
            error("Parentheses mismatch");
    }

    if (chkglb)
        if (ptr = findglb(ssname)) {
            if (ptr[CLASS] != EXTERNAL
                && class != EXTERNAL && (ptr[IDENT] != FUNCTION || tarray[0] != FUNCTION)) {

                fprintf(stderr, "Multiple non-external defn\n");
                multidef(ssname);
            }
        }

    if (r == HIER_LEN)
        error("Declaration too complex");
    else
        tarray[r] = VARIABLE;

    if (tarray[0] == VARIABLE)
        k = 1;
    else if (tarray[0] == FUNCTION)
        k = 0;                  /* ? */
    else if (tarray[0] == POINTER)
        k = 1;
    else if (tarray[0] == ARRAY)
        k = arrays[0];

    *kptr = k;
}

/*
**  getformals ... read in formal parameters from the function declaration
**      and make them the first entries in the local symbols table.
*/

getformals()
{
    char locname[NAMESIZE], loctype[HIER_LEN];
    char *findloc();

    locptr = STARTLOC;
    argstk = 0;
    loctype[0] = VARIABLE;

    while (match(")") == 0) {
        if (symname(locname, YES)) {
            if (findloc(locname) != NULL)
                multidef(locname);
            else {
                addsym(locname, loctype, 0, argstk, &locptr, AUTOMATIC);
                argstk = argstk + BPW;
            }
        } else {
            error("Invalid formal parameter name");
            junk();
        }

        blanks();

        if (streq(lptr, ")") == 0) {
            if (match(",") == 0)
                error("no comma");
        }

    }
    if (endst()) ;              /* merely tell the compiler it exists */
}
