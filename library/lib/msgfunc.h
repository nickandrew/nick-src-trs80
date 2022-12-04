/* msgfunc.h */

extern int readtxt(FILE *fp, char *bp, int rr);
extern int getstxt(char *cp, int len, FILE *fp, char *bp, int *prr, int *prp);
extern int getctxt(FILE *fp, char *bp, int *prr, int *prp);
extern int putctxt(int ch, FILE *fp, char *bp, int *pwr, int *pwp, char *fm);
extern int putstxt(const char *s, FILE *fp, char *bp, int *pwr, int *pwp, char *fm);
extern int flushtxt(FILE *fp, char *bp, int *pwr, int *pwp);
extern int writefree(FILE *fp, char *bp);
