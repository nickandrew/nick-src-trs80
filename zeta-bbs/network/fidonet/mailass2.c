/*  mailass2.c ... Process new messages in the local mail database
**	@(#) mailass2.c: 01 Aug 90
**
**  Process local mail, Fidonet mail or ACSnet mail
**	local mail: 	Duplicate the message into another
**	Fidonet mail:	Write a Fidonet packet to prophet
**	ACSnet mail:	Write a Fidonet packet to ACSgate
**
*/

#include <stdio.h>

#define EXTERN extern
#include "mailass.h"
#include "zeta.h"

#ifdef	REALC
extern FILE	*openf2();
extern char	*nextword();
#endif

/* open up all files, and ensure the packets contain a valid header */

openf() {
	loctxt_p = openf2(LOCTXT);
	lochdr_p = openf2(LOCHDR);
	loctop_p = openf2(LOCTOP);
	if (createf(FIDOPKT)) exit(1);
	if (createf(ACSPKT)) exit(1);
	fido_p = openf2(FIDOPKT);
	acs_p = openf2(ACSPKT);
	makepkt(fido_p, HOST_NET, HOST_NODE, HOST_ZONE);
	makepkt(acs_p, ACS_NET, ACS_NODE, ACS_ZONE);
}

/* read the number of messages and the free sector bitmap */

init() {
	int	n;

	n = secseek(loctop_p, 0);
	if (n) {
		fputs("Could not seek loctop_p to 0!\n", stderr);
		exit(2);
	}

	n = secread(loctop_p, topbuf);
	if (n) {
		fputs("Could not read first sector of topic file!\n", stderr);
		exit(2);
	}

	num_msg = getw(topbuf);

	n = secseek(loctxt_p, 0);
	if (n) {
		fputs("Could not seek loctxt_p to 0!\n", stderr);
		exit(2);
	}

	n = secread(loctxt_p, freemap);
	if (n) {
		fputs("Could not read free space bitmap!\n", stderr);
		exit(2);
	}
}

/*  read_hdr ... read a 16 byte header record */

int	read_hdr() {
	int	n;

	fseek(lochdr_p, this_msg * 16, 0);
	n = fread(oldhdr, 1, 16, lochdr_p);
	if (n == 16) return 0;	/* ok */

	fputs("Error reading header file\n", stderr);

	return -1;
}

/* close all the open files */

closef() {
	fclose(loctxt_p);
	fclose(lochdr_p);
	fclose(loctop_p);
	fclose(fido_p);
	fclose(acs_p);
}

/* readhead ...
**	read the 4 fields from loctxt
*/

int	readhead() {
	int	n;

	read_rec = getw(oldhdr+3);
	if (read_rec < 0 || read_rec > 2047) {
		fputs("Bad record number!\n", stderr);
		return 1;
	}

	n = readtxt(loctxt_p, oldtxt, read_rec);
	read_pos = 2;
	if (n) {
		fputs("Could not read first sector of message!\n", stderr);
		return n;
	}

	n = getctxt(loctxt_p, oldtxt, &read_rec, &read_pos);	/* ff */
	n = getctxt(loctxt_p, oldtxt, &read_rec, &read_pos);	/* 0  */
	n = getctxt(loctxt_p, oldtxt, &read_rec, &read_pos);	/* 0  */

	n = getstxt(oldfrom, 80, loctxt_p, oldtxt, &read_rec, &read_pos);
	n |= getstxt(oldto, 80, loctxt_p, oldtxt, &read_rec, &read_pos);
	n |= getstxt(olddate, 80, loctxt_p, oldtxt, &read_rec, &read_pos);
	n |= getstxt(oldsubj, 80, loctxt_p, oldtxt, &read_rec, &read_pos);

	if (n) {
		fputs("Unable to read header fields from loctxt\n", stderr);
	}

	return n;
}

/* save the topic code (ha) of the new message */

savetopic(msgn, tc)
int	msgn, tc;
{
	int	offset;

	offset = 4096 + msgn;
	fseek(loctop_p, offset, 0);
	fputc(tc & 255, loctop_p);
}

/* writedat ...
**	write data headers for new local message
*/

int	writedat() {
	int	n;

	n = putctxt(0xff, loctxt_p, newtxt, &write_rec,
		&write_pos, freemap);
	n |= putctxt(0, loctxt_p, newtxt, &write_rec,
		&write_pos, freemap);
	n |= putctxt(0, loctxt_p, newtxt, &write_rec,
		&write_pos, freemap);

	n |= write2(newfrom);
	n |= write2(newto);
	n |= write2(newdate);
	n |= write2(newsubj);

	if (n) {
		fputs("Local message base full! (writedat)\n", stderr);
		recover(1, 0, 0);
	}

	return n;
}

/*  write2 ...
**	Write a CR-terminated string to the new message
*/

int	write2(s)
char	*s;
{
	int	n;

	n = putstxt(s, loctxt_p, newtxt, &write_rec,
		&write_pos, freemap);
	n |= putctxt(0x0d, loctxt_p, newtxt, &write_rec,
		&write_pos, freemap);

	return n;
}

/*  localcpy ...
** Copy the entire text of one local message to another
*/

