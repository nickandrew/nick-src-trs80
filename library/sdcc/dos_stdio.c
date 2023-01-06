/*  dos_stdio.c - stdio functions: fopen, fputc etc.
**
*/

#include "doscalls.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Maximum number of concurrently open files. fds from 0 to 19.
// fd 0 = stdin, 1 = stdout, 2 = stderr
#define MAX_FILES 20

// open_file slot is in use
#define OF_FLAG_INUSE 1
// It is a device, not a disk file (affects fclose)
#define OF_FLAG_DCB   2

static const int sector_size = 256;  // Fixed by DOS

// Mode bits
#define MODE_READ 2
#define MODE_WRITE 4
#define MODE_APPEND 8
#define MODE_EXISTING 16

struct open_file {
  char flag;
  char *buf;
  union dos_fcb *fcbptr;
};

// TODO Make these do something
FILE *stdin = (FILE *) 0;
FILE *stdout = (FILE *) 0;
FILE *stderr = (FILE *) 0;

struct open_file fd_array[MAX_FILES];

static int parse_mode(const char *mode) {
  int mode_bits = 0;
  if (mode[0] == 'r') {
    mode_bits = MODE_READ | MODE_EXISTING;
    if (mode[1] == '+') {
      mode_bits |= MODE_WRITE;
    }
  }
  else if (mode[0] == 'w') {
    mode_bits = MODE_WRITE;
    if (mode[1] == '+') {
      mode_bits |= MODE_READ;
    }
  }
  else if (mode[0] == 'a') {
    mode_bits = MODE_WRITE | MODE_APPEND;
    if (mode[1] == '+') {
      mode_bits |= MODE_READ;
    }
  }

  return mode_bits;
}


int fileno(FILE *fp)
{
  // Sanity checking
  if (fp < fd_array || fp > (fd_array + MAX_FILES)) {
    return -1;
  }

  // Subtracting two pointers should return an integer
  return (struct open_file *) fp - fd_array;
}

int _openfcb(const char *pathname, const char *mode, union dos_fcb *buf) {
  int mode_bits = parse_mode(mode);
  // Ignore terminating the pathname with \r for the moment
  int rc = dos_file_extract(pathname, buf);
  if (rc) {
    return rc;
  }
  char *buffer = malloc(256);
  if (!buffer) {
    // Error exit
    return 1;
  }

  if (mode_bits & MODE_EXISTING) {
    // Urk need a 256-byte buffer for the file
    rc = dos_file_open_ex(buf, buffer, 0);
    // Reclaim buffer
    return rc;
  }
  else {
    // Urk need a 256-byte buffer for the file
    rc = dos_file_open_new(buf, buffer, 0);
    return rc;
  }
}

int fclose(FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;

  if (!ofp->flag & OF_FLAG_INUSE) {
    // errno = ?
    return -1;
  }

  if (ofp->flag & OF_FLAG_DCB) {
    // It's a device, not a file.
    // There's no explicit close action, just free the slot.
    ofp->flag = 0;
    ofp->buf = NULL;
    ofp->fcbptr = NULL;
    return 0;
  }

  dos_file_close(ofp->fcbptr);
  free(ofp->fcbptr);
  free(ofp->buf);
  ofp->buf = NULL;
  ofp->flag = 0;

  return 0;
}

int feof(FILE *stream) {
  stream;
  // TODO
  return 0;
}

int fgetc(FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;
  int rc = dos_read_byte(ofp->fcbptr);
  return rc;
}

// TODO: This needs to be checked for accuracy
char *fgets(char *s, int size, FILE *stream) {
  if (feof(stream)) {
    return NULL;
  }

  char *buf = s;
  int c;

  while (size > 1) {
    c = fgetc(stream);
    if (c == EOF) {
      if (buf == s) {
        return NULL;
      }
      else {
        *buf = '\0';
        return s;
      }
    }

    *buf++ = c;
    if (c == '\n') {
      *buf++ = '\0';
      return s;
    }
    size--;
  }

  *buf = '\0';
  return s;
}

