/*       Languages & Processors
**
**       compiler.h - L2 Compiler header
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/

FILE *f_asm,           /* Asm source output */
     *f_debug;         /* debugging output (optional) */


#define TRUE              1
#define FALSE             0

/* the self defining goal */

#define EMPTY             90

/* The goal and opcode stacks */

#define MAXGLSTK          100
#define MAXOPSTK          100

int     goalstack[MAXGLSTK],
        opstack[MAXOPSTK],
        goalsp, opsp;

/* The returned values from LA */

int     cclass, ccode, clevel, cerror;

/* Other miscellany */

int     argcount,
        lareason,
        needtoken,
        errflag,
        goal,
        debug = 0,
        location;

/* The function descriptor table */

#define MAXFUNCS        30

struct functb {
    int     startloc;
    int     nparam;
    int     nlocal;
    int     flevel;
} functabl[MAXFUNCS];


/*  The syntax graph / goal table */

#define NUMGOALS        100

int   alt[NUMGOALS],
      def[NUMGOALS],
      act[NUMGOALS],
      suc[NUMGOALS];


/*  The machine code output buffer */

#define OUTBUF          1000

int   outbuf[OUTBUF];

/*  The assembly language definition  */

char *asmtab[31] = {
    "-----",
    "+",
    "-",
    "*",
    "/",
    "=",
    "<>",
    "<",
    "<=",
    ">",
    ">=",
    ":=",
    "or",
    "and",
    "return",
    "  +",
    "  -",
    "stop",
    "crash",
    "read",
    "write",
    "ws",
    "wn",
    "gif",
    "go",
    "isp",
    "call",
    "isb",
    "rs",
    "rn",
    "start"      };

extern FILE *f_in, *f_out;
extern int  currlevel;
extern int  errorfound;