int	localcpy() {
	int	n;
	char	ch;

	do {
		ch = getctxt(loctxt_p, oldtxt, &read_rec, &read_pos);
		if (ch < 0) {
			fputs("Trouble reading local msg\n", stderr);
			recover(1, 0, 0);
			return 1;
		}

		n = putctxt(ch, loctxt_p, newtxt, &write_rec,
			&write_pos, freemap);
		if (n) {
			fputs("Local message base full! (localcpy)\n", stderr);
			recover(1, 0, 0);
			return n;
		}
	} while (ch != 0);

	n = flushtxt(loctxt_p, newtxt, &write_rec, &write_pos);

	if (n) {
		fputs("Trouble flushing local message\n", stderr);
		recover(1, 0, 0);
	}

	return n;
}

/*  setproc ...
**	Set the flags for this message as processed
*/

int	setproc() {
	int	n;

	fseek(lochdr_p, this_msg * 16, 0);
	oldhdr[0] |= F_PROCESSED;
	n = fwrite(oldhdr, 1, 16, lochdr_p);
	if (n == 16) return 0;

	fputs("Could not rewrite header file!\n", stderr);
	return 1;
}

/* copymsg ...
**	Copy a message and translate into Fidonet standard
*/

int	copymsg(fp)
FILE	*fp;
{
	char	ch;

	do {
		ch = getctxt(loctxt_p, oldtxt, &read_rec, &read_pos);
		if (ch == -1) {
			fputs("Trouble reading loctxt\n", stderr);
			return -1;
		}

		switch(ch) {
		case 0x0d:
			fputc(0x0d, fp);
			fputc(0x0a, fp);
			break;
		default:
			fputc(ch, fp);
		}
	} while (ch != 0);

	fputc(0, fp);
	fputc(0, fp);

	return 0;
}

/*  write_hdr ...
**	write the 16 byte local header record
*/

int	write_hdr() {
	int	n;

	fseek(lochdr_p, num_msg * 16, 0);
	n = fwrite(newhdr, 1, 16, lochdr_p);
	if (n != 16) {
		fputs("Could not write header file!\n", stderr);
		return -1;
	}

	++num_msg;
	return 0;
}

/*  rewrite_hdr ...
**	rewrite the old local header record (as a deleted message).
*/

int	rewrite_hdr() {
	int	n;

	fseek(lochdr_p, this_msg * 16, 0);
	n = fwrite(oldhdr, 1, 16, lochdr_p);
	if (n != 16) {
		fputs("Could not rewrite header file!\n", stderr);
		return -1;
	}

	return 0;
}

/* recover ...
** try to recover from errors
**	type == 1	Write error on msgtxt file
**	type == 2	Recover Fidonet packet (p1, p2 = fp, rba)
*/

recover(type, p1, p2)
int	type;
FILE	*p1;
int	p2;
{
	int	recnum;
	int	n;

	if (type == 1) {
		putfree(freemap, rec_first);
		recnum = rec_first;
		while (recnum != write_rec) {
			n = readtxt(loctxt_p, newtxt, recnum);
			if (n) {
				fputs("Could not recover (read)\n", stderr);
				exit(8);
			}
			recnum = getw(newtxt);
			putfree(freemap, recnum);
		}

		n = writefree(loctxt_p, freemap);
		if (n) {
			fputs("Could not recover (write)\n", stderr);
			exit(8);
		}
		return;
	}

	if (type == 2) {
		/* zap away the start of this packed message */
		fseek(p1, p2, 0);
		fputc(0, p1);
		fputc(0, p1);
		return;
	}
}

/* bouncecpy ...
**	Copy appropriate text into the new message
**  type:
**	0 - bounce to local user (explain addresses)
**	1 - bounce to remote user (say no Zeta user)
**	2 - bounce to sysop (detected bounce loop)
*/

int	bouncecpy(type)
int	type;
{
	int	n;

	n = 0;
	if (type != 2) {
		n |= bounce2(bm[0]);
		n |= bounce2(oldto);
		n |= bounce2(bm[1]);
	}

	if (type == 0) {
		n |= bounce2(bm[2]);
		n |= bounce2(bm[3]);
		n |= bounce2(bm[4]);
		n |= bounce2(bm[5]);
		n |= bounce2(bm[6]);
	}

	if (type == 1) {
		n |= bounce2(bm[8]);
	}

	if (type == 2) {
		n |= bounce2(bm[7]);
		strcpy(tstring, "From: ");
		strcat(tstring, oldfrom);
		strcat(tstring, "\n");
		n |= bounce2(tstring);
		strcpy(tstring, "To:  ");
		strcat(tstring, oldto);
		strcat(tstring, "\n");
		n |= bounce2(tstring);
	}

	if (type != 0) {
		n |= bounce2(bm[9]);
		/* copy the full text of the message */
	}

	if (n) return n;

	n = putctxt(0, loctxt_p, newtxt, &write_rec, &write_pos, freemap);

	n |= flushtxt(loctxt_p, newtxt, &write_rec, &write_pos);

	return n;
}

/* bounce2 ...
**	write a string to the text file
*/

int	bounce2(s)
char	*s;
{
	return putstxt(s, loctxt_p, newtxt, &write_rec,
		&write_pos, freemap);
}

/* write_top ...
**	rewrite the number of messages
*/

int	write_top() {
	int	n;

	fseek(loctop_p, 0, 0);
	fputc(num_msg & 255, loctop_p);
	fputc((num_msg>>8) & 255, loctop_p);
	return 0;
}

/* end of mailass2.c */
