/* @(#) bbass.h: 14 Aug 90
** Header for bbass program
*/

#ifdef	REALC

#define LOCTXT	"loctxt.zms"
#define LOCTOP	"loctop.zms"
#define LOCHDR	"lochdr.zms"
#define MSGTXT	"msgtxt.zms"
#define MSGTOP	"msgtop.zms"
#define MSGHDR	"msghdr.zms"

#else

#define LOCTXT	"loctxt.zms:0"
#define LOCTOP	"loctop.zms:0"
#define LOCHDR	"lochdr.zms:0"
#define MSGTXT	"msgtxt.zms:2"
#define MSGTOP	"msgtop.zms:2"
#define MSGHDR	"msghdr.zms:2"

#endif

#define FIDOPKT	"a2c9a258.out/poof:2"
#define ACSPKT	"be7aa25b.out/poof:2"

/* Some Zeta uids */
#define NOBODY		0
#define SYSOP_UID	2
#define POST_UID	3
#define POSTMASTER	"Postmaster"
#define SYSOP		"Sysop"

/* Processing codes */
#define	TO_NONE		0
#define TO_LOCAL	1
#define TO_FIDO		2
#define TO_ACS		3
#define TO_BOUNCE	4

/* msghdr file flags */
#define	F_DELETED	1
#define	F_INCOMING	2
#define	F_OUTGOING	4
#define F_PROCESSED	8
#define	F_NEW		16
#define F_INTRANSIT	32

/* bundle message header flags */
#define MA_PUBLIC	0
#define MA_PRIVATE	1

/* Some constant text strings */
#define	AREA	"AREA: "
#define SEEN	"\001SEEN-BY: "
#define	FMPT	"\001FMPT "
#define	TOPT	"\001TOPT "
#define INTL	"\001INTL "
#define EID	"\001EID: "
#define PATH	"\001PATH: "
#define ORIGIN	" * Origin: "
#define TEAR	"--- Zeta."

EXTERN
int	rc,		/* cumulative program return code */
	num_msgl,	/* total number of messages in local */
	num_msgm,	/* total number of messages in message */
	this_msg,	/* current one in process */
	read_rec,	/* record number of text to read */
	read_pos,	/* current byte within record of text */
	to_type,	/* type of address within To field */
	to_zone,	/* which Fido zone a message goes to */
	to_net,		/* which Fido net a message goes to */
	to_node,	/* which Fido node a message goes to */
	to_point,	/* which Fido point a message goes to */
	conf_no,	/* Conference number of this message */
	user_no,	/* Local Zeta user number */
	write_rec,	/* current record # to write */
	write_pos,	/* position of record to write next */
	rec_first,	/* first record of message (for recovery) */
	ap_msg,		/* rba of acsnet packet (for recovery) */
	fp_msg;		/* rba of fidonet packet (for recovery) */

EXTERN
FILE	*loctxt_p,	/* local text file */
	*loctop_p,	/* local topic file */
	*lochdr_p,	/* local headers file */
	*msgtxt_p,	/* message text file */
	*msgtop_p,	/* message topic file */
	*msghdr_p,	/* message headers file */
	*fido_p,	/* default Fidonet output packet */
	*acs_p;		/* default ACSnet output packet */

EXTERN
char	oldfrom[80],	/* fields on the current message */
	oldto[80],
	olddate[80],
	oldsubj[80];

EXTERN
char	newfrom[80],	/* altered fields (on new message) */
	newto[80],
	newdate[80],
	newsubj[80];

EXTERN
char	freeloc[256],	/* local text file free sector bitmap */
	freemsg[256],	/* message text file free sector bitmap */
	tstring[80],	/* temporary string */
	oldhdr[16],	/* old header record */
	newhdr[16],	/* new header record */
	oldtxt[256],	/* reading text record */
	newtxt[256],	/* writing text record */
	topbufl[256],	/* local topic file buffer */
	topbufm[256],	/* message topic file buffer */
	pkthdr[58],	/* packet header buffer */
	pktmsg[14];	/* packet message header buffer */

EXTERN
char	*user_field;	/* points to buffer used by user_search */

/* char	*(bm[10]); */	/* 10 bounce message lines */
EXTERN
const char *bm[10]; 	/* 10 bounce message lines */

// defined in bbass1:
extern void openf(void);
extern void init(void);
extern void closef(void);
extern int ignorel(void);
extern int ignorem(void);
extern int do_msg(void);
extern int findtopic(int tc);
extern int deleteold(void);
extern int chk_local(void);
extern int local(void);
extern int fido(void);
extern int usenet(void);
extern void buildhdr(int send, int recv, int flags);
extern void localdat(void);
extern void fidodat(void);
extern void recover(int type, FILE *p1, int p2);
extern void printout(void);

// defined in bbass2:
extern int addarea(FILE *fp, char *areaname);
extern int addtear(FILE *fp, int conftype);
extern int copymsg(FILE *fp);
extern int localcpy(void);
extern int localfls(void);
extern int read_hdr(void);
extern int readhead(void);
extern int rewrite_hdr(void);
extern int setproc(void);
extern int write2(char *s);
extern int write_hdr(void);
extern int writedat(void);
extern int wtop_loc(void);
extern int wtop_msg(void);
extern void closloc(void);
extern void closmsg(void);
extern void initloc(void);
extern void initmsg(void);
extern void nnout(int net, int node, FILE *fp);
extern void openloc(void);
extern void openmsg(void);
extern void savetopic(int msgn, int tc);

// defined in zeta-bbs/include/routines.asm
extern int user_search(char *);

/* end of bbass.h */
