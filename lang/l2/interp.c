/*      Languages & Processors
**
**      interp.c  - L2 machine language interpreter
**
**      Nick Andrew, 8425464    (zeta@amdahl)
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "interp.h"
#include "opcodes.h"
#include "la.h"

extern FILE *f_out;

int   data[1000],program[1000];
int   sp=0, sb, sb1, l, rv;
int   pc, level, st, fn, lalev;

static void setlevptr(void);
static void pushs(int value);
static int pops(void);
void loadmem(void);

int execute(void)
{
    int value, temp1;

    value = program[pc++];

    if (debug) {
        fprintf(f_debug, "pc:%5d   instr:%5d   sp:%5d\n", pc - 1, value, sp);
    }

    if (value >= 0) {
        pushs(value);
        return 0;
    }

    switch (value) {

    case -1:                   /* addition */
        pushs(pops() + pops());
        break;

    case -2:                   /* binary subtraction */
        temp1 = pops();
        pushs(pops() - temp1);
        break;

    case -3:                   /* multiplication */
        pushs(pops() * pops());
        break;

    case -4:                   /* division */
        temp1 = pops();
        if (temp1 == 0) {
            fprintf(stderr, "Division by zero\n");
            return 1;
        }
        pushs(pops() / temp1);
        break;

    case -5:                   /* equality */
        pushs(pops() == pops());        /* 1 or 0 */
        break;

    case -6:                   /* not equal */
        pushs(pops() != pops());
        break;

    case -7:                   /* less than */
        temp1 = pops();
        pushs(pops() < temp1);
        break;

    case -8:                   /* less than or equal to */
        temp1 = pops();
        pushs(pops() <= temp1);
        break;

    case -9:                   /* greater than */
        temp1 = pops();
        pushs(pops() > temp1);
        break;

    case -10:                  /* greater than or equal to */
        temp1 = pops();
        pushs(pops() >= temp1);
        break;

    case -11:                  /* assignment */
        temp1 = pops();
        data[pops()] = temp1;
        break;

    case -12:                  /* logical or */
        pushs(pops() || pops());
        break;

    case -13:                  /* logical AND */
        pushs(pops() && pops());
        break;

    case -14:                  /* RETURN instruction */
        rv = pops();
        sp = sb - 4;
        data[sp] = rv;
        level = data[sp + 2];
        sb = data[sp + 4];
        pc = data[sp + 1];
        break;

    case -15:                  /* unary + (no-op) */
        break;

    case -16:                  /* unary - */
        pushs(-pops());
        break;

    case -17:                  /* STOP instruction */
        printf("STOP encountered at %d\n", pc - 1);
        return 1;
        break;

    case -18:                  /* CRASH instruction */
        printf("CRASH at %d\n", pc - 1);
        return 1;
        break;

    case -19:                  /* READ instruction */
        fprintf(stdout, "? ");
        scanf("%d", &temp1);
        /* if redirecting output then echo input */
        if (!isatty(1))
            printf("%d\n", temp1);
        data[pops()] = temp1;
        break;

    case -20:                  /* WRITE instruction */
        putchar('\n');
        break;

    case -21:                  /* WS instruction */
        fputs(strtabl + pops(), stdout);
        break;

    case -22:                  /* WN infraction */
        printf(" %d", pops());
        break;

    case -23:                  /* GIF instruction */
        temp1 = pops();
        if (!pops())
            pc = temp1;
        break;

    case -24:                  /* GO instruction */
        pc = pops();
        break;

    case -25:                  /* ISP instruction */
        sp += 5;
        break;

    case -26:                  /* CALL instruction */
        fn = pops();
        sb1 = sp - functabl[fn].nparam;
        data[sb1 - 3] = pc;     /* its already incremented */
        data[sb1] = sb;
        setlevptr();
        data[sb1 - 2] = level;
        level = functabl[fn].flevel;
        sb = sb1;

        /* allocate space for locals */
        sp = sp + functabl[fn].nlocal;
        pc = functabl[fn].startloc;
        break;

    case -27:                  /* ISB instruction */
        lalev = pops();
        st = sb;
        if (lalev < level)
            for (l = lalev; l < level; ++l)
                st = data[st - 1];
        data[sp] = data[sp] + st;
        break;

    case -28:                  /* RS instruction */
        pushs(data[pops()]);
        break;

    case -29:                  /* RN instruction */
        /* Was: pushs(numbtabl[pops()]);
        ** I'm guessing that this is just an index into a constant value,
        ** not a data structure.
        */
        pushs(numbtabl[pops()].numb);
        break;

    case -30:                  /* START instruction */
        level = 1;
        sp = functabl[1].nlocal;
        pc = functabl[1].startloc;
        break;

    default:
        printf("Illegal instruction: %d\n", value);
        break;
    }
    return 0;
}

/*
**  setlevptr() ... Set the pointer to the previous level s/b
*/

static void setlevptr(void)
{

    int sb2;

    if (functabl[fn].flevel == level) {
        data[sb1 - 1] = data[data[sb1] - 1];
    } else if (functabl[fn].flevel > level) {
        data[sb1 - 1] = data[sb1];
    } else {
        sb2 = data[sb1];
        for (l = functabl[fn].flevel; l < level; ++l)
            sb2 = data[sb2 - 1];
        data[sb1 - 1] = data[sb2 - 1];
    }
}

static void pushs(int value)
{
    if (sp >= 1000) {
        fprintf(stderr, "Execution stack overflow, sp = %d\n", sp);
        exit(1);
    }
    data[++sp] = value;
}

static int pops(void)
{
    if (sp < 0) {
        fprintf(stderr, "Execution stack underflow\n");
        exit(1);
    }
    return data[sp--];
}

void loadmem(void)
{
    int loc;
    rewind(f_out);
    loc = 1;
    while (!feof(f_out)) {
        /* Was: program[loc] = getw(f_out); */
        int i, n;
        n = fscanf(f_out, " %d", &i);
        if (n != 1) {
            break;
        }
        ++loc;
    }
}
