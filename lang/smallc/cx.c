/*
**      Small-C Compiler Version 2.2 - 01-Nov-87 - cx.c
**
**      Copyright 1982, J. E. Hendrix
**
*/

#include        "cc.h"

char
        optimize,               /* optimize output of staging buffer */
        monitor,                /* monitor function headers? */
        stage[STAGESIZE],       /* output staging buffer */
        symtab[SYMTBSZ],        /* symbol table */
        litq[LITABSZ],          /* literal pool */
        macn[MACNSIZE],         /* macro name buffer */
        macq[MACQSIZE],         /* macro string buffer */
        pline[LINESIZE],        /* parsing buffer */
        mline[LINESIZE],        /* macro buffer */
        swq[SWTABSZ],           /* switch queue */
        *line,                  /* points to pline or mline */
        *lptr,                  /* ptr to either */
        *glbptr,                /* ptrs to next entries */
        *locptr,                /* ptr to next local symbol */
        *stagenext,             /* next addr in stage */
        *stagelast,             /* last addr in stage */
        quote[2],               /* literal string for '"' */
        *cptr,                  /* work ptrs to any char buffer */
        *cptr2,
        *cptr3,
        typearr[HIER_LEN],      /* Type hierarchy array */
        msname[NAMESIZE],       /* macro symbol name array */
        ssname[NAMESIZE],       /* static symbol name array */
        xc,                     /* work char */
        *xcp;                   /* work char ptr */

int
        nogo,                   /* > 0 disables goto statements */
        noloc,                  /* > 0 disables block locals */
        opindex,                /* index to matched operator */
        opsize,                 /* size of operator in bytes */
        swactive,               /* true inside a switch */
        swdefault,              /* default label #, else 0 */
        *swnext,                /* address of next entry */
        *swend,                 /* address of last table entry */
        wq[WQTABSZ],            /* while queue */
        *wqptr,                 /* ptr to next entry */
        litptr,                 /* ptr to next entry */
        macptr,                 /* macro buffer index */
        pptr,                   /* ptr to parsing buffer */
        ch,                     /* current character of line being scanned */
        nch,                    /* next character of line being scanned */
        declared,            /* # of local bytes declared, else -1 when done */
        iflevel,                /* #if... nest level */
        skiplevel,              /* level at which #if... skipping started */
        nxtlab,                 /* next avail label */
        litlab,                 /* label # assigned to literal pool */
        csp,                    /* compiler relative stk ptr */
        argstk,                 /* function argument sp */
        argtop,
        ncmp,                   /* # open compound statements */
        errflag,                /* non-zero after 1st error in statement */
        eof,                    /* set non-zero after final input eof */
        files,                 /* non-zero if file list specified on cmd line*/
        filearg,                /* current file arg index */
        glbflag,                /* non-zero if internal globals */
        ctext,                  /* non-zero to intermix c-source */
        ccode,                  /* non-zero when parsing c-code */
                                /* zero when parsing assembly code */
        lastst,                 /* last executed statement type */
        xi,                     /* work int */
        *xip;                   /* work int ptr */

FILE
    *input,                  /* file pointer for input file */
    *input2,                 /* file pointer for "include" file */
    *output,                 /* file pointer for output file */
    *listfp;                 /* file pointer to list device */

int
    (*oper)(),          /* address of binary operator function */
    (*(op[16]))(),      /* function addresses of binary operators */
    (*(op2[16]))();     /* same for unsigned operators */
