/* sys/types.h
** sdcc type sizes:
**   char  unsigned  8 bits
**   short signed   16 bits
**   int   signed   16 bits
**   long  signed   32 bits
**   long long signed 64 bits
**   float signed   4 bytes
**   pointer 1-4 bytes
**
**   Helped out by: https://pubs.opengroup.org/onlinepubs/009696799/basedefs/sys/types.h.html
*/

typedef int           mode_t;
typedef int           intptr_t;
typedef long          off_t;
typedef unsigned int  size_t;
typedef int           ssize_t;
typedef int           time_t;

/* Maximum value of a signed size */
#define SSIZE_MAX  32767
