/*  mailass ... Process new messages in the local mail database
**	@(#) mailass1.c: 1.1g 14 Aug 90
**
**  Process local mail, Fidonet mail or ACSnet mail
**	local mail: 	Duplicate the message into another
**	Fidonet mail:	Write a Fidonet bundle to our Fidonet link
**	ACSnet mail:	Write a Fidonet-type bundle to ACSgate
**
**  Types of mail:
**	Incoming:	Has been delivered to a user of Zeta
**	Outgoing:	Was sent by a Zeta user, to be delivered
**	In-transit:	Routed or Bounced messages.
**
** 1.1g 14 Aug 90
**	Add "flags" parameter to invocation of makemsg() function
**	to specify the "private" attribute.
**	Changed some error messages
** 1.1f 01 Aug 90
**	Change to use bundle routines from lib/bunfunc.c
**	Add make-believe header translation, (newheaders <-- oldheaders)
** 1.1e 11 Jun 90
**	Changed from FIDO_NET to HOST_NET, from FIDO_NODE to HOST_NODE.
** 1.1d 19 May 90
**	Change net/node number of ACSnet link
**	Add informative messages
**	Neaten the code a little
** 1.1c 25 Nov 89
**	Text of bounce messages was empty!
** 1.1b 05 Aug 89
**	Fixed a bug in bouncing code, improved handling of "full" messages
** 1.1a 19 Jun 89
**	Base version
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define EXTERN
#include "mailass.h"
#include "bbass.h"
#include "bb7func.h"
#include "bunfunc.h"
#include "openf2.h"
#include "getw.h"
#include "gettime.h"
#include "msgfunc.h"
#include "zeta.h"

int main()
{
    int n;

    rc = 0;
    openf();
    init();

    for (this_msg = 0; this_msg < num_msg; ++this_msg) {
        if (n = read_hdr()) {
            fputs("Mailass: bad MSGHDR file!\n", stderr);
            rc |= 8;
            break;
        }

        if (ignorel())
            continue;

        if (n = do_msg()) {
            fputs("Do_msg encountered error!\n", stderr);
            rc |= 16;
            break;
        }
    }

    rc |= writefree(loctxt_p, freemap);
    rc |= write_top();
    closef();

    return rc;
}

/* ignorel ...
**	Ignore PROCESSED and DELETED messages
**	return 0 if message should be processed
**	(thats for OUTGOING and INTRANSIT)
*/

int ignorel(void)
{
    if (oldhdr[0] & (F_PROCESSED | F_DELETED))
        return 1;               /* ignore */
    if (oldhdr[0] & (F_OUTGOING | F_INTRANSIT))
        return 0;
    return 1;
}

/* do_msg ...
**	read the 4 header fields
**	parse the To: address
**	process in the correct manner, any of:
**		copy as incoming message
**		write a message within a Fidonet bundle
**		bounce (as in-transit) to the sender or to Sysop
*/

int do_msg(void)
{
    int rc = 0;

    if (readhead())
        return 1;

    if (parse())
        return 2;               /* unable to parse or bounce */

    switch (to_type) {
    case TO_LOCAL:
        rc = local();
        break;
    case TO_FIDO:
        rc = fido();
        break;
    case TO_ACS:
        rc = acsnet();
        break;
    case TO_BOUNCE:
        rc = pars_bounce();
        break;
    }

    if (rc) {
        fputs("Local, Fidonet or ACSnet message output failed.\n", stderr);
        return rc;
    }

    if (oldhdr[0] & (F_INTRANSIT | F_OUTGOING)) {
        rc = deleteold();
        if (rc)
            fputs("Could not delete outgoing|intransit msg\n", stderr);
    }
    return rc;
}

/*  Parse ... 
**	parse the To: address
*/

int parse(void)
{
    /* just as a small interlude. Write to screen */

    fputs("From: ", stderr);
    fputs(oldfrom, stderr);
    fputs("\nTo:   ", stderr);
    fputs(oldto, stderr);
    fputs("\nSubj: ", stderr);
    fputs(oldsubj, stderr);
    fputc('\n', stderr);

    to_type = TO_BOUNCE;

    if (chk_fido()) {
        to_type = TO_FIDO;
        return 0;
    }
    if (chk_acs()) {
        to_type = TO_ACS;
        return 0;
    }
    if (chk_local()) {
        to_type = TO_LOCAL;
        return 0;
    }
    return 0;
}

/*  deleteold ...
**	delete an in-transit or outgoing message after processing
*/

