/* packctl.h: header for packctl.c
**	@(#) packctl.h: 20 May 90
*/

#ifdef	REALC

#define	CONTROL	"packdis.ctl"

#else

#define	CONTROL	"packdis.ctl:2"

#endif

#define	MAXCONFS	32

#define E_FIDONET	1
#define E_ACSNET	2

EXTERN
int	confs;		/* number of conferences */

EXTERN
FILE	*ctrl_p;	/* control file */

EXTERN
char	conftab[500],	/* buffer to store conference names */
	*confptr;	/* pointer into conftab */

EXTERN
int	confpos[MAXCONFS],	/* bug in CC for sizes of char * arrays */
	conftop[MAXCONFS],	/* topic code for each conference */
	conftyp[MAXCONFS],	/* type (acsnet | fidonet) */
	confcnt[MAXCONFS];	/* count of messages for each conference */

/* end of packctl.h */
