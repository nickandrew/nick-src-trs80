/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:33:39 - c8.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include <stdlib.h>
#include <stdio.h>

#include        "cc.h"

char exbuff[32];                /* external name buffer */

/*
**      print all assembler info before any code is generated
*/

header()
{
    ol("COM\t'<small c compiler output>'");
    outstr("*MOD\n");
}

/*
**      print any assembler stuff needed at the end
*/

trailer()
{

    ol("END");
}

/*
**      make an external name
*/

char *exname(s)
char *s;
{

    char *p;

    p = exbuff;

    *p++ = '_';

    while (*s) {
        if (*s >= 'a' && *s <= 'z')
            *p++ = (*s++ & 95);
        else
            *p++ = *s++;
    }
    *p++ = 0;

    return (exbuff);
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
char *name;
{

/*      outstr(";\textrn\t");   */
/*      outstr(exname(name));   */
/*      nl();               */
}

/*
**      fetch object indirect to primary reference
*/

indirect(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    char *ptr;
    ptr = *lvsymp;

    if (ptr != 0) {
        if (ptr[lval[LVHIER] + IDENT] != VARIABLE) {
            call("CCGINT");
        } else {
            if (ptr[TYPE] == CCHAR)
                call("CCGCHAR");
            else
                call("CCGINT");
        }
        return;
    } else {
        fprintf(stderr, "* indirect: no link to symbol table\n");
        exit(1);
    }

/*    if (lval[LVSTYPE] == CCHAR)
        call("CCGCHAR");
    else call("CCGINT");
*/
}

/*
**      fetch a static memory cell into primary register
*/

getmem(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    char *sym;

    sym = *lvsymp;

    if ((sym[IDENT] != POINTER) && (sym[TYPE] == CCHAR)) {
        ot("LD\tA,(");
        outstr(exname(sym + NAME));
        outstr(")");
        nl();
        call("CCSXT");
    } else {
        ot("LD\tHL,(");
        outstr(exname(sym + NAME));
        outstr(")");
        nl();
    }
}

/*
**      fetch address of the specified symbol into primary register
*/

getloc(sym)
char *sym;
{

    const1(getint(sym + OFFSET, OFFSIZE) - csp);
    ol("ADD\tHL,SP");
}

/*
**      store primary register into static cell
*/

putmem(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    char *sym;

    sym = *lvsymp;

    if ((sym[IDENT] != POINTER) & (sym[TYPE] == CCHAR)) {
        ol("LD\tA,L");
        ot("LD\t(");
        outstr(exname(sym + NAME));
        outstr("),A");
    } else {
        ot("LD\t(");
        outstr(exname(sym + NAME));
        outstr("),HL");
    }
    nl();
}

/*
**      put on the stack the type object in primary register
*/

putstk(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    char *ptr;
    ptr = *lvsymp;

    if (ptr != 0) {
        if (ptr[lval[LVHIER] + IDENT] == POINTER) {
            call("CCPINT");
            return;
        } else {
            if (lval[LVSTYPE] == CCHAR) {
                ol("LD\tA,L");
                ol("LD\t(DE),A");
            } else
                call("CCPINT");
            return;
        }
    } else {
        fprintf(stderr, "* putstk: no link to symbol table\n");
        exit(1);
    }

/*    if (lval[LVSTYPE] == CCHAR) {
**      ol("LD\tA,L");
**      ol("LD\t(DE),A");
**  } else 
**      call("CCPINT");
*/
}

/*
**      move primary register to secondary
*/

move()
{

    ol("LD\tD,H");
    ol("LD\tE,L");
}

/*
**      swap primary and seconday registers
*/

swap()
{

    ol("EX\tDE,HL");            /* peephole() uses trailing ";;" */
}

/*
**      partial instruction to get immediate operand
**      into primary register
*/

immed()
{

    ot("LD\tHL,");
}

/*
**      partial instruction to get immediate operand
**      into secondary register
*/

immed2()
{

    ot("LD\tDE,");
}

/*
**      push primary register onto stack
*/

push()
{

    ol("PUSH\tHL");
    csp = csp - BPW;
}

/*
**      unpush or pop as required
*/

smartpop(lval, lvsymp, lvopfpp, lvstgpp, start)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
char *start;
{

/*        if (lval[LVSECR])         */
    /*                pop();            *//* secondary was used */
/*        else                      */
/*                unpush(start);        */

    pop();
}

/*
**      pop stack to secondary register
*/

pop()
{

    ol("POP\tDE");
    csp = csp + BPW;
}

/*
**      swap primary register and stack
*/

swapstk()
{

    ol("EX\t(SP),HL");
}

/*
**      process switch statement
*/

sw()
{

    call("CCSWITCH");
}

/*
**      call specified routine name
*/

call(sname)
char *sname;
{

    ot("CALL\t");
    outstr(sname);
    nl();
}

/*
**      return from subroutine
*/

ret()
{

    ol("RET");
}

/*
**      perform subroutine call to value on stack
*/

callstk()
{

    immed();
    outstr("$+5");
    nl();
    swapstk();
    ol("JP\t(HL)");
    csp = csp + BPW;
}

/*
**      jump to internal label number
*/

jump(label)
int label;
{

    ot("JP\t");
    printlabel(label);
    nl();
}

/*
**      test primary register and jump if false
*/

testjump(label)
int label;
{

    ol("LD\tA,H");
    ol("OR\tL");
    ot("JP\tZ,");
    printlabel(label);
    nl();
}

/*
**      test primary against zero and jump if false
*/

zerojump(oper, label, lval, lvsymp, lvopfpp, lvstgpp)
int label, lval[];
int (*oper)();
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    clearstage(*lvstgpp, NULL); /* clear conventional code */
    (*oper) (label);
}

