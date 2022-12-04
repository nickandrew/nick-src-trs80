/*  packdis2.c ... packet handling routines for packdis
**	@(#) packdis2.c: 11 Jun 90
*/

#include <stdio.h>

#include "openf2.h"

#define EXTERN extern
#include "packdis.h"
#include "packctl.h"
#include "zeta.h"

#ifdef	REALC
#define LONG	long
#else
#define	LONG	int
#endif

/* read_head:
**  Read the 4 null-terminated fields date, to, from, subj
*/

int read_head()
{
    int c;

    c = getfield(fdate, 21, packet_p);
    if (c)
        fputs("Long fdate field\n", stderr);
    c = getfield(fto, 37, packet_p);
    if (c)
        fputs("Long fto field\n", stderr);
    c = getfield(ffrom, 37, packet_p);
    if (c)
        fputs("Long ffrom field\n", stderr);
    c = getfield(fsubj, 72, packet_p);
    if (c)
        fputs("Long fsubj field\n", stderr);

    fixstr(fdate);
    fixstr(fto);
    fixstr(ffrom);
    fixstr(fsubj);

    return 0;
}

/* readline ... sorta like fgets, but for a packeted message */

/* variable declarations for a bit of speed */
int rdl_ch;
int rdl_n;
char *rdl_ptr;

int readline()
{
    rdl_ptr = line;
    rdl_n = 79;
    while (rdl_n > 0) {
        rdl_ch = fgetc(packet_p);
        if (rdl_ch == 0x8d)
            continue;           /* ignore soft CRs */
        if (rdl_ch == 0x0a)
            continue;           /* ignore linefeeds */
        if (rdl_ch == EOF || rdl_ch == 0)
            break;
        *(rdl_ptr++) = rdl_ch;
        --rdl_n;
        if (rdl_ch == 0x0d)
            break;
    }
    *rdl_ptr = '\0';
    return rdl_ch;
}

/* read_body:
**	Read the body of the message and find out certain
**	things about it
*/

int read_body()
{
    int n;
    char *place;

    n = readline();
    if (n == EOF) {
        fputs("Early EOF on packet\n", stderr);
        return 2;
    }

    if (n == 0) {
        fputs("Empty message\n", stderr);
        return 1;
    }

    if ((place = commence(line, AREA)) == NULL) {

        fputs("Is not echomail\n", stderr);
        msg_type |= IS_NETMAIL; /* so it can be bounced */

        /* not echo, check for ^A words */
        do {
            if (*line == 0x01)
                doifna();
            n = readline();
        } while (n != 0 && n != EOF);

        if (n == EOF) {
            fputs("Truncated message!\n", stderr);
            return 6;
        }

        /* copy to field (possibly formatted username) */
        strcpy(to_str, fto);

        /* create from address */
        strcpy(from_str, ffrom);

        /* if not ACSnet, add (nnn/nnn) */
        if ((msg_type & IS_ACSNET) == 0) {
            fidocat(from_str, fromzone, fromnet, fromnode, frompoint);
        }
    } else {

        /* is echo, determine conference & origin */
        msg_type |= IS_ECHOMAIL;
        findconf(place);        /* returns general as last resort */

        n = readline();
        while (n != EOF && n != 0) {
            if (*line == 0x01)
                doifna();
            if ((place = commence(line, ORIGIN)) != NULL)
                doorigin(place);
            n = readline();
        }

        if (n == EOF) {
            fputs("Truncated message!\n", stderr);
            return 7;
        }

        /* copy to field (possibly formatted username) */
        strcpy(to_str, fto);

        /* create from address */
        strcpy(from_str, ffrom);
        if ((msg_type & IS_ACSNET) == 0) {
            fidocat(from_str, fromzone, fromnet, fromnode, frompoint);
        }
    }

    return 0;
}

/* doifna ... handle ifna-kludge keywords */

