/* dos_fcntl.c - implementations of open() and creat() */

#include <fcntl.h>

int open(const char *pathname, int flags, mode_t mode) {
  pathname; flags; mode;
  // TODO
  return 0;
}

int creat(const char *pathname, mode_t mode) {
  return open(pathname, O_CREAT|O_WRONLY|O_TRUNC, mode);
}
