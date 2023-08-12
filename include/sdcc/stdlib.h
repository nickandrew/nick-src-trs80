/* stdlib.h */

#include <sys/types.h>

extern  int       atoi(const char *nptr);
extern  void      *calloc(size_t nmemb, size_t size);
extern  void      exit(int status);
extern  void      free(void *ptr);
extern  char      *itoa(int n, char *buffer, ...);  // code might not use the radix arg
extern  void      *malloc(size_t size);
extern  int       rand(void);
extern  void      srand(unsigned int seed);
extern  int       system(const char *command);
