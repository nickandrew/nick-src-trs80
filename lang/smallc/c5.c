/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:33:11 - c5.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

/*
**      lval[0] LVSYM   - symbol table address - 0 for constant => replaced by lvsymp
**      lval[1] LVSTYPE - type of indirect obj to fetch - 0 for static
**      lval[2] LVPTYPE - type of pointer or array - 0 for others
**      lval[3] LVCONST - true if constant expression
**      lval[4] LVCONVL - value of constant expression
**      lval[5] LVSECR  - true if secondary register altered
**      lval[6] LVOPFP  - function address of highest/last binary operator
**      lval[7] LVSTGP  - stage address of "oper 0" code - 0 otherwise
**      lval[8] LVHIER  - Position of Lvalue within type hierarchy
*/

/*
**      skim over terms adjoining || and && operators
*/

skim(opstr, testfunc, dropval, endval, heir, lval, lvsymp)
char *opstr;
int (*testfunc)(), dropval, endval, (*heir)(), lval[];
char **lvsymp;
{
    int k, hits, droplab, endlab;

    hits = 0;

    for (;;) {
        k = plunge1(heir, lval, lvsymp);

        if (nextop(opstr)) {
            bump(opsize);

            if (hits == 0) {
                hits = 1;
                droplab = getlabel();
            }

            dropout(k, testfunc, droplab, lval, lvsymp);
        } else if (hits) {
            dropout(k, testfunc, droplab, lval, lvsymp);
            const1(endval);
            jump(endlab = getlabel());
            postlabel(droplab);
            const1(dropval);
            postlabel(endlab);
            lval[LVSTYPE] = lval[LVPTYPE] = lval[LVCONST] = lval[LVSTGP] = 0;
            return (0);
        } else
            return (k);
    }
}

/*
**      test for early dropout from || or && evaluations
*/

dropout(k, testfunc, exit1, lval, lvsymp)
int k, exit1, lval[];
int (*testfunc)();
char **lvsymp;
{

    if (k)
        rvalue(lval, lvsymp);
    else if (lval[LVCONST])
        const1(lval[LVCONVL]);

    (*testfunc) (exit1);
}

/*
**      plunge to a lower level
*/

plunge(opstr, opoff, heir, lval, lvsymp)
char *opstr;
int opoff, lval[];
int (*heir)();
char **lvsymp;
{
    int k, lval2[LVALUE];
    char *lv2sym;

    lv2sym = 0;
    k = plunge1(heir, lval, lvsymp);

    if (nextop(opstr) == 0)
        return (k);

    if (k)
        rvalue(lval, lvsymp);

    for (;;) {
        if (nextop(opstr)) {
            bump(opsize);
            opindex = opindex + opoff;
            plunge2(op[opindex], op2[opindex], heir, lval, lvsymp, lval2, &lv2sym);
        } else
            return (0);
    }
}

/*
**      unary plunge to lower level
*/

plunge1(heir, lval, lvsymp)
int lval[];
int (*heir)();
char **lvsymp;
{
    char *before, *start;
    int k;

    setstage(&before, &start);
    k = (*heir) (lval, lvsymp);

    if (lval[LVCONST])
        clearstage(before, NULL);

    return (k);
}

/*
**      binary plunge to lower level
*/

plunge2(oper, oper2, heir, lval, lvsymp, lval2, lv2symp)
int lval[], lval2[];
int (*oper)(), (*oper2)(), (*heir)();
char **lvsymp, **lv2symp;
{
    char *before, *start;

    setstage(&before, &start);
    lval[LVSECR] = 1;
    lval[LVSTGP] = 0;

    if (lval[LVCONST]) {
        if (plunge1(heir, lval2, lv2symp))
            rvalue(lval2, lv2symp);

        if (lval[LVCONVL] == 0)
            lval[LVSTGP] = stagenext;

        const2(lval[LVCONVL] << dbltest(lval2, lv2symp, lval, lvsymp));
    } else {
        push();
        if (plunge1(heir, lval2, lv2symp))
            rvalue(lval2, lv2symp);

        if (lval2[LVCONST]) {
            if (lval2[LVCONVL] == 0)
                lval[LVSTGP] = start;

            if (oper == add) {
                csp = csp + 2;
                clearstage(before, NULL);
                const2(lval2[LVCONVL] << dbltest(lval, lvsymp, lval2, lv2symp));
            } else {
                const1(lval2[LVCONVL] << dbltest(lval, lvsymp, lval2, lv2symp));
                smartpop(lval2, lv2symp, start);
            }
        } else {
            smartpop(lval2, lv2symp, start);
            if ((oper == add) | (oper == sub)) {
                if (dbltest(lval, lvsymp, lval2, lv2symp))
                    doublereg();

                if (dbltest(lval2, lv2symp, lval, lvsymp)) {
                    swap();
                    doublereg();

                    if (oper == sub)
                        swap();
                }
            }
        }
    }

    if (oper) {
        if (lval[LVCONST] = lval[LVCONST] & lval2[LVCONST]) {
            lval[LVCONVL] = calc(lval[LVCONVL], oper, lval2[LVCONVL]);
            clearstage(before, NULL);
            lval[LVSECR] = 0;
        } else {
            if ((lval[LVPTYPE] == 0) & (lval2[LVPTYPE] == 0)) {
                (*oper) ();
                lval[LVOPFP] = oper;
            } else {
                (*oper2) ();
                lval[LVOPFP] = oper2;
            }
        }

        if (oper == sub) {
            if ((lval[LVPTYPE] == CINT) & (lval2[LVPTYPE] == CINT)) {
                swap();
                const1(1);
                asr();
            }
        }

        if ((oper == sub) | (oper == add))
            result(lval, lvsymp, lval2, lv2symp);
    }
}

