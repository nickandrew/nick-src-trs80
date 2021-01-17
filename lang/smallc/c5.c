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
**      lval[6] LVOPFP  - function address of highest/last binary operator => replaced by lvopfpp
**      lval[7] LVSTGP  - stage address of "oper 0" code - 0 otherwise => replaced by lvstgpp
**      lval[8] LVHIER  - Position of Lvalue within type hierarchy
*/

/* Initialise all elements of an lval to 0 */
init_lval(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    int i;

    for (i = 0; i <= LVHIER; ++i)
        lval[i] = 0;

    *lvsymp = 0;
    *lvopfpp = 0;
    *lvstgpp = 0;
}

/*
**      skim over terms adjoining || and && operators
*/

skim(opstr, testfunc, dropval, endval, heir, lval, lvsymp, lvopfpp, lvstgpp)
char *opstr;
int (*testfunc)(), dropval, endval, (*heir)(), lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    int k, hits, droplab, endlab;

    hits = 0;

    for (;;) {
        k = plunge1(heir, lval, lvsymp, lvopfpp, lvstgpp);

        if (nextop(opstr)) {
            bump(opsize);

            if (hits == 0) {
                hits = 1;
                droplab = getlabel();
            }

            dropout(k, testfunc, droplab, lval, lvsymp, lvopfpp, lvstgpp);
        } else if (hits) {
            dropout(k, testfunc, droplab, lval, lvsymp, lvopfpp, lvstgpp);
            const1(endval);
            jump(endlab = getlabel());
            postlabel(droplab);
            const1(dropval);
            postlabel(endlab);
            lval[LVSTYPE] = lval[LVPTYPE] = lval[LVCONST] = 0;
            *lvstgpp = 0;
            return (0);
        } else
            return (k);
    }
}

/*
**      test for early dropout from || or && evaluations
*/

dropout(k, testfunc, exit1, lval, lvsymp, lvopfpp, lvstgpp)
int k, exit1, lval[];
int (*testfunc)();
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    if (k)
        rvalue(lval, lvsymp, lvopfpp, lvstgpp);
    else if (lval[LVCONST])
        const1(lval[LVCONVL]);

    (*testfunc) (exit1);
}

/*
**      plunge to a lower level
*/

plunge(opstr, opoff, heir, lval, lvsymp, lvopfpp, lvstgpp)
char *opstr;
int opoff, lval[];
int (*heir)();
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    int k, lval2[LVALUE];
    char *lv2sym;
    int (*lv2opfp)();
    char *lv2stgp;

    init_lval(lval2, &lv2sym, &lv2opfp, &lv2stgp);
    k = plunge1(heir, lval, lvsymp, lvopfpp, lvstgpp);

    if (nextop(opstr) == 0)
        return (k);

    if (k)
        rvalue(lval, lvsymp, lvopfpp, lvstgpp);

    for (;;) {
        if (nextop(opstr)) {
            bump(opsize);
            opindex = opindex + opoff;
            plunge2(op[opindex], op2[opindex], heir, lval, lvsymp, lvopfpp, lvstgpp, lval2, &lv2sym,
                    &lv2opfp, &lv2stgp);
        } else
            return (0);
    }
}

/*
**      unary plunge to lower level
*/

plunge1(heir, lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
int (*heir)();
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    char *before, *start;
    int k;

    setstage(&before, &start);
    k = (*heir) (lval, lvsymp, lvopfpp, lvstgpp);

    if (lval[LVCONST])
        clearstage(before, NULL);

    return (k);
}

/*
**      binary plunge to lower level
*/