int deleteold(void)
{
    int n;
    int recnum;

    recnum = getw(oldhdr + 3);  /* first record */

    while (recnum != 0) {
        /* delete an allocated block */
        putfree(freemap, recnum);
        n = readtxt(loctxt_p, oldtxt, recnum);
        if (n)
            return n;
        recnum = getw(oldtxt);
    }

    n = writefree(loctxt_p, freemap);
    if (n)
        return n;

    oldhdr[0] |= F_DELETED;
    n = rewrite_hdr();
    if (n)
        return n;

    return 0;
}

/*  chk_fido ...
**	Return 1 if it is a valid fido address
**	valid ::= one or more name followed by location
**	name ::= string of A-Z, a-z, 0-9, '-'
**	location ::= '(', nnn, '/', ')', NULL
*/

int chk_fido(void)
{
    char *cp, *oldcp;
    int i;
    char ch;

    oldcp = oldto;
    /* check character set of words */
    if (chkname(oldcp) == 0)
        return 0;               /* need at least 1 name */
    cp = nextword(oldcp);

    while (*cp) {
        if (chkname(oldcp) == 0)
            return 0;           /* not a name */
        oldcp = cp;
        cp = nextword(oldcp);
    }

    /* get the nnn/nnn address and determine if legal */

    if (chkfido(oldcp) == 0)
        return 0;               /* not a valid (z:nnn/nnn.p) */

    oldcp[-1] = 0;              /* remove " (nnn/nnn)" */

    /* change the case of the name to Fidonet conventions */
    i = 1;
    for (oldcp = oldto; *oldcp; ++oldcp) {
        ch = *oldcp;
        if (ch == ' ') {
            i = 1;
            continue;
        }
        if (i) {
            if (ch >= 'a' && ch <= 'z')
                ch &= 0x5f;
            i = 0;
        } else {
            if (ch >= 'A' && ch <= 'Z')
                ch |= 0x20;
        }
        *oldcp = ch;
    }

    return 1;
}

/* chkname ... ensure a string contains valid name-like characters */

int chkname(char *cp)
{
    char ch;

    for (; *cp && (*cp != ' '); ++cp) {
        ch = *cp;
        if (ch >= 'A' && ch <= 'Z')
            continue;
        if (ch >= 'a' && ch <= 'z')
            continue;
        if (ch >= '0' && ch <= '9')
            continue;
        if (ch == '-')
            continue;
        return 0;
    }
    return 1;
}

/* nextword ...
**	return address of either end of string, or
**	of character after first space
*/

char *nextword(char *cp)
{
    while (*cp && *cp != ' ')
        ++cp;
    if (*cp == 0)
        return cp;
    return ++cp;
}

/* chkfido ...
**	parse the (z:nnn/nnn.p) word, and assign
**	to_zone, to_net, to_node, to_point
*/

int chkfido(char *cp)
{
    int value;

    to_zone = to_net = to_node = to_point = 0;

    if (*cp != '(')
        return 0;

    if (!isdigit(*++cp))
        return 0;

    value = atoi(cp);
    while (*cp && *cp != ':' && *cp != '/' && *cp != ')')
        ++cp;

    if (*cp == ':') {
        to_zone = value;
        if (!isdigit(*++cp))
            return 0;
        value = atoi(cp);
        while (*cp && *cp != '/' && *cp != ')')
            ++cp;
    }

    to_net = value;
    if (*cp != '/')
        return 0;

    if (!isdigit(*++cp))
        return 0;
    to_node = atoi(cp);

    while (*cp && *cp != '.' && *cp != ')')
        ++cp;

    if (*cp == '.') {
        if (!isdigit(*++cp))
            return 0;
        to_point = atoi(cp);
        while (*cp && *cp != ')')
            ++cp;
    }

    if (*cp++ != ')')
        return 0;
    if (*cp != 0)
        return 0;

    return 1;
}

/*  chk_acs ...
**	Return 1 if it is a valid acsnet address
**	valid ::= one rfc822 optionally followed by junk
**	rfc822 ::= name@site.domain[.domains]
**	junk ::= anything after a space
*/

