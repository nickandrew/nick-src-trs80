
/*
** CSYSLIB -- System-Level Library Functions
*/

#include stdio.h
#include clib.def
#define NOCCARGC    /* no argument count passing */
#define DIR         /* compile directory option */

/*
****************** System Variables ********************
*/

int
 *Uauxsz,            /* addr of Uxsize[] in AUXBUF */
  Uauxin,            /* addr of Uxinit() in AUXBUF */
  Uauxrd,            /* addr of Uxread() in AUXBUF */
  Uauxwt,            /* addr of Uxwrite() in AUXBUF */
  Uauxfl,            /* addr of Uxflush() in AUXBUF */

  Ucnt=1,            /* arg count for main */
  Uvec[20],          /* arg vectors for main */

  Ustatus[MAXFILES] = {RDBIT, WRTBIT, RDBIT|WRTBIT},
                     /* status of respective file */
  Udevice[MAXFILES] = {CPMCON, CPMCON, CPMCON},
                     /* non-disk device assignments */
  Unextc[MAXFILES]  = {EOF, EOF, EOF},
                     /* pigeonhole for ungetc bytes */
  Ufcbptr[MAXFILES], /* FCB pointers for open files */
  Ubufptr[MAXFILES], /* buffer pointers for files */
  Uchrpos[MAXFILES], /* character position in buffer */
  Udirty[MAXFILES];  /* "true" if changed buffer */

char
 *Umemptr,           /* pointer to free memory. */
  Uarg1[]="*";       /* first arg for main */

/*
*************** System-Level Functions *****************
*/

/*
** -- Process Command Line, Execute main(), and Exit to CP/M
*/
Umain() {
  Uparse();
  main(Ucnt,Uvec);
  exit(0);
  }

/*
** Parse command line and setup argc and argv.
*/
Uparse() {
  char *count, *ptr;
  count = 128;  /* CP/M command buffer address */
  ptr = Ualloc((count = *count&255)+1, YES);
  strncpy(ptr, 129, count);
  Uvec[0]=Uarg1;				/* first arg = "*" */
  while (*ptr) {
    if(isspace(*ptr)) {++ptr; continue;}
    switch(*ptr) {
      case '<': ptr = Uredirect(ptr, "r", stdin);
                continue;
      case '>': if(*(ptr+1) == '>')
                     ptr = Uredirect(ptr+1, "a", stdout);
                else ptr = Uredirect(ptr,   "w", stdout);
                continue;
      default:  if(Ucnt < 20) Uvec[Ucnt++] = ptr;
                ptr = Ufield(ptr);
      }
    }
  }

/*
** Isolate next command-line field.
*/
Ufield(ptr) char *ptr; {
  while(*ptr) {
    if(isspace(*ptr)) {
      *ptr = NULL;
      return (++ptr);
      }
    ++ptr;
    }
  return (ptr);
  }

/*
** Redirect stdin or stdout.
*/
Uredirect(ptr, mode, std)  char *ptr, *mode; int std; {
  char *fn;
  fn = ++ptr;
  ptr = Ufield(ptr);
  if(Uopen(fn, mode, std)==ERR) exit('R');
  return (ptr);
  }

/*
** ------------ File Open
*/

