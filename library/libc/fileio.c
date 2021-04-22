/*  fileio.c - fopen, fputchar etc
**
*/

#include "doscalls.h"

#include <stdio.h>
#include <stdlib.h>
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

FILE *fopen(const char *pathname, const char *mode)
{
  pathname; mode; // Mark as used

  int fd = 0;
  int rc;

  printf("fopen(%s, %s)\n", pathname, mode);

  // Order of operations:
  // 1. Allocate and prepare an FCB
  // 1. DOS open the FCB

  union dos_fcb *fcb_ptr;
  fcb_ptr = malloc(sizeof(*fcb_ptr));
  rc = dos_file_extract(pathname, fcb_ptr);
  if (rc) {
    // errno = rc;
    free(fcb_ptr);
    return NULL;
  }

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
