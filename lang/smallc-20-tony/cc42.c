/*
**	add primary and secondary registers (result in primary)
*/

add()
	{

	ol("add hl,de");
}

/*
**	subtract primary from secondary register (result in primary)
*/

sub()
	{

	ol("sub hl,de");
}

/*
**	multiply primary and secondary registers (result in primary)
*/

mult()
	{

	call("ccmult");
}

/*
**	divide secondary by primary register
**	(quotient in primary, remainder in secondary)
*/

div()
	{

	call("ccdiv");
}

/*
**	remainder of secondary / primary
**	(remainder in primary, quotient in secondary)
*/

mod()
	{

	div();
	swap();
}

/*
**	inclusive or primary and secondary registers
**	(result in primary)
*/

or()
	{

	call("ccor");
}

/*
**	exclusive or primary and secondary registers
**	(result in primary)
*/

xor()
	{

	call("ccxor");
}

/*
**	and primary and secondary registers (result in primary)
*/

and()
	{

	call("ccand");
}

/*
**	logical negation of primary register
*/

lneg()
	{

	call("cclneg");
}

/*
**	arithmetic shift right secondary register
**	number of bits given in primary register
**	(result in primary)
*/

asr()
	{

	call("ccasr");
}

/*
**	arithmetic shift left secondary register
**	number of bits given in primary register
**	(result in primary)
*/

asl()
	{

	call("ccasl");
}

/*
**	two's complement primary register
*/

neg()
	{

	call("ccneg");
}

/*
**	one's complement primary register
*/

com()
	{

	call("cccom");
}

/*
**	increment primary register by one object of whatever size
*/

inc(n)
int	n;
	{

	while (1)	{
		ol("inc hl");

		if (--n < 1)
			break;
	}
}

/*
**	decrement primary register by one object of whatever size
*/

dec(n)
int	n;
	{

	while (1)	{
		ol("dec hl");

		if (--n < 1)
			break;
	}
}

/*
**	test for equal to
*/

eq()
	{

	call("cceq");
}

/*
**	test for equal to zero
*/

eq0(label)
int	label;
	{

	ol("ld a,h");
	ol("or l");
	ot("jp nz,");
	printlabel(label);
	nl();
}

/*
**	test for not equal to
*/

ne()
	{

	call("ccne");
}

/*
**	test for not equal to zero
*/

ne0(label)
int	label;
	{

	ol("ld a,h");
	ol("or l");
	ot("jp z,");
	printlabel(label);
	nl();
}

/*
**	test for less than (signed)
*/

lt()
	{

	call("cclt");
}

/*
**	test for less than zero
*/

lt0(label)
int	label;
	{

	ol("xor a");
	ol("or h");
	ot("jp p,");
	printlabel(label);
	nl();
}

/*
**	test for less than or equal to (signed)
*/

le()
	{

	call("ccle");
}

/*
**	test for less than or equal to zero
*/

le0(label)
int	label;
	{

	ol("ld a,h");
	ol("or l");
	ol("jp z,$+8");
	ol("xor a");
	ol("or h");
	ot("jp p,");
	printlabel(label);
	nl();
}

/*
**	test for greater than (signed)
*/

gt()
	{

	call("ccgt");
}

/*
**	test for greater than zero
*/

gt0(label)
int	label;
	{

	ol("xor a");
	ol("or h");
	ot("jp m,");
	printlabel(label);
	nl();
	ol("or l");
	ot("jp z,");
	printlabel(label);
	nl();
}

/*
**	test for greater than or equal to (signed)
*/

ge()
	{

	call("ccge");
}

/*
**	test for greater than or equal to zero
*/

ge0(label)
int	label;
	{

	ol("xor a");
	ol("or h");
	ot("jp m,");
	printlabel(label);
	nl();
}

/*
**	test for less than (unsigned)
*/

ult()
	{

	call("ccult");
}

/*
**	test for less than to zero (unsigned)
*/

ult0(label)
int	label;
	{

	ot("jp ");
	printlabel(label);
	nl();
}


/*
**	test for less than or equal to (unsigned)
*/

ule()
	{

	call("ccule");
}

/*
**	test for greater than (unsigned)
*/

ugt()
	{

	call("ccugt");
}

/*
**	test for greater than or equal to (unsigned)
*/

uge()
	{

	call("ccuge");
}

