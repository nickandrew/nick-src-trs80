/*
**	print all assembler info before any code is generated
*/

header()
	{

	beglab = getlabel();

#ifndef	LINK
	if (beglab < 3)
#endif
	{
#ifdef	SMALL_VM
		ol("ld de,#$+6");
		ol("jp cc9998");
#endif
		jump(beglab);
	}
}

/*
**	print any assembler stuff needed at the end
*/

trailer()
	{

#ifdef	SMALL_VM
#ifndef	LINK
	if ((beglab == 1) | (beglab > 9000))
#endif
	{
		ol("cc9997: jp ccboj");
		ol("cc9998: ds 6");
		ol("push de");
		ol("ld de,#$+6");
		ol("jp cc9997");
		ol("org cc9998");
		ol("jp $+6");
	}
#endif

	ol("end");
}

/*
**	load # args before function call
*/

loadargc(val)
int	val;
	{

#ifdef	HASH
	if (search("NOCCARGC", macn, NAMESIZE + 2, MACNEND, MACNBR, 0) == 0)	{
#else
	if (findmac("NOCCARGC") == 0)	{
#endif
		ot("ld a,#");
		outdec(val);
		nl();
	}
}

/*
**	declare entry point
*/

entry()
	{

	outstr(ssname);
	col();

#ifdef	LINK
	ol("entry");
#else
	nl();
#endif
}

/*
**	declare external reference
*/

external(name)
char	*name;
	{

#ifdef	LINK
	outstr(name);
	col();
	ol("extern");
#endif
}

/*
**	fetch object indirect to primary reference
*/

indirect(lval)
int	lval[];
	{

	if (lval[1] == CCHAR)
		call("ccgchar");
	else
		call("ccgint");
}

/*
**	fetch a static memory cell into primary register
*/

getmem(lval)
int	lval[];
	{
	char	*sym;

	sym = lval[0];

	if ((sym[IDENT] != POINTER) & (sym[TYPE] == CCHAR))	{
		ot("ld a,");
		outstr(sym + NAME);
		nl();
		call("ccsxt");
	}
	else	{
		ot("ld hl,");
		outstr(sym + NAME);
		nl();
	}
}

/*
**	fetch address of the specified symbol into primary register
*/

getloc(sym)
char	*sym;
	{

	const(getint(sym + OFFSET, OFFSIZE) - csp);
	ol("add hl,sp");
}

/*
**	store primary register into static cell
*/

putmem(lval)
int	lval[];
	{
	char	*sym;

	sym = lval[0];

	if ((sym[IDENT] != POINTER) & (sym[TYPE] == CCHAR))	{
		ol("ld a,l");
		ot("ld ");
		outstr(sym + NAME);
		ol(",a");
	}
	else	{
		ot("ld ");
		outstr(sym + NAME);
		outstr(",hl");
	}

	nl();
}

/*
**	put on the stack the type object in primary register
*/

putstk(lval)
int	lval[];
	{

	if (lval[1] == CCHAR)	{
		ol("ld a,l");
		ol("ld (de),a");
	}
	else
		call("ccpint");
}

/*
**	move primary register to secondary
*/

move()
	{

	ol("ld d,h");
	ol("ld e,l");
}

/*
**	swap primary and seconday registers
*/

swap()
	{

	ol("ex de,hl");
}

/*
**	partial instruction to get immediate operand
**	into primary register
*/

immed()
	{

	ot("ld hl,#");
}

/*
**	partial instruction to get immediate operand
**	into secondary register
*/

immed2()
	{

	ot("ld de,#");
}

/*
**	push primary register onto stack
*/

push()
	{

	ol("push hl;");		/* needed to pad out in unpush() */
	csp = csp - BPW;
}

/*
**	unpush or pop as required
*/

smartpop(lval, start)
int	lval[];
char	*start;
	{

	if (lval[5])
		pop();	/* secondary was used */
	else
		unpush(start);
}

/*
**	replace a push with a swap
*/

unpush(dest)
char	*dest;
	{
	int	i;
	char	*sour;

#ifdef	TAB
	sour = "\tex de,hl";
#else
	sour = "ex de,hl";
#endif

	while (*sour)
		*dest++ = *sour++;

	sour = stagenext;

	while (--sour > dest)	{
		/* adjust stack references */
#ifdef	TAB
		if (streq(sour, "\tadd hl,sp"))	{
#else
		if (streq(sour, "add hl,sp"))	{
#endif
			--sour;
			i = BPW;

			while (numeric(*(--sour)))	{
				if ((*sour = *sour - i) < '0')	{
					*sour = *sour + 10;
					i = 1;
				}
				else
					i = 0;
			}
		}
	}

	csp = csp + BPW;
}

/*
**	pop stack to secondary register
*/

pop()
	{

	ol("pop de");
	csp = csp + BPW;
}

/*
**	swap primary register and stack
*/

swapstk()
	{

	ol("ex hl,(sp)");
}

/*
**	process switch statement
*/

sw()
	{

	call("ccswitch");
}

/*
**	call specified routine name
*/

call(sname)
char	*sname;
	{

	ot("call ");
	outstr(sname);
	nl();
}

/*
**	return from subroutine
*/

ret()
	{

	ol("ret");
}

/*
**	perform subroutine call to value on stack
*/

callstk()
	{

	immed();
	outstr("$+5");
	nl();
	swapstk();
	ol("jp (hl)");
	csp = csp + BPW;
}

/*
**	jump to internal label number
*/

jump(label)
int	label;
	{

	ot("jp ");
	printlabel(label);
	nl();
}

/*
**	test primary register and jump if false
*/

testjump(label)
int	label;
	{

	ol("ld a,h");
	ol("or l");
	ot("jp z,");
	printlabel(label);
	nl();
}

/*
**	test primary against zero and jump if false
*/

zerojump(oper, label, lval)
int	label, lval[];
int	(*oper)();
	{

	clearstage(lval[7], 0);		/* clear conventional code */
	(*oper)(label);
}

/*
**	define storage according to size
*/

defstorage(size)
int	size;
	{

	if (size == 1)
		ot("dcb ");
	else
		ot("dcw ");
}

/*
**	point to following objects
*/

point()
	{

	ol("dcw $+2");
}

/*
**	modify stack pointer to value given
*/

modstk(newsp, save)
int	newsp, save;
	{
	int	k;

	k = newsp - csp;

	if (k == 0)
		return (newsp);

	if (k >= 0)	{
		if (k < 7)	{
			if (k & 1)	{
				ol("inc sp");
				k--;
			}

			while (k)	{
				ol("pop bc");
				k = k - BPW;
			}

			return (newsp);
		}
	}

	if (k < 0)	{
		if (k > -7)	{
			if (k & 1)	{
				ol("dec sp");
				k++;
			}

			while (k)	{
				ol("push bc");
				k = k + BPW;
			}

			return (newsp);
		}
	}

	if (save)
		swap();

	const(k);
	ol("add hl,sp");
	ol("ld sp,hl");

	if (save)
		swap();

	return (newsp);
}

/*
**	double primary register
*/

doublereg()
	{

	ol("add hl,hl");
}