/*
**      define storage according to size
*/

defstorage(size)
int size;
{

    if (size == 1)
        ot("DEFB\t");
    else
        ot("DEFW\t");
}

/*
**      point to following objects
*/

point()
{

    ol("DEFW\t$+2");
}

/*
**      modify stack pointer to value given
*/

modstk(newsp, save)
int newsp, save;
{
    int k;

    k = newsp - csp;

    if (k == 0)
        return (newsp);

    if (k >= 0) {
        if (k < 7) {
            if (k & 1) {
                ol("INC\tSP");
                k--;
            }

            while (k) {
                ol("POP\tBC");
                k = k - BPW;
            }

            return (newsp);
        }
    }

    if (k < 0) {
        if (k > -7) {
            if (k & 1) {
                ol("DEC\tSP");
                k++;
            }

            while (k) {
                ol("PUSH\tBC");
                k = k + BPW;
            }

            return (newsp);
        }
    }

    if (save)
        swap();

    const1(k);
    ol("ADD\tHL,SP");
    ol("LD\tSP,HL");

    if (save)
        swap();

    return (newsp);
}

/*
**      double primary register
*/

doublereg()
{

    ol("ADD\tHL,HL");
}

/*
**      change to data segment
*/

dataseg()
{

/*      outstr(";\tDSEG\n");    */
}

/*
**      change to text segment
*/

textseg()
{

/*      outstr(";\tCSEG\n");    */
}

/* dumpsym ... dump the symbol table */
dumpsym(flag)
int flag;
{
    FILE *st;
    char *cp;

    if (flag == 1) {
        char x;
        scanf(" %c", &x);
        if (x != 'y')
            return;
    }

    if ((st = fopen("symloc", "w")) == NULL)
        return;

    cp = STARTLOC;

    while (cp < ENDLOC)
        fputc(*(cp++), st);
    fclose(st);
    if ((st = fopen("symglb", "w")) == NULL)
        return;
    cp = STARTGLB;

    while (cp < ENDGLB)
        fputc(*(cp++), st);
    fclose(st);
}
