/*
**      Small C Compiler Version 2.2 - 84/03/05 16:32:34 - c2.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

/*
**      statement parser
**
**      called whenever syntax requires a statement
**
**      this routine performs that statement
**      and returns a number telling which one
*/

statement()
        {

        if ((ch == 0) & (eof))
                return (-1);
        else if (amatch("char", 4))     {
                declloc(CCHAR);
                ns();
        }
        else if (amatch("int", 3))      {
                declloc(CINT);
                ns();
        }
        else    {
                if (declared >= 0)      {
                        if (ncmp > 1)
                                nogo = declared;

                        csp = modstk(csp - declared, NO);
                        declared = -1;
                }

                if (match("{"))
                        compound();
                else if (amatch("if", 2))       {
                        doif();
                        lastst = STIF;
                }
                else if (amatch("while", 5))    {
                        dowhile();
                        lastst = STWHILE;
                }
                else if (amatch("do", 2))       {
                        dodo();
                        lastst = STDO;
                }
                else if (amatch("for", 3))      {
                        dofor();
                        lastst = STFOR;
                }
                else if (amatch("switch", 6))   {
                        doswitch();
                        lastst = STSWITCH;
                }
                else if (amatch("case", 4))     {
                        docase();
                        lastst = STCASE;
                }
                else if (amatch("default", 7))  {
                        dodefault();
                        lastst = STDEF;
                }
                else if (amatch("goto", 4))     {
                        dogoto();
                        lastst = STGOTO;
                }
                else if (dolabel())
                        ;
                else if (amatch("return", 6))   {
                        doreturn();
                        ns();
                        lastst = STRETURN;
                }
                else if (amatch("break", 5))    {
                        dobreak();
                        ns();
                        lastst = STBREAK;
                }
                else if (amatch("continue", 8)) {
                        docont();
                        ns();
                        lastst = STCONT;
                }
                else if (match(";"))
                        errflag = 0;
                else if (match("#asm")) {
                        doasm();
                        lastst = STASM;
                }
                else    {
                        doexpr();
                        ns();
                        lastst = STEXPR;
                }
        }

        return (lastst);
}

/*
**      semicolon enforcer
*/

ns()
        {

        if (match(";") == 0)
                error("no semicolon");
        else
                errflag = 0;
}

compound()
        {
        int     savcsp;
        char    *savloc;

        savcsp = csp;
        savloc = locptr;
        declared = 0;
        ++ncmp;

        while (match("}") == 0)
                if (eof)        {
                        error("no final }");
                        break;
                }
                else
                        statement();

        --ncmp;
        csp = modstk(savcsp, NO);
        cptr = savloc;

        while (cptr < locptr)   {
                cptr2 = nextsym(cptr);

                if (cptr[IDENT] == LABEL)       {
                        while (cptr < cptr2)
                                *savloc++ = *cptr++;
                }
                else
                        cptr = cptr2;
        }

        locptr = savloc;
        declared = -1;
}

doif()
        {
        int     flab1, flab2;

        flab1 = getlabel();
        test(flab1, YES);
        statement();

        if (amatch("else", 4) == 0)     {
                postlabel(flab1);
                return;
        }

        flab2 = getlabel();

        if ((lastst != STRETURN) & (lastst != STGOTO))
                jump(flab2);

        postlabel(flab1);
        statement();
        postlabel(flab2);
}

doexpr()
        {
        int     const, val;
        char    *before, *start;

        for (;;)        {
                setstage(&before, &start);
                expression(&const, &val);
                clearstage(before, start);

                if (ch != ',')
                        break;

                bump(1);
        }
}

dowhile()
        {
        int     wq[4];

        addwhile(wq);
        postlabel(wq[WQLOOP]);
        test(wq[WQEXIT], YES);
        statement();
        jump(wq[WQLOOP]);
        postlabel(wq[WQEXIT]);
        delwhile();
}

dodo()
        {
        int     wq[4], top;

        addwhile(wq);
        postlabel(top = getlabel());
        statement();
        needtoken("while");
        postlabel(wq[WQLOOP]);
        test(wq[WQEXIT], YES);
        jump(top);
        postlabel(wq[WQEXIT]);
        delwhile();
        ns();
}

