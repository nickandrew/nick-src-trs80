/*
**	execution begins here
*/

#ifdef	CMD_LINE
main(argc, argv)
int	argc, *argv;
	{

	argcs = argc;
	argvs = argv;
#else
main()
	{
#endif

#ifdef	DYNAMIC
	swnext = CCALLOC(SWTABSZ);
	swend = swnext + ((SWTABSZ - SWSIZ) >> 1);
	stage = CCALLOC(STAGESIZE);
	stagelast = stage + STAGELIMIT;
	wq = CCALLOC(WQTABSZ * BPW);
	litq = CCALLOC(LITABSZ);
#ifdef	HASH
	macn = CCALLOC(MACNSIZE);
	cptr = macn - 1;
	while (++cptr < MACNEND)
		*cptr = 0;
#endif
	macq = CCALLOC(MACQSIZE);
	pline = CCALLOC(LINESIZE);
	mline = CCALLOC(LINESIZE);
#else
	swend = (swnext = swq) + SWTABSZ - SWSIZ;
	stagelast = stage + STAGELIMIT;
#endif

	swactive =		/* not in switch */
	stagenext =		/* direct output mode */
	iflevel =		/* #if... nesting level = 0 */
	skiplevel =		/* #if... not encountered */
	macptr =		/* clear the macro pool */
	csp =			/* stack ptr (relative) */
	errflag =		/* not skipping errors till ";" */
	eof =			/* not eof yet */
	ncmp =			/* not in compound statement */
	files =
	filearg =
	quote[1] = 0;

	func1 =			/* first function */
	ccode = 1;		/* enable preprocessing */

	wqptr = wq;		/* clear while queue */
	quote[0] = '"';		/* fake a quote literal */
	input = input2 = EOF;

	ask();
	openin();
	preprocess();
#ifdef	SMALL_VM
	fopen(" ", NULL);
#endif
#ifdef	DYNAMIC
#ifdef	HASH
	symtab = CCALLOC(NUMLOCS * SYMAVG + NUMGLBS * SYMMAX);
#else
	symtab = CCALLOC(NUMLOCS * SYMAVG);
#endif
#endif
#ifdef	HASH
	cptr = STARTGLB - 1;
	while (++cptr < ENDGLB)
		*cptr = 0;
#endif
	glbptr = STARTGLB;
	glbflag = 1;
	ctext = 0;

	header();
	setops();
	parse();
	outside();
	trailer();
	fclose(output);
}

/*
**	process all input text
**
**	At this level, only static declarations,
**	defines, includes and function definitions
**	are legal...
*/

parse()
	{

	while (eof == 0)	{
		if (amatch("extern", 6))
			dodeclare(EXTERNAL);
		else if (dodeclare(STATIC))
			;
		else if (match("#asm"))
			doasm();
		else if (match("#include"))
			doinclude();
		else if (match("#define"))
			addmac();
		else
			newfunc();

		blanks();
	}
}

/*
**	dump the literal pool
*/

dumplits(size)
int	size;
	{
	int	j, k;

	k = 0;

	while (k < litptr)	{
#ifdef	POLL
		CCPOLL(1);
#endif
		defstorage(size);
		j = 10;

		while (j--)	{
			outdec(getint(litq + k, size));
			k = k + size;

			if ((j == 0) | (k >= litptr))	{
				nl();
				break;
			}

			outbyte(',');
		}
	}
}

/*
**	dump zeros for default initial values
*/

dumpzero(size, count)
int	size, count;
	{
	int	j;

	while (count > 0)	{
#ifdef	POLL
		CCPOLL(1);
#endif
		defstorage(size);
		j = 30;

		while (j--)	{
			outdec(0);

			if ((--count <= 0) | (j == 0))	{
				nl();
				break;
			}

			outbyte(',');
		}
	}
}

/*
**	verify compile ends ouside any function
*/

outside()
	{

	if (ncmp)
		error("no closing bracket");
}

/*
**	get run options
*/

#ifdef	CMD_LINE

ask()
	{
	int	i;
	int	argc;
	char	*argv;
	int	*arg;

	i = listfp = nxtlab = 0;
	output = stdout;
#ifdef	OPTIMIZE
	optimize =
#endif
	alarm = monitor = pause = NO;
	line = mline;

	argc = argcs;
	arg = argvs;

	while (--argc)	{
		argv = *++arg;

		if (*argv != '-')
			continue;

		switch (*++argv)	{

		case 'l':
		case 'L':
			listfp = stdout;
			continue;

		case 'a':
		case 'A':
			alarm = YES;
			continue;

		case 'm':
		case 'M':
			monitor = YES;
			continue;

		case 'o':
		case 'O':
			optimize = YES;
			continue;

		case 'p':
		case 'P':
			pause = YES;
			continue;


#ifndef	LINK
		case 'b':
		case 'B':
			continue;
#endif

		default:
			sout("usage: cc [file] ... [-m] [-a] [-p] [-l]", stderr);
#ifdef	OPTIMIZE
			sout(" [-o]", stderr);
#endif
#ifndef	LINK
			sout(" [-b#]", stderr);
#endif
			sout("\n", stderr);
			abort(ERRCODE);
		}
	}
}

#else

ask()
	{

#ifdef	OPTIMIZE
	optimize =
#endif
	monitor = alarm = pause = listfp = nxtlab = 0;
	line = mline;

	while (1)	{
		prompt("Output file: ", line, LINESIZE);

		if (output = fopen(line, "w"))
			break;
		else
			lout("open error", stderr);
	}

#ifndef	LINK
	while (1)	{
		prompt("Beginning label number: ", line, LINESIZE);
		bump(0);

		if (number(&nxtlab))
			break;
	}
#endif

	while (1)	{
		prompt("Monitor function headers? ", line, LINESIZE);

		if (upper(*line) == 'Y')
			monitor = YES;
		else if (upper(*line) != 'N')
			continue;

		break;
	}

	while (1)	{
		prompt("Sound alarm on errors? ", line, LINESIZE);

		if (upper(*line) == 'Y')
			alarm = YES;
		else if (upper(*line) != 'N')
			continue;

		break;
	}

	while (1)	{
		prompt("Pause on errors? ", line, LINESIZE);

		if (upper(*line) == 'Y')
			pause = YES;
		else if (upper(*line) != 'N')
			continue;

		break;
	}

#ifdef	OPTIMIZE
	while (1)	{
		prompt("Optimize for size? ", line, LINESIZE);

		if (upper(*line) == 'Y')
			optimize = YES;
		else if (upper(*line) != 'N')
			continue;

		break;
	}
#endif

	while (1)	{
		prompt("Listing file descriptor: ", line, LINESIZE);

		if (numeric(*line) & (line[1] == NULL))
			listfp = *line - '0';
		else if (*line != NULL)
			continue;

		break;
	}
}
#endif

/*
**	get next input file
*/

openin()
	{

	input = EOF;

#ifdef	CMD_LINE
	while (++filearg != argcs)	{
		strcpy(pline, argvs[filearg]);

		if (pline[0] == '-')
			continue;
#else
	while (prompt("Input file: ", pline, LINESIZE))	{
#endif

		if ((input = fopen(pline, "r")) == NULL)	{
			sout(pline, stderr);
			lout(": open error", stderr);
			abort(ERRCODE);
		}

		sout(pline, stderr);
		lout(":", stderr);

		files = YES;
		kill();
		return;
	}

	if (files++)
		eof = YES;
	else
		input = stdin;

	kill();
}

#ifndef	CMD_LINE
prompt(msg, ans, anslen)
char	*msg, *ans;
int	anslen;
	{

	sout(msg, stderr);
	fgets(ans, anslen, stderr);
}
#endif

setops()
	{

	op2[00] =	op[00] = or;	/* heir5 */
	op2[01] =	op[01] = xor;	/* heir6 */
	op2[02] =	op[02] = and;	/* heir7 */
	op2[03] =	op[03] = eq;	/* heir8 */
	op2[04] =	op[04] = ne;
	op2[05] = ule;	op[05] = le;	/* heir9 */
	op2[06] = uge;	op[06] = ge;
	op2[07] = ult;	op[07] = lt;
	op2[08] = ugt;	op[08] = gt;
	op2[09] =	op[09] = asr;	/* heir10 */
	op2[10] =	op[10] = asl;
	op2[11] =	op[11] = add;	/* heir11 */
	op2[12] =	op[12] = sub;
	op2[13] =	op[13] = mult;	/* heir12 */
	op2[14] =	op[14] = div;
	op2[15] =	op[15] = mod;
}

char	*
fgets(lp, max, fp)
char	*lp;
int	max, fp;
	{
	int	c;

	if (feof(fp))
		return (NULL);

	while (max--)	{
		*lp = c = getc(fp);

		if (c == EOF || c == '\n')	{
			*lp = 0;
			return (lp);
		}

		lp++;
	}

	*lp = 0;
	return (lp);
}
