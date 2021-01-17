/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:33:22 - c6.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

heir13(lval)
int lval[];
{
    int k;
    char *ptr;
    int hierpos, incval;

    if (match("++")) {
        if (heir13(lval) == 0) {
            needlval();
            return (0);
        }

        step(1, lval);
        return (0);
    } else if (match("--")) {
        if (heir13(lval) == 0) {
            needlval();
            return (0);
        }

        step(-1, lval);
        return (0);
    } else if (match("~")) {
        if (heir13(lval))
            rvalue(lval);

        com();
        lval[LVCONVL] = ~lval[LVCONVL];
        return (0);
    } else if (match("!")) {
        if (heir13(lval))
            rvalue(lval);

        lneg();
        lval[LVCONVL] = !lval[LVCONVL];
        return (0);
    } else if (match("-")) {
        if (heir13(lval))
            rvalue(lval);

        neg();
        lval[LVCONVL] = -lval[LVCONVL];
        return (0);
    } else if (match("*")) {
        if (heir13(lval)) {
            rvalue(lval);
        }
        if (ptr = lval[LVSYM]) {
            hierpos = lval[LVHIER];
            if (ptr[IDENT + hierpos] != VARIABLE)
                lval[LVHIER] = ++hierpos;
            else
                error("Not a pointer type");
        } else
            fprintf(stderr, "* ptr: no symbol table\n");

        if (ptr = lval[LVSYM]) {
            hierpos = lval[LVHIER];
            if (ptr[IDENT + hierpos] == VARIABLE) {
                lval[LVSTYPE] = ptr[TYPE];
                lval[LVPTYPE] = 0;
            } else {
                lval[LVSTYPE] = CINT;
                if (ptr[IDENT + hierpos + 1] == VARIABLE)
                    lval[LVPTYPE] = 0;
                else
                    lval[LVPTYPE] = ptr[TYPE];
            }
        } else {
            lval[LVSTYPE] = CINT;
        }

        lval[LVCONST] = 0;
        return (1);
    } else if (match("&")) {
        if (heir13(lval) == 0) {
            error("illegal address");
            return (0);
        }

        ptr = lval[LVSYM];
        lval[LVPTYPE] = ptr[TYPE];

        if (lval[LVSTYPE])
            return (0);

        address(ptr);
        lval[LVSTYPE] = ptr[TYPE];
        return (0);
    } else {
        k = heir14(lval);

        if (match("++")) {
            if (k == 0) {
                needlval();
                return (0);
            }

            incval = step(1, lval);
            inc(-incval);
            return (0);
        } else if (match("--")) {
            if (k == 0) {
                needlval();
                return (0);
            }

            incval = step(-1, lval);
            inc(incval);
            return (0);
        } else
            return (k);
    }
}

heir14(lval)
int lval[];
{
    int k, lval2[LVALUE], hierpos;
    char *ptr, *before, *start;

    k = primary(lval);
    ptr = lval[LVSYM];
    blanks();

    if ((ch == '[') | (ch == '(')) {
        lval[LVSECR] = 1;

        for (;;) {
            hierpos = lval[LVHIER];
            if (match("[")) {
                if (ptr == 0) {
                    error("can't subscript (not an lvalue)");
                    junk();
                    needtoken("]");
                    return (0);
                } else if (ptr[IDENT + hierpos] == POINTER) {
                    rvalue(lval);
                } else if (ptr[IDENT + hierpos] != ARRAY) {
                    error("can't subscript (not ptr or array)");
                    k = 0;
                }

                setstage(&before, &start);
                lval2[LVCONST] = 0;
                plunge2(0, 0, heir1, lval2, lval2);
                needtoken("]");

                if (ptr[IDENT + hierpos] != VARIABLE)
                    lval[LVHIER] = ++hierpos;

                if (lval2[LVCONST]) {   /* if constant expr */
                    clearstage(before, NULL);

                    if (lval2[LVCONVL]) {       /* if index!=0 */
                        int index;

                        if ((ptr[IDENT + hierpos] != VARIABLE)
                            || (ptr[TYPE] == CINT))
                            index = (lval2[LVCONVL] * SINT);
                        else
                            index = lval2[LVCONVL];

                        if (index > 3 || index < -3) {
                            const2(index);
                            add();
                        } else
                            inc(index); /* optim */
                    }
                } else {

                    if ((ptr[IDENT + hierpos] != VARIABLE)
                        || (ptr[TYPE] == CINT))
                        doublereg();

                    add();
                }

                if (ptr[IDENT + hierpos] == VARIABLE)
                    lval[LVPTYPE] = 0;
                lval[LVSTYPE] = ptr[TYPE];
                k = 1;
            } else if (match("(")) {
                if (ptr == 0)
                    callfunction(NULL);
                else if (ptr[IDENT + hierpos] != FUNCTION) {
                    rvalue(lval);
                    callfunction(NULL);
                } else
                    callfunction(ptr);

                k = lval[LVSYM] = lval[LVCONST] = 0;
            } else
                return (k);
        }
    }

    if (ptr == 0)
        return (k);

    if (ptr[IDENT] == FUNCTION) {
        address(ptr);
        return (0);
    }

    return (k);
}