plunge2(oper, oper2, heir, lval, lvsymp, lvopfpp, lvstgpp, lval2, lv2symp, lv2opfpp, lv2stgpp)
int lval[], lval2[];
int (*oper)(), (*oper2)(), (*heir)();
char **lvsymp, **lv2symp;
int (**lvopfpp)(), (**lv2opfpp)();
char **lvstgpp, **lv2stgpp;
{
    char *before, *start;

    setstage(&before, &start);
    lval[LVSECR] = 1;
    *lvstgpp = 0;

    if (lval[LVCONST]) {
        if (plunge1(heir, lval2, lv2symp, lv2opfpp, lv2stgpp))
            rvalue(lval2, lv2symp, lv2opfpp, lv2stgpp);

        if (lval[LVCONVL] == 0)
            *lvstgpp = stagenext;

        const2(lval[LVCONVL] <<
               dbltest(lval2, lv2symp, lv2opfpp, lv2stgpp, lval, lvsymp, lvopfpp, lvstgpp));
    } else {
        push();
        if (plunge1(heir, lval2, lv2symp, lv2opfpp, lv2stgpp))
            rvalue(lval2, lv2symp, lv2opfpp, lv2stgpp);

        if (lval2[LVCONST]) {
            if (lval2[LVCONVL] == 0)
                *lvstgpp = start;

            if (oper == add) {
                csp = csp + 2;
                clearstage(before, NULL);
                const2(lval2[LVCONVL] <<
                       dbltest(lval, lvsymp, lvopfpp, lvstgpp, lval2, lv2symp, lv2opfpp, lv2stgpp));
            } else {
                const1(lval2[LVCONVL] <<
                       dbltest(lval, lvsymp, lvopfpp, lvstgpp, lval2, lv2symp, lv2opfpp, lv2stgpp));
                smartpop(lval2, lv2symp, lv2opfpp, lv2stgpp, start);
            }
        } else {
            smartpop(lval2, lv2symp, lv2opfpp, lv2stgpp, start);
            if ((oper == add) | (oper == sub)) {
                if (dbltest(lval, lvsymp, lvopfpp, lvstgpp, lval2, lv2symp, lv2opfpp, lv2stgpp))
                    doublereg();

                if (dbltest(lval2, lv2symp, lv2opfpp, lv2stgpp, lval, lvsymp, lvopfpp, lvstgpp)) {
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
                *lvopfpp = oper;
            } else {
                (*oper2) ();
                *lvopfpp = oper2;
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
            result(lval, lvsymp, lvopfpp, lvstgpp, lval2, lv2symp, lv2opfpp, lv2stgpp);
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
    int (*lvopfp)();
    char *lvstgp;

    init_lval(lval, &lvsym, &lvopfp, &lvstgp);
    if (heir1(lval, &lvsym, &lvopfp, &lvstgp))
        rvalue(lval, &lvsym, &lvopfp, &lvstgp);

    if (lval[LVCONST]) {
        *pi_const = 1;
        *val = lval[LVCONVL];
    } else
        *pi_const = 0;
}

heir1(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    int k, lval2[LVALUE];
    char *lv2sym;
    int (*lv2opfp)();
    char *lv2stgp;
    int (*oper)();

    init_lval(lval2, &lv2sym, &lv2opfp, &lv2stgp);
    k = plunge1(heir3, lval, lvsymp, lvopfpp, lvstgpp);

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
            rvalue(lval, lvsymp, lvopfpp, lvstgpp);
        }

        plunge2(oper, oper, heir1, lval, lvsymp, lvopfpp, lvstgpp, lval2, &lv2sym, &lv2opfp,
                &lv2stgp);

        if (oper)
            pop();
    } else {
        if (oper) {
            rvalue(lval, lvsymp, lvopfpp, lvstgpp);
            plunge2(oper, oper, heir1, lval, lvsymp, lvopfpp, lvstgpp, lval2, &lv2sym, &lv2opfp,
                    &lv2stgp);
        } else {
            if (heir1(lval2, &lv2sym, &lv2opfp, &lv2stgp))
                rvalue(lval2, &lv2sym, &lv2opfp, &lv2stgp);

            lval[LVSECR] = lval2[LVSECR];
        }
    }

    store(lval, lvsymp, lvopfpp, lvstgpp);
    return (0);
}

heir3(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (skim("||", eq0, 1, 0, heir4, lval, lvsymp, lvopfpp, lvstgpp));
}

heir4(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{
    return (skim("&&", ne0, 0, 1, heir5, lval, lvsymp, lvopfpp, lvstgpp));
}

heir5(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("|", 0, heir6, lval, lvsymp, lvopfpp, lvstgpp));
}

heir6(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("^", 1, heir7, lval, lvsymp, lvopfpp, lvstgpp));
}

heir7(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("&", 2, heir8, lval, lvsymp, lvopfpp, lvstgpp));
}

heir8(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("== !=", 3, heir9, lval, lvsymp, lvopfpp, lvstgpp));
}

heir9(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("<= >= < >", 5, heir10, lval, lvsymp, lvopfpp, lvstgpp));
}

heir10(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge(">> <<", 9, heir11, lval, lvsymp, lvopfpp, lvstgpp));
}

heir11(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("+ -", 11, heir12, lval, lvsymp, lvopfpp, lvstgpp));
}

heir12(lval, lvsymp, lvopfpp, lvstgpp)
int lval[];
char **lvsymp;
int (**lvopfpp)();
char **lvstgpp;
{

    return (plunge("* / %", 13, heir13, lval, lvsymp, lvopfpp, lvstgpp));
}
