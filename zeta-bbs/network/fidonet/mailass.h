/* @(#) mailass.h: 13 May 90
** Header for mailass1.c
*/

#define LOCTXT	"loctxt.zms:0"
#define LOCTOP	"loctop.zms:0"
#define LOCHDR	"lochdr.zms:0"

#define FIDOPKT	"a2c9a258.out/poof:2"
#define ACSPKT	"be7aa25b.out/poof:2"

/* Some Zeta uids */
#define NOBODY		0
#define SYSOP_UID	2
#define POST_UID	3
#define POSTMASTER	"Postmaster"
#define SYSOP		"Sysop"

#define	TO_NONE		0
#define TO_LOCAL	1
#define TO_FIDO		2
#define TO_ACS		3
#define TO_BOUNCE	4

#define	F_DELETED	1
#define	F_INCOMING	2
#define	F_OUTGOING	4
#define F_PROCESSED	8
#define	F_NEW		16
#define F_INTRANSIT	32

#ifdef	REALC
extern	int	getsecond(), getminute(), gethour();
extern	int	getday(), getmonth(), getyear();
extern	int	secseek(), secread(), secwrite();
extern	int	zeromem(), getfree(), putfree(), user_search();
#endif

EXTERN
int	rc,		/* cumulative program return code */
	num_msg,	/* total number of messages */
	this_msg,	/* current one in process */
	read_rec,	/* record number of text to read */
	read_pos,	/* current byte within record of text */
	to_type,	/* type of address within To field */
	to_zone,	/* which fido zone a message goes to */
	to_net,		/* which Fido net a message goes to */
	to_node,	/* which Fido node a message goes to */
	to_point,	/* which fido point a message goes to */
	user_no,	/* Local Zeta user number */
	write_rec,	/* current record # to write */
	rec_first,	/* first record of message (for recovery) */
	write_pos,	/* position of record to write next */
	ap_msg,		/* rba of acsnet packet for recovery */
	fp_msg;		/* rba of fidonet packet for recovery */

EXTERN
FILE	*loctxt_p,	/* text file */
	*loctop_p,	/* topic file */
	*lochdr_p,	/* message headers file */
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
char	freemap[256],	/* text file free sector bitmap */
	tstring[80],	/* temporary string */
	oldhdr[16],	/* old header record */
	newhdr[16],	/* new header record */
	oldtxt[256],	/* reading text record */
	newtxt[256],	/* writing text record */
	topbuf[256],	/* topic file buffer? */
	pkthdr[58],	/* packet header buffer */
	pktmsg[14];	/* packet message header buffer */

EXTERN
char	*user_field;	/* points to buffer used by user_search */

/* char	*(bm[10]); */	/* 10 bounce message lines */
EXTERN
int	bm[10]; 	/* 10 bounce message lines */

/* end of mailass.h */