primary(lval)
int lval[];
{
    char *ptr, *findloc(), *findglb(), *addsym();
    int k;
    char ftype[HIER_LEN];

    ftype[0] = FUNCTION;
    ftype[1] = VARIABLE;
    if (match("(")) {
        k = heir1(lval);
        needtoken(")");
        return (k);
    }

    putint(0, lval, LVALUE << LBPW);

    if (symname(ssname, YES)) {
        if (ptr = findloc(ssname)) {
            if (ptr[IDENT] == LABEL) {
                experr();
                return 0;
            }

            if (ptr[IDENT] != FUNCTION)
                getloc(ptr);
            lval[LVSYM] = ptr;
            lval[LVSTYPE] = ptr[TYPE];
            lval[LVHIER] = 0;

            if (ptr[IDENT] == POINTER) {
                lval[LVSTYPE] = CINT;
                lval[LVPTYPE] = ptr[TYPE];
                return 1;
            }

            if (ptr[IDENT] == ARRAY) {
                lval[LVPTYPE] = ptr[TYPE];
                return 0;
            }

            return 1;
        }

        if (ptr = findglb(ssname)) {
            if (ptr[IDENT] != FUNCTION) {
                lval[LVSYM] = ptr;
                lval[LVSTYPE] = 0;
                lval[LVHIER] = 0;

                if (ptr[IDENT] != ARRAY) {
                    if (ptr[IDENT] == POINTER)
                        lval[LVPTYPE] = ptr[TYPE];

                    return (1);
                }

                address(ptr);
                lval[LVSTYPE] = lval[LVPTYPE] = ptr[TYPE];
                return 0;
            } else {
                lval[LVSYM] = ptr;
                lval[LVSTYPE] = 0;
                return 0;
            }
        }


        fprintf(stderr, "* Cd %s\n", ssname);
        ptr = addsym(ssname, ftype, CINT, 0, &glbptr, STATIC);
        lval[LVHIER] = 0;
        lval[LVSYM] = ptr;
        lval[LVSTYPE] = 0;
        return (0);
    }

    if (constant(lval) == 0)
        experr();

    return (0);
}

experr()
{

    error("invalid expression");
    const1(0);
    junk();
}

callfunction(ptr)
char *ptr;
{
    int nargs, i_const, val;
    char *exname();

    nargs = 0;
    blanks();

    if (ptr != NULL)
        if (ptr[IDENT] != FUNCTION)
            ptr = NULL;

    if (ptr == NULL)
        push();

    while (streq(lptr, ")") == 0) {
        if (endst())
            break;

        expression(&i_const, &val);

        if (ptr == NULL)
            swapstk();

        push();
        nargs = nargs + BPW;

        if (match(",") == 0)
            break;
    }

    needtoken(")");

    if (ptr)
        call(exname(ptr + NAME));
    else
        callstk();

    csp = modstk(csp + nargs, YES);
}
