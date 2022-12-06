#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
/*
** Unlink (delete) the named file. 
** Entry: fn = Null-terminated CP/M file name.
**             May be prefixed by letter of drive.
** Returns NULL on success, else ERR.
*/
unlink(fn) char *fn; {
  char fcb[FCBSIZE];
  pad(fcb, NULL, FCBSIZE);
  if(Unewfcb(fn, fcb) && Ubdos(DELFIL, fcb) != 255)
    return (NULL);
  return (ERR);
  }
#asm
delete  equ    unlink
        entry  delete
#endasm
