#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Close fd 
** Entry: fd = File descriptor for file to be closed.
** Returns NULL for success, otherwise ERR
*/
extern int Ufcbptr[], Ustatus[], Udevice[];
fclose(fd) int fd; {
  if(!Umode(fd)) return (ERR);
  if(!isatty(fd)) {
    if(fflush(fd) || Ubdos(CLOFIL,Ufcbptr[fd])==255)
      return (ERR);
    }
  return (Ustatus[fd]=Udevice[fd]=NULL);
  }

