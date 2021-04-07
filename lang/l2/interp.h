/*      Languages & Processors
**
**      interp.h  - L2 machine language interpreter
**
**      Nick Andrew, 8425464    (zeta@amdahl)
**
*/

#include "compiler.h"

/*      String table. */

extern char   strtabl[];

/* The function descriptor table */
extern struct functb functabl[];

extern  FILE *f_asm;
extern  FILE *f_debug;
extern  int  debug;

extern  void loadmem(void);
extern  int execute(void);
