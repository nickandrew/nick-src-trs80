/*
**  @(#) ankhmail.h - Process Zeta's incoming files - 14 Aug 90
**
*/

#define PASSWORD	"/poof"

/*  Command heads and tails */

char    packone[]  = "packdis -r ";
char	packstr[] = "packdis -pr";
char    unarc1[]  = "unarc88 -xo ";
char    copy[]    = "cp ";
char    drive0[]  = ":0 ";
char    drive1[]  = ":1 ";

/*  Mask filenames to trigger processing */

char    arc1mask[] = "A000FFFE.???";
char    arc2mask[] = "A0000001.???";
char    arc3mask[] = "BBB10004.???";

char    fnewsmask[] = "FNEWS???.ARC";
char    fidomask[] =  "FIDO???.NWS";
char    ndiffmask[] = "NODEDIFF.???";
char	newsmask[] = "NEWS????.???";	/* .NWS or .ARC */
char	netmask[] = "PKT????.NET";

/*  Other usefile filenames */

char    infiles[] = "infiles:2";
char    packets[] = "packets:2";

char	line[80],		/* line read from INFILES */
	cmd[80],		/* command to execute */
	fn[80],			/* actual filename being processed */
	findline[80],
	findfn[80];		/* filename result from a find */

char	proctype,		/* result from processing */
	nextfn[80],
	string[8];

int	retcode=0,
	arccode,		/* return code from unarc & others */
	fncode,
	ndcode,
	p_flag = 0,		/* to process file "packets" when done */
	d_flag = 0,		/* to do "packdis" when done */
	is_pkts = 0,
	group_ok = 0;		/* 1=>all packets in an arcmail processed */

int     filepos,
	findpos,
	oldpos;

FILE    *inf,			/* list of received files */
	*fp,			/* any file */
	*pac;			/* list of packets */

extern  int     chkwild(), arcnext();

/* end of ankhmail.h */
