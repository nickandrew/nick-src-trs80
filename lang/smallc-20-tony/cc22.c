ifline()
	{

	while (1)	{
		inline();

		if (eof)
			return;

		if (match("#ifdef"))	{
			++iflevel;
			if (skiplevel)
				continue;

			blanks();

#ifdef	HASH
			if (search(lptr, macn, NAMESIZE + 2, MACNEND, MACNBR, 0) == 0)
#else
			if (findmac(lptr) == 0)
#endif
				skiplevel = iflevel;

			continue;
		}

		if (match("#ifndef"))	{
			++iflevel;

			if (skiplevel)
				continue;

			blanks();

#ifdef	HASH
			if (search(lptr, macn, NAMESIZE + 2, MACNEND, MACNBR, 0))
#else
			if (findmac(lptr))
#endif
				skiplevel = iflevel;

			continue;
		}

		if (match("#else"))	{
			if (iflevel)	{
				if (skiplevel == iflevel)
					skiplevel = 0;
				else if (skiplevel == 0)
					skiplevel = iflevel;
			}
			else
				noiferr();

			continue;
		}

		if (match("#endif"))	{
			if (iflevel)	{
				if (skiplevel == iflevel)
					skiplevel = 0;

				--iflevel;
			}
			else
				noiferr();

			continue;
		}

		if (skiplevel)
			continue;

		if (listfp)	{
			if (listfp == output)
				cout(';', output);

			lout(line, listfp);
		}

		if (ch == 0)
			continue;

		break;
	}
}

keepch(c)
char	c;
	{

	if (pptr < LINEMAX)
		pline[++pptr] = c;
}

preprocess()
	{
	int	k;
	char	c;

	if (ccode)	{
		line = mline;
		ifline();

		if (eof)
			return;
	}
	else	{
		line = pline;
		inline();
		return;
	}

	pptr = -1;

	while (ch)	{
		if (white())	{
			keepch(' ');

			while (white())
				gch();
		}
		else if (ch == '"')	{
			keepch(ch);
			gch();

			while ((ch != '"') | ((*(lptr - 1) == 92) & (*(lptr - 2) != 92)))	{
				if (ch == 0)	{
					error("no quote");
					break;
				}

				keepch(gch());
			}

			gch();
			keepch('"');
		}
		else if (ch == 39)	{
			keepch(39);
			gch();

			while ((ch != 39) | ((*(lptr - 1) == 92) & (*(lptr - 2) != 92)))	{
				if (ch == 0)	{
					error("no apostrophe");
					break;
				}

				keepch(gch());
			}

			gch();
			keepch(39);
		}
		else if ((ch == '/') & (nch == '*'))	{
			bump(2);
			while (((ch == '*') & (nch == '/')) == 0)	{
				if (ch)
					bump(1);
				else	{
					ifline();

					if (eof)
						break;
				}
			}

			bump(2);
		}
		else if (an(ch))	{
			k = 0;

			while (an(ch))	{
				if (k < NAMEMAX)
					msname[k++] = ch;

				gch();
			}

			msname[k] = 0;

#ifdef	HASH
			if (search(msname, macn, NAMESIZE + 2, MACNEND, MACNBR, 0))	{
				k = getint(cptr + NAMESIZE, 2);

				while (c = macq[k++])
					keepch(c);
			}
#else
			if (k = findmac(msname))
				while (c = macq[k++])
					keepch(c);
#endif
			else	{
				k = 0;

				while (c = msname[k++])
					keepch(c);
			}
		}
		else
			keepch(gch());
	}

	if (pptr >= LINEMAX)
		error("line too long");

	keepch(0);
	line = pline;
	bump(0);
}

noiferr()
	{

	error("no matching #if...");
	errflag = 0;
}

addmac()
	{
	int	k;

	if (symname(msname, NO) == 0)	{
		illname();
		kill();
		return;
	}

	k = 0;

#ifdef	HASH
	if (search(msname, macn, NAMESIZE + 2, MACNEND, MACNBR, 0) == 0)	{
		if (cptr2 = cptr)
			while (*cptr2++ = msname[k++])
				;
		else	{
			error("macro name table full");
			return;
		}
	}

	putint(macptr, cptr + NAMESIZE, 2);
#else
	while (putmac(msname[k++]))
		;
#endif

	while(white())
		gch();

	while(putmac(gch()))
		;

	if (macptr >= MACMAX)	{
		error("macro string queue full");
		abort(ERRCODE);
	}
}

putmac(c)
char	c;
	{

	macq[macptr] = c;

	if (macptr < MACMAX)
		++macptr;

	return (c);
}

#ifdef	HASH
/*
**	search for symbol match
**
**	on return cptr points to slot found or empty slot
*/

search(sname, buf, len, end, max, off)
char	*sname, *buf, *end;
int	len, max, off;
	{

	cptr = cptr2 = buf + ((hash(sname) % (max - 1)) * len);

	while (*cptr != 0)	{
		if (astreq(sname, cptr + off, NAMEMAX))
			return (1);

		if ((cptr = cptr + len) >= end)
			cptr = buf;

		if (cptr == cptr2)
			return (cptr = 0);
	}

	return (0);
}

