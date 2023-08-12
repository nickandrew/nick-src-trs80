/*
**	Small-C Compiler Version 2.0
**
**	Copyright 1982 J. E. Hendrix
**
**	Part 2
*/

#include	"stdio.h"
#include	"cc.def"

/*
**	external references in part 1
*/

extern char
#ifdef	DYNAMIC
	*symtab,
	*stage,
#ifdef	HASH
	*macn,
#endif
	*macq,
	*pline,
	*mline,
#else
	symtab[SYMTBSZ],
	stage[STAGESIZE],
#ifdef	HASH
	macn[MACNSIZE],
#endif
	macq[MACQSIZE],
	pline[LINESIZE],
	mline[LINESIZE],
#endif
	alarm, *glbptr, *line, *lptr, *cptr, *cptr2, *cptr3,
	*locptr, msname[NAMESIZE], optimize, pause, quote[2],
	*stagelast, *stagenext;

extern int
#ifdef	DYNAMIC
	*wq,
#else
	wq[WQTABSZ],
#endif
#ifndef	HASH
	mack,
#endif
	ccode, ch, csp, eof, errflag, iflevel, input, input2,
	listfp, macptr, nch, nxtlab, op[16], opindex, opsize,
	output, pptr, skiplevel, *wqptr;

extern int	openin();

/*
**	external references in part 4
*/

#ifdef	OPTIMIZE
extern int	peephole();
#endif

#include	"cc21.c"
#include	"cc22.c"
