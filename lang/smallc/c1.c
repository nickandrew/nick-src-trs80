/*
**      Small C Compiler Version 2.2 - 84/03/05 16:32:21 - c1.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

/*
**      open an include file
*/

doinclude()
        {

        blanks();

        if ((input2 = fopen(lptr, "r")) == NULL)        {
                input2 = EOF;
                error("open failure on include file");
        }

        kill();
}

/*
**      test for global declarations
*/

dodeclare(class)
int     class;
        {

        if (amatch("char", 4))  {
                declglb(CCHAR, class);
                ns();
                return (1);
        }
        else if ((amatch("int", 3)) | (class == EXTERNAL))      {
                declglb(CINT, class);
                ns();
                return (1);
        }

        return (0);
}

/*
**      declare a static variable
*/

declglb(type, class)
int     type, class;
        {
        int     k, j;

        for (;;)        {
                if (endst())
                        return;

                if (match("*")) {
                        j = POINTER;
                        k = 0;
                }
                else    {
                        j = VARIABLE;
                        k = 1;
                }

                if (symname(ssname, YES) == 0)
                        illname();

                if (findglb(ssname))
                        multidef(ssname);

                if (match("()"))
                        j = FUNCTION;
                else if (match("["))    {
                        k = needsub();
                        j = ARRAY;
                }

                if (class == EXTERNAL)
                        external(ssname);
                else
                        j = initials(type >> 2, j, k);

                addsym(ssname, j, type, k, &glbptr, class);

                if (match(",") == 0)
                        return;
        }
}

/*
**      declare local variables
*/

declloc(typ)
int     typ;
        {
        int     k, j;

        if (noloc)
                error("not allowed with goto");

        if (declared < 0)
                error("must declare first in block");

        for (;;)        {
                for (;;)        {
                        if (endst())
                                return;

                        if (match("*"))
                                j = POINTER;
                        else
                                j = VARIABLE;

                        if (symname(ssname, YES) == 0)
                                illname();

                        k = BPW;

                        if (match("[")) {
                                k = needsub();

                                if (k)  {
                                        j = ARRAY;

                                        if (typ == CINT)
                                                k = k << LBPW;
                                }
                                else
                                        j = POINTER;
                        }
                        else if (match("()"))
                                j = FUNCTION;
                        else if ((typ == CCHAR) & (j == VARIABLE))
                                k = SBPC;

                        declared = declared + k;
                        addsym(ssname, j, typ, csp - declared, &locptr, AUTOMATIC);
                        break;
                }

                if (match(",") == 0)
                        return;
        }
}

/*
**      initialize global objects
*/

initials(size, ident, dim)
int     size, ident, dim;
        {
        int     savedim;

        litptr = 0;

        if (dim == 0)
                dim = -1;

        savedim = dim;
        dataseg();
        entry();

        if (match("=")) {
                if (match("{")) {
                        while (dim)     {
                                init(size, ident, &dim);

                                if (match(",") == 0)
                                        break;
                        }

                        needtoken("}");
                }
                else
                        init(size, ident, &dim);
        }

        if ((dim == -1) & (dim == savedim))     {
                stowlit(0, size = BPW);
                ident = POINTER;
        }

        dumplits(size);
        dumpzero(size, dim);
        return (ident);
}

/*
**      evaluate one initializer
*/

init(size, ident, dim)
int     size, ident;
int     *dim;
        {
        int     value;

        if (qstr(&value))       {
                if ((ident == VARIABLE) | (size != 1))
                        error("must assign to char pointer or array");

                *dim = *dim - (litptr - value);

                if (ident == POINTER)
                        point();
        }
        else if (constexpr(&value))     {
                if (ident == POINTER)
                        error("cannot assign to pointer");

                stowlit(value, size);
                *dim = *dim - 1;
        }
}

/*
**      get required array size
*/

needsub()       {
        int     val;

        if (match("]"))
                return (0);

        if (constexpr(&val) == 0)
                val = 1;

        if (val < 0)    {
                error("negative size illegal");
                val = -val;
        }

        needtoken("]");
        return (val);
}

/*
**      begin a function
**
**      called from "parse" and tries to make a function
**      out of the following text
**
**      Patched per P. L. Woods (DDJ #52)
*/

newfunc()
        {
        char    *ptr;

        nogo = noloc = lastst = litptr = 0;
        litlab = getlabel();
        locptr = STARTLOC;
        textseg();

        if (monitor)
                lout(line, stderr);

        if (symname(ssname, YES) == 0)  {
                error("illegal function or declaration");
                kill();
                return;
        }

        if (ptr = findglb(ssname))      {
                if (ptr[IDENT] != FUNCTION)
                        multidef(ssname);
                else if (ptr[OFFSET] == FUNCTION)
                        multidef(ssname);
                else
                        ptr[OFFSET] = FUNCTION;
        }
        else
                addsym(ssname, FUNCTION, CINT, FUNCTION, &glbptr, STATIC);

        if (match("(") == 0)
                error("no open paren");

        entry();
        locptr = STARTLOC;
        argstk = 0;

        while (match(")") == 0) {
                if (symname(ssname, YES))       {
                        if (findloc(ssname))
                                multidef(ssname);
                        else    {
                                addsym(ssname, 0, 0, argstk, &locptr, AUTOMATIC);
                                argstk = argstk + BPW;
                        }
                }
                else    {
                        error("illegal argument name");
                        junk();
                }

                blanks();

                if (streq(lptr, ")") == 0)      {
                        if (match(",") == 0)
                                error("no comma");
                }

                if (endst())
                        break;
        }

        csp = 0;
        argtop = argstk;

        while (argstk)  {
                if (amatch("char", 4))  {
                        doargs(CCHAR);
                        ns();
                }
                else if (amatch("int", 3))      {
                        doargs(CINT);
                        ns();
                }
                else    {
                        error("wrong number of arguments");
                        break;
                }
        }

        if (statement() != STRETURN)
                ret();

        if (litptr)     {
                dataseg();
                printlabel(litlab);
                col();
                dumplits(1);
        }
}

/*
**      declare argument types
**
**      called from "newfunc" this routine adds an entry in
**      the local symbol table for each named argument
**
**      Rewritten per P. L. Woods (DDJ #52)
*/

doargs(t)
int     t;
        {
        int     j, legalname;
        char    c, *argptr;

        for (;;)        {
                if (argstk == 0)
                        return;

                if (match("*"))
                        j = POINTER;
                else
                        j = VARIABLE;

                if ((legalname = symname(ssname, YES)) == 0)
                        illname();

                if (match("[")) {
                        while (inbyte() != ']')
                                if (endst())
                                        break;

                        j = POINTER;
                }

                if (legalname)  {
                        if (argptr = findloc(ssname))   {
                                argptr[IDENT] = j;
                                argptr[TYPE] = t;
                                putint(argtop - getint(argptr + OFFSET, OFFSIZE), argptr + OFFSET, OFFSIZE);
                        }
                        else
                                error("not an argument");
                }

                argstk = argstk - BPW;

                if (endst())
                        return;

                if (match(",") == 0)
                        error("no comma");
        }
}
