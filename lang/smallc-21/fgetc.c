#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
extern int Uchrpos[];
/*
** Character-stream input of one character from fd.
** Entry: fd = File descriptor of pertinent file.
** Returns the next character on success, else EOF.
*/
fgetc(fd) int fd; {
  int ch;
  while(1) {
    switch(ch = Uread(fd)) {
      default:     return (ch);
      case CPMEOF: switch(Uchrpos[fd]) {
                     default: --Uchrpos[fd];
                     case 0:
                     case BUFSIZE:
                     }
                   Useteof(fd);
                   return (EOF);
      case CR:     return ('\n');
      case LF:    /* NOTE: Uconin() maps LF -> CR */
      }
    }
  }
#asm
getc equ   fgetc
     entry getc
#endasm

