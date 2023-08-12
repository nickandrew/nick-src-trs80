/*
 *	Small C Interface to CP/M
 *
 *	Copyright (C) 1983 - Anthony McGrath
 */

#define	ERR	-2
#define	EOF	-1
#define	NULL	0

#define	F_UNUSED	0
#define	F_READ		1
#define	F_WRITE		2

#define	FCBSIZE	36
#define	DMASIZE	128

#define	CONSOLE	0
#define	PRINTER	1

#asm
;
;	Startup Routine
;
	ORG	100H
;
	LXI	H,80H		; get argument start area
	PUSH	H		; put as argument to CCSTART
	CALL	CCSTART		; perform initialization & call main
	JMP	CCEXIT		; and then exit
;
;	CP/M Interface to Small C
;
;	Called:
;		cpm(func, arg)
;
;	Return:
;		whatever CP/M has in HL (copy of A if 2.0 or better)
;
CPM:
	POP	H	; get return address
	POP	D	; get argument
	POP	B	; get function code
	PUSH	B	; restore B
	PUSH	D	; restore D
	PUSH	H	; restore return address
	CALL	5H	; jump to CP/M
	RET		; return to caller
#endasm

char	ccftab[16];		/* file table */
int	ccdma[16];		/* buffer addresses */
int	ccdmap[16];		/* buffer pointers */
int	ccfcb[16];		/* FCB addresses */

int	ccargc;			/* argument count */
int	ccargv[20];		/* argv array for main */
char	ccargs[128];		/* argument storage area */

int	stdin;
int	stdout;
int	stderr;
int	stdlist;

