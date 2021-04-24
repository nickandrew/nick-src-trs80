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
#define OF_FLAG_INUSE  1
#define OF_FLAG_DEVICE 2

static const int sector_size = 256;  // Fixed by DOS

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
  char mode_char = mode[0];

  printf("fopen(%s, %s)\n", pathname, mode);

  if (mode_char != 'a' && mode_char != 'r' && mode_char != 'w') {
    // errno = ??
    return NULL;
  }

  // Order of operations:
  // 1. Allocate and prepare an FCB
  // 2. Allocate a 256-byte buffer
  // 3. DOS open the FCB
  // 4. If Append mode, position the FCB
  // 5. Find a free file descriptor and update it
  // 6. Return a pointer to the file descriptor

  union dos_fcb *fcb_ptr;

  fcb_ptr = malloc(sizeof(*fcb_ptr));
  if (!fcb_ptr) {
    // Out of memory
    // errno = ??
    return NULL;
  }

  rc = dos_file_extract(pathname, fcb_ptr);
  if (rc) {
    // errno = rc;
    free(fcb_ptr);
    return NULL;
  }

  char *buf = malloc(sector_size);
  if (!buf) {
    // Out of memory
    // errno = ??
    free(fcb_ptr);
    return NULL;
  }

  if (mode_char == 'r') {
    rc = dos_file_open_ex(fcb_ptr, buf, sector_size);
  } else {
    rc = dos_file_open_new(fcb_ptr, buf, sector_size);
  }

  if (rc) {
    // errno = rc;
    free(fcb_ptr);
    free(buf);
    return NULL;
  }

  if (mode_char == 'a') {
    rc = dos_file_seek_eof(fcb_ptr);
    if (rc) {
      // errno = rc;
      free(fcb_ptr);
      free(buf);
      return NULL;
    }
  }

  // Ensure writes do not bugger eof
  fcb_ptr->bits1 |= 1<<6;

  for (fd = 0; fd < MAX_FILES; ++fd) {
    struct open_file *ofp = fd_array + fd;
    if (!(ofp->flag & OF_FLAG_INUSE)) {
      ofp->flag |= OF_FLAG_INUSE;
      ofp->fcbptr = fcb_ptr;
      return (FILE *) ofp;
    }
  }

  // Maximum number of files are open
  free(fcb_ptr);
  free(buf);
  return NULL;
}
