/*  bbass2.c ... 
**	Functions for Bbass
**	@(#) bbass2.c: 27 Aug 90
**
*/

#include <stdio.h>

#define EXTERN extern
#include "bbass.h"
#include "packctl.h"
#include "zeta.h"

#ifdef	REALC
extern FILE	*openf2();
extern char	*nextword();
#endif

/* openloc - open local message files */

openloc() {
	loctxt_p = openf2(LOCTXT);
	lochdr_p = openf2(LOCHDR);
	loctop_p = openf2(LOCTOP);
}

/* openmsg - open BB message files */

openmsg() {
	msgtxt_p = openf2(MSGTXT);
	msghdr_p = openf2(MSGHDR);
	msgtop_p = openf2(MSGTOP);
}

/* initloc: read the number of messages and the free sector bitmap */

initloc() {
	int	n;

	n = secseek(loctop_p, 0);
	if (n) {
		fputs("Could not seek loctop_p to 0!\n", stderr);
		exit(2);
	}

	n = secread(loctop_p, topbufl);
	if (n) {
		fputs("Could not read first sector of topic file!\n", stderr);
		exit(2);
	}

	num_msgl = getw(topbufl);

	n = secseek(loctxt_p, 0);
	if (n) {
		fputs("Could not seek loctxt_p to 0!\n", stderr);
		exit(2);
	}

	n = secread(loctxt_p, freeloc);
	if (n) {
		fputs("Could not read free space bitmap!\n", stderr);
		exit(2);
	}
}

/* initmsg: read the number of messages and the free sector bitmap */

initmsg() {
	int	n;

	n = secseek(msgtop_p, 0);
	if (n) {
		fputs("Could not seek msgtop_p to 0!\n", stderr);
		exit(2);
	}

	n = secread(msgtop_p, topbufm);
	if (n) {
		fputs("Could not read first sector of topic file!\n", stderr);
		exit(2);
	}

	num_msgm = getw(topbufm);

	n = secseek(msgtxt_p, 0);
	if (n) {
		fputs("Could not seek msgtxt_p to 0!\n", stderr);
		exit(2);
	}

	n = secread(msgtxt_p, freemsg);
	if (n) {
		fputs("Could not read free space bitmap!\n", stderr);
		exit(2);
	}
}

/*  read_hdr ... read a 16 byte header record */

int	read_hdr() {
	int	n;

	fseek(msghdr_p, this_msg * 16, 0);
	n = fread(oldhdr, 1, 16, msghdr_p);
	if (n == 16) return 0;	/* ok */

	fputs("Error reading header file\n", stderr);

	return -1;
}

/* closloc - close the local message files */

closloc() {
	fclose(loctxt_p);
	fclose(lochdr_p);
	fclose(loctop_p);
}

/* closmsg - close the BB message files */

closmsg() {
	fclose(msgtxt_p);
	fclose(msghdr_p);
	fclose(msgtop_p);
}

/* readhead ...
**	read the 4 fields from msgtxt
*/

int	readhead() {
	int	n;

	read_rec = getw(oldhdr+3);
	if (read_rec < 0 || read_rec > 2047) {
		fputs("Bad record number!\n", stderr);
		return 1;
	}

	n = readtxt(msgtxt_p, oldtxt, read_rec);
	read_pos = 2;
	if (n) {
		fputs("Could not read first sector of message!\n", stderr);
		return n;
	}

	n = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);	/* ff */
	n = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);	/* 0  */
	n = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);	/* 0  */

	n = getstxt(oldfrom, 80, msgtxt_p, oldtxt, &read_rec, &read_pos);
	n |= getstxt(oldto, 80, msgtxt_p, oldtxt, &read_rec, &read_pos);
	n |= getstxt(olddate, 80, msgtxt_p, oldtxt, &read_rec, &read_pos);
	n |= getstxt(oldsubj, 80, msgtxt_p, oldtxt, &read_rec, &read_pos);

	if (n) {
		fputs("Unable to read header fields from msgtxt\n", stderr);
	}

	return n;
}

/* savetopic ...
**	save the topic code (ha) of the new local message
*/

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
		&write_pos, freeloc);
	n |= putctxt(0, loctxt_p, newtxt, &write_rec,
		&write_pos, freeloc);
	n |= putctxt(0, loctxt_p, newtxt, &write_rec,
		&write_pos, freeloc);

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
**	Write a CR-terminated string to the new local message
*/

int	write2(s)
char	*s;
{
	int	n;

	n = putstxt(s, loctxt_p, newtxt, &write_rec,
		&write_pos, freeloc);
	n |= putctxt(0x0d, loctxt_p, newtxt, &write_rec,
		&write_pos, freeloc);

	return n;
}

/*  localcpy ...
**	Copy the text of a message from msgtxt to loctxt
*/

