/*  bunfunc.c ...  Functions to read & write bundles
**	@(#) bunfunc.c 14 Aug 90
**
**	The following functions are provided:
**
**  makepkt(fp, net, node, zone)
**	Create a bundle from us (defined in zeta.h) to the specified node.
**  makemsg(fp, flags)
**	Write a type-2 message header from us to the node specified by
**	the external variables to_net and to_node. Set the message flags
**	to that specified by the flags parameter.
**  copydat(fp)
**	Copy the 4 message header fields (to, from, date, subject) into
**	the bundle from the external variables (newdate, newfrom, newto,
**	newsubj).
**
**  Modifications:
** 14 Aug 90	Add flags parameter to makemsg() function
** 31 Jul 90	Add zone numbers to bundle header
** 19 May 90	Base version
*/

#include <stdio.h>
#include "zeta.h"

/* Variables ... */

#define EXTERN	extern

EXTERN char pkthdr[], pktmsg[], newdate[], newfrom[], newto[], newsubj[];

EXTERN int to_zone, to_net, to_node, to_point;

/*  makepkt ... Make & write a bundle header if necessary */

int makepkt(fp, net, node, zone)
FILE *fp;
int net, node, zone;
{
    int n;

    n = fseek(fp, 0, 2);
    if (n > 0) {
        return 0;
    }

    putw(pkthdr + 0, ZETA_NODE);
    putw(pkthdr + 2, node);
    putw(pkthdr + 4, getyear() + 1900);
    putw(pkthdr + 6, getmonth() - 1);
    putw(pkthdr + 8, getday());
    putw(pkthdr + 10, gethour());
    putw(pkthdr + 12, getminute());
    putw(pkthdr + 14, getsecond());
    putw(pkthdr + 16, 0);       /* rate=0 */
    putw(pkthdr + 18, 2);       /* ver=2 */
    putw(pkthdr + 20, ZETA_NET);
    putw(pkthdr + 22, net);

    for (n = 24; n < 58; ++n)
        pkthdr[n] = 0;

    putw(pkthdr + 34, ZETA_ZONE);
    putw(pkthdr + 36, zone);

    n = fwrite(pkthdr, 1, 58, fp);
    if (n != 58) {
        fputs("Cannot write bundle header!\n", stderr);
        exit(3);
        return 3;
    }

    fputc(0, fp);
    fputc(0, fp);
    return 0;
}

/*  makemsg ... Make & write a 14 byte long message header for a bundle */

int makemsg(fp, flags)
FILE *fp;
int flags;
{
    int n;

    putw(pktmsg + 0, 2);        /* type=2 */
    putw(pktmsg + 2, ZETA_NODE);
    putw(pktmsg + 4, to_node);
    putw(pktmsg + 6, ZETA_NET);
    putw(pktmsg + 8, to_net);
    putw(pktmsg + 10, flags);   /* Message Attributes */
    putw(pktmsg + 12, 10);      /* cost */

    n = fwrite(pktmsg, 1, 14, fp);
    if (n != 14) {
        fputs("Cannot write bundle message header!\n", stderr);
        return 3;
    }
    return 0;
}

/* copydat ...
**	Write the 4 fields into a Fidonet bundle
*/

int copydat(fp)
FILE *fp;
{
    int n;

    fputs(newdate, fp);
    fputc(0, fp);
    fputs(newto, fp);
    fputc(0, fp);
    fputs(newfrom, fp);
    fputc(0, fp);
    fputs(newsubj, fp);
    fputc(0, fp);

    return 0;                   /* kludge */
}

/* end of bunfunc.c */
