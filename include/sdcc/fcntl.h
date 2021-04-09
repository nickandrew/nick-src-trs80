/* fcntl.h */

#include <sys/types.h>

extern  int       open(const char *pathname, int flags);
extern  int       creat(const char *pathname, mode_t mode);
