/*
**      Small C Compiler Version 2.2 - 84/03/05 16:33:30 - c7.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

/*
**      true if val1 -> int ptr or int array and val2 not ptr or array
*/

dbltest(val1, val2)
int     val1[], val2[];
        {

	char *ptr;
	int  hierpos;
	if (ptr=val2[LVSYM])
		if (ptr[IDENT+val2[LVHIER]] != VARIABLE)
			return 0;

	if (ptr=val1[LVSYM]) {
		hierpos=val1[LVHIER];
		if (ptr[IDENT+hierpos]==VARIABLE)
			return 0;
		if (ptr[IDENT+hierpos+1]==ARRAY
		  ||ptr[IDENT+hierpos+1]==VARIABLE)
			if (ptr[TYPE]==CINT) return 1;
			else return 0;
		else return 1;
	}
			
        if (val1[2] != CINT)
                return (0);

        if (val2[2])
                return (0);

	fprintf(stderr,"* dbltest: val1 not in sym tab\n");
        return (1);
}

/*
**      determine type of binary operation
*/

result(lval, lval2)
int     lval[], lval2[];
        {

	char *ptr1,*ptr2;
	ptr1=lval[LVSYM];
	ptr2=lval2[LVSYM];
	if (ptr1 && ptr2) {
		if ((ptr1[IDENT+lval[LVHIER]] == POINTER)
	          & (ptr2[IDENT+lval2[LVHIER]] == POINTER))
			lval[LVPTYPE] = 0;
	}
        else if (ptr2) {
		if (ptr2[IDENT+lval2[LVHIER]]==POINTER)      {
                        lval[LVSYM] = lval2[LVSYM];
                        lval[LVSTYPE] = lval2[LVSTYPE];
                        lval[LVPTYPE] = lval2[LVPTYPE];
                        lval[LVHIER] = lval2[LVHIER];
                }
        }
}

int step(oper, lval)
int     lval[];
int     (*oper)();
        {

	char *ptr;
	int  incval,hierpos;

	incval = lval[LVPTYPE] >> 2;
	if (ptr=lval[LVSYM]) {
		hierpos=lval[LVHIER];
		fprintf(stderr,"step: hierpos = %d\n",hierpos);
		if (ptr[IDENT+hierpos]==POINTER) {
			if (ptr[IDENT+hierpos+1]!=VARIABLE
			  ||ptr[TYPE]==CINT)
				incval = SINT;
			else
				incval = SCHAR;
		} else if (ptr[IDENT+hierpos]==VARIABLE) {
			incval = 1;
		} else {
			error("Must be a pointer or a variable");
			return;
		}
	fprintf(stderr,"step: adjusting by %d\n",incval);
	} else fprintf(stderr,"step: No symbol table entry\n");

        if (lval[LVSTYPE]==0) {
        	rvalue(lval);
        	(*oper)(incval);
        	store(lval);
		return incval;
	}
        if (lval[5])    {
                push();
                rvalue(lval);
                (*oper)(incval);
                pop();
                store(lval);
                return incval;
        }
        else    {
                move();
                lval[5] = 1;
        }

        rvalue(lval);
        (*oper)(incval);
        store(lval);
	return incval;
}

store(lval)
int     lval[];
        {

        if (lval[LVSTYPE])
                putstk(lval);
        else
                putmem(lval);
}

rvalue(lval)
int     lval[];
        {

        if ((lval[LVSYM] != 0) & (lval[LVSTYPE] == 0))
                getmem(lval);
        else
                indirect(lval);
}

