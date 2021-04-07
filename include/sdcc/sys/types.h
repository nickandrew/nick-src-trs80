/* sys/types.h */

#define size_t    long
#define mode_t    int
#define fpos_t    int

/* Could be this is in the wrong file */
extern  int       open(const char *pathname, int flags);
extern  int       creat(const char *pathname, mode_t mode);
