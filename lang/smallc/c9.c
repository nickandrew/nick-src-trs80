/*
**      Small C Compiler Version 2.2 - 84/03/05 16:33:56 - c9.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

/*
**      add primary and secondary registers (result in primary)
*/

add()
        {

        ol("dad d");
}

/*
**      subtract primary from secondary register (result in primary)
*/

sub()
        {

        call("ccsub");
}

/*
**      multiply primary and secondary registers (result in primary)
*/

mult()
        {

        call("ccmult");
}

/*
**      divide secondary by primary register
**      (quotient in primary, remainder in secondary)
*/

div()
        {

        call("ccdiv");
}

/*
**      remainder of secondary / primary
**      (remainder in primary, quotient in secondary)
*/

mod()
        {

        div();
        swap();
}

/*
**      inclusive or primary and secondary registers
**      (result in primary)
*/

or()
        {

        call("ccor");
}

/*
**      exclusive or primary and secondary registers
**      (result in primary)
*/

xor()
        {

        call("ccxor");
}

/*
**      and primary and secondary registers (result in primary)
*/

and()
        {

        call("ccand");
}

/*
**      logical negation of primary register
*/

lneg()
        {

        call("cclneg");
}

/*
**      arithmetic shift right secondary register
**      number of bits given in primary register
**      (result in primary)
*/

asr()
        {

        call("ccasr");
}

/*
**      arithmetic shift left secondary register
**      number of bits given in primary register
**      (result in primary)
*/

asl()
        {

        call("ccasl");
}

/*
**      two's complement primary register
*/

neg()
        {

        call("ccneg");
}

/*
**      one's complement primary register
*/

com()
        {

        call("cccom");
}

/*
**      increment primary register by one object of whatever size
*/

inc(n)
int     n;
        {

        for (;;)        {
                ol("inx h");

                if (--n < 1)
                        break;
        }
}

/*
**      decrement primary register by one object of whatever size
*/

dec(n)
int     n;
        {

        for (;;)        {
                ol("dcx h");

                if (--n < 1)
                        break;
        }
}

/*
**      test for equal to
*/

eq()
        {

        call("cceq");
}

/*
**      test for equal to zero
*/

eq0(label)
int     label;
        {

        ol("mov a,h");
        ol("ora l");
        ot("jnz ");
        printlabel(label);
        nl();
}

/*
**      test for not equal to
*/

ne()
        {

        call("ccne");
}

/*
**      test for not equal to zero
*/

ne0(label)
int     label;
        {

        ol("mov a,h");
        ol("ora l");
        ot("jz ");
        printlabel(label);
        nl();
}

/*
**      test for less than (signed)
*/

lt()
        {

        call("cclt");
}

/*
**      test for less than zero
*/

lt0(label)
int     label;
        {

        ol("xra a");
        ol("ora h");
        ot("jp ");
        printlabel(label);
        nl();
}

/*
**      test for less than or equal to (signed)
*/

le()
        {

        call("ccle");
}

/*
**      test for less than or equal to zero
*/

le0(label)
int     label;
        {

        ol("mov a,h");
        ol("ora l");
        ol("jz .+8");
        ol("xra a");
        ol("ora h");
        ot("jp ");
        printlabel(label);
        nl();
}

/*
**      test for greater than (signed)
*/

gt()
        {

        call("ccgt");
}

/*
**      test for greater than zero
*/

gt0(label)
int     label;
        {

        ol("xra a");
        ol("ora h");
        ot("jm ");
        printlabel(label);
        nl();
        ol("ora l");
        ot("jz ");
        printlabel(label);
        nl();
}

/*
**      test for greater than or equal to (signed)
*/

ge()
        {

        call("ccge");
}

/*
**      test for greater than or equal to zero
*/

ge0(label)
int     label;
        {

        ol("xra a");
        ol("ora h");
        ot("jm ");
        printlabel(label);
        nl();
}

/*
**      test for less than (unsigned)
*/

ult()
        {

        call("ccult");
}

/*
**      test for less than to zero (unsigned)
*/

