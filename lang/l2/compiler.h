/*       Languages & Processors
**
**       compiler.h - L2 Compiler header
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/

/* Protect against multiple inclusion */
#ifndef _COMPILER_H_
#define _COMPILER_H_

#define TRUE              1
#define FALSE             0

/* the self defining goal */

#define EMPTY             90

/* The goal and opcode stacks */

#define MAXGLSTK          100
#define MAXOPSTK          100

/* The function descriptor table */

#define MAXFUNCS        30

struct functb {
    int     startloc;
    int     nparam;
    int     nlocal;
    int     flevel;
};

/*  The syntax graph / goal table */

#define NUMGOALS        100

/*  The machine code output buffer */

#define OUTBUF          1000

extern int  currlevel;

extern void compile(void);
extern void l2init(void);
extern void outflush(void);

#endif /* ifndef _COMPILER_H_ */
