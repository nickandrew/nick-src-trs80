#define NOCCARGC  /* no argument count passing */
/*
** Rewind file to beginning. 
*/
rewind(fd) int fd; {
  return(cseek(fd, 0, 0));
  }
