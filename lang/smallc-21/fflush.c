#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
extern int Udirty[], *Uauxsz, Uauxfl;
/*
** Write buffer for fd if it has changes.
** Entry: fd = File descriptor of pertinent file.
** Returns NULL on success, otherwise EOF.
** Returns NULL if file is opened for input only
**         or if it is not a disk file.
*/
fflush(fd) int fd; {
  if(Umode(fd) & WRTBIT) {
    if((Uauxsz && Uauxsz[fd] && Uauxfl(fd)) ||
       (!isatty(fd) && Udirty[fd] && Usector(fd, WRTRND))) {
      Useterr(fd);
      return (ERR);
      }
    }
  return (NULL);
  }