ult0(label)
int     label;
        {

        ot("jmp ");
        printlabel(label);
        nl();
}


/*
**      test for less than or equal to (unsigned)
*/

ule()
        {

        call("ccule");
}

/*
**      test for greater than (unsigned)
*/

ugt()
        {

        call("ccugt");
}

/*
**      test for greater than or equal to (unsigned)
*/

uge()
        {

        call("ccuge");
}

peephole(ptr)
char    *ptr;
        {

        while (*ptr)    {
                if (streq(ptr, "\tlxi h,0\n\tdad sp\n\tcall ccgint"))   {
                        if (streq(ptr + 31, "xchg;;"))  {
                                pp2();
                                ptr = ptr + 38;
                        }
                        else    {
                                pp1();
                                ptr = ptr + 30;
                        }
                }
                else if (streq(ptr, "\tlxi h,2\n\tdad sp\n\tcall ccgint"))      {
                        if (streq(ptr + 31, "xchg;;"))  {
                                pp3(pp2);
                                ptr = ptr + 38;
                        }
                        else    {
                                pp3(pp2);
                                ptr = ptr + 30;
                        }
                }
                else if (streq("\t.text\n\t.data\n"))   {
                        ptr = ptr + 14;
                }
                else if (optimize)      {
                        if (streq(ptr, "\tdad sp\n\tcall ccgint"))      {
                                ol("call ccdsgi");
                                ptr = ptr + 21;
                        }
                        else if (streq(ptr, "\tdad d\n\tcall ccgint"))  {
                                ol("call ccddgi");
                                ptr = ptr + 20;
                        }
                        else if (streq(ptr, "\tdad sp\n\tcall ccgchar"))        {
                                ol("call ccdsgc");
                                ptr = ptr + 22;
                        }
                        else if (streq(ptr, "\tdad d\n\tcall ccgchar")) {
                                ol("call ccddgc");
                                ptr = ptr + 21;
                        }
                        else if (streq(ptr,
"\tdad sp\n\tmov d,h\n\tmov e,l\n\tcall ccgint\n\tinx h\n\tcall ccpint"))               {
                                ol("call ccinci");
                                ptr = ptr + 59;
                        }
                        else if (streq(ptr,
"\tdad sp\n\tmov d,h\n\tmov e,l\n\tcall ccgint\n\tdcx h\n\tcall ccpint"))               {
                                ol("call ccdeci");
                                ptr = ptr + 59;
                        }
                        else if (streq(ptr,
"\tdad sp\n\tmov d,h\n\tmov e,l\n\tcall ccgchar\n\tinx h\n\tmov a,l\n\tstax d"))                {
                                ol("call ccincc");
                                ptr = ptr + 64;
                        }
                        else if (streq(ptr,
"\tdad sp\n\tmov d,h\n\tmov e,l\n\tcall ccgchar\n\tdcx h\n\tmov a,l\n\tstax d"))                {
                                ol("call ccdecc");
                                ptr = ptr + 64;
                        }
                        else if (streq(ptr, "\tdad d\n\tpop d\n\tcall ccpint")) {
                                ol("call ccddpdpi");
                                ptr = ptr + 27;
                        }
                        else if (streq(ptr, "\tdad d\n\tpop d\n\tmov a,l\n\tstax d"))   {
                                ol("call ccddpdpc");
                                ptr = ptr + 31;
                        }
                        else if (streq(ptr, "\tpop d\n\tcall ccpint"))  {
                                ol("call ccpdpi");
                                ptr = ptr + 20;
                        }
                        else if (streq(ptr, "\tpop d\n\tmov a,l\n\tstax d"))    {
                                ol("call ccpdpc");
                                ptr = ptr + 24;
                        }

                        /* additional optimizing logic goes here */
                        else
                                cout(*ptr++, output);
                }
                else
                        cout(*ptr++, output);
        }
}

pp1()
        {

        ol("pop h");
        ol("push h");
}

pp2()
        {

        ol("pop d");
        ol("push d");
}

pp3(pp)
int     (*pp)();
        {

        ol("pop b");
        (*pp)();
        ol("push b");
}