/*
** Open file on specified fd.
*/
Uopen(fn, mode, fd) char *fn, *mode; int fd; {
  char *fcb;
  if(!strchr("rwa", *mode)) return (ERR);
  Unextc[fd] = EOF;
  if(Uauxin) Uauxin(fd);
  if(strcmp(fn,"CON:")==0) {
    Udevice[fd]=CPMCON; Ustatus[fd]=RDBIT|WRTBIT; return (fd);
    }
  if(strcmp(fn,"RDR:")==0) {
    Udevice[fd]=CPMRDR; Ustatus[fd]=RDBIT;  return (fd);
    }
  if(strcmp(fn,"PUN:")==0) {
    Udevice[fd]=CPMPUN; Ustatus[fd]=WRTBIT; return (fd);
    }
  if(strcmp(fn,"LST:")==0) {
    Udevice[fd]=CPMLST; Ustatus[fd]=WRTBIT; return (fd);
    }
  if(fcb = Ufcbptr[fd]) pad(fcb, NULL, FCBSIZE);
  else {
    if((fcb = Ufcbptr[fd] = Ualloc(FCBSIZE, YES)) == NULL
          || (Ubufptr[fd] = Ualloc(BUFSIZE, YES)) == NULL)
        return (ERR);
    }
  pad(Ubufptr[fd], CPMEOF, BUFSIZE);
  Udirty[fd] = Udevice[fd] = Uchrpos[fd] = 0;
#ifdef DIR
  if(fn[1] == ':' && fn[2] == NULL) {  /* directory file */
    pad(fcb, NULL, FCBSIZE);
    pad(fcb+NAMEOFF, '?', NTSIZE);
    if(toupper(fn[0]) != 'X') *fcb = toupper(fn[0]) - 64;
    Uchrpos[fd] = BUFSIZE;
    Udevice[fd] = FNDFIL;
    Ustatus[fd] = RDBIT;
    return (fd);
    }
#endif
  if(!Unewfcb(fn,fcb)) return (ERR);
  switch(*mode) {
    case 'r': {
      if(Ubdos(OPNFIL,fcb)==255) return (ERR);
      Ustatus[fd] =  RDBIT;
      if(Usector(fd,  RDRND)) Useteof(fd);
      break;
      }
    case 'w': {
      if(Ubdos(FNDFIL,fcb)!=255) Ubdos(DELFIL,fcb);
    create:
      if(Ubdos(MAKFIL,fcb)==255) return (ERR);
      Ustatus[fd] = EOFBIT|WRTBIT;
      break;
      }
    default: {      /* append mode */
      if(Ubdos(OPNFIL,fcb)==255) goto create;
      Ustatus[fd] = RDBIT;
      cseek(fd, -1, 2);
      while(fgetc(fd)!=EOF) ;
      Ustatus[fd] = EOFBIT|WRTBIT;
      }
    }
  if(*(mode+1)=='+') Ustatus[fd] |= RDBIT|WRTBIT;
  return (fd);
  }

/*
** Create CP/M file control block from file name. 
** Entry: fn  = Legal CP/M file name (null terminated)
**              May be prefixed by letter of drive.
**        fcb = Pointer to memory space for CP/M fcb.
** Returns the pointer to the fcb.
*/
Unewfcb(fn, fcb) char *fn, *fcb; {
  char *fnptr;
  pad(fcb+1, SPACE, NTSIZE);
  if(*(fn + 1) == ':') {
    *fcb = toupper(*fn) - 64;
    fnptr = fn + 2;
    }
  else fnptr = fn;
  if(*fnptr == NULL) return (NO);
  fnptr = Uloadfn(fcb + NAMEOFF, fnptr, NAMESIZE);
  if(*fnptr == '.') ++fnptr;
  else if(*fnptr) return (NO);
  fnptr = Uloadfn(fcb + TYPEOFF, fnptr, TYPESIZE);
  if(*fnptr) return (NO);
  return (YES);
  }

/*
** Load into fcb and validate file name.
*/
Uloadfn(dest, sour, max) char *dest, *sour; int max; {
  while(*sour && !strchr("<>.,;:=?*[]", *sour)) {
    if(max--) *dest++ = toupper(*sour++);
    else break;
    }
  return (sour);
  }

/*
** ------------ File Input
*/

/*
** Binary-stream input of one byte from fd.
*/
Uread(fd) int fd; {
  char *bufloc;
  int ch;
  switch (Umode(fd)) {
    default: Useterr(fd); return (EOF);
    case RDBIT:
    case RDBIT|WRTBIT:
    }
  if((ch = Unextc[fd]) != EOF) {
    Unextc[fd] = EOF;
    return (ch);
    }
  switch(Udevice[fd]) {
    /* PUN & LST can't occur since they are write mode */
    case CPMCON: return (Uconin());
    case CPMRDR: return (Ubdos(RDRINP,NULL));
    default:
         if(Uauxsz && Uauxsz[fd]) return (Uauxrd(fd));
         if(Uchrpos[fd]>=BUFSIZE && !Ugetsec(fd))
           return (EOF);
         bufloc = Ubufptr[fd] + Uchrpos[fd]++;
         return (*bufloc);
    }
  }

/*
** Console character input.
*/
Uconin() {
  int ch;
  while(!(ch = Ubdos(DCONIO, 255))) ;
  switch(ch) {
    case ABORT: exit(0);
    case    LF:
    case    CR: Uconout(LF); return (Uconout(CR));
    case   DEL: ch = RUB;
       default: if(ch < 32) { Uconout('^'); Uconout(ch+64);}
                else Uconout(ch);
                return (ch);
    }
  }

