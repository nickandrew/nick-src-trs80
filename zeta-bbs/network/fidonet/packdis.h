/* packdis.h: header for packdis program
**	@(#) packdis.h: 20 May 90
*/

#ifdef	REALC

#define LOCTXT	"loctxt.zms"
#define LOCTOP	"loctop.zms"
#define LOCHDR	"lochdr.zms"
#define MSGTXT	"msgtxt.zms"
#define MSGTOP	"msgtop.zms"
#define MSGHDR	"msghdr.zms"
#define	PACKETS	"packets"

#else

#define LOCTXT	"loctxt.zms:0"
#define LOCTOP	"loctop.zms:0"
#define LOCHDR	"lochdr.zms:0"
#define MSGTXT	"msgtxt.zms:2"
#define MSGTOP	"msgtop.zms:2"
#define MSGHDR	"msghdr.zms:2"
#define	PACKETS	"packets:2"

#endif

/* The following stuff should really be in "zeta.h" */
#define OUR_ZONE	3
#define	OLD_NET		713
#define	OLD_NODE	602

#define	IS_NONE		0
#define	IS_ECHOMAIL	1
#define	IS_NETMAIL	2
#define	IS_ZETAUSER	4
#define	IS_ACSNET	8

#define	NOLINK		0
#define	FIDOLINK	1
#define	ACSLINK		2

#define	F_DELETED	1
#define	F_INCOMING	2
#define	F_OUTGOING	4
#define F_PROCESSED	8
#define	F_NEW		16
#define	F_INTRANSIT	32

#define	AREA	"AREA:"
#define SEEN	"\001SEEN-BY:"
#define	FMPT	"\001FMPT "
#define	TOPT	"\001TOPT "
#define INTL	"\001INTL "
#define EID	"\001EID:"
#define PATH	"\001PATH:"
#define ORIGIN	" * Origin: "

#ifdef	REALC
extern	int	getsecond(), getminute(), gethour();
extern	int	getday(), getmonth(), getyear();
extern	int	secseek(), secread(), secwrite();
extern	int	zeromem(), getfree(), putfree(), user_search();
extern	char	*commence(), *numstr();
#endif

EXTERN
int	r_flag,		/* 1==remove packet if success */
	p_flag,		/* 1==process batch file as well as args */
	i_flag,		/* 1==ignore minor errors when reading packets */
	loc_msgs,	/* number of messages in loc */
	msg_msgs,	/* number of messages in msg */
	msg_type,	/* type of message */
	conf_no,	/* conference Nr of this message */
	user_no,	/* Local Zeta user number */
	rec_first,	/* first record of message (for recovery) */
	fromlink,	/* link the packet came in on */
	pktnet,		/* packet from this net */
	pktnode,	/* packet from this node */
	fromzone,	/* message from zone (nicked from ifna kludge) */
	fromnet,	/* message from net */
	fromnode,	/* message from node */
	frompoint,	/* message from point (nicked from ifna kludge) */
	tonet,		/* message to net */
	tonode,		/* message to node */
	tozone,		/* message to zone */
	topoint;	/* message to point */

EXTERN
int	read_rec,	/* record number of text to read */
	read_pos,	/* current byte within record of text */
	write_rec,	/* current record number to write */
	write_pos;	/* position of record to write next */

EXTERN
FILE	*loctxt_p,	/* mail text file */
	*loctop_p,	/* mail topic file */
	*lochdr_p,	/* mail message headers file */
	*msgtxt_p,	/* echomail text file */
	*msgtop_p,	/* echomail topic file */
	*msghdr_p,	/* echomail message headers file */
	*packet_p,	/* input packet file */
	*batch_p;	/* "packets" batch input file */

EXTERN
char	line[80],	/* a scratchpad line */
	batchline[80],	/* input line from batch */
	fn[80],		/* a filename */
	from_str[80],	/* From address */
	to_str[80],	/* To address */
	ffrom[80],	/* fields on the packed fidonet message */
	fto[80],
	fdate[80],
	fsubj[80];

EXTERN
char	msgfree[256],	/* echomail file free sector bitmap */
	newtxt[256],	/* writing text sector */
	locfree[256],	/* mail file free sector bitmap */
	topbuf[256],	/* topic file buffer? */
	newhdr[16],	/* new echomail/mail file header record */
	pkthdr[58],	/* packet header buffer */
	pktmsg[12];	/* packet message header buffer */

EXTERN
char	rba_1[3],	/* start of message text within packet */
	rba_2[3];	/* start of next message or end of packet or 0 */

EXTERN
char	*user_field;	/* points to buffer used by user_search */

extern	int	optind;
extern	char	*optarg;

/* end of packdis.h */
