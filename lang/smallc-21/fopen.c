#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
/*
** Open file indicated by fn.
** Entry: fn   = Null-terminated CP/M file name.
**               May be prefixed by letter of dirve.
**               May be just CON:, RDR:, PUN:, or LST:.
**        mode = "a"  - append
**               "r"  - read
**               "w"  - write
**               "a+" - append update
**               "r+" - read   update
**               "w+" - write  update
** Returns a file descriptor on success, else NULL.
*/
fopen(fn, mode) char *fn, *mode; {
  int fd;
  fd = 0; /* skip stdin (= error return) */
  while(++fd < MAXFILES) {
    if(Umode(fd) == NULL) {
      if(Uopen(fn, mode, fd)!=ERR) return (fd);
      break;
      }
    }
  return (NULL);
  }

