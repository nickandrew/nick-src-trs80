/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:32:21 - c1.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include "cc.h"

/*
**      open an include file
*/

doinclude()
        {

        char filename[80];

        blanks();

        xcp=lptr;           /* handle <name> and "name" */
        if (*xcp=='"' || *xcp=='<') ++xcp;
        for (xi=0;(*xcp!='>' && *xcp!='"');++xi)
           filename[xi]= *xcp++;
        filename[xi]=0;
        if ((input2 = fopen(filename, "r")) == NULL)        {
                input2 = NULL;
                error("open failure on include file");
        }

        kill();
}

/*
**   Do global declarations and new functions
*/

dodeclare(class)
int     class;
        {

        int ftype;
        if (amatch("char", 4))  {
                ftype=declglb(CCHAR, class);
        }
        else if ((amatch("int", 3)) | (class == EXTERNAL))      {
                ftype=declglb(CINT, class);
        } else  {       /* class==STATIC, must be function following */
            ftype=declglb(CINT, class);
        }

        if (ftype==FUNCTION && class==STATIC)
            newfunc();
        else
            ns();

        return;
}

/*
**      declare a static (global) variable or function etc...
*/

int declglb(type, class)
int     type, class;
        {
        int     k;
        char        firsttype;
        int size;

        for (;;)        {

            if (type==CCHAR) size=SCHAR;
            else size=SINT;

            declparse(typearr,&k,YES,YES,class);
            firsttype=typearr[0];
            if (firsttype==POINTER)
                    size=SINT;

                if (class == EXTERNAL)
                        external(ssname);
                else
                        typearr[0] = initials(size,firsttype,k);

                addsym(ssname, typearr, type, k, &glbptr, class);

            if (firsttype==FUNCTION && class==STATIC)
                    return firsttype;
            if (match(",")) continue;
            if (endst()) return firsttype;
        }
}

/*
**      declare local variables
*/

declloc(type)
int     type;
        {
        int     k,class;

        if (noloc)
                error("not allowed with goto");

        if (declared < 0)
                error("must declare first in block");

        for (;;)        {

            declparse(typearr,&k,YES,NO,AUTOMATIC);

            if (typearr[0] == VARIABLE)
                    if (type==CINT) k = SINT;
                    else k = SBPC;
            else
                    if ((typearr[1]!=VARIABLE)
                      ||(typearr[0]==POINTER)
                      ||(type==CINT))
                        k *= SINT; 
                    else k *= SBPC;

                declared = declared + k;

            if (typearr[0]==FUNCTION)
                    class = EXTERNAL;
            else    class = AUTOMATIC;

                addsym(ssname,typearr,type,csp-declared,&locptr,class);
                if (match(",")) continue;
            if (endst()) return;
        }
}

/*
**      initialize global objects
*/

initials(size, ident, dim)
int     size, ident, dim;
        {
        int     savedim;

        if (ident==FUNCTION) {      /* can't initialize a function */
            return ident;
        }

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

        if ((dim == -1) && (dim == savedim))     {
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
**      called from "dodeclare" and tries to make a function
**      out of the following text
**
*/

newfunc()
{

        nogo = noloc = lastst = litptr = 0;
        litlab = getlabel();
        textseg();

        if (monitor)
                lout(line, stderr);

        entry();
        outstr("\tDEBUG\t'");
        outstr(ssname);
        outstr("'\n");

        /* formal parameters already known */

        csp = 0;
        argtop = argstk;

        while (argstk) {
                if (amatch("char", 4)) {
                        doargs(CCHAR);
                        ns();
                }
                else if (amatch("int", 3)) {
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

doargs(type)
int     type;
        {
        int     i, k;
        char    *argptr,*findloc();

        for (;;)        {
                if (argstk == 0) return;

            declparse(typearr, &k, NO, NO,AUTOMATIC);
            /* k (length)  unused. NO,     <- no array bounds needed */
            /*                       , NO  <- don't search globals   */

            /* an array passed as a parameter must be considered a   */
            /* pointer instead. The rules for indexing a ptr differ  */

            if (typearr[0]==ARRAY) typearr[0]=POINTER;

                if (argptr = findloc(ssname))   {
                    for (i=0;i<HIER_LEN;++i)
                        argptr[IDENT+i]=typearr[i];
                        argptr[TYPE] = type;
                        putint(argtop - getint(argptr+OFFSET,OFFSIZE),
                           argptr + OFFSET, OFFSIZE);
                } else {
                        error("not an argument");
            }

                argstk = argstk - BPW;  /* argument chars conv to ints */
            if (match(",")) continue;
                if (endst()) return;
        }
}
