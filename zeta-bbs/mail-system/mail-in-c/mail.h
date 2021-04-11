/*
**  mail.h:  Variables for 'mail'
*/


#define  STANDALONE
#define  MAXMSGS     25
#define  TEMP        "temp.msg"
#define  DEAD        "dead.msg"
#define  MAILFILE    "mailfile"
#define  SAVEFILE    "tempfile"

/* Global functions */

// mail1.c
extern void sendmail(void);

// mail2.c
extern FILE *fopene(const char *name, const char *mode);
extern void std_out(const char *s);
extern void error(char *s);
extern int getint(int pos);
extern void setint(int place, int i);
extern void getfields(int *f1, int *f2, int *f3);
extern void wordcat(char **cpp, int start, int count);
extern void bwrite(char *data, int len);
extern void bflush(void);
extern int bgetc(void);
extern void bprint(FILE *f);
extern void readblk(void);
extern void writeblk(void);
extern void readfree(void);
extern void writefree(void);
extern int getfree(void);
extern void putfree(int blk);
extern FILE *fopene(const char *name, const char *mode);

// mail3.c
extern int setrange(char *cp, int def);
extern int getrange(void);

// mail4.c
extern void help(void);
extern void print(char *range);
extern void headings(char *range);
extern void getsubj(int subj);
extern void mail(char *to_who, int subj);
extern void reply(char *range);
extern void save(char *range);
extern void delete(char *range);

// mail5.c
extern void entermsg(void);

// getuid() is implemented in library/lib/getuid.{asm,c} (but looks incomplete/erroneous)
extern int getuid(char *s);
// getuname() is implemented in zeta-bbs/include/getuname.asm (incomplete/erroneous)
extern void getuname(char *cp);
// z_asctime() is non standard; implemented in include/include/asctime.asm
extern void z_asctime(char *cp);
// z_itoa() is non standard; implemented in library/lib/atoi.c
extern void z_itoa(int i, char *cp);

/* Global variables */

EXTERN   FILE     *mf, *tf, *fpin;

EXTERN   int      chkmail, to_uid, totmail, uid;
EXTERN   int      i, n, dot, yourmail[MAXMSGS+1];
EXTERN   int      blkpos, thisblk, nextblk, newblk;
EXTERN   int      thismsg, priormsg, nextmsg;
EXTERN   int      length, chars;

EXTERN   char     from[80], to[80], date[32], subject[80];
EXTERN   char     command[80], string[80], username[24];
EXTERN   char     block[256], text[256];
EXTERN   char     *cp;