calc(left, oper, right)
int left, right;
int (*oper)();
{

    if (oper == or)
        return (left | right);
    else if (oper == xor)
        return (left ^ right);
    else if (oper == and)
        return (left & right);
    else if (oper == eq)
        return (left == right);
    else if (oper == ne)
        return (left != right);
    else if (oper == le)
        return (left <= right);
    else if (oper == ge)
        return (left >= right);
    else if (oper == lt)
        return (left < right);
    else if (oper == gt)
        return (left > right);
    else if (oper == asr)
        return (left >> right);
    else if (oper == asl)
        return (left << right);
    else if (oper == add)
        return (left + right);
    else if (oper == sub)
        return (left - right);
    else if (oper == mult)
        return (left * right);
    else if (oper == op_div)
        return (left / right);
    else if (oper == mod)
        return (left % right);
    else
        return (0);
}

expression(pi_const, val)
int *pi_const, *val;
{
    int lval[LVALUE];
    char *lvsym;

    lvsym = 0;
    if (heir1(lval, &lvsym))
        rvalue(lval, &lvsym);

    if (lval[LVCONST]) {
        *pi_const = 1;
        *val = lval[LVCONVL];
    } else
        *pi_const = 0;
}

heir1(lval, lvsymp)
int lval[];
char **lvsymp;
{
    int k, lval2[LVALUE];
    char *lv2sym;
    int (*oper)();

    lv2sym = 0;
    k = plunge1(heir3, lval, lvsymp);

    if (lval[LVCONST])
        const1(lval[LVCONVL]);

    if (match("|="))
        oper = or;
    else if (match("^="))
        oper = xor;
    else if (match("&="))
        oper = and;
    else if (match("+="))
        oper = add;
    else if (match("-="))
        oper = sub;
    else if (match("*="))
        oper = mult;
    else if (match("/="))
        oper = op_div;
    else if (match("%="))
        oper = mod;
    else if (match(">>="))
        oper = asr;
    else if (match("<<="))
        oper = asl;
    else if (match("="))
        oper = 0;
    else
        return (k);

    if (k == 0) {
        needlval();
        return (0);
    }

    if (lval[LVSTYPE]) {
        if (oper) {
            push();
            rvalue(lval, lvsymp);
        }

        plunge2(oper, oper, heir1, lval, lvsymp, lval2, &lv2sym);

        if (oper)
            pop();
    } else {
        if (oper) {
            rvalue(lval, lvsymp);
            plunge2(oper, oper, heir1, lval, lvsymp, lval2, &lv2sym);
        } else {
            if (heir1(lval2, &lv2sym))
                rvalue(lval2, &lv2sym);

            lval[LVSECR] = lval2[LVSECR];
        }
    }

    store(lval, lvsymp);
    return (0);
}

heir3(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (skim("||", eq0, 1, 0, heir4, lval, lvsymp));
}

heir4(lval, lvsymp)
int lval[];
char **lvsymp;
{
    return (skim("&&", ne0, 0, 1, heir5, lval, lvsymp));
}

heir5(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("|", 0, heir6, lval, lvsymp));
}

heir6(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("^", 1, heir7, lval, lvsymp));
}

heir7(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("&", 2, heir8, lval, lvsymp));
}

heir8(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("== !=", 3, heir9, lval, lvsymp));
}

heir9(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("<= >= < >", 5, heir10, lval, lvsymp));
}

heir10(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge(">> <<", 9, heir11, lval, lvsymp));
}

heir11(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("+ -", 11, heir12, lval, lvsymp));
}

heir12(lval, lvsymp)
int lval[];
char **lvsymp;
{

    return (plunge("* / %", 13, heir13, lval, lvsymp));
}
