/*
**	Small-C Compiler Version 2.0
**
**	Copyright 1982 J. E. Hendrix
**
**	Part 4
*/

#include	"stdio.h"
#include	"cc.def"

/*
**	external references in part 1
*/

extern char
#ifdef	HASH
	*macn,
#endif
#ifdef	OPTIMIZE
	optimize,
#endif
	*stagenext, ssname[NAMESIZE];

extern int
	beglab, csp, output;

/*
**	external references in part 2
*/

extern int
#ifdef	HASH
	search(),
#else
	findmac(),
#endif
	clearstage(), col(), cout(), getint(), getlabel(), nl(),
	numeric(), ol(), ot(), printlabel(), lout(), outdec(),
	outstr(), streq();

/*
**	external references in part 3
*/

extern int	const();

#include	"cc41.c"
#include	"cc42.c"