doifna()
{
    char *place;

    /* ignore, ignore */
    if ((place = commence(line, PATH)) != NULL) {
        return;
    }

    if ((place = commence(line, EID)) != NULL) {
        return;
    }

    fputs("Hey, look: ", stderr);
    fputs(line + 1, stderr);
    fputs("\n", stderr);

    if ((place = commence(line, FMPT)) != NULL) {
        /* handle from-point */
        frompoint = atoi(place);
        return;
    }

    if ((place = commence(line, TOPT)) != NULL) {
        /* handle to-point */
        topoint = atoi(place);
        return;
    }

    if ((place = commence(line, INTL)) != NULL) {
        /* handle inter-zone */
        return;
    }
}

/* findconf ... search the conference table for this one */

findconf(string)
char *string;
{
    char *cp;

    /* remove the trailing CR from the area name */
    for (cp = string; *cp; ++cp) ;
    if (cp[-1] == 0x0d)
        cp[-1] = '\0';

    conf_no = 0;

    fputs(string, stderr);
    while (conf_no < confs) {

        if (!strcmp(confpos[conf_no], string)) {
            fputs(": ", stderr);
            return;
        }
        ++conf_no;
    }

    /* not found - set to general */
    conf_no = 0;

    fputs(" unknown: ", stderr);
}

/* doorigin ... Parse an origin line */

doorigin(string)
char *string;
{
    char *lp;

    fromzone = frompoint = fromnet = fromnode = 0;

    /* find the end of the origin string */
    for (lp = string; *lp; ++lp) ;

    /* find last delimiter */
    while (*lp != ' ' && *lp != ':' && *lp != '(' && *lp != '*')
        --lp;

    /* get the zone, if any */
    if (*lp == ':') {
        --lp;
        fromzone = atoi(lp);
        ++lp;
    }

    /* bypass the delimiter (whatever it was) */
    ++lp;

    /* get two numbers separated by a slash */
    fromnet = atoi(lp);
    while (*lp && *lp != '/')
        ++lp;
    if (*lp == '/') {
        ++lp;
        fromnode = atoi(lp);
    }

    /* followed by an optional point number */
    while (*lp && *lp != '.')
        ++lp;
    if (*lp == '.') {
        ++lp;
        frompoint = atoi(lp);
    }
}

/* position the packet file to rba_2 if non-zero, otherwise
**  position to rba_1 and search for the end of message
*/

reposition()
{
    int ch;

    if (rba_2[0] | rba_2[1] | rba_2[2]) {
        setpos(packet_p, rba_2);
        return;
    }

    setpos(packet_p, rba_1);
    do {
        ch = fgetc(packet_p);
    } while (ch != 0 && ch != EOF);

    if (ch == EOF) {
        fputs("Reposition error\n", stderr);
    } else
        fputs("Repositioned\n", stderr);
}

/* read and check packet header */

int read_pkthdr()
{
    int n;
    int ptonode, ptonet, ver;

    n = fread(pkthdr, 1, 58, packet_p);
    if (n != 58) {
        fputs("Cannot read packet header!\n", stderr);
        return 2;
    }

    pktnode = getw(pkthdr + 0);
    ptonode = getw(pkthdr + 2);
    pktnet = getw(pkthdr + 20);
    ptonet = getw(pkthdr + 22);

    if (getw(pkthdr + 18) != 2) {
        pnumb(stderr, "Packet version = ", getw(pkthdr + 18), "!\n");
        return 2;
    }

    if (ptonode != ZETA_NODE || ptonet != ZETA_NET) {
        fputs("Packet is not addressed to Zeta!\n", stderr);
        return 2;
    }

    fromlink = NOLINK;
    if (pktnode == HOST_NODE && pktnet == HOST_NET) {
        fputs("Packet from our Fidonet link\n", stderr);
        fromlink = FIDOLINK;
    }
    if (pktnode == ACS_NODE && pktnet == ACS_NET) {
        fputs("Packet from our ACSnet link\n", stderr);
        fromlink = ACSLINK;
    }
    if (fromlink == NOLINK) {
        fputs("Packet from somebody else\n", stderr);
    }
    return 0;
}

