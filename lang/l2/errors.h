/*       Languages & Processors
**
**       errors.h - Some error handling routines
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/



extern  int  linepos;                /* for the error position */
extern  FILE *f_list;                /* for messages */

int     errorfound = 0;
