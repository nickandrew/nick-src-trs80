#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
extern int Ufcbptr[], Uchrpos[], Unextc[];
/*
** Position fd to the 128-byte record indicated by
** "offset" relative to the point indicated by "base."
** 
**     BASE     OFFSET-RELATIVE-TO
**       0      first record
**       1      current record
**       2      end of file (last record + 1)
**
** Returns NULL on success, else EOF.
*/
cseek(fd, offset, base) int fd, offset, base; {
  int oldrrn, *rrn;
  if(!Umode(fd) || isatty(fd) || fflush(fd)) return (EOF);
  rrn = Ufcbptr[fd] + RRNOFF;
  oldrrn = *rrn;
  switch (base) {
    case 2: Ubdos(POSEND, Ufcbptr[fd]);
    case 1: *rrn += offset; break;
    case 0: *rrn = offset;  break;
    default: return (EOF);
    }
  if(Usector(fd,  RDRND)) {
    *rrn = oldrrn;
    return (EOF);
    }
  Uchrpos[fd] = 0;
  Unextc[fd] = EOF;
  Uclreof(fd);
  return (NULL);
  }

