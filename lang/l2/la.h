/*      Languages & Processors
**
**      la.h  - Lexical analyser header
**
**      Nick Andrew, 8425464    (zeta@amdahl)
**
*/

/* Max discrete hash values 0..255 */

#define MAXHASH     256

/* Max number of simultaneous descriptors */

#define MAXDESC     50

/* Max names used within one program */

#define MAXNAME     100

/* Max length of all strings used */

#define MAXSTR      2000

/* Max different numbers in one program */

#define MAXNUMB     200


/* maximum symbol length for name table */

#define SYMMAX      80

extern char namestr[];
extern int  code;
extern FILE *f_list;
extern char string[];
extern int  number;
