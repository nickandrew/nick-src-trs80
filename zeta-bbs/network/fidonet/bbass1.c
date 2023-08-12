/*  bbass ... Process new messages in the message database
**	@(#) bbass1.c: 1.0c 14 Aug 90
**
**  Process new mail entered into the msgtxt database
**	Echomail:	Write a Fidonet bundle to our Fidonet link
**	News:		Write a Fidonet bundle to our ACSnet link
**	If to a real user, copy to loctxt also
**
** 1.0c 14 Aug 90
**	Fix creation of bundle messages (private bit) in bunfunc.c
** 1.0b 31 Jul 90
**	Add zone numbers to bundle header
**	Modify to use bunfunc.c
** 1.0a 11 Jun 90
**	Change FIDO_NET to HOST_NET, FIDO_NODE to HOST_NODE
** 1.0  20 May 90
**	Base version
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define EXTERN
#include "bbass.h"
#include "bunfunc.h"
#include "gettime.h"
#include "getw.h"
#include "openf2.h"
#include "bb7func.h"
#include "msgfunc.h"
#include "zeta.h"
#include "packctl.h"

int main()
{
    int n;

    rc = 0;
    openf();
    init();
    read_control();

    for (this_msg = 0; this_msg < num_msgm; ++this_msg) {
        if (n = read_hdr()) {
            fputs("Bbass: bad header file!\n", stderr);
            rc |= 8;
            break;
        }

        if (ignorem())
            continue;

        if (n = do_msg()) {
            fputs("Bbass: Do_msg encountered error!\n", stderr);
            rc |= 16;
            break;
        }
    }

    rc |= writefree(loctxt_p, freeloc);
    rc |= wtop_loc();
    rc |= writefree(msgtxt_p, freemsg);
    rc |= wtop_msg();
    closef();

    return rc;
}

/* open up all files, and ensure the bundles contain a valid header */

void openf(void)
{
    openloc();
    openmsg();
    if (createf(FIDOPKT))
        exit(1);
    if (createf(ACSPKT))
        exit(1);
    fido_p = openf2(FIDOPKT);
    acs_p = openf2(ACSPKT);
    makepkt(fido_p, HOST_NET, HOST_NODE, HOST_ZONE);
    makepkt(acs_p, ACS_NET, ACS_NODE, ACS_ZONE);
}

/* initialise the two database files */

void init(void)
{
    initmsg();
    initloc();
}

/* close all the open files */

