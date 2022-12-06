#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
extern int Ustatus[];
/*
** Character-stream output of a character to fd.
** Entry: ch = Character to write.
**        fd = File descriptor of perinent file.
** Returns character written on success, else EOF.
*/
fputc(ch, fd) int ch, fd; {
  switch(ch) {
    case EOF:  Uwrite(CPMEOF, fd); break;
    case '\n': Uwrite(CR, fd); Uwrite(LF, fd); break;
    default:   Uwrite(ch, fd);
    }
  if(Ustatus[fd] & ERRBIT) return (EOF);
  return (ch);
  }
#asm
putc equ   fputc
     entry putc
#endasm
