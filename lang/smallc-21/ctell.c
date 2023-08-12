#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
extern int Ufcbptr[], Uchrpos[];
/*
** Return offset to current 128-byte record.
*/
ctell(fd) int fd; {
  int *rrn;
  if(!Umode(fd) || isatty(fd)) return (-1);
  rrn=Ufcbptr[fd]+RRNOFF;
  return (*rrn);
  }
/*
** Return offset to next character in current buffer.
*/
ctellc(fd) int fd; {
  return (Uchrpos[fd]);
  }

