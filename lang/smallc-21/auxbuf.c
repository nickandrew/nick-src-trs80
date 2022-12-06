#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
extern int *Uauxsz, Uauxin, Uauxrd, Uauxwt, Uauxfl, Ustatus[];
/*
** This module is loaded with a program only if auxbuf()
** is called.  It links to Uopen(), Uread(), Uwrite(), and
** fflush() through Uauxsz, Uauxin, Uauxrd, Uauxwt, and Uauxfl
** in CSYSLIB.  This technique reduces the overhead for
** programs which don't use auxiliary buffering.  Presumably,
** if there is enough memory for extra buffering, there is
** room to spare for this overhead too.  A bug in some
** versions of Small-C between 2.0 and 2.1 may cause the calls
** to Uauxrd, Uauxwt, and Uauxfl in Uread(), Uwrite(), and
** fflush(), respectively, to produce bad code.  The current
** compiler corrects the problem.
*/
int
  Uxsize[MAXFILES],  /* size of buffer */
  Uxaddr[MAXFILES],  /* aux buffer address */
  Uxnext[MAXFILES],  /* address of next byte in buffer */
  Uxend[MAXFILES],   /* address of end-of-data in buffer */
  Uxeof[MAXFILES];   /* true if current buffer ends file */
/*
** auxbuf -- allocate an auxiliary input buffer for fd
**   fd = file descriptor of an open file
** size = size of buffer to be allocated
** Returns NULL on success, else ERR.
** Note: Ungetc() still works.
**       A 2nd call returns ERR, but has no effect.
**       If fd is a device, buffer is allocated but ignored.
**       Buffer stays allocated when fd is closed.
**       Do not mix reads and writes or perform seeks on fd.
*/
auxbuf(fd, size) int fd; char *size; {   /* fake unsigned */
  if(!Umode(fd) || !size || avail(NO) < size   || Uxsize[fd])
    return (ERR);
  Uxaddr[fd] = malloc(size); Uxinit(fd);
  Uauxin = Uxinit;    /* tell Uopen() where Uxinit() is */
  Uauxrd = Uxread;    /* tell Uread() where Uxread() is */
  Uauxwt = Uxwrite;   /* tell Uwrite() where Uxwrite() is */
  Uauxsz = Uxsize;    /* tell both where Uxsize[] is */
  Uauxfl = Uxflush;   /* tell fflush() where Uxflush() is */
  Uxsize[fd] = size;  /* tell Uread() that fd has aux buf */
  return (NULL);
  }

/*
** Initialize aux buffer controls
*/
Uxinit(fd) int fd; {
  Uxnext[fd] = Uxend[fd] = Uxaddr[fd];
  Uxeof[fd] = NO;
  }

/*
** Fill buffer if necessary, and return next byte.
*/
Uxread(fd) int fd; {
  char *ptr;
  while(YES) {
    ptr = Uxnext[fd];
    if(ptr < Uxend[fd]) {++Uxnext[fd]; return (*ptr);}
    if(Uxeof[fd]) {Useteof(fd); return (EOF);}
    Uauxsz = NULL;          /* avoid recursive loop */
    Uxend[fd] = Uxaddr[fd]
              + read(fd, Uxnext[fd]=Uxaddr[fd], Uxsize[fd]);
    Uauxsz = Uxsize;        /* restore Uauxsz */
    if(feof(fd)) {Uxeof[fd] = YES; Uclreof(fd);}
    }
  }

/*
** Empty buffer if necessary, and store ch in buffer.
*/
Uxwrite(ch, fd) int ch, fd; {
  char *ptr;
  while(YES) {
    ptr = Uxnext[fd];
    if(ptr < (Uxaddr[fd] + Uxsize[fd]))
      {*ptr = ch; ++Uxnext[fd]; return (ch);}
    if(Uxflush(fd)) return (EOF);
    }
  }

/*
** Flush aux buffer to file.
*/
Uxflush(fd) int fd; {
  int i, j;
  i = Uxnext[fd] - Uxaddr[fd];
  Uauxsz = NULL;   /* avoid recursive loop */
  j = write(fd, Uxnext[fd]=Uxaddr[fd], i);
  Uauxsz = Uxsize; /* restore Uauxsz */
  if(i != j) return (EOF);
  return (NULL);
  }
