/* bb7func.h */

extern int  createf(char *filename);
extern void fixperm(FILE *);
extern int  getfree(char *fm);
extern void putfree(char *fp, int value);
extern int  secread(FILE *fp, char *bp);
extern int  secseek(FILE *fp, int sector);
extern int  secwrite(FILE *fp, char *p);
extern int  user_sea(char *);
extern void zeromem(char *p, int length);