test(label, parens)
int     label, parens;
        {
        int     lval[LVALUE];
        char    *before, *start;

        if (parens)
                needtoken("(");

        for (;;)        {
                setstage(&before, &start);

                if (heir1(lval))
                        rvalue(lval);

                if (match(","))
                        clearstage(before, start);
                else
                        break;
        }

        if (parens)
                needtoken(")");


        if (lval[LVCONST])    {
                clearstage(before, 0);

                if (lval[LVCONVL])
                        return;

                jump(label);
                return;
        }

        if (lval[7])    {
                oper = lval[6];

                if ((oper == eq) | (oper == ule))
                        zerojump(eq0, label, lval);
                else if ((oper == ne) | (oper == ugt))
                        zerojump(ne0, label, lval);
                else if (oper == gt)
                        zerojump(gt0, label, lval);
                else if (oper == ge)
                        zerojump(ge0, label, lval);
                else if (oper == uge)
                        clearstage(lval[7], 0);
                else if (oper == lt)
                        zerojump(lt0, label, lval);
                else if (oper == ult)
                        zerojump(ult0, label, lval);
                else if (oper == le)
                        zerojump(le0, label, lval);
                else
                        testjump(label);
        }
        else
                testjump(label);

        clearstage(before, start);
}

constexpr(val)
int     *val;
        {
        int     const;
        char    *before, *start;

        setstage(&before, &start);
        expression(&const, val);
        clearstage(before, 0);

        if (const == 0)
                error("must be constant expression");

        return (const);
}

const(val)
int     val;
        {

        immed();
        outdec(val);
        nl();
}

const2(val)
int     val;
        {

        immed2();
        outdec(val);
        nl();
}

constant(lval)
int     lval[];
        {

        lval[LVCONST] = 1;

        if (number(&lval[LVCONVL]))
                immed();
        else if (pstr(&lval[LVCONVL]))
                immed();
        else if (qstr(&lval[LVCONVL]))    {
                lval[LVCONST] = 0;
                immed();
                printlabel(litlab);
                outbyte('+');
        }
        else
                return (0);

        outdec(lval[LVCONVL]);
        nl();
        return (1);
}

number(val)
int     *val;
        {
        int     k, minus;

        k = minus = 0;

        for (;;)        {
                if (match("+"))
                        ;
                else if (match("-"))
                        minus = 1;
                else
                        break;
        }

        if (numeric(ch) == 0)
                return (0);

        while (numeric(ch))
                k = k * 10 + (inbyte() - '0');

        if (minus)
                k = (-k);

        *val = k;
        return 1;
}

address(ptr)
char    *ptr;
        {

        immed();
        outstr(exname(ptr + NAME));
        nl();
}

pstr(val)
int     *val;
        {
        int     k;

        k = 0;

        if (match("'") == 0)
                return (0);

        while (ch != 39)
                k = (k & 255) * 256 + (litchar() & 255);

        ++lptr;
        *val = k;
        return (1);
}

qstr(val)
int     *val;
        {
        char    c;

        if (match(quote) == 0)
                return (0);

        *val = litptr;

        while (ch != '"')       {
                if (ch == 0)
                        break;

                stowlit(litchar(), 1);
        }

        gch();
        litq[litptr++] = 0;
        return (1);
}

stowlit(value, size)
int     value, size;
        {

        if ((litptr + size) >= LITMAX)  {
                error("literal queue overflow");
                exit(1);
        }

        putint(value, litq + litptr, size);
        litptr = litptr + size;
}

/*
**      return current literal char & bump ptr
*/

litchar()       {
        int     i, oct;

        if ((ch != 92) | (nch == 0))
                return (gch());

        gch();

        if (ch == 'n')  {
                gch();
                return (13);    /* CR or NL */
        }

        if (ch == 'r')  {
                gch();
                return (13);    /* CR */
        }

        if (ch == 't')  {
                gch();
                return (9);     /* HT */
        }

        if (ch == 'b')  {
                gch();
                return (8);     /* BS */
        }

        if (ch == 'f')  {
                gch();
                return (12);    /* FF */
        }

        i = 3;
        oct = 0;

        while (((i--) > 0) & (ch >= '0') & (ch <= '7'))
                oct = (oct << 3) + gch() - '0';

        if (i == 2)
                return (gch());
        else
                return (oct);
}
