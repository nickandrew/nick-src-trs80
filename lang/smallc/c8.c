/*
**      Small C Compiler Version 2.2 - 84/03/05 16:33:39 - c8.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

char    exbuff[32];             /* external name buffer */

/*
**      print all assembler info before any code is generated
*/

header()
        {
}

/*
**      print any assembler stuff needed at the end
*/

trailer()
        {

        ol(".end");
}

/*
**      make an external name
*/

exname(s)
char    *s;
        {
        char    *p;

        p = &exbuff;

        *p++ = '_';

        while (*p++ = *s++)
                ;

        return (&exbuff);
}

/*
**      declare entry point
*/

entry()
        {

        external(ssname);
        outstr(exname(ssname));
        col();
        nl();
}

/*
**      declare external reference
*/

external(name)
char    *name;
        {

        ot(".globl ");
        outstr(exname(name));
        nl();
}

/*
**      fetch object indirect to primary reference
*/

indirect(lval)
int     lval[];
        {

        if (lval[1] == CCHAR)
                call("ccgchar");
        else
                call("ccgint");
}

/*
**      fetch a static memory cell into primary register
*/

getmem(lval)
int     lval[];
        {
        char    *sym;

        sym = lval[0];

        if ((sym[IDENT] != POINTER) & (sym[TYPE] == CCHAR))     {
                ot("lda ");
                outstr(exname(sym + NAME));
                nl();
                call("ccsxt");
        }
        else    {
                ot("lhld ");
                outstr(exname(sym + NAME));
                nl();
        }
}

/*
**      fetch address of the specified symbol into primary register
*/

getloc(sym)
char    *sym;
        {

        const(getint(sym + OFFSET, OFFSIZE) - csp);
        ol("dad sp");
}

/*
**      store primary register into static cell
*/

putmem(lval)
int     lval[];
        {
        char    *sym;

        sym = lval[0];

        if ((sym[IDENT] != POINTER) & (sym[TYPE] == CCHAR))     {
                ol("mov a,l");
                ot("sta ");
        }
        else
                ot("shld ");

        outstr(exname(sym + NAME));
        nl();
}

/*
**      put on the stack the type object in primary register
*/

putstk(lval)
int     lval[];
        {

        if (lval[1] == CCHAR)   {
                ol("mov a,l");
                ol("stax d");
        }
        else
                call("ccpint");
}

/*
**      move primary register to secondary
*/

move()
        {

        ol("mov d,h");
        ol("mov e,l");
}

/*
**      swap primary and seconday registers
*/

swap()
        {

        ol("xchg;;");   /* peephole() uses trailing ";;" */
}

/*
**      partial instruction to get immediate operand
**      into primary register
*/

immed()
        {

        ot("lxi h,");
}

/*
**      partial instruction to get immediate operand
**      into secondary register
*/

immed2()
        {

        ot("lxi d,");
}

/*
**      push primary register onto stack
*/

push()
        {

        ol("push h");
        csp = csp - BPW;
}

/*
**      unpush or pop as required
*/

smartpop(lval, start)
int     lval[];
char    *start;
        {

        if (lval[5])
                pop();  /* secondary was used */
        else
                unpush(start);
}

/*
**      replace a push with a swap
*/

unpush(dest)
char    *dest;
        {
        int     i;
        char    *sour;

        sour = "\txchg;;";      /* peephole() uses trailing ";;" */

        while (*sour)
                *dest++ = *sour++;

        sour = stagenext;

        while (--sour > dest)   {
                /* adjust stack references */
                if (streq(sour, "\tdad sp"))    {
                        --sour;
                        i = BPW;

                        while (numeric(*(--sour)))      {
                                if ((*sour = *sour - i) < '0')  {
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
**      pop stack to secondary register
*/

pop()
        {

        ol("pop d");
        csp = csp + BPW;
}

/*
**      swap primary register and stack
*/

swapstk()
        {

        ol("xthl");
}

/*
**      process switch statement
*/

sw()
        {

        call("ccswitch");
}

/*
**      call specified routine name
*/

call(sname)
char    *sname;
        {

        ot("call ");
        outstr(sname);
        nl();
}

/*
**      return from subroutine
*/

ret()
        {

        ol("ret");
}

/*
**      perform subroutine call to value on stack
*/

callstk()
        {

        immed();
        outstr(".+5");
        nl();
        swapstk();
        ol("pchl");
        csp = csp + BPW;
}

/*
**      jump to internal label number
*/

jump(label)
int     label;
        {

        ot("jmp ");
        printlabel(label);
        nl();
}

/*
**      test primary register and jump if false
*/

testjump(label)
int     label;
        {

        ol("mov a,h");
        ol("ora l");
        ot("jz ");
        printlabel(label);
        nl();
}

/*
**      test primary against zero and jump if false
*/

zerojump(oper, label, lval)
int     label, lval[];
int     (*oper)();
        {

        clearstage(lval[7], 0);         /* clear conventional code */
        (*oper)(label);
}

/*
**      define storage according to size
*/

defstorage(size)
int     size;
        {

        if (size == 1)
                ot(".byte ");
        else
                ot(".word ");
}

/*
**      point to following objects
*/

point()
        {

        ol(".word .+2");
}

/*
**      modify stack pointer to value given
*/

modstk(newsp, save)
int     newsp, save;
        {
        int     k;

        k = newsp - csp;

        if (k == 0)
                return (newsp);

        if (k >= 0)     {
                if (k < 7)      {
                        if (k & 1)      {
                                ol("inx sp");
                                k--;
                        }

                        while (k)       {
                                ol("pop b");
                                k = k - BPW;
                        }

                        return (newsp);
                }
        }

        if (k < 0)      {
                if (k > -7)     {
                        if (k & 1)      {
                                ol("dcx sp");
                                k++;
                        }

                        while (k)       {
                                ol("push b");
                                k = k + BPW;
                        }

                        return (newsp);
                }
        }

        if (save)
                swap();

        const(k);
        ol("dad sp");
        ol("sphl");

        if (save)
                swap();

        return (newsp);
}

/*
**      double primary register
*/

doublereg()
        {

        ol("dad h");
}

/*
**      change to data segment
*/

dataseg()
        {

        ol(".data");
}

/*
**      change to text segment
*/

textseg()
        {

        ol(".text");
}
