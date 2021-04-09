/*
**  mail.h:  Variables for 'mail'
*/


#define  STANDALONE
#define  MAXMSGS     25
#define  TEMP        "temp.msg"
#define  DEAD        "dead.msg"
#define  MAILFILE    "mailfile"
#define  SAVEFILE    "tempfile"

EXTERN   FILE     *mf,*tf,*fpin;

EXTERN   int      chkmail, to_uid, totmail, uid;
EXTERN   int      i, n, dot, yourmail[MAXMSGS+1];
EXTERN   int      rangemsg, ranges, rangef, rangen;
EXTERN   int      blkpos, thisblk, nextblk, newblk;
EXTERN   int      thismsg, priormsg, nextmsg;
EXTERN   int      length, chars;

EXTERN   char     from[80], to[80], date[32], subject[80];
EXTERN   char     command[80], string[80], username[24];
EXTERN   char     block[256], text[256];
EXTERN   char     *cp, *rangecp;