ccstart(argp)
char	*argp;
	{
	char	*p, *q, *last;
	char	fname[20];
	char	*f;

	for (i = 0; i < 8; i++)
		ccftab[i] = F_UNUSED;

	stdin = stdout = stderr = CONSOLE;
	stdlist = PRINTER;

	ccargc = 0;
	p = argp + 1;
	last = p + *argp;
	q = ccargs;

	ccargv[ccargc++] = "#";

	while (++p < last)	{
		if (*p == ' ')
			continue;
		else if (*p == '<')	{
			while (*p == ' ')
				;

			if (p >= last)
				break;

			if (*p == '0')	{
				stdin = CONSOLE;
				++p;
			}
			else if (*p == '1')	{
				putchar('\n');
				puts("You cannot assign printer as input");
				ccexit();
			}
			else	{
				f = fname;
				while (*p != ' ' && p < last)
					*f++ = *p++;

				*f = 0;

				stdin = fopen(fname, "r");

				if (stdin == ERR)	{
					putchar('\n');
					puts("Cannot open ");
					puts(fname);
					ccexit();
				}
			}
		else if (*p == '>')	{
			while (*p == ' ')
				;

			if (p > last)
				break;

			if (*p == '0')	{
				stdout = CONSOLE;
				++p;
			}
			else if (*p == '1')	{
				stdout = PRINTER;
				++p;
			}
			else	{
				f = fname;

				while (*p != ' ' && p < last)
					*f++ = *p++;

				*f = 0;

				stdout = fopen(fname, "w");

				if (stdout == ERR)	{
					putchar('\n');
					puts("Cannot open ");
					puts(fname);
					ccexit();
				}
			}
		else	{
			ccargv[ccargc++] = q;

			while (*p != ' ' && p < last)
				*q++ = *p++;

			*q++ = 0;
		}
	}

	main(ccargc, ccargv);
}

getarg(n, s, size, argc, argv)
int	n;
char	*s;
int	size, argc, *argv;
	{
	char	*s1, *s2;
	int	i;

	if (n < 0 || n >= argc)
		return (EOF);

	s1 = argv[n];
	s2 = s;

	for (i = 0; i < size; i++)	{
		if (!*s1)
			break;

		*s2++ = *s1++;
	}

	*s2 = 0;
	return (s);
}

fopen(name, mode)
char	*name, *mode;
	{
	int	iop;

	for (iop = 0; iop < 16 && ccftab[iop] != F_UNUSED; iop++)
		;

	if (iop >= 16)
		return (ERR);

	if (*mode == 'w')
		ccftab[iop] = F_WRITE;
	else
		ccftab[iop] = F_READ;

	if ((ccfcb[iop] = alloc(FCBSIZE)) == NULL)	{
		ccftab[iop] = F_UNUSED;
		return (ERR);
	}

	if ((ccdma[iop] = alloc(DMASIZE)) == NULL)	{
		ccftab[iop] = F_UNUSED;
		free(ccfcb[iop]);
		return (ERR);
	}

	ccmkfcb(ccfcb[iop], name);

	if (ccftab[iop] == F_WRITE)	{
		cpm(19, ccfcb[iop]);

		if (cpm(22, ccfcb[iop]) == 255)	{
			ccftab[iop] = F_UNUSED;
			free(ccfcb[iop]);
			free(ccdma[iop]);
			return (ERR);
		}
	}
	else if (cpm(15, ccfcb[iop]) == 255)	{
		ccftab[iop] = F_UNUSED;
		free(ccfcb[iop]);
		free(ccdma[iop]);
		return (ERR);
	}

	ccdmap[iop] = EOF;

	return (iop + 2);
}

ccmkfcb(f, s)
char	*f, *s;
	{
	char	wbuf[20];
	char	*w;
	int	i;

	w = f;
	for (i = 0; i < FCBSIZE; i++)
		*w++ = 0;

	for (w = wbuf; *s; s++)
		if (*s >= 'a' && *s <= 'z')
			*w++ = *s - 'a' + 'A';
		else if (*s != ' ')
			*w++ = *s;

	*w = 0;

	if (wbuf[1] == ':')	{
		w = &wbuf[2];
		*f++ = *wbuf - 'A' + 1;
	}
	else	{
		w = wbuf;
		*f++ = 0;
	}

	for (i = 0; i < 8 && *w && *w != '.'; i++)
		*f++ = *w++;

	for (; i < 8; i++)
		*f++ = ' ';

	for (i = 0; i < 2 && *w; i++)
		*f++ = *w++;

	for (; i < 2; i++)
		*f++ = ' ';
}

fclose(iop)
int	iop;
	{
	int	r;

	if (iop < 2)
		return (NULL);

	putc(iop, '\32');

	r = fflush(iop);

	if ((iop -= 2) < 0)
		return (r);

	if (cpm(16, ccfcb[iop]) == 255)
		r = ERR;

	free(ccfcb[iop]);
	free(ccdma[iop]);
	ccftab[iop] = F_UNUSED;

	return (r);
}

fflush(iop)
int	iop;
	{

	if ((iop -= 2) < 0)
		return (NULL);

	if (ccftab[iop] != F_WRITE)
		return (NULL);

	if (ccdmap[iop] == EOF)
		return (NULL);

	ccdmap[iop] = EOF;

	if (cpm(21, ccfcb[iop]) == 255)
		return (ERR);

	return (NULL);
}

putchar(c)
char	c;
	{

	return (putc(stdout, c));
}

getchar()
	{

	return (getc(stdin));
}

fputc(iop, ch)
int	iop;
char	ch;
	{

	return (putc(iop, ch));
}

fgetc(iop)
int	iop;
	{

	return (getc(iop));
}

putc(iop, ch)
int	iop;
char	ch;
	{
	char	*p;

	if (iop == 0)
		cpm(2, ch);
	else if (iop == 1)
		cpm(5, ch);
	else	{
		iop -= 2;

		if (ccftab[iop] != F_WRITE)
			return (ERR);

		p = ccdma[iop];

		if (ccdmap[iop] >= DMASIZE - 1)
			if (fflush(iop + 2) == ERR)
				return (ERR);

		p[++ccdmap[iop]] = ch;
	}

	return (NULL);
}

getc(iop)
int	iop;
	{
	int	c;
	char	*p;

	if (iop == 0)
		c = cpm(1, 0);
	else if (iop == 1)
		c = EOF;
	else	{
		iop -= 2;

		if (ccftab[iop] != F_READ)
			return (EOF);

		if (ccdmap[iop] == EOF || ccdmap[iop] >= DMASIZE)	{
			cpm(26, ccdma[iop]);

			if (cpm(20, ccfcb[iop]) != 0)
				return (EOF);

			ccdmap[iop] = 0;
		}

		p = ccdma[iop];
		c = p[ccdmap[iop]++];
	}

	if (c == '\32')
		c = EOF;

	return (c);
}

puts(s)
char	*s;
	{

	while (*s)
		putchar(*s++);

	return (putchar('\n'));
}

fputs(s, iop)
char	*s;
int	iop;
	{
	int	r;

	while (*s)
		r = putc(*s, iop);

	return (r);
}
