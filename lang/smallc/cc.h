/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:34:10 - cc.h
**
**      Copyright 1982, J. E. Hendrix
**
**      Macro Definitions
*/

#include        <stdio.h>

/*
**      machine dependent parameters
*/

#define BPW     2       /* bytes per word */
#define LBPW    1       /* log2(BPW) */
#define SBPC    1       /* stack bytes per character */

/*
**      symbol table format
*/

#define IDENT   0
#define TYPE    1
#define CLASS   2
#define OFFSET  3
#define NAME    5
#define OFFSIZE (NAME-OFFSET)
#define SYMAVG  10
#define SYMMAX  14

/*
**      symbol table parameters
*/

#define NUMLOCS         100
#define STARTLOC        symtab
#define ENDLOC          (symtab + (NUMLOCS * SYMAVG))
#define NUMGLBS         500
#define STARTGLB        ENDLOC
#define ENDGLB          (ENDLOC + ((NUMGLBS - 1) * SYMMAX))
#define SYMTBSZ         8000    /* NUMLOCS * SYMAVG + NUMGLBS * SYMMAX */

/*
**      System wide name size (for symbols)
*/

#define NAMESIZE        9
#define NAMEMAX         8

/*
**      possible entries for "IDENT"
*/

#define LABEL           0
#define VARIABLE        1
#define ARRAY           2
#define POINTER         3
#define FUNCTION        4

/*
**      possible entries for "TYPE"
**
**      low order 2 bits make type unique within length
**      high order bits give length of object
*/

/*      LABEL           0 */
#define CCHAR           (1 << 2)
#define CINT            (BPW << 2)

/*
**      possible entries for "CLASS"
*/

/*      LABEL           0 */
#define STATIC          1
#define AUTOMATIC       2
#define EXTERNAL        3

/*
**      "switch" table
*/

#define SWSIZ           (2 * BPW)
#define SWTABSZ         (25 * SWSIZ)

/*
**      "while" statement queue
*/

#define WQTABSZ         30
#define WQSIZ           3
#define WQMAX           (wq + WQTABSZ - WQSIZ)

/*
**      entry offsets in while queue
*/

#define WQSP            0
#define WQLOOP          1
#define WQEXIT          2

/*
**      literal pool
*/

#define LITABSZ         700
#define LITMAX          (LITABSZ - 1)

/*
**      input line
*/

#define LINEMAX         80
#define LINESIZE        81

/*
**      output staging buffer size
*/

#define STAGESIZE       800
#define STAGELIMIT      (STAGESIZE - 1)

/*
**      macro (define) pool
*/

#define MACNBR          90
#define MACNSIZE        990     /* 90 * (NAMESIZE + 2) */
#define MACNEND         (macn + MACNSIZE)
#define MACQSIZE        450
#define MACMAX          (MACQSIZE - 1)

/*
**      statement types
*/

#define STIF            1
#define STWHILE         2
#define STRETURN        3
#define STBREAK         4
#define STCONT          5
#define STASM           6
#define STEXPR          7
#define STDO            8
#define STFOR           9
#define STSWITCH        10
#define STCASE          11
#define STDEF           12
#define STGOTO          13

#define YES             1
#define NO              0

/*
**      variables
*/

extern char
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
        msname[NAMESIZE],       /* macro symbol name array */
        ssname[NAMESIZE];       /* static symbol name array */

extern int
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
        declared,               /* # of local bytes declared, else -1 when done */
        iflevel,                /* #if... nest level */
        skiplevel,              /* level at which #if... skipping started */
        func1,                  /* true for first function */
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
        files,                  /* non-zero if file list specified on cmd line */
        filearg,                /* current file arg index */
        glbflag,                /* non-zero if internal globals */
        ctext,                  /* non-zero to intermix c-source */
        ccode,                  /* non-zero when parsing c-code */
                                /* zero when parsing assembly code */
        listfp,                 /* file pointer to list device */
        lastst,                 /* last executed statement type */
        *iptr;                  /* work ptr to any int buffer */

extern int
        heir1(), heir3(), heir4(), heir5(), heir6(), heir7(),
        heir8(), heir9(), heir10(), heir11(), heir12(), heir13(),
        heir14();

extern int
        add(), and(), asl(), asr(), div(), eq(), ge(), gt(),
        le(), lt(), mod(), mult(), ne(), or(), sub(), uge(),
        ugt(), ule(), ult(), xor();

extern int
        dec(), eq0(), ge0(), gt0(), inc(), le0(), lt0(), ne0(), ult0();

