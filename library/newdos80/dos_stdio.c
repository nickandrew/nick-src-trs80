/*  dos_stdio.c - stdio functions: fopen, fputc etc.
**
*/

#include "doscalls.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dos_stdio.h"

// Maximum number of concurrently open files. fds from 0 to 19.
// fd 0 = stdin, 1 = stdout, 2 = stderr
#define MAX_FILES 20

// open_file slot is in use
#define OF_FLAG_INUSE 1
// It is a device, not a disk file (affects fclose)
#define OF_FLAG_DCB   2
// End Of File has been seen on this open file
#define OF_FLAG_EOF   4
// Error marker
#define OF_FLAG_ERROR 8

static const int sector_size = 256;  // Fixed by DOS

// Mode bits
#define MODE_READ 2
#define MODE_WRITE 4
#define MODE_APPEND 8
#define MODE_EXISTING 16

// These are initialized by _init_stdio()
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


void clearerr(FILE *fp) {
  struct open_file *ofp = (struct open_file *) fp;

  ofp->flag &= ~(OF_FLAG_EOF | OF_FLAG_ERROR);
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
  struct open_file *ofp = (struct open_file *) stream;

  if (ofp->flag & OF_FLAG_EOF) {
    return 1;
  }
  return 0;
}

int ferror(FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;

  if (ofp->flag & OF_FLAG_ERROR) {
    return 1;
  }
  return 0;
}

int fgetc(FILE *stream) {
  struct open_file *ofp = (struct open_file *) stream;
  int rc;

  // FIXME: Hack for reading from stdin.
  // I really need to implement cooked mode, to read a line of text
  // at a time
  if (ofp->fcbptr == (void *) 0x4015) {
    do {
      rc = dos_read_byte(ofp->fcbptr);
    } while (rc == 0);
    rc &= 0xff;
    if (rc == 0x0d) {
      rc = 0x0a;
    }
    // ESC can mean EOF for the moment
    if (rc == 1) {
      ofp->flag |= OF_FLAG_EOF;
      return EOF;
    }
    return rc;
  }

  rc = dos_read_byte(ofp->fcbptr);

  if (rc < 0) {
    // errno = ?
    ofp->flag |= OF_FLAG_EOF;
    return EOF;
  }
  return rc;
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
      ofp->flag = OF_FLAG_INUSE;
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
      ofp->flag = OF_FLAG_INUSE | OF_FLAG_DCB;
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
    ofp->flag |= OF_FLAG_ERROR;
    return -1;
  }

  return c & 0xff;
}

int fputs(const char *s, FILE *stream) {
  while (*s) {
    if (fputc(*s, stream) == EOF)
      return EOF;
    s++;
  }

  return 0;
}

/* fread(ptr, size, nmemb, stream) ... Read 'nmemb' items of size
** 'size' from 'stream'. Return the number of items successfully
** read.
*/

size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream) {
  size_t s;
  size_t ndone = 0;
  int ch;
  char *p = (char *) ptr;

  if (size) {
    while (ndone < nmemb) {
      s = size;
      do {
        ch = fgetc(stream);
        if (ch == EOF) return ndone;
        *p++ = ch;
      } while (--s);
      ++ndone;
    }
  }

  return ndone;
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

  ofp->flag &= ~OF_FLAG_EOF;
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
  // Cast to (char *) because arithmetic on (void *) is not allowed
  const char *p = (const char *) ptr;

  if (size)
    while (ndone != nmemb) {
      s = size;
      do {
        putc(*p++, stream);
      } while (--s);

      if (ferror(stream)) {
        return ndone;
      }
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
  ofp->flag &= ~OF_FLAG_EOF;
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

/*  _init_stdio() ...
**
**  This runs just after global/static initialization.
**  It sets up stdin/stdout/stderr for use before _main starts.
*/

void _init_stdio(void)
{
  stdin = fopen_dcb((void *) 0x4015);
  stdout = fopen_dcb((void *) 0x401d);
  stderr = fopen_dcb((void *) 0x4025);

  // Run this function at program start time
  __asm
  .area _GSINIT
  call  __init_stdio
  .area _CODE
  __endasm;
}
