/* msgfunc.h */

extern int readtxt(FILE *fp, char *bp, int rr);
extern int getstxt(char *cp, int len, FILE *fp, char *bp, int *prr, int *prp);
extern int getctxt(FILE *fp, char *bp, int *prr, int *prp);
extern int putctxt(int ch, FILE *fp, char *bp, int *pwr, int *pwp, char *fm);
extern int putstxt(char *s, FILE *fp, char *bp, int *pwr, int *pwp, char *fm);
extern int flushtxt(FILE *fp, char *bp, int *pwr, int *pwp);
extern int writefree(FILE *fp, char *bp);

/* I don't know where these should be defined */
extern int  getfree(char *fm);
extern int  getw(char *buf);
extern void putw(char *buf, int value);
extern void putfree(char *fp, int value);
extern int  secread(FILE *fp, char *bp);
extern int  secseek(FILE *fp, int sector);
extern int  secwrite(FILE *fp, char *p);
extern void zeromem(char *p, int length);
