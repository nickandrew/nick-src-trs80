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
#define OF_FLAG_INUSE 1

// Mode bits
#define MODE_READ 2
#define MODE_WRITE 4
#define MODE_APPEND 8
#define MODE_EXISTING 16

struct open_file {
  char flag;
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

void junk() {
  union dos_fcb bill;
  strcpy(bill.filename, "filename/txt\r"); // Terminate with \r or \x03
  // This can be done after opening
  bill.next_l = 0;
  bill.next_h = 0;
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
  stream;
  // TODO
  return 0;
}

int feof(FILE *stream) {
  stream;
  // TODO
  return 0;
}

int fgetc(FILE *stream) {
  stream;
  // TODO
  return EOF;
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

int fprintf(FILE *stream, const char *format, ...) {
  stream; format;
  // TODO
  return EOF;
}

int fputc(int c, FILE *stream) {
  c; stream;
  // TODO
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
  stream; offset; whence;
  // TODO
  return 0;
}

long ftell(FILE *stream) {
  stream; // Mark as used
  return 0;
}

size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream) {
	ptr; size; nmemb; stream;
	// TODO
	return 0;
}

int getchar(void) {
  // TODO
  return EOF;
}

int putc(int c, FILE *stream) {
  return fputc(c, stream);
}

void rewind(FILE *stream) {
  stream;
  // TODO
}
