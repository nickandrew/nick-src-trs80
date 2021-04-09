/* unistd.h for sdcc */

#include <sys/types.h>

#define NULL      ((void *) 0)

extern int isatty(int fd);
extern ssize_t read(int fd, void *buf, size_t count);
