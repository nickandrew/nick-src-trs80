#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Rename a file.
**  from = address of old filename.
**    to = address of new filename.
**  Returns NULL on success, else ERR.
*/
rename(from, to) char *from, *to; {
  char fcb[FCBSIZE];
  pad(fcb, NULL, FCBSIZE);
  if(!Unewfcb(to, fcb) || Ubdos(OPNFIL, fcb) != 255) {
    Ubdos(CLOFIL, fcb);
    return (ERR);
    }
  if(Unewfcb(from, fcb) &&
     Unewfcb(to, fcb+NAMEOFF2) &&
     Ubdos(RENAME, fcb) != 255)
    return (NULL);
  return (ERR);
  }