int chk_acs(void)
{
    char *cp;
    char ch;

    /* parse left part */
    for (cp = oldto; *cp != '@'; ++cp) {
        ch = *cp;
        if (ch == 0 || ch == ' ')
            return 0;           /* no @? */
        if (ch >= 'A' && ch <= 'Z')
            continue;
        if (ch >= 'a' && ch <= 'z')
            continue;
        if (ch >= '0' && ch <= '9')
            continue;
        if (ch == '-')
            continue;
        if (ch == '!' || ch == '.' || ch == '%')
            return 0;
    }

    ++cp;                       /* bypass @ */
    if (*cp == 0)
        return 0;

    for (; *cp; ++cp) {
        ch = *cp;
        if (ch == ' ') {
            *cp = 0;
            return 1;           /* ignore junk */
        }
        if (ch >= 'A' && ch <= 'Z')
            continue;
        if (ch >= 'a' && ch <= 'z')
            continue;
        if (ch >= '0' && ch <= '9')
            continue;
        if (ch == '-')
            continue;
        if (ch == '!' || ch == '@' || ch == '%')
            return 0;
    }

    return 1;
}

/*  chk_local ...
**	Return 1 if it is a valid Zeta user name
*/

int chk_local(void)
{
    user_no = user_search(oldto);
    if (user_no <= 0) {
        fputs("User name not found: ", stderr);
        fputs(oldto, stderr);
        fputc('\n', stderr);
        return 0;
    }
    return 1;
}

/*  local ...
**  Process a message to be delivered to a local user
**	Allocate a text sector
**	Save the (ha) "topic code" of the new message
**	Build a new message header from the old
**	Create new data headers & write to text file
**	Copy message into new message
**	Write new header
**	Set processed flag on old message
*/

int local(void)
{
    int n;

    write_rec = rec_first = getfree(freemap);
    if (write_rec == -1) {
        fputs("Local message system full!\n", stderr);
        return 8;
    }

    write_pos = 2;
    zeromem(newtxt, 256);

    savetopic(num_msg, 0);      /* save 0 topic code */
    buildhdr(NOBODY, user_no, F_INCOMING | F_NEW);
    localdat();
    n = writedat();             /* write data headers */
    if (n)
        return n;

    n = localcpy();
    if (n)
        return n;

    n = write_hdr();
    if (n)
        return n;

    n = setproc();
    if (n)
        return n;

    return 0;
}

/* build a new message header */

void buildhdr(int send, int recv, int flags)
{
    newhdr[0] = flags;
    newhdr[1] = 8;              /* # lines (dummy - not used?) */
    newhdr[2] = 0;              /* was msb of rba */
    putw(newhdr + 3, write_rec);        /* first sector address */
    newhdr[5] = getday();
    newhdr[6] = getmonth();
    newhdr[7] = getyear();
    putw(newhdr + 8, send);     /* sender uid */
    putw(newhdr + 10, recv);    /* receiver uid */
    newhdr[12] = 0;             /* topic 0 */
    newhdr[13] = getsecon();
    newhdr[14] = getminut();
    newhdr[15] = gethour();
}

/* localdat ...
**	Create new data headers for new local messages
*/

void localdat(void)
{
    strcpy(newfrom, oldfrom);
    strcpy(newto, user_field);  /* from user_search */
    strcpy(newdate, olddate);
    strcpy(newsubj, oldsubj);
}

/* tranhdr ...
**	Create fidonet type headers from old headers
**	OK so it is simplistic... so what?
*/

void tranhdr(void)
{
    strcpy(newfrom, oldfrom);
    strcpy(newto, oldto);
    strcpy(newdate, olddate);
    strcpy(newsubj, oldsubj);
}

/*  fido ...
**  Process a Fidonet netmail message
**	Position the output Fidonet bundle
**	Create and write a message header
**	Copy the message, with translation
**	Set the current message to processed.
*/