/* read a fidonet message header and check its contents a little */

int read_msghdr()
{
    int n, n1, n2;

    n1 = fgetc(packet_p);
    n2 = fgetc(packet_p);

    if (n1 == EOF || n2 == EOF) {
        fputs("Truncated packet\n", stderr);
        return 2;
    }

    n1 = (n1 & 255) + 256 * (n2 & 255);

    if (n1 == 0) {
        /* end of packet */
        return 1;
    }

    if (n1 != 2) {
        fputs("Message version # != 2!\n", stderr);
        return 2;
    }

    n = fread(pktmsg, 1, 12, packet_p);
    if (n != 12) {
        fputs("Short message header\n", stderr);
        return 2;
    }

    fromnode = getw(pktmsg + 0);
    tonode = getw(pktmsg + 2);
    fromnet = getw(pktmsg + 4);
    tonet = getw(pktmsg + 6);

    fromzone = 0;
    frompoint = 0;

    return 0;
}

/* read_every ..
**	Go through the (possibly entire) message, and determine:
**	- If it is addressed to us
**	- If it is addressed to a Zeta user
**	- If it is echomail (read_body)
**		- where did it originate from
**		- what conference is it in
**	- If it is netmail (read_body)
**		- What Zone, net, node, point
**
**	From this information build up:
**	from_str	Contains a from address
**	to_str		Contains a to address
**	conf_no		Nr of echomail conf (or 0 if unknown)
**	user_no		Zeta user number
**	msg_type	Contains one or more of these bits set:
**		IS_NETMAIL
**		IS_ECHOMAIL
**		IS_ZETAUSER
**		IS_ACSNET
**	This information is sufficient to process it!
*/

int read_every()
{
    int rc;

    msg_type = IS_NONE;

    rc = read_head();
    if (rc)
        return 2;
    savepos(packet_p, rba_1);   /* like ftell() */
    zeropos(rba_2);             /* set it to 0 */

    if (fromnet == ACS_NET && fromnode == ACS_NODE) {
        msg_type |= IS_ACSNET;
    }

    /* set to reroute if not to us */

    if (tonet != ZETA_NET || tonode != ZETA_NODE) {
        if (tonet != OLD_NET || tonode != OLD_NODE) {
            strcpy(to_str, fto);

            /* add (nnn/nnn) if not going to ACSnet */
            if (tonet != ACS_NET || tonode != ACS_NODE) {
                fidocat(to_str, 0, tonet, tonode, 0);
            }

            strcpy(from_str, ffrom);
            fidocat(from_str, 0, fromnet, fromnode, 0);
            msg_type |= IS_NETMAIL;
            return 0;
        }
    }

    user_no = user_search(fto);
    if (user_no > 0) {
        /* a valid Zeta user! */
        strcpy(fto, user_field);        /* format it (urgh) */
        msg_type |= IS_ZETAUSER;
    }

    rc = read_body();
    if (rc == 1)
        return 1;               /* empty message */
    if (rc)
        return 2;
    return 0;
}

/* fidocat ... concatenate a fidonet address to a string */

fidocat(s, zone, net, node, point)
char *s;
int zone, net, node, point;
{
    char *cp;

    for (cp = s; *cp; ++cp) ;

    *cp++ = ' ';
    *cp++ = '(';

    if (zone && zone != OUR_ZONE) {
        cp = numstr(cp, zone);
        *cp++ = ':';
    }

    cp = numstr(cp, net);
    *cp++ = '/';
    cp = numstr(cp, node);

    if (point) {
        *cp++ = '.';
        cp = numstr(cp, point);
    }

    *cp++ = ')';
    *cp++ = 0;
}
