#define NOCCARGC  /* no argument count passing */
#include stdio.h
extern Unextc[];
/*
** Put c back into file fd.
** Entry:  c = character to put back
**        fd = file descriptor
** Returns c if successful, else EOF.
*/
ungetc(c, fd) int c, fd; {
  if(!Umode(fd) || Unextc[fd]!=EOF || c==EOF) return (EOF);
  return (Unextc[fd] = c);
  }