/*
** Read one sector from fd.
*/
Ugetsec(fd) int fd; {
#ifdef DIR
  if(Udevice[fd]) {        /* directory file */
    char *bp, *name, *type, *end;
    Ubdos(SETDMA, 128);
    if((name = Ubdos(Udevice[fd], Ufcbptr[fd])) == 255) {
      Useteof(fd);
      return (NO);
      }
    Udevice[fd] = FNDNXT;
    name = (name << 5) + (128 + NAMEOFF);
    type = name + NAMESIZE;
    end = name + NTSIZE;
    bp = Ubufptr[fd] + BUFSIZE;
    *--bp = CR;
    while(--end >= name) { /* put filename at end of buffer */
      if(*end == SPACE) continue;
      *--bp = *end;
      if(end == type) *--bp = '.';
      }
    Uchrpos[fd] = bp - Ubufptr[fd];
    return (YES);
    }
#endif
  if(fflush(fd)) return (NO);
  Uadvance(fd);
  if(Usector(fd, RDRND)) {
    pad(Ubufptr[fd], CPMEOF, BUFSIZE);
    Useteof(fd);
    return (NO);
    }
  return (YES);
  }

/*
** ------------ File Output
*/

/*
** Binary-Stream output of one byte to fd.
*/
Uwrite(ch, fd) int ch, fd; {
  char *bufloc;
  switch (Umode(fd)) {
    default: Useterr(fd); return (EOF);
    case WRTBIT:
    case WRTBIT|RDBIT:
    case WRTBIT|EOFBIT:
    case WRTBIT|EOFBIT|RDBIT:
    }
  switch(Udevice[fd]) {
    /* RDR can't occur since it is read mode */
    case CPMCON: return (Uconout(ch));
    case CPMPUN:
    case CPMLST: Ubdos(Udevice[fd], ch);
                 break;
    default:
      if(Uauxsz && Uauxsz[fd]) return (Uauxwt(ch, fd));
      if(Uchrpos[fd]>=BUFSIZE && !Uputsec(fd)) return (EOF);
      bufloc = Ubufptr[fd] + Uchrpos[fd]++;
      *bufloc = ch;
      Udirty[fd] = YES;
    }
  return (ch);
  }

/*
** Console character output.
*/
Uconout(ch) int ch; {
  Ubdos(DCONIO, ch);
  return (ch);
  }

/*
** Write one sector to fd. 
*/
Uputsec(fd) int fd; {
  if(fflush(fd)) return (NO);
  Uadvance(fd);
  if(Ustatus[fd]&EOFBIT || Usector(fd, RDRND))
    pad(Ubufptr[fd], CPMEOF, BUFSIZE);
  return (YES);
  }

/*
** ------------ Buffer Service
*/

/*
** Advance to next sector.
*/
Uadvance(fd) int fd; {
  int *rrn;
  rrn = Ufcbptr[fd] + RRNOFF;
  ++(*rrn);
  Uchrpos[fd] = 0;
  }

/*
** Sector I/O.
*/
Usector(fd, func) int fd, func; {
  int error;
  Ubdos(SETDMA, Ubufptr[fd]);
  error = Ubdos(func, Ufcbptr[fd]);
  Ubdos(SETDMA, 128);
  Udirty[fd] = NO;
  return (error);
  }

/*
** ------------ File Status
*/

/*
** Return fd's open mode, else NULL.
*/
Umode(fd) char *fd; {
  if(fd < MAXFILES) return (Ustatus[fd]);
  return (NULL);
  }

/*
** Set eof status for fd and
** disable future i/o unless writing is allowed.
*/
Useteof(fd) int fd; {
  Ustatus[fd] |= EOFBIT;
  }

/*
** Clear eof status for fd.
*/
Uclreof(fd) int fd; {
  Ustatus[fd] &= ~EOFBIT;
  }

/*
** Set error status for fd.
*/
Useterr(fd) int fd; {
  Ustatus[fd] |= ERRBIT;
  }

/*
** ------------ Memory Allocation
*/

/*
** Allocate n bytes of (possibly zeroed) memory.
** Entry: n = Size of the items in bytes.
**    clear = "true" if clearing is desired.
** Returns the address of the allocated block of memory
** or NULL if the requested amount of space is not available.
*/
Ualloc(n, clear) char *n; int clear; {
  char *oldptr;
  if(n < avail(YES)) {
    if(clear) pad(Umemptr, NULL, n);
    oldptr = Umemptr;
    Umemptr += n;
    return (oldptr);
    }
  return (NULL);
  }

/*
** ------------ CP/M Interface
*/

/*
** Issue CP/M function and return result. 
** Entry: c  = CP/M function code (register C)
**        de = CP/M parameter (register DE or E)
** Returns the CP/M return code (register A)
*/
Ubdos(c,de) int c,de; {
#asm
        pop     h       ;hold return address
        pop     d       ;load CP/M function parameter
        pop     b       ;load CP/M function number
        push    b       ;restore
        push    d       ;  the
        push    h       ;     stack
        call    5       ;call bdos
        mvi     h,0     ;
        mov     l,a     ;return the CP/M response
#endasm
  }