// mode can be 'r', 'w', 'a', 'r+', 'w+', 'a+' and possible trailing 'b'
FILE *fopen(const char *pathname, const char *mode)
{
  int fd = 0;
  int rc;
  char mode_char = mode[0];

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

  // TODO: Set FCB access level 5 (READ) in FCB

  if (mode_char == 'a') {
    rc = dos_file_seek_eof(fcb_ptr);
    if (rc) {
      // errno = rc;
      free(fcb_ptr);
      free(buf);
      return NULL;
    }
  }

  // Set EOF to NEXT only on successful writes which result in NEXT
  // exceeding EOF.
  fcb_ptr->bits2 |= 1<<6;

  // Find an available free file descriptor
  for (fd = 0; fd < MAX_FILES; ++fd) {
    struct open_file *ofp = fd_array + fd;
    if (!(ofp->flag & OF_FLAG_INUSE)) {
      ofp->flag |= OF_FLAG_INUSE;
      ofp->buf = buf;
      ofp->fcbptr = fcb_ptr;
      return (FILE *) ofp;
    }
  }

  // Maximum number of files are open
  free(fcb_ptr);
  free(buf);
  dos_mess_pr("fopen() maximum number of files are open\r");
  return NULL;
}

/* fopen_dcb() ... Associate an open file with an existing Device Control Block
**
**  Call this 3 times at program initialization time, to associate
**  file descriptors 0, 1, 2 with stdin, stdout and stderr.
*/

FILE *fopen_dcb(void *ptr)
{
  unsigned int fd;

  // Find an available free file descriptor
  for (fd = 0; fd < MAX_FILES; ++fd) {
    struct open_file *ofp = fd_array + fd;
    if (!(ofp->flag & OF_FLAG_INUSE)) {
      ofp->flag |= OF_FLAG_INUSE | OF_FLAG_DCB;
      ofp->buf = (void *) 0;
      ofp->fcbptr = (union dos_fcb *) ptr;
      return (FILE *) ofp;
    }
  }

  // Maximum number of files are open
  return NULL;
}

int fputc(int c, FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;

  if (!ofp->flag & OF_FLAG_INUSE) {
    // errno = ?
    return -1;
  }

  int rc = dos_write_byte(ofp->fcbptr, c);
  if (rc) {
    // errno = ?
    return -1;
  }

  return 0;
}

int fputs(const char *s, FILE *stream) {
  while (*s) {
    fputc(*s, stream);
    s++;
  }

  return 0;
}

size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream) {
  ptr; size; nmemb; stream;
  // TODO
  return 0;
}

int fseek(FILE *stream, long offset, int whence) {
  struct open_file *ofp = (struct open_file *) stream;
  int rc;

  switch (whence)
  {
    case 1:
      offset += dos_file_next(ofp->fcbptr);
      break;
    case 2:
      offset += dos_file_eof(ofp->fcbptr);
  }

  rc = dos_file_seek_rba(ofp->fcbptr, offset);

  if (rc) {
    return -1;
  }

  return 0;
}

long ftell(FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;
  long rc = dos_file_next(ofp->fcbptr);
  return rc;
}

size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream) {
	size_t s;
  size_t ndone = 0;
  // Not sure why I had to do this to stop an error on the putc call
  const char *p = (const char *) ptr;

  if (size)
    while (ndone != nmemb) {
      s = size;
      do {
        putc(*p++, stream);
        // if (ferror(file)) return ndone;
      } while (--s);
      ++ndone;
    }

	return ndone;
}

int putc(int c, FILE *stream) {
  return fputc(c, stream);
}

void rewind(FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;
  dos_file_rewind(ofp->fcbptr);
}

static void output_char_file(char c, void *p)
{
  fputc(c, (FILE *) p);
}

int fprintf(FILE *fp, const char *format, ...)
{
  va_list arg;
  int i;

  va_start(arg, format);
  i = _print_format(output_char_file, (void *) fp, format, arg);
  va_end(arg);

  return i;
}
