/*
**	Small-C Compiler Version 2.0
**
**	Copyright 1982 J. E. Hendrix
**
**	Part 3
*/

#include	"stdio.h"
#include	"cc.def"

/*
**	external references in part 1
*/

extern char
#ifdef	DYNAMIC
	*stage,
	*litq,
#else
	stage[STAGESIZE],
	litq[LITABSZ],
#endif
	*glbptr, *lptr, ssname[NAMESIZE], quote[2], *stagenext;

extern int
	ch, csp, litlab, litptr, nch, op[16], op2[16], oper, opindex, opsize;

/*
**	external references in part 2
*/

extern int
	addsym(), blanks(), bump(), clearstage(), endst(), error(),
	findglb(), findloc(), gch(), getlabel(), inbyte(), junk(),
	match(), needlval(), needtoken(), nextop(), nl(), numeric(),
	outbyte(), outdec(), outstr(), postlabel(), printlabel(),
	putint(), setstage(), streq(), symname();

/*
**	external references in part 4
*/

extern int
	add(), and(), asl(), asr(), call(), callstk(), com(), dec(),
	div(), doublereg(), eq(), eq0(), ge(), ge0(), getloc(), getmem(),
	gt(), gt0(), immed(), immed2(), inc(), indirect(), jump(), le(),
	le0(), lneg(), loadargc(), lt(), lt0(), mod(), modstk(), move(),
	mult(), ne(), ne0(), neg(), or(), pop(), push(), putmem(), putstk(),
	ret(), smartpop(), sub(), swap(), swapstk(), testjump(), uge(),
	ugt(), ule(), ult(), ult0(), xor(), zerojump();

/*
**	forward definitions
*/

extern int
	heir1(), heir3(), heir4(), heir5(), heir6(), heir7(),
	heir8(), heir9(), heir10(), heir11(), heir12(), heir13(),
	heir14();

#include	"cc31.c"
#include	"cc32.c"
#include	"cc33.c"