hash(sname)
char	*sname;
	{
	int	i, c;

	i = 0;

	while (c = *sname++)
		i = (i << 1) + c;

	return (i);
}
#else

findmac(sname)
char	*sname;
	{

	mack = 0;

	while (mack < macptr)	{
		if (astreq(sname, macq + mack, NAMEMAX))	{
			while (macq[mack++])
				;

			return (mack);
		}

		while (macq[mack++])
			;

		while (macq[mack++])
			;
	}

	return (0);
}
#endif

setstage(before, start)
int	*before, *start;
	{

	if ((*before = stagenext) == 0)
		stagenext = stage;

	*start = stagenext;
}

clearstage(before, start)
char	*before, *start;
	{

	*stagenext = 0;

	if (stagenext = before)
		return;

	if (start)	{
#ifdef	OPTIMIZE
		peephole(start);
#else
		sout(start, output);
#endif
	}
}

outdec(number)
int	number;
	{
	int	k, zs;
	char	c;

	zs = 0;
	k = 10000;

	if (number < 0)	{
		number = (-number);
		outbyte('-');
	}

	while (k >= 1)	{
		c = number / k + '0';

		if ((c != '0') | (k == 1) | (zs))	{
			zs = 1;
			outbyte(c);
		}

		number = number % k;
		k = k / 10;
	}
}

ol(ptr)
char	ptr[];
	{

	ot(ptr);
	nl();
}

ot(ptr)
char	ptr[];
	{

#ifdef	TAB
	tab();
#endif
	outstr(ptr);
}

outstr(ptr)
char	ptr[];
	{

#ifdef	POLL
	CCPOLL(1);
#endif

	while (*ptr >= ' ')
		outbyte(*ptr++);
}

outbyte(c)
char	c;
	{

	if (stagenext)	{
		if (stagenext == stagelast)	{
			error("staging buffer overflow");
			return (0);
		}
		else
			*stagenext++ = c;
	}
	else
		cout(c, output);

	return (c);
}

cout(c, fd)
char	c;
int	fd;
	{

	if (fputc(c, fd) == EOF)
		xout();
}

sout(string, fd)
char	*string;
int	fd;
	{

	if (fputs(string, fd) == EOF)
		xout();
}

lout(line, fd)
char	*line;
int	fd;
	{

	sout(line, fd);
	cout('\n', fd);
}

xout()
	{

	fputs("output error\n", stderr);
	abort(ERRCODE);
}

nl()
	{

	outbyte('\n');
}

tab()	{

#ifdef	TAB
	outbyte(TAB);
#endif
}

col()
	{

#ifdef	COL
	outbyte(':');
#endif
}

error(msg)
char	msg[];
	{

	if (errflag)
		return;

	errflag = 1;
	lout(line, stderr);
	errout(msg, stderr);

	if (alarm)
		fputc(7, stderr);

	if (pause)
		while (fgetc(stderr) != '\n')
			;

	if (listfp > 0)
		errout(msg, listfp);
}

errout(msg, fp)
char	msg[];
int	fp;
	{
	int	k;

	k = line + 2;

	while (++k <= lptr)
		cout(' ', fp);

	lout("/\\", fp);
	sout("**** ", fp);
	lout(msg, fp);
}

streq(str1, str2)
char	str1[], str2[];
	{
	int	k;

	k = 0;

	while (str2[k])	{
		if ((str1[k]) != (str2[k]))
			return (0);

		++k;
	}

	return (k);
}

astreq(str1, str2, len)
char	str1[], str2[];
int	len;
	{
	int	k;

	k = 0;

	while (k < len)	{
		if ((str1[k]) != (str2[k]))
			break;

		if (str1[k] < ' ')
			break;

		if (str2[k] < ' ')
			break;

		++k;
	}

	if (an(str1[k]))
		return (0);

	if (an(str2[k]))
		return (0);

	return (k);
}

match(lit)
char	*lit;
	{
	int	k;

	blanks();

	if (k = streq(lptr, lit))	{
		bump(k);
		return (1);
	}

	return (0);
}

amatch(lit, len)
char	*lit;
int	len;
	{
	int	k;

	blanks();

	if (k = astreq(lptr, lit, len))	{
		bump(k);

		while (an(ch))
			inbyte();

		return(1);
	}

	return (0);
}

nextop(list)
char	*list;
	{
	char	op[4];

	opindex = 0;
	blanks();

	while (1)	{
		opsize = 0;

		while (*list > ' ')
			op[opsize++] = *list++;

		op[opsize] = 0;

		if (opsize = streq(lptr, op))
			if ((*(lptr + opsize) != '=') & (*(lptr + opsize) != *(lptr + opsize - 1)))
				return (1);

		if (*list)	{
			++list;
			++opindex;
		}
		else
			return (0);
	}
}

blanks()
	{

	while (1)	{
		while (ch)	{
			if (white())
				gch();
			else
				return;
		}

		if (line == mline)
			return;

		preprocess();

		if (eof)
			break;
	}
}
