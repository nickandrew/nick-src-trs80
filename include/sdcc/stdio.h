/* standard IO file for sdcc TRS-80 */
/*  STDIO.H */

#include <sys/types.h>
#include <stdarg.h>

typedef long          fpos_t;
typedef void          FILE;

#define EOF       (-1)
#define BUFSIZ    256
#define NULL      ((void *) 0)
#define SEP       '.'

extern  FILE      *stdin;
extern  FILE      *stdout;
extern  FILE      *stderr;

// These are used by implementations of printf: fprintf, etc.
typedef void (*pfn_outputchar)(char c, void* p);
extern int _print_format (pfn_outputchar pfn, void* pvoid, const char *format, va_list ap);

extern  void      clearerr(FILE *stream);
extern  int       fclose(FILE *stream);
extern  int       feof(FILE *stream);
extern  int       ferror(FILE *stream);
extern  int       fgetc(FILE *stream);
extern  int       fgetpos(FILE *stream, fpos_t *pos);
extern  int       fileno(FILE *stream);
extern  char      *fgets(char *s, int size, FILE *stream);
extern  FILE      *fopen(const char *pathname, const char *mode);
extern  int       fprintf(FILE *stream, const char *format, ...);
extern  int       fputc(int c, FILE *stream);
extern  int       fputs(const char *s, FILE *stream);
extern  size_t    fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
extern  int       fscanf(FILE *stream, const char *format, ...);
extern  int       fseek(FILE *stream, long offset, int whence);
extern  int       fsetpos(FILE *stream, const fpos_t *pos);
extern  long      ftell(FILE *stream);
extern  size_t    fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
extern  int       getc(FILE *stream);
extern  int       getchar(void);
extern  char      *gets(char *s);
extern  int       printf(const char *format, ...);
extern  int       putc(int c, FILE *stream);
extern  int       putchar(int c);
extern  int       puts(const char *s);
extern  void      rewind(FILE *stream);
extern  int       scanf(const char *format, ...);
extern  int       sprintf(char *str, const char *format, ...);
extern  int       sscanf(const char *str, const char *format, ...);
extern  int       ungetc(int c, FILE *stream);
