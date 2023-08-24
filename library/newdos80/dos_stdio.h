/* dos_stdio.h - Definitions and data types for dos_stdio
*/

#ifndef _DOS_STDIO_H_
#define _DOS_STDIO_H_

struct open_file {
  char flag;
  char *buf;
  union dos_fcb *fcbptr;
};

#endif /* _DOS_STDIO_H_ */
