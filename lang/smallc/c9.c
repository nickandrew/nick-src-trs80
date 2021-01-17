/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:33:56 - c9.c
**
**      Copyright 1982 J. E. Hendrix
**
**      Lacking the peephole() routine ... that will go in a
**      stand-alone optimiser called peephole.
**
*/

#include        "cc.h"

/*
**      add primary and secondary registers (result in primary)
*/

add()
{
    ol("ADD\tHL,DE");
}

/*
**      subtract primary from secondary register (result in primary)
*/

sub()
{

    call("CCSUB");
}

/*
**      multiply primary and secondary registers (result in primary)
*/

mult()
{

    call("CCMULT");
}

/*
**      divide secondary by primary register
**      (quotient in primary, remainder in secondary)
*/

op_div()
{

    call("CCDIV");
}

/*
**      remainder of secondary / primary
**      (remainder in primary, quotient in secondary)
*/

mod()
{

    op_div();
    swap();
}

/*
**      inclusive or primary and secondary registers
**      (result in primary)
*/

or()
{

    call("CCOR");
}

/*
**      exclusive or primary and secondary registers
**      (result in primary)
*/

xor()
{

    call("CCXOR");
}

/*
**      and primary and secondary registers (result in primary)
*/

and()
{

    call("CCAND");
}

/*
**      logical negation of primary register
*/

lneg()
{

    call("CCLNEG");
}

/*
**      arithmetic shift right secondary register
**      number of bits given in primary register
**      (result in primary)
*/

asr()
{

    call("CCASR");
}

/*
**      arithmetic shift left secondary register
**      number of bits given in primary register
**      (result in primary)
*/

asl()
{

    call("CCASL");
}

/*
**      two's complement primary register
*/

neg()
{

    call("CCNEG");
}

/*
**      one's complement primary register
*/

com()
{

    call("CCCOM");
}

/*
**      increment primary register by 'n'
**      decrement primary register by 'n'
*/

inc(n)
int n;
{

    fprintf(stderr, "Increment value is: %d\n", n);
    while (n > 0) {
        ol("INC\tHL");
        --n;
    }
    while (n < 0) {
        ol("DEC\tHL");
        ++n;
    }
}

/*
**      decrement primary register by one object of whatever size
*/

dec(n)
int n;
{

    for (;;) {
        ol("DEC\tHL");

        if (--n < 1)
            break;
    }
}

/*
**      test for equal to
*/

eq()
{

    call("CCEQ");
}

/*
**      test for equal to zero
*/

eq0(label)
int label;
{

    ol("LD\tA,H");
    ol("OR\tL");
    ot("JP\tNZ,");
    printlabel(label);
    nl();
}

/*
**      test for not equal to
*/

ne()
{

    call("CCNE");
}

/*
**      test for not equal to zero
*/

ne0(label)
int label;
{

    ol("LD\tA,H");
    ol("OR\tL");
    ot("JP\tZ,");
    printlabel(label);
    nl();
}

/*
**      test for less than (signed)
*/

lt()
{

    call("CCLT");
}

/*
**      test for less than zero
*/

lt0(label)
int label;
{

    ol("XOR\tA");
    ol("OR\tH");
    ot("JP\tP,");               /* this right?? Jump if positive?? */
    printlabel(label);
    nl();
}

/*
**      test for less than or equal to (signed)
*/

le()
{

    call("CCLE");
}

/*
**      test for less than or equal to zero
*/

le0(label)
int label;
{

    ol("LD\tA,H");
    ol("OR\tL");
    ol("JP\tZ,$+8");
    ol("XOR\tA");
    ol("OR\tH");
    ot("JP\tP,");
    printlabel(label);
    nl();
}

/*
**      test for greater than (signed)
*/

gt()
{

    call("CCGT");
}

/*
**      test for greater than zero
*/

gt0(label)
int label;
{

    ol("XOR\tA");
    ol("OR\tH");
    ot("JP\tM,");
    printlabel(label);
    nl();
    ol("OR\tL");
    ot("JP\tZ,");
    printlabel(label);
    nl();
}

/*
**      test for greater than or equal to (signed)
*/

ge()
{

    call("CCGE");
}

/*
**      test for greater than or equal to zero
*/

ge0(label)
int label;
{

    ol("XOR\tA");
    ol("OR\tH");
    ot("JP\tM,");
    printlabel(label);
    nl();
}

/*
**      test for less than (unsigned)
*/

ult()
{

    call("CCULT");
}

/*
**      test for less than to zero (unsigned)
*/

ult0(label)
int label;
{

    ot("JP\t");                 /* always succeeds */
    printlabel(label);
    nl();
}


/*
**      test for less than or equal to (unsigned)
*/

ule()
{

    call("CCULE");
}

/*
**      test for greater than (unsigned)
*/

ugt()
{

    call("CCUGT");
}

/*
**      test for greater than or equal to (unsigned)
*/

uge()
{

    call("CCUGE");
}
