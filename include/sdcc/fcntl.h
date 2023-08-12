/* fcntl.h */

#include <sys/types.h>

#define O_RDONLY     00
#define O_WRONLY     01
#define O_RDWR       02
#define O_CREAT    0100
#define O_TRUNC   01000

extern  int       open(const char *pathname, int flags, mode_t mode);
extern  int       creat(const char *pathname, mode_t mode);
