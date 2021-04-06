/*  packdis3.c - part of packdis, packet disassembler
**	Message file handling routines for packdis
**	@(#) packdis3.c: 20 May 90
*/


#include <stdio.h>

#define EXTERN extern
#include "packdis.h"
#include "packctl.h"
#include "zeta.h"

#ifdef	REALC
extern FILE *openf2();
#define LONG	long
#else
#define LONG	int
#endif

/* open the local mail database files and read initial stuff */

open_loc()
{
    int n;

    loctxt_p = openf2(LOCTXT);
    lochdr_p = openf2(LOCHDR);
    loctop_p = openf2(LOCTOP);

    n = read_info(loctxt_p, loctop_p, &loc_msgs, locfree);
    if (n) {
        fputs("Could not read local info!\n", stderr);
        exit(1);
    }
}

/* open the echomail database files and read initial stuff */

open_msg()
{
    int n;

    msgtxt_p = openf2(MSGTXT);
    msghdr_p = openf2(MSGHDR);
    msgtop_p = openf2(MSGTOP);

    n = read_info(msgtxt_p, msgtop_p, &msg_msgs, msgfree);
    if (n) {
        fputs("Could not read msgtxt info!\n", stderr);
        exit(1);
    }
}

/* read the number of messages and the free sector bitmap */

int read_info(txt_p, top_p, pmsgs, freeptr)
FILE *txt_p;
FILE *top_p;
int *pmsgs;
char *freeptr;
{
    int n;

    n = secseek(top_p, 0);
    if (n) {
        return n;
    }

    n = secread(top_p, topbuf);
    if (n) {
        return n;
    }

    *pmsgs = getw(topbuf);

    n = secseek(txt_p, 0);
    if (n)
        return n;

    n = secread(txt_p, freeptr);
    return n;
}

/* write_loc: If IS_NETMAIL or IS_ZETAUSER, then write it to loctxt
**	return 0 if successful, 1 if message system full, 2 if packet
**	error, >2 if fatal error
*/

int write_loc()
{
    int n;
    int msg_flag;

    if ((msg_type & (IS_NETMAIL | IS_ZETAUSER)) == 0)
        return 0;
    setpos(packet_p, rba_1);    /* like fseek() */

    write_rec = rec_first = getfree(locfree);
    if (write_rec == -1) {
        fputs("Local mail system full (1)!\n", stderr);
        return 1;
    }

    write_pos = 2;
    zeromem(newtxt, 256);
    savetopic(loctop_p, loc_msgs, 0);   /* save 0 topic code */
    msg_flag = F_NEW;
    if (msg_type & IS_ZETAUSER)
        msg_flag |= F_INCOMING;
    else
        msg_flag |= F_INTRANSIT;        /* Mailass to bounce */

    buildmsg(msg_flag, 0, user_no, 0);

    localdat();
    n = writeld();              /* write loc data headers */
    if (n)
        return n;

    n = loc_cpy();              /* write loc message */
    if (n)
        return n;

    n = writeh(lochdr_p, &loc_msgs);    /* write loc header */
    if (n)
        return n;

    savepos(packet_p, rba_2);   /* save position for later */
    fputs("write_loc worked\n", stderr);
    return 0;
}

/* write_msg: If IS_ECHOMAIL, then write it to msgtxt
**	return 0 if successful, 1 if message system full, 2 if packet
**	error, >2 if fatal error
*/

int write_msg()
{
    int n;

    if ((msg_type & IS_ECHOMAIL) == 0)
        return 0;

    setpos(packet_p, rba_1);    /* like fseek() */

    write_rec = rec_first = getfree(msgfree);
    if (write_rec == -1) {
        fputs("News & Echomail message base full (2)!\n", stderr);
        return 1;
    }

    write_pos = 2;
    zeromem(newtxt, 256);
    savetopic(msgtop_p, msg_msgs, conftop[conf_no]);
    buildmsg(0, 0, user_no, conftop[conf_no]);

    msgdat();

    n = writemd();              /* write msg data headers */
    if (n)
        return n;

    n = msg_cpy();
    if (n)
        return n;

    n = writeh(msghdr_p, &msg_msgs);
    if (n)
        return n;

    savepos(packet_p, rba_2);   /* save position for later */
/*	fputs("write_msg worked\n", stderr);	*/
    return 0;
}

/* save the topic code of the message */

savetopic(fp, msgn, tc)
FILE *fp;
int msgn, tc;
{
    LONG offset;

    offset = 4096 + msgn;
    fseek(fp, offset, 0);
    fputc(tc & 255, fp);
}

/* build a 16-byte header for the msg file */

buildmsg(flags, sndr, rcvr, topic)
int flags, sndr, rcvr, topic;
{
    newhdr[0] = flags;
    newhdr[1] = 3;              /* # lines (dummy - not used?) */
    newhdr[2] = 0;              /* was msb of rba */
    putw(newhdr + 3, write_rec);        /* first sector address */
    newhdr[5] = getday();
    newhdr[6] = getmonth();
    newhdr[7] = getyear();
    putw(newhdr + 8, sndr);     /* ids unused */
    putw(newhdr + 10, rcvr);    /* receiver uid */
    newhdr[12] = topic;         /* topic code */
    newhdr[13] = getsecond();
    newhdr[14] = getminute();
    newhdr[15] = gethour();
}

/* create local data headers (should already be done mostly) */

localdat()
{
}

/* create msg data headers (should already be done mostly) */

