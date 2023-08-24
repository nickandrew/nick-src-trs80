/* dos_stdio_fgets.c - implement fgets()
**
** It's separate from the rest of dos_stdio.c to avoid a dependency
** on rom_kbline() in dos_stdio.c
*/

#include <stdio.h>
#include <string.h>
#include <rom.h>

#include "dos_stdio.h"

// TODO: This needs to be checked for accuracy
char *fgets(char *s, int size, FILE *stream) {
  if (feof(stream)) {
    return NULL;
  }

  // FIXME: Hack for reading from stdin.
  struct open_file *ofp = (struct open_file *) stream;
  if (ofp->fcbptr == (void *) 0x4015) {
    int rc = rom_kbline(s, size - 1);
    if (rc < 0) {
      return NULL;
    }
    strcat(s, "\n");
    return s;
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
