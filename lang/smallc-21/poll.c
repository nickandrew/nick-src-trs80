#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Poll for console input or interruption
*/
poll(pause) int pause; {
  int i;
  i = Ubdos(DCONIO, 255);
  if(pause) {
    if(i == PAUSE) {
      while(!(i = Ubdos(DCONIO, 255))) ;
      if(i == ABORT) exit(0);
      return (0);
      }
    if(i == ABORT) exit(0);
    }
  return (i);
  }