dofor()
        {
        int     wq[4], lab1, lab2;

        addwhile(wq);
        lab1 = getlabel();
        lab2 = getlabel();
        needtoken("(");

        if (match(";") == 0)    {
                doexpr();
                ns();
        }

        postlabel(lab1);

        if (match(";") == 0)    {
                test(wq[WQEXIT], NO);
                ns();
        }

        jump(lab2);
        postlabel(wq[WQLOOP]);

        if (match(")") == 0)    {
                doexpr();
                needtoken(")");
        }

        jump(lab1);
        postlabel(lab2);
        statement();
        jump(wq[WQLOOP]);
        postlabel(wq[WQEXIT]);
        delwhile();
}

doswitch()
        {
        int     wq[4], endlab, swact, swdef, *swnex, *swptr;

        swact = swactive;
        swdef = swdefault;
        swnex = swptr = swnext;

        addwhile(wq);
	/* copy WQLOOP value from last while/switch so continue within
	   switch statement works */
	wq[WQLOOP] = *(wqptr - WQSIZ + WQLOOP);
        needtoken("(");
        doexpr();
        needtoken(")");
        swdefault = 0;
        swactive = 1;
        jump(endlab = getlabel());
        statement();
        jump(wq[WQEXIT]);
        postlabel(endlab);
        sw();

        while (swptr < swnext)  {
                defstorage(CINT >> 2);
                printlabel(*swptr++);
                outbyte(',');
                outdec(*swptr++);
                nl();
        }

        defstorage(CINT >> 2);
        outdec(0);
        nl();

        if (swdefault)
                jump(swdefault);

        postlabel(wq[WQEXIT]);
        delwhile();

        swnext = swnex;
        swdefault = swdef;
        swactive = swact;
}

docase()
        {

        if (swactive == 0)
                error("not in switch");

        if (swnext > swend)     {
                error("too many cases");
                return;
        }

        postlabel(*swnext++ = getlabel());
        constexpr(swnext++);
        needtoken(":");
}

dodefault()
        {

        if (swactive)   {
                if (swdefault)
                        error("multiple defaults");
        }
        else
                error("not in switch");

        needtoken(":");
        postlabel(swdefault = getlabel());
}

dogoto()
        {

        if (nogo > 0)
                error("not allowed with block-locals");
        else
                noloc = 1;

        if (symname(ssname, YES))
                jump(addlabel());
        else
                error("bad label");

        ns();
}

dolabel()
        {
        char    *savelptr;

        blanks();
        savelptr = lptr;

        if (symname(ssname, YES))       {
                if (gch() == ':')       {
                        postlabel(addlabel());
                        return (1);
                }
                else
                        bump(savelptr - lptr);
        }

        return (0);
}

addlabel()
        {

	char	labtype[HIER_LEN];
	labtype[0]=LABEL;
        if (cptr = findloc(ssname))     {
                if (cptr[IDENT] != LABEL)
                        error("not a label");
        }
        else
                cptr=addsym(ssname,labtype,LABEL,getlabel(),&locptr,LABEL);

        return (getint(cptr + OFFSET, OFFSIZE));
}

doreturn()
        {

        if (endst() == 0)       {
                doexpr();
                modstk(0, YES);
        }
        else
                modstk(0, NO);

        ret();
}

dobreak()
        {
        int     *ptr;

        if ((ptr = readwhile()) == 0)
                return;

        modstk((ptr[WQSP]), NO);
        jump(ptr[WQEXIT]);
}

docont()
        {
        int     *ptr;

        if ((ptr = readwhile()) == 0)
                return;

        modstk((ptr[WQSP]), NO);
        jump(ptr[WQLOOP]);
}

doasm()
        {

        ccode = 0;

        for (;;)        {
                inline();

                if (match("#endasm"))
                        break;

                if (eof)
                        break;

                lout(line, output);
        }

        kill();
        ccode = 1;
}
