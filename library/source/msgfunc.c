/* msgfunc ... Functions for message bases
**	Version 1.0  04 Mar 89
*/

#include <stdio.h>

/* read a particular sector from the text file */

int	readtxt(fp,bp,rr)
FILE	*fp;		/* file pointer */
char	*bp;		/* sector buffer pointer */
int	rr;		/* read record number */
{
	int	n;

	n = secseek(fp,rr);
	if (n) {
		fputs("readtxt: Could not seek!\n",stderr);
		return n;
	}

	n = secread(fp,bp);
	if (n) {
		fputs("readtxt: Could not read!\n",stderr);
	}
	return n;
}

/* getstxt ...
**	get a string from the text file
**	input string delimited by 0 or CR (CR not placed in output)
*/

int	getstxt(cp,len,fp,bp,prr,prp)
char	*cp;
int	len;
FILE	*fp;		/* text file pointer */
char	*bp;		/* sector buffer pointer */
int	*prr;		/* pointer to read record number */
int	*prp;		/* pointer to read position */
{
	int	c,n;

	if (len<2) return -1;

	while (--len) {
		if (*prp == 256) {
			*prr = getw(bp);
			if (*prr == 0) break;	/* eof */
			n = readtxt(fp,bp,*prr);
			if (n) return n;
			*prp = 2;
		}

		c = bp[(*prp)++];
		if (c==0 || c==0x0d) break;
		*cp++ = c;
	}
	*cp = 0;
	return 0;
}

/* getctxt ... get one character from the text file */

int	getctxt(fp,bp,prr,prp)
FILE	*fp;		/* text file pointer */
char	*bp;		/* sector buffer pointer */
int	*prr;		/* pointer to read record number */
int	*prp;		/* pointer to read position */
{
	int	n;

	if (*prp == 256) {
		*prr = getw(bp);
		if (*prr == 0) return -1;	/* eof */
		n = readtxt(fp,bp,*prr);
		if (n) return -n;
		*prp = 2;
	}

	return bp[(*prp)++];
}

/* write one character to the text file */

int	putctxt(ch,fp,bp,pwr,pwp,fm)
int	ch;
FILE	*fp;		/* text file pointer */
char	*bp;		/* sector buffer pointer */
int	*pwr;		/* pointer to write record number */
int	*pwp;		/* pointer to write position */
char	*fm;		/* free sector bitmap */
{
	int	n;
	int	nextrec;

	if (*pwp == 256) {
		nextrec = getfree(fm);
		if (nextrec == -1) {
			return -1;
		}

		putw(bp,nextrec);
		n = secseek(fp,*pwr);
		if (n) {
			/* undo that which hath been done */
			putfree(fm,nextrec);
			fputs("Could not seek loctxt_p to write_rec!\n",stderr);
			return n;
		}

		n = secwrite(fp,bp);
		if (n) {
			/* undo that which hath been done */
			putfree(fm,nextrec);
			fputs("Could not write text file!\n",stderr);
			return n;
		}

		zeromem(bp,256);
		*pwr = nextrec;
		*pwp = 2;
	}

	bp[(*pwp)++] = (ch & 255);
	return 0;
}

/* write a string of chars to the text file */

int	putstxt(s,fp,bp,pwr,pwp,fm)
char	*s;
FILE	*fp;		/* text file pointer */
char	*bp;		/* sector buffer pointer */
int	*pwr;		/* pointer to write record number */
int	*pwp;		/* pointer to write position */
char	*fm;		/* free sector bitmap */
{
	int	n;
	int	nextrec;

	while (*s) {
		if (*pwp == 256) {
			nextrec = getfree(fm);
			if (nextrec == -1) {
				return -1;
			}

			putw(bp,nextrec);
			n = secseek(fp,*pwr);
			if (n) {
				/* undo that which hath been done */
				putfree(fm,nextrec);
				fputs(
				"Could not seek loctxt_p to write_rec!\n",
				stderr);
				return n;
			}

			n = secwrite(fp,bp);
			if (n) {
				/* undo that which hath been done */
				putfree(fm,nextrec);
				fputs("Could not write text file!\n",stderr);
				return n;
			}

			zeromem(bp,256);
			*pwr = nextrec;
			*pwp = 2;
		}
		bp[(*pwp)++] = *(s++);
	}
	return 0;
}

/*  flushtxt ...
**	to be executed at the end of a message
*/

int	flushtxt(fp,bp,pwr,pwp)
FILE	*fp;		/* text file pointer */
char	*bp;		/* sector buffer pointer */
int	*pwr;		/* pointer to write record number */
int	*pwp;		/* pointer to write position */
{
	int	n;

	putw(bp,0);
	n = secseek(fp,*pwr);
	if (n) {
		fputs("Could not seek loctxt_p to write_rec!\n",stderr);
		return n;
	}

	n = secwrite(fp,bp);
	if (n) {
		fputs("Could not flush text file!\n",stderr);
		return n;
	}

	zeromem(bp,256);
	*pwr = 0;
	*pwp = 256;	/* should be ineffective! invalid value */
	return 0;
}

/* writefree ...
**	write the free space bitmap
*/

int	writefree(fp,bp)
FILE	*fp;
char	*bp;
{
	int	n;

	n = secseek(fp,0);
	if (n) {
		fputs("Could not seek loctxt_p to beginning!\n",stderr);
		return n;
	}

	n = secwrite(fp,bp);
	if (n) {
		fputs("Could not write text file freemap!\n",stderr);
		return n;
	}

	return 0;
}
