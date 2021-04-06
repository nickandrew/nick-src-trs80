/*  Packdis ... Process fidonet packets sent to Zeta
**	@(#) packdis1.c: 1.0h 20 May 90
**	Packdis1 contains high-level control routines
**
**  Process echomail into msgtxt (and loctxt if addressed to a zeta user)
**  Process netmail of any sort into loctxt as an in-transit message,
**	which will be processed by Mailass later.
**
** 1.0h 19 May 90
**	Change net & node address of ACSgate
**	Clarify some messages & change output slightly
** 1.0g 05 Aug 89
**	Fix aborts due to long "From" fields in packets
**	Fix code to bounce a netmail message to a nonexistent Zeta user
** 1.0f 17 Jul 89
**	Base version
*/

#include <stdio.h>

#define EXTERN
#include "packdis.h"
#include "packctl.h"
#include "zeta.h"

EXTERN char optstring[] = "rRpPiI";

#ifdef	REALC
extern FILE *openf2();
#define LONG	long
#else
#define LONG	int
#endif

main(argc, argv)
int argc;
char *argv[];
{
    int c;
    int status, rc;

    rc = 0;
    open_loc();
    open_msg();
    read_control();

    while ((c = getopt(argc, argv, optstring)) != EOF)
        switch (c) {
        case 'R':
        case 'r':
            r_flag = 1;
            break;

        case 'P':
        case 'p':
            p_flag = 1;
            break;

        case 'I':
        case 'i':
            i_flag = 1;
            break;

        default:
            usage();
        }

    if (p_flag)
        rc = proc_batch();

    while (optind < argc && rc <= 2) {
        rc = proc_pkt(argv[optind++]);
    }

    closef();
    exit(0);
}

/* print a useful usage message */

usage()
{
    fputs("Usage: packdis [-p] [-r] [packet files ...]\n", stderr);
    fputs("-p:  Read packet names from batched file PACKETS\n", stderr);
    fputs("-r:  Remove packets if successfully processed\n", stderr);
    exit(1);
}

/* proc_batch
** process a (possible) batch of messages, from "packets"
*/

int proc_batch()
{
    int rc;
    LONG filepos;
    int group_ok;

    batch_p = openf2(PACKETS);

    group_ok = 1;

    for (;;) {
        filepos = ftell(batch_p);
        if (fgets(batchline, 79, batch_p) == NULL)
            break;

        getfn(batchline, fn);
        fixfn(fn);

        if (*batchline == 'A') {
            if (!group_ok) {
                fputs("Cannot remove ", stderr);
                fputs(fn, stderr);
                fputs("- partly processed\n", stderr);
                group_ok = 1;
                continue;
            }

            /* remove! */
            unlink(fn);
            *batchline = 'R';
            /* rewrite the line */
            fseek(batch_p, filepos, 0);
            fputs(batchline, batch_p);
            continue;
        }

        if (*batchline == 'R') {
            group_ok = 1;
            continue;
        }

        if (*batchline == 'E') {
            fputs("Packet ", stderr);
            fputs(fn, stderr);
            fputs(" is in error\n", stderr);
            group_ok = 0;
            continue;
        }

        if (*batchline != ' ')  /* was processed */
            continue;

        rc = proc_pkt(fn);

        if (rc == 0) {
            fseek(batch_p, filepos, 0);
            *batchline = '-';
            fputs(batchline, batch_p);
        } else {
            group_ok = 0;
            if (rc == 2) {
                fseek(batch_p, filepos, 0);
                *batchline = 'E';
                fputs(batchline, batch_p);
            }
            if (rc > 2)
                break;
        }
    }
    fclose(batch_p);
    if (rc <= 2)
        rc = 0;
    return rc;
}

/* proc_pkt ...
** process one packet fully as possible.
** Before return, commit changes
**	return code:
**	0	All OK
**	1	Message system full, backed out
**	2	Packet has an error, backed out
**	x	Fatal error
*/

int proc_pkt(fn)
char *fn;
{
    int n, rc, rc1, rc2;

    packet_p = fopen(fn, "r");
    if (packet_p == NULL) {
        fputs("Cannot open packet ", stderr);
        fputs(fn, stderr);
        fputs(" - ignoring\n", stderr);
        return 1;
    }

    fputs("Processing ", stderr);
    fputs(fn, stderr);
    fputc('\n', stderr);

    rc = read_pkthdr();
    if (rc)
        return 2;

    while (1) {
        rc = read_msghdr();
        if (rc) {
            if (rc == 1)
                rc = 0;
            break;
        }

        /* process this message */

        rc = read_every();
        if (rc == 1)
            continue;           /* empty message */
        if (rc > 1)
            break;              /* some sort of error */

        rc = write_msg();       /* write to echomail file */
        if (rc)
            break;

        rc = write_loc();       /* write to local mail file */
        if (rc)
            break;

        reposition();
    }

    if (rc) {
        fputs("Backing out of loctxt, msgtxt changes\n", stderr);
        n = read_info(loctxt_p, loctop_p, &loc_msgs, locfree);
        if (n) {
            fputs("Could not reread loctxt\n", stderr);
        }
        n = read_info(msgtxt_p, msgtop_p, &msg_msgs, msgfree);
        if (n) {
            fputs("Could not reread msgtxt\n", stderr);
        }
        return rc;
    }

    fputs("Committing changes\n", stderr);

    rc = writefree(loctxt_p, locfree);
    rc |= write_top(loctop_p, loc_msgs);
    if (rc) {
        fputs("Could not commit change to loctxt\n", stderr);
        return 3;
    }

    rc = writefree(msgtxt_p, msgfree);
    rc |= write_top(msgtop_p, msg_msgs);
    if (rc) {
        fputs("Could not commit change to msgtxt\n", stderr);
        return 3;
    }

    fclose(packet_p);
    if (r_flag) {
        fputs("Unlinking ", stderr);
        fputs(fn, stderr);
        fputs("\n", stderr);
        unlink(fn);
    }
    return 0;
}
