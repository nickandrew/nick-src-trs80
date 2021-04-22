/*  fileio.c - fopen, fputchar etc
**
*/

#include "doscalls.h"
#include <stdio.h>
#include <string.h>

// Maximum number of concurrently open files. fds from 0 to 19.
// fd 0 = stdin, 1 = stdout, 2 = stderr
#define MAX_FILES 20
#define OF_FLAG_INUSE 1

struct open_file {
  char flag;
  union dos_fcb *fcbptr;
};

struct open_file fd_array[MAX_FILES];

int fileno(FILE *fp)
{
  // Sanity checking
  if (fp < fd_array || fp > (fd_array + MAX_FILES)) {
    return -1;
  }

  // Subtracting two pointers should return an integer
  return (struct open_file *) fp - fd_array;
}

void junk() {
  union dos_fcb bill;
  strcpy(bill.filename, "filename/txt\r"); // Terminate with \r or \x03
  // This can be done after opening
  bill.next_l = 0;
  bill.next_h = 0;
}

FILE *fopen(const char *pathname, const char *mode)
{
  pathname; mode; // Mark as used

  int fd = 0;

  for (fd = 0; fd < MAX_FILES; ++fd) {
    struct open_file *ofp = fd_array + fd;
    if (!ofp->flag & OF_FLAG_INUSE) {
      ofp->flag |= OF_FLAG_INUSE;
      return (FILE *) ofp;
    }
  }

  // Maximum number of files are open
  return (FILE *) 0;
}
