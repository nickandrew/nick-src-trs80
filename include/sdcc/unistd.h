/* unistd.h for sdcc */

#include <sys/types.h>

#define NULL      ((void *) 0)

#include <sys/types.h>

#define NULL      ((void *) 0)

extern int     brk(void *addr);
extern int     getopt(int argc, char * const argv[], const char *optstring);
extern int     isatty(int fd);
extern ssize_t read(int fd, void *buf, size_t count);
extern void    *sbrk(intptr_t increment);
extern int     unlink(const char *pathname);
extern ssize_t read(int fd, void *buf, size_t count);
