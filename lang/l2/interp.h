/*      Languages & Processors
**
**      interp.c  - L2 machine language interpreter
**
**      Nick Andrew, 8425464    (zeta@amdahl)
**
*/

int   data[1000],program[1000];
int   sp=0, sb, sb1, l, rv;
int   pc, level, st, fn, lalev;

/*      String table. */

extern char   strtabl[];

/*      Number table. */

extern struct numbtb  {
    int   numb;
    struct numbtb *leftptr;
    struct numbtb *rightptr;
} numbtabl[];


/* The function descriptor table */


extern struct functb {
    int     startloc;
    int     nparam;
    int     nlocal;
    int     flevel;
} functabl[];

extern  FILE *f_asm;
extern FILE *f_debug;
extern int  debug;
