#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Close all open files and exit to CP/M. 
** Entry: errcode = Character to be sent to stderr.
** Returns to CP/M rather than the caller.
*/
exit(errcode) char errcode; {
  int fd;
  if(errcode) Uconout(errcode);
  for(fd=0; fd < MAXFILES; fclose(fd++));
  Ubdos(GOCPM,NULL);
  }
#asm
abort  equ    exit
       entry  abort
#endasm