int fido(void)
{
    int n;

    fp_msg = fseek(fido_p, -2, 2);

    n = makemsg(fido_p, MA_PRIVATE);
    if (n) {
        fputs("Could not make Fido link message header\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    /* Translate headers into Fidonet-acceptable format */

    tranhdr();

    n = copydat(fido_p);
    if (n) {
        fputs("Could not copy header info to Fido link\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    n = copymsg(fido_p);
    if (n) {
        fputs("Could not copy message to Fido link\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    n = setproc();
    if (n) {
        fputs("Could not set message to processed\n", stderr);
        return n;
    }

    return 0;
}

/*  acsnet ...
**	Process a message to be mailed through ACSnet
**	Basically the same as fido(), except using acs_p
*/

int acsnet(void)
{
    int n;

    ap_msg = fseek(acs_p, -2, 2);

    to_net = ACS_NET;
    to_node = ACS_NODE;

    n = makemsg(acs_p, MA_PRIVATE);
    if (n) {
        fputs("Could not make ACSnet link message header\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    /* Translate headers into ACSgate-acceptable format */

    tranhdr();

    n = copydat(acs_p);
    if (n) {
        fputs("Could not copy header info to ACSnet link\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    n = copymsg(acs_p);
    if (n) {
        fputs("Could not copy message to ACSnet link\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    n = setproc();
    if (n) {
        fputs("Could not set message to processed\n", stderr);
        return n;
    }

    return 0;
}

/*  pars_bounce ...
**  Bounce a message with invalid To:
**	Create either incoming or in-transit message explaining what
**	went wrong.  If there appears to be a bounce loop, send the
**	message to Sysop instead.
*/

int firstbounce = 1;            /* never bounced before */

int pars_bounce(void)
{
    int n, bnc_flags, bnc_from, bnc_to, bnc_type;

    fputs("Bouncing!\n", stderr);

    write_rec = rec_first = getfree(freemap);
    if (write_rec == -1) {
        fputs("Bounce: message system full!\n", stderr);
        return 8;
    }

    write_pos = 2;
    zeromem(newtxt, 256);

    savetopic(num_msg, 0);      /* save 0 topic code */

    /* analyse how we have to bounce this message */
    /* if outgoing, create incoming, else create in-transit */

    bnc_from = POST_UID;

    if (oldhdr[0] & F_OUTGOING) {
        /* bouncing from an outgoing message */
        bnc_flags = F_INCOMING | F_NEW;
        bnc_to = getw(oldhdr + 8);
        bnc_type = 0;
    } else {
        /* bouncing from an in-transit message */
        if (strcmp(oldfrom, POSTMASTER) && strcmp(oldto, POSTMASTER)) {
            /* not (from or to postmaster) */
            bnc_flags = F_INTRANSIT;
            bnc_to = NOBODY;
            bnc_type = 1;
        } else {
            bnc_type = 2;       /* bounce to sysop */
            bnc_flags = F_INCOMING | F_NEW;
            bnc_to = SYSOP_UID;
        }
    }

    /* build a bounce header */
    bouncehdr(bnc_from, bnc_to, bnc_flags);

    /* create and write data headers */
    bouncedat(bnc_type);
    n = writedat();
    if (n)
        return n;

    /* copy the text of the message if necessary */
    if (firstbounce)
        bounceinit();
    n = bouncecpy(bnc_type);
    if (n)
        return n;

    /* write 16 byte header */
    n = write_hdr();
    if (n)
        return n;

    n = setproc();
    if (n)
        return n;

    fputs("Bounce worked\n", stderr);
    return 0;
}

/*  bouncehdr ...
**	build a message header for bouncing
*/

void bouncehdr(int send, int recv, int flags)
{
    newhdr[0] = flags;          /* incoming|new or in-transit */
    newhdr[1] = 8;              /* # lines (dummy - not used?) */
    newhdr[2] = 0;              /* was msb of rba */
    putw(newhdr + 3, write_rec);        /* first sector address */
    newhdr[5] = getday();
    newhdr[6] = getmonth();
    newhdr[7] = getyear();
    putw(newhdr + 8, send);     /* sender uid */
    putw(newhdr + 10, recv);    /* receiver uid */
    newhdr[12] = 0;             /* topic 0 */
    newhdr[13] = getsecon();
    newhdr[14] = getminut();
    newhdr[15] = gethour();
}

/* bouncedat ...
**	create new data headers for new bounced messages
*/

void bouncedat(int type)
{
    strcpy(newfrom, POSTMASTER);
    if (type == 2)
        strcpy(newto, SYSOP);
    else
        strcpy(newto, oldfrom);
    strcpy(newdate, olddate);
    strcpy(newsubj, oldsubj);
}

/* bounceinit ... initialise the bounce text array */

void bounceinit(void)
{

    firstbounce = 0;

    bm[0] = "Your message addressed To: '";
    bm[1] = "'\ncould not be delivered because the\n";
    bm[2] = "destination address is wrong. Valid address formats are like:\n\n";
    bm[3] = "To: Fred Nurk (711/401)         Send to a user on Fidonet 711/401\n";
    bm[4] = "To: evans@ditsyda.oz            Send to an ACSnet userid\n";
    bm[5] = "To: Mick Jagger                 Send to a local Zeta user\n";
    bm[6] = "\nPlease re-enter your message with correct To:\n\n";
    bm[7] = "The following message appears to be in a bounce loop.\n\n";
    bm[8] = "destination address is not a known user of Zeta.\n\n";
    bm[9] = "The text of the message follows:\n\n";
}

/* end of mailass1.c */
