/*
**	stdio.c -- standard I/O library
**
**	Copyright 1982  J. E. Hendrix
*/

#include	call.a

#define	NOCCARGC	/* don't pass arg counts */

#define	SP	32
#define	CTL_D	4
#define	DEL	127
#define	LST_PORT	9
#define	LST_FILE	17
#define	stdin	0
#define	stdout	1
#define	stderr	2
#define	stdport	3
#define	stdlist	4
#define	ERR	-2
#define	EOF	-1
#define	NULL	0
#define	CR	13
#define	LF	10

#asm
GETC:
	JMP	FGETC
PUTC:
	JMP	FPUTC
FFLUSH:
	JMP	CCFLUSH
ABORT:
	JMP	CCEXIT
EXIT:
	JMP	CCEXIT
UNLINK:
	JMP	CCPURGE
#endasm

fgetc(fd)
int	fd;
	{
	char	c;
	int	flag;

	while (1)	{
		flag = CCREAD(fd, &c, 1);

		if (c != LF)
			break;
	}

	if ((flag == NULL) | (flag == ERR) | (c <= NULL) | (c == CTL_D))
		return (EOF);

	if (CCFILE(fd) == 0)	{
		if (c == DEL)
			c = '\b';

		if (c != '\b')	{
			if (fd == stdin)
				fd = stderr;

			fputc(c, fd);
		}
	}

	return (c & 255);
}

getchar()
	{

	return (fgetc(stdin));
}

fgets(string, size, fd)
char	string[];
int	size, fd;
	{
	int	k, sz, echo;
	char	c;

	if (CCFILE(fd) != 0)	{
		CCDELIM('\n');

		if ((k = CCREAD(fd, string, --size)) < 1)
			return (NULL);

		if (*string == LF)
			sz = 1;
		else
			sz = 0;

		if (string[sz] <= NULL)
			return (NULL);

		if (string[--k] != '\n')
			++k;

		string[k] = NULL;
		k = -1;

		while (string[++k] = string[sz++])
			;
	}
	else	{
		k = 0;
		sz = size;

		while ((--sz > 0) & ((c = string[k] = fgetc(fd)) != CR))	{
			if (c == EOF)
				return (NULL);

			if (c == '\b')	{
				if (k > 0)	{
					--k;
					++sz;

					if ((echo = fd) == stdin)
						echo = stderr;

					fputs("\b \b", echo);
				}
			}
			else
				++k;
		}

		string[k] = 0;
	}

	return (string);
}

fputs(string, fd)
char	string[];
int	fd;
	{
	int	i, k;

	i = 0;
	k = -1;

	while (string[i])	{
		while (string[++k] >= ' ')
			;

		if (string[k] == NULL)
			--k;

		if (CCWRITE(fd, string + i, k - i + 1) < k - i + 1)
			return (EOF);

		if (string[k] == '\n')	{
			if (CCWRITE(fd, "\12", 1) < 1)
				return (EOF);
		}

		i = k + 1;
	}

	return (NULL);
}

puts(string)
char	string[];
	{

	fputs(string, stdout);
	fputc(CR, stdout);
}

fopen(name, mode)
char	*name, *mode;
	{
	int	xfermode, fd;

	if (mode == NULL)
		xfermode = 0;
	else if (*mode == 'u')
		xfermode = 3;
	else if (*mode == 'w')
		xfermode = 2;
	else
		xfermode = 1;

	fd = LST_PORT;

	while (fd < LST_FILE)	{
		if (CCMODE(++fd) != 0)
			continue;

		if (CCOPEN(fd, name, xfermode, 0, 0, 0) == 0)
			return (fd);

		break;
	}

	return (NULL);
}

fclose(fd)
int	fd;
	{
	char	c;

	c = 255;

	if ((CCMODE(fd) == 2) & (CCFILE(fd) != 0))
		CCWRITE(fd, &c, 1);

	CCCLOSE(fd);
}

getarg(n, str, maxsz, argc, argv)
int	n;
char	*str;
int	maxsz, argc, *argv;
	{
	char	*dptr, *sptr;
	int	cnt;

	if ((n > (argc - 1)) | (n < 0))	{
		str[0] = NULL;
		return (EOF);
	}

	cnt = 0;
	dptr = str;
	sptr = argv[n];

	while (*dptr++ = *sptr++)
		if (++cnt >= (maxsz - 1))	{
			*dptr = NULL;
			break;
		}

	return (cnt);
}
