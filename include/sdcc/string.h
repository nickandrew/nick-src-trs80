/* string.h */

#include <sys/types.h>

extern  void      *memcpy(void *dest, const void *src, size_t n);
extern  char      *strcat(char *dest, const char *src);
extern  char      *strchr(const char *s, int c);
extern  int       strcmp(const char *s1, const char *s2);
extern  char      *strcpy(char *dest, const char *src);
extern  int       stricmp(const char *s1, const char *s2);
extern  size_t    strlen(const char *s);
extern  char      *strncat(char *dest, const char *src, size_t n);
extern  int       strncmp(const char *s1, const char *s2, size_t n);
extern  char      *strncpy(char *dest, const char *src, size_t n);
