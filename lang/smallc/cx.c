/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:34:26 - cx.c
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
	typearr[HIER_LEN],	/* Type hierarchy array */
        msname[NAMESIZE],       /* macro symbol name array */
        ssname[NAMESIZE];       /* static symbol name array */

int
        nogo,                   /* > 0 disables goto statements */
        noloc,                  /* > 0 disables block locals */
        op[16],                 /* function addresses of binary operators */
        op2[16],                /* same for unsigned operators */
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
        oper,                   /* address of binary operator function */
        ch,                     /* current character of line being scanned */
        nch,                    /* next character of line being scanned */
        declared,            /* # of local bytes declared, else -1 when done */
        iflevel,                /* #if... nest level */
        skiplevel,              /* level at which #if... skipping started */
        nxtlab,                 /* next avail label */
        litlab,                 /* label # assigned to literal pool */
        beglab,                 /* beginning label -- first function */
        csp,                    /* compiler relative stk ptr */
        argstk,                 /* function argument sp */
        argtop,
        ncmp,                   /* # open compound statements */
        errflag,                /* non-zero after 1st error in statement */
        eof,                    /* set non-zero after final input eof */
        input,                  /* fd # for input file */
        input2,                 /* fd # for "include" file */
        output,                 /* fd # for output file */
        files,                 /* non-zero if file list specified on cmd line*/
        filearg,                /* current file arg index */
        glbflag,                /* non-zero if internal globals */
        ctext,                  /* non-zero to intermix c-source */
        ccode,                  /* non-zero when parsing c-code */
                                /* zero when parsing assembly code */
        listfp,                 /* file pointer to list device */
        lastst,                 /* last executed statement type */
        *iptr;                  /* work ptr to any int buffer */