#ifdef	OPTIMIZE
peephole(ptr)
char	*ptr;
	{

	while (*ptr)	{

#ifdef	TAB
		if (streq(ptr, "\tld hl,#0\n\tadd hl,sp\n\tcall ccgint"))	{
			if (streq(ptr + 34, "ex de,hl"))	{
				pp2();
				ptr = ptr + 42;
			}
			else	{
				pp1();
				ptr = ptr + 33;
			}
		}
		else if (streq(ptr, "\tld hl,#2\n\tadd hl,sp\n\tcall ccgint"))	{
			if (streq(ptr + 34, "ex de,hl"))	{
				pp3(pp2);
				ptr = ptr + 42;
			}
			else	{
				pp3(pp2);
				ptr = ptr + 33;
			}
		}
		else if (optimize)	{
			if (streq(ptr, "\tadd hl,sp\n\tcall ccgint"))	{
				ol("call ccdsgi");
				ptr = ptr + 24;
			}
			else if (streq(ptr, "\tadd hl,de\n\tcall ccgint"))	{
				ol("call ccddgi");
				ptr = ptr + 24;
			}
			else if (streq(ptr, "\tadd hl,sp\n\tcall ccgchar"))	{
				ol("call ccdsgc");
				ptr = ptr + 25;
			}
			else if (streq(ptr, "\tadd hl,de\n\tcall ccgchar"))	{
				ol("call ccddgc");
				ptr = ptr + 25;
			}
			else if (streq(ptr,
"\tadd hl,sp\n\tld d,h\n\tld e,l\n\tcall ccgint\n\tinc hl\n\tcall ccpint"))		{
				ol("call ccinci");
				ptr = ptr + 59;
			}
			else if (streq(ptr,
"\tadd hl,sp\n\tld d,h\n\tld e,l\n\tcall ccgint\n\tdec hl\n\tcall ccpint"))		{
				ol("call ccdeci");
				ptr = ptr + 59;
			}
			else if (streq(ptr,
"\tadd hl,sp\n\tld d,h\n\tld e,l\n\tcall ccgchar\n\tinc hl\n\tld a,l\n\tld (de),a"))		{
				ol("call ccincc");
				ptr = ptr + 66;
			}
			else if (streq(ptr,
"\tadd hl,sp\n\tld d,h\n\tld e,l\n\tcall ccgchar\n\tdec hl\n\tld a,l\n\tld (de),a"))		{
				ol("call ccdecc");
				ptr = ptr + 66;
			}
			else if (streq(ptr, "\tadd hl,de\n\tpop de\n\tcall ccpint"))	{
				ol("call ccddpdpi");
				ptr = ptr + 31;
			}
			else if (streq(ptr, "\tadd hl,de\n\tpop de\n\tld a,l\n\tld (de),a"))	{
				ol("call ccddpdpc");
				ptr = ptr + 37;
			}
			else if (streq(ptr, "\tpop de\n\tcall ccpint"))	{
				ol("call ccpdpi");
				ptr = ptr + 21;
			}
			else if (streq(ptr, "\tpop de\n\tld a,l\n\tld (de),a"))	{
				ol("call ccpdpc");
				ptr = ptr + 27;
			}

			/* additional optimizing logic goes here */
#else
		if (streq(ptr, "ld hl,#0\nadd hl,sp\ncall ccgint"))	{
			if (streq(ptr + 31, "ex de,hl"))	{
				pp2();
				ptr = ptr + 38;
			}
			else	{
				pp1();
				ptr = ptr + 30;
			}
		}
		else if (streq(ptr, "ld hl,#2\nadd hl,sp\ncall ccgint"))	{
			if (streq(ptr + 31, "ex de,hl"))	{
				pp3(pp2);
				ptr = ptr + 38;
			}
			else	{
				pp3(pp2);
				ptr = ptr + 30;
			}
		}
		else if (optimize)	{
			if (streq(ptr, "add hl,sp\ncall ccgint"))	{
				ol("call ccdsgi");
				ptr = ptr + 21;
			}
			else if (streq(ptr, "add hl,de\ncall ccgint"))	{
				ol("call ccddgi");
				ptr = ptr + 20;
			}
			else if (streq(ptr, "add hl,sp\ncall ccgchar"))	{
				ol("call ccdsgc");
				ptr = ptr + 22;
			}
			else if (streq(ptr, "add hl,de\ncall ccgchar"))	{
				ol("call ccddgc");
				ptr = ptr + 21;
			}
			else if (streq(ptr,
"add hl,sp\nld d,h\nld e,l\ncall ccgint\ninc hl\ncall ccpint"))		{
				ol("call ccinci");
				ptr = ptr + 59;
			}
			else if (streq(ptr,
"add hl,sp\nld d,h\nld e,l\ncall ccgint\ndec hl\ncall ccpint"))		{
				ol("call ccdeci");
				ptr = ptr + 59;
			}
			else if (streq(ptr,
"add hl,sp\nld d,h\nld e,l\ncall ccgchar\ninc hl\nld a,l\nld (de),a"))		{
				ol("call ccincc");
				ptr = ptr + 64;
			}
			else if (streq(ptr,
"add hl,sp\nld d,h\nld e,l\ncall ccgchar\ndec hl\nld a,l\nld (de),a"))		{
				ol("call ccdecc");
				ptr = ptr + 64;
			}
			else if (streq(ptr, "add hl,de\npop de\ncall ccpint"))	{
				ol("call ccddpdpi");
				ptr = ptr + 27;
			}
			else if (streq(ptr, "add hl,de\npop de\nld a,l\nld (de),a"))	{
				ol("call ccddpdpc");
				ptr = ptr + 31;
			}
			else if (streq(ptr, "pop de\ncall ccpint"))	{
				ol("call ccpdpi");
				ptr = ptr + 20;
			}
			else if (streq(ptr, "pop de\nld a,l\nld (de),a"))	{
				ol("call ccpdpc");
				ptr = ptr + 24;
			}

			/* additional optimizing logic goes here */
#endif
			else
				cout(*ptr++, output);
		}
		else
			cout(*ptr++, output);
	}
}

pp1()
	{

	ol("pop hl");
	ol("push hl");
}

pp2()
	{

	ol("pop de");
	ol("push de");
}

pp3(pp)
int	(*pp)();
	{

	ol("pop bc");
	(*pp)();
	ol("push bc");
}

#endif
