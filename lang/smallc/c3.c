/*
**      Small C Compiler Version 2.2 - 84/03/05 16:32:44 - c3.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

junk()
        {

        if (an(inbyte()))
                while (an(ch))
                        gch();
        else
                while (an(ch) == 0)     {
                        if (ch == 0)
                                break;

                        gch();
                }

        blanks();
}

endst()
        {

        blanks();
        return ((streq(lptr, ";") | (ch == 0)));
}

illname()
        {

        error("illegal symbol");
        junk();
}

multidef(sname)
char    *sname;
        {
	char string[32];
	sprintf(string,"%s already defined",sname);
        error(string);
}

needtoken(str)
char    *str;
        {

        if (match(str) == 0)
                error("missing token");
}

needlval()
        {

        error("must be an lvalue");
}

findglb(sname)
char    *sname;
        {

       if (search(sname,
		STARTGLB,
		SYMMAX,
		ENDGLB,
		NUMGLBS,
		NAME))
                return (cptr);

        return (0);
}

findloc(sname)
char    *sname;
        {

        cptr = locptr - 1;

        while (cptr > STARTLOC) {
                cptr = cptr - *cptr;

                if (astreq(sname, cptr, NAMEMAX))
                        return (cptr - NAME);

                cptr = cptr - NAME - 1;
        }

        return (0);
}

addsym(sname, idarray, type, value, lgptrptr, class)
char    *sname, type;
char	idarray[];
int     value, *lgptrptr, class;
        {

	int	i;
        if (lgptrptr == &glbptr)        {
                if (cptr2 = findglb(sname))
                        return (cptr2);

                if (cptr == 0)  {
                        error("global symbol table overflow");
                        return (0);
                }
        }
        else    {
                if (locptr > (ENDLOC - SYMMAX)) {
                        error("local symbol table overflow");
                        exit(1);
                }

                cptr = *lgptrptr;
        }

	for (i=0;i<HIER_LEN;++i)
		cptr[IDENT+i] = idarray[i];
        cptr[TYPE] = type;
        cptr[CLASS] = class;
        putint(value, cptr + OFFSET, OFFSIZE);
        cptr3 = cptr2 = cptr + NAME;

        while (an(*sname))
                *cptr2++ = *sname++;

        if (lgptrptr == &locptr)        {
                *cptr2 = cptr2 - cptr3;
                *lgptrptr = ++cptr2;
        }

        return (cptr);
}

nextsym(entry)
char    *entry;
        {

        entry = entry + NAME;

        while (*entry++ >= ' ')
                ;

        return (entry);
}

/*
**      get integer i of length len into
**      address addr (low byte first)
*/

getint(addr, len)
char    *addr;
int     len;
        {
        int i;

        i = *(addr + --len);

        while (len--)
                i = (i << 8) | *(addr + len) & 255;

        return (i);
}

/*
**      put integer i of length len into address addr
**      (low byte first)
*/

putint(i, addr, len)
char    *addr;
int     i, len;
        {

        while (len--)   {
                *addr++ = i;
                i = i >> 8;
        }
}

/*
**      test if next input string is legal symbol name
*/

symname(sname, ucase)
char    *sname;
int     ucase;
        {
        int     k;
        char    c;

        blanks();

        if (alpha(ch) == 0)
                return (0);

        k = 0;

        while (an(ch))  {
                        sname[k] = gch();

                if (k < NAMEMAX)
                        ++k;
        }

        sname[k] = 0;
        return (1);
}

/*
**      return next available label number
*/

getlabel()
        {

        return (++nxtlab);
}

/*
**      post a label in the program
*/

postlabel(label)
int     label;
        {

        printlabel(label);
        col();
        nl();
}

/*
**      print the specified number as a label
*/

printlabel(label)
int     label;
        {

        outstr("$?");
        outdec(label);
}

/*
**      test if given character is alphabetic
*/

alpha(c)
char    c;
        {

    return (  ((c >= 'a') & (c <= 'z'))
	    | ((c >= 'A') & (c <= 'Z'))
	    | (c == '_'));
}

/*
**      test if given character is numeric
*/

numeric(c)
char    c;
        {

        return ((c >= '0') & (c <= '9'));
}

/*
**      test if given character is alphanumeric
*/

an(c)
char    c;
        {

        return ((alpha(c)) | (numeric(c)));
}

addwhile(ptr)
int     ptr[];
        {
        int     k;

        ptr[WQSP] = csp;
        ptr[WQLOOP] = getlabel();
        ptr[WQEXIT] = getlabel();

        if (wqptr == WQMAX)     {
                error("too many active loops");
                exit(1);
        }

        k = 0;

        while (k < WQSIZ)
                *wqptr++ = ptr[k++];
}

delwhile()
        {

        if (readwhile())
                wqptr = wqptr - WQSIZ;
}

readwhile()
        {

        if (wqptr == wq)        {
                error("no active loops");
                return (0);
        }
        else
                return (wqptr - WQSIZ);
}

white()
        {

        if (*lptr == ' ')
                return (1);

        if (*lptr == 9)
                return (1);

        return (0);
}

gch()
        {
        int     c;

        if (c = ch)
                bump(1);

        return (c);
}

bump(n)
int     n;
        {

        if (n)
                lptr = lptr + n;
        else
                lptr = line;

        if (ch = nch = *lptr)
                nch = *(lptr + 1);
}

kill()
        {

        *line = 0;
        bump(0);
}

inbyte()
        {

        while (ch == 0) {
                if (eof)
                        return (0);

                preprocess();
        }

        return (gch());
}

inline()
        {
        int     k, unit;

        for (;;)        {
                if (input == EOF)
                        openin();

                if (eof)
                        return;

                if ((unit = input2) == EOF)
                        unit = input;

                if (fgets(line, LINEMAX, unit) == NULL) {
                        fclose(unit);

                        if (input2 != EOF)
                                input2 = EOF;
                        else
                                input = EOF;
                }
                else    {
                        bump(0);
                        return;
                }
        }
}