msgdat()
{
}

/* write local data headers to local file */

int writeld()
{
    int n;

    fputs("From: ", stderr);
    fputs(from_str, stderr);
    fputs("\nTo: ", stderr);
    fputs(to_str, stderr);
    fputc('\n', stderr);

    n = lputc(0xff);
    if (n == 0) {
        n = lputc(0);
        n |= lputc(0);
        n |= lputs(from_str);
        n |= lputc(0x0d);
        n |= lputs(to_str);
        n |= lputc(0x0d);
        n |= lputs(fdate);
        n |= lputc(0x0d);
        n |= lputs(fsubj);
        n |= lputc(0x0d);
    }

    if (n) {
        fputs("Local message base full (3)!\n", stderr);
        return 1;
    }

    return 0;
}

/* shorten the routines to put a char or string to local or msg */

int lputc(c)
int c;
{
    return putctxt(c, loctxt_p, newtxt, &write_rec, &write_pos, locfree);
}

int lputs(s)
int s;
{
    return putstxt(s, loctxt_p, newtxt, &write_rec, &write_pos, locfree);
}

int mputc(c)
int c;
{
    return putctxt(c, msgtxt_p, newtxt, &write_rec, &write_pos, msgfree);
}

int mputs(s)
int s;
{
    return putstxt(s, msgtxt_p, newtxt, &write_rec, &write_pos, msgfree);
}

/* write msg data headers to message file */

int writemd()
{
    int n;

    fputs(fsubj, stderr);
    fputc('\n', stderr);

    n = mputc(0xff);
    if (n == 0) {
        n |= mputc(0);
        n |= mputc(0);
        n |= mputs(from_str);
        n |= mputc(0x0d);
        n |= mputs(to_str);
        n |= mputc(0x0d);
        n |= mputs(fdate);
        n |= mputc(0x0d);
        n |= mputs(fsubj);
        n |= mputc(0x0d);
    }

    if (n) {
        fputs("News message base full (4)!\n", stderr);
        return 1;
    }

    return 0;
}

/* copy the packet (with translation) to local file */

int loc_cpy()
{
    int n;
    char ch;

    if (msg_type & IS_ECHOMAIL)
        n = readline();         /* read AREA line and ignore */

    n = readline();
    while (n != EOF && n != 0) {
        if (*line == 0x01) {
            /* ignore ^A lines */
            n = readline();
            continue;
        }

        if (lputs(line)) {
            fputs("Local message base full (5)\n", stderr);
            return 1;           /* do not assign to n */
        }

        if ((msg_type & IS_ECHOMAIL) && commence(line, ORIGIN) != NULL)
            break;              /* ignore all after origin */

        n = readline();
    }

    /* bypass everything after origin */
    while (n != 0 && n != EOF)
        n = readline();

    /* packet was truncated */
    if (n == EOF) {
        fputs("Truncated message (loc_cpy)\n", stderr);
        return 2;
    }

    if (n = lputc(0))
        return 1;

    n = flushtxt(loctxt_p, newtxt, &write_rec, &write_pos);
    if (n)
        return 3;

    return 0;
}

/* copy the packet (with different translation) to msg file */

int msg_cpy()
{
    int n;
    char ch;

    n = readline();             /* read AREA line and ignore */

    n = readline();
    while (n != EOF && n != 0) {
        if (*line == 0x01) {
            /* ignore ^A lines */
            n = readline();
            continue;
        }

        if (mputs(line)) {
            fputs("News & Echomail message base full (6)\n", stderr);
            return 1;           /* do not assign to n */
        }

        if (commence(line, ORIGIN) != NULL)
            break;              /* ignore all after origin */

        n = readline();
    }

    /* bypass everything after origin */
    while (n != 0 && n != EOF)
        n = readline();

    /* packet was truncated */
    if (n == EOF) {
        fputs("Truncated message (msg_cpy)\n", stderr);
        return 2;
    }

    n = mputc(0);
    if (n)
        return 1;

    n = flushtxt(msgtxt_p, newtxt, &write_rec, &write_pos);
    if (n)
        return 2;

    return 0;
}

/* write 16-byte header record to loc|msg files */

int writeh(hp, pmsgs)
FILE *hp;
int *pmsgs;
{
    int n;
    LONG l;

    l = *pmsgs * 16;
    fseek(hp, l, 0);
    n = fwrite(newhdr, 1, 16, hp);
    if (n == 16) {
        ++(*pmsgs);
        return 0;
    }

    fputs("Could not write header record!\n", stderr);
    return 3;
}

/* get a null-terminated string of a maximum length from a file */

int getfield(s, n, fp)
char *s;
int n;
FILE *fp;
{
    int c;
    while (n--) {
        c = fgetc(fp);
        if (c == EOF || c == 0)
            break;
        *s++ = c;
    }
    *s++ = 0;
    return c;
}

/* write the number of messages */

int write_top(fp, msgs)
FILE *fp;
int msgs;
{
    int n;

    n = secseek(fp, 0);
    if (n)
        return n;

    n = secread(fp, topbuf);
    if (n)
        return n;

    putw(topbuf, msgs);

    n = secseek(fp, 0);
    if (n)
        return n;

    n = secwrite(fp, topbuf);
    return n;
}

/* close all open files */

closef()
{
    fclose(loctxt_p);
    fclose(loctop_p);
    fclose(lochdr_p);
    fclose(msgtxt_p);
    fclose(msgtop_p);
    fclose(msghdr_p);
}