void closef(void)
{
    closloc();
    closmsg();
    fclose(fido_p);
    fclose(acs_p);
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

/* ignorem ...
**	Ignore PROCESSED and DELETED msgtxt messages
**	return 0 if message should be processed
**	(thats for F_NEW mostly, and F_OUTGOING for later)
*/

int ignorem(void)
{
    if (oldhdr[0] & (F_PROCESSED | F_DELETED))
        return 1;               /* ignore */
    if (oldhdr[0] & (F_NEW | F_OUTGOING))
        return 0;
    return 1;
}

/* do_msg ...
**	read the 4 header fields
**	find message's topic in topic array
**	if (found)
**		determine fidonet or usenet
**		create message in output bundle
**	(maybe message is a local message also)
**	if (To != "All")
**		check if a valid user
**		if a valid user
**			copy to local mail
**	return
**
*/

int do_msg(void)
{
    int rc;

    if (readhead())
        return 1;

    printout();

    conf_no = findtopic(oldhdr[12]);

    if (conf_no != -1) {
        /* gee, a real echomail/news locally generated message! */
        if (conftyp[conf_no] == E_FIDONET)
            rc = fido();
        else
            rc = usenet();

        if (rc) {
            fputs("Fidonet or USENET message output failed.\n", stderr);
            return rc;
        }

    } else {
        /* do a setproc() here, to say the message has been
         ** processed w.r.t Fidonet and USENET. If local message
         ** copy fails later, there's nothing we can do to
         ** recover and retry later
         */

        rc = setproc();
        if (rc)
            return rc;
    }

    /* Ignore messages to "All" */

    if (!strcmp(oldto, "All"))
        return 0;

    /* But return if it is not to a Zeta user */

    if (chk_local() == 0)
        return 0;

    rc = local();

    if (rc) {
        fputs("Local message copy failed!\n", stderr);
        fputs("Message is set to processed anyway\n", stderr);
        fputs("There is no recovery!\n", stderr);
        return rc;
    }

    return 0;
}

/*  Findtopic ...
**	Find the given topic number in the conf array
**	Return conf number if found, or -1 if not found
*/

int findtopic(int tc)
{
    int i;

    for (i = 0; i < confs; ++i) {
        if (conftop[i] == tc)
            return i;
    }

    return -1;
}

/*  deleteold ...
**	delete an in-transit or outgoing message after processing
**	(loctxt)
**	Not used in current version of program
*/

int deleteold(void)
{
    int n;
    int recnum;

    recnum = getw(oldhdr + 3);  /* first record */

    while (recnum != 0) {
        /* delete an allocated block */
        putfree(freeloc, recnum);
        n = readtxt(loctxt_p, oldtxt, recnum);
        if (n)
            return n;
        recnum = getw(oldtxt);
    }

    n = writefree(loctxt_p, freeloc);
    if (n)
        return n;

    oldhdr[0] |= F_DELETED;
    n = rewrite_hdr();
    if (n)
        return n;

    return 0;
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
**  Copy a message to the loctxt database
**	Reread the message from the top
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

    /* reposition to the start of the message text */

    if (readhead())
        return 1;

    write_rec = rec_first = getfree(freeloc);
    if (write_rec == -1) {
        fputs("Bbass: Local message system very full!\n", stderr);
        return 8;
    }

    write_pos = 2;
    zeromem(newtxt, 256);

    savetopic(num_msgl, 0);     /* save 0 topic code */
    buildhdr(NOBODY, user_no, F_INCOMING | F_NEW);
    localdat();

    n = writedat();             /* write data headers */
    if (n)
        return n;

    n = localcpy();             /* write the data itself */
    if (n)
        return n;

    n = localfls();             /* flush the output */
    if (n)
        return n;

    n = write_hdr();
    if (n)
        return n;

    return 0;
}

/*  fido ...
**  Create a Fidonet echomail message
**	Position the output Fidonet bundle
**	Create and write a bundle message header
**	Add an AREA line
**	Copy the message, with translation
**	Add a SEEN-BY line
**	Set the current message to processed.
*/

int fido(void)
{
    int n;

    fp_msg = fseek(fido_p, -2, 2);

    to_net = HOST_NET;
    to_node = HOST_NODE;

    n = makemsg(fido_p, MA_PUBLIC);
    if (n) {
        fputs("Could not make message header\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    fidodat();                  /* convert the old to new headers */
    n = copydat(fido_p);
    if (n) {
        fputs("Could not copy header info to fidonet\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    n = addarea(fido_p, confpos[conf_no]);
    if (n) {
        fputs("Could not add AREA line\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    n = copymsg(fido_p);
    if (n) {
        fputs("Could not copy message to fidonet\n", stderr);
        recover(2, fido_p, fp_msg);
        return n;
    }

    n = addtear(fido_p, conftyp[conf_no]);
    if (n) {
        fputs("Could not add tear line, origin etc...\n", stderr);
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

/*  usenet ...
**	Process a message to go into USENET
**	Basically the same as fido(), except using acs_p
*/

int usenet(void)
{
    int n;

    ap_msg = fseek(acs_p, -2, 2);

    to_net = ACS_NET;
    to_node = ACS_NODE;

    n = makemsg(acs_p, MA_PUBLIC);
    if (n) {
        fputs("Could not make message header to ACSnet\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    fidodat();                  /* convert the old to new headers */
    n = copydat(acs_p);
    if (n) {
        fputs("Could not copy header info to ACSnet bundle\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    n = addarea(acs_p, confpos[conf_no]);
    if (n) {
        fputs("Could not add AREA line to ACSnet bundle\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    n = copymsg(acs_p);
    if (n) {
        fputs("Could not copy message to ACSnet bundle\n", stderr);
        recover(2, acs_p, ap_msg);
        return n;
    }

    n = addtear(acs_p, conftyp[conf_no]);
    if (n) {
        fputs("Could not add tear line, origin etc...\n", stderr);
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

/* build a new message header for lochdr */

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

/* fidodat ...
**	Create new data headers for Echomail/USENET
*/

void fidodat(void)
{
    char *cp;

    /* these fields could be too long! */
    strcpy(newfrom, oldfrom);
    strcpy(newto, oldto);

    /* get rid of the (nnn/nnn) possibly after the name */
    for (cp = newto; *cp; ++cp) {
        if (*cp == '(') {
            *cp = '\0';
            if (cp[-1] == ' ')
                cp[-1] = '\0';
            break;
        }
    }

    /* this date format is probably not correct */
    strcpy(newdate, olddate);

    /* must be sure the subject is short enough too! */
    strcpy(newsubj, oldsubj);
}

/* recover ...
** try to recover from errors
**	type == 1	Write error on loctxt file
**	type == 2	Recover Fidonet bundle (p1 = fp, p2 = rba)
*/

void recover(int type, FILE *p1, int p2)
{
    int recnum;
    int n;

    if (type == 1) {
        fputs("Recovery type 1\n", stderr);
        fputs("Freeing newly allocated loctxt blocks.\n", stderr);
        putfree(freeloc, rec_first);
        recnum = rec_first;
        while (recnum != write_rec) {
            n = readtxt(loctxt_p, newtxt, recnum);
            if (n) {
                fputs("Could not recover (read)\n", stderr);
                exit(8);
            }
            recnum = getw(newtxt);
            putfree(freeloc, recnum);
        }

        /* write the free block map */
        n = writefree(loctxt_p, freeloc);
        if (n) {
            fputs("Could not recover (write)\n", stderr);
            exit(8);
        }
        return;
    }

    if (type == 2) {
        /* zap away the start of this packed message */
        /* this does nothing for the EOF, by the way */

        fputs("Recovery type 2 - Zap start of bundle.\n", stderr);
        fseek(p1, p2, 0);
        fputc(0, p1);
        fputc(0, p1);
        return;
    }
}

/*  printout ...
**	Write the message header to the screen
*/

void printout(void)
{
    fputs("From: ", stderr);
    fputs(oldfrom, stderr);
    fputs("\nTo:   ", stderr);
    fputs(oldto, stderr);
    fputs("\nSubj: ", stderr);
    fputs(oldsubj, stderr);
    fputs("\n\n", stderr);
}

/* end of bbass1.c */