int	localcpy() {
	int	n;
	char	ch;

	ch = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);
	while (ch != 0) {
		if (ch < 0) {
			fputs("Trouble reading message msgtxt\n", stderr);
			recover(1, 0, 0);
			return 1;
		}

		n = putctxt(ch, loctxt_p, newtxt, &write_rec,
			&write_pos, freeloc);
		if (n) {
			fputs("Local message base full! (localcpy)\n", stderr);
			recover(1, 0, 0);
			return n;
		}
		ch = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);
	}

	return 0;
}

/*  localfls ...
**	Flush the local output (loctxt)
*/

int	localfls() {
	int	n;

	n = putctxt(0, loctxt_p, newtxt, &write_rec,
		&write_pos, freeloc);
	if (n) {
		fputs("Local message base full! (localfls)\n", stderr);
		recover(1, 0, 0);
		return n;
	}

	n = flushtxt(loctxt_p, newtxt, &write_rec, &write_pos);

	if (n) {
		fputs("Trouble flushing local message\n", stderr);
		recover(1, 0, 0);
	}

	return n;
}

/*  setproc ...
**	Set the flags for this message as processed (msghdr)
*/

int	setproc() {
	int	n;

	fseek(msghdr_p, this_msg * 16, 0);
	oldhdr[0] |= F_PROCESSED;
	n = fwrite(oldhdr, 1, 16, msghdr_p);
	if (n == 16) return 0;

	fputs("Could not rewrite msghdr file!\n", stderr);
	return 1;
}

/* copymsg ...
**	Copy a message and translate into Fidonet standard
*/

int	copymsg(fp)
FILE	*fp;
{
	char	ch;

	ch = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);
	while (ch != 0) {
		if (ch == -1) {
			fputs("Trouble reading msgtxt\n", stderr);
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
		ch = getctxt(msgtxt_p, oldtxt, &read_rec, &read_pos);
	}

	return 0;
}

/*  write_hdr ...
**	write the 16 byte header record to lochdr
*/

int	write_hdr() {
	int	n;

	fseek(lochdr_p, num_msgl * 16, 0);
	n = fwrite(newhdr, 1, 16, lochdr_p);
	if (n != 16) {
		fputs("Could not write lochdr file!\n", stderr);
		return -1;
	}

	++num_msgl;
	return 0;
}

/*  rewrite_hdr ...
**	rewrite the old header record (msghdr) as processed (I hope).
*/

int	rewrite_hdr() {
	int	n;

	fseek(msghdr_p, this_msg * 16, 0);
	n = fwrite(oldhdr, 1, 16, msghdr_p);
	if (n != 16) {
		fputs("Could not rewrite msghdr file!\n", stderr);
		return -1;
	}

	return 0;
}

/* wtop_loc ...
**	rewrite the number of messages (loctop)
*/

int	wtop_loc() {
	int	n;

	fseek(loctop_p, 0, 0);
	fputc(num_msgl & 255, loctop_p);
	fputc((num_msgl >> 8) & 255, loctop_p);
	return 0;
}

/* wtop_msg ...
**	rewrite the number of messages (msgtop)
*/

int	wtop_msg() {
	int	n;

	fseek(msgtop_p, 0, 0);
	fputc(num_msgm & 255, msgtop_p);
	fputc((num_msgm >> 8) & 255, msgtop_p);
	return 0;
}

/*  addarea ...
**	Write an area line to the output bundle file
*/

int	addarea(fp, areaname)
FILE	*fp;
char	*areaname;
{
	fputs(AREA, fp);
	fputs(areaname, fp);
	fputc(0x0d, fp);
	fputc(0x0a, fp);

	return 0;
}

/*  addtear ...
**	Write tear line, origin, and SEEN-BYs
*/

int	addtear(fp, conftype)
FILE	*fp;
int	conftype;
{
	fputs(TEAR, fp);
	fputc(0x0d, fp);
	fputc(0x0a, fp);

	fputs(ORIGIN, fp);
	fputs("Zeta - MINIX, Unix, Xenix support! (02) 627-4177 ", fp);
	fputs("(3:", fp);

	nnout(ZETA_NET, ZETA_NODE, fp);
	fputs(")", fp);
	fputc(0x0d, fp);
	fputc(0x0a, fp);

	fputs(SEEN, fp);

	nnout(ZETA_NET, ZETA_NODE, fp);
	fputc(' ', fp);
	if (conftype == E_ACSNET)
		nnout(ACS_NET, ACS_NODE, fp);
	else
		nnout(HOST_NET, HOST_NODE, fp);

	fputc(0x0d, fp);
	fputc(0x0a, fp);
	fputc(0x0d, fp);
	fputc(0x0a, fp);

	/* End the message */
	fputc(0, fp);

	/* Write two null bytes to end the bundle (later overwritten) */
	fputc(0, fp);
	fputc(0, fp);

	return 0;
}

/* output a net and node number to a file */

nnout(net, node, fp)
int	net;
int	node;
FILE	*fp;
{
	itoa(net, tstring);
	fputs(tstring, fp);
	fputs("/", fp);
	itoa(node, tstring);
	fputs(tstring, fp);
}

/* end of bbass2.c */
