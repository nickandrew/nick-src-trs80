/*
**      Small-C Compiler Version 2.2 - 84/03/05 16:32:54 - c4.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include <stdlib.h>
#include <stdio.h>

#include        "cc.h"

ifline()
{

    for (;;) {
        inline();

        if (eof)
            return;

        if (match("#ifdef")) {
            ++iflevel;
            if (skiplevel)
                continue;

            blanks();

            if (search(lptr, macn, NAMESIZE + 2, MACNEND, MACNBR, 0) == 0)
                skiplevel = iflevel;

            continue;
        }

        if (match("#ifndef")) {
            ++iflevel;

            if (skiplevel)
                continue;

            blanks();

            if (search(lptr, macn, NAMESIZE + 2, MACNEND, MACNBR, 0))
                skiplevel = iflevel;

            continue;
        }

        if (match("#else")) {
            if (iflevel) {
                if (skiplevel == iflevel)
                    skiplevel = 0;
                else if (skiplevel == 0)
                    skiplevel = iflevel;
            } else
                noiferr();

            continue;
        }

        if (match("#endif")) {
            if (iflevel) {
                if (skiplevel == iflevel)
                    skiplevel = 0;

                --iflevel;
            } else
                noiferr();

            continue;
        }

        if (skiplevel)
            continue;

        if (listfp != NULL) {
            if (listfp == output)
                cout(';', output);

            lout(line, listfp);
        }

        if (ch == 0)
            continue;

        break;
    }
}

keepch(c)
char c;
{

    if (pptr < LINEMAX)
        pline[++pptr] = c;
}

preprocess()
{
    int k;
    char c;

    if (ccode) {
        line = mline;
        ifline();

        if (eof)
            return;
    } else {
        line = pline;
        inline();
        return;
    }

    pptr = -1;

    while (ch) {
        if (white()) {
            keepch(' ');

            while (white())
                gch();
        } else if (ch == '"') {
            keepch(ch);
            gch();

            while ((ch != '"') | ((*(lptr - 1) == 92) & (*(lptr - 2) != 92))) {
                if (ch == 0) {
                    error("no quote");
                    break;
                }

                keepch(gch());
            }

            gch();
            keepch('"');
        } else if (ch == 39) {
            keepch(39);
            gch();

            while ((ch != 39) | ((*(lptr - 1) == 92) & (*(lptr - 2) != 92))) {
                if (ch == 0) {
                    error("no apostrophe");
                    break;
                }

                keepch(gch());
            }

            gch();
            keepch(39);
        } else if ((ch == '/') & (nch == '*')) {
            bump(2);
            while (((ch == '*') & (nch == '/')) == 0) {
                if (ch)
                    bump(1);
                else {
                    ifline();

                    if (eof)
                        break;
                }
            }

            bump(2);
        } else if (an(ch)) {
            k = 0;

            while (an(ch)) {
                if (k < NAMEMAX)
                    msname[k++] = ch;

                gch();
            }

            msname[k] = 0;

            if (search(msname, macn, NAMESIZE + 2, MACNEND, MACNBR, 0)) {
                k = getint(cptr + NAMESIZE, 2);

                while (c = macq[k++])
                    keepch(c);
            } else {
                k = 0;

                while (c = msname[k++])
                    keepch(c);
            }
        } else
            keepch(gch());
    }

    if (pptr >= LINEMAX)
        error("line too long");

    keepch(0);
    line = pline;
    bump(0);
}

noiferr()
{

    error("no matching #if...");
    errflag = 0;
}

addmac()
{
    int k;

    if (symname(msname, NO) == 0) {
        illname();
        kill();
        return;
    }

    k = 0;

    if (search(msname, macn, NAMESIZE + 2, MACNEND, MACNBR, 0) == 0) {
        if (cptr2 = cptr)
            while (*cptr2++ = msname[k++]) ;
        else {
            error("macro name table full");
            return;
        }
    }

    putint(macptr, cptr + NAMESIZE, 2);

    while (white())
        gch();

    while (putmac(gch())) ;

    if (macptr >= MACMAX) {
        error("macro string queue full");
        exit(1);
    }
}

putmac(c)
char c;
{

    macq[macptr] = c;

    if (macptr < MACMAX)
        ++macptr;

    return (c);
}

hash(sname)
char *sname;
{

    xi = 0;

    while (xc = *sname++)
        xi = (xi << 1) + xc;

    return (xi);
}

setstage(before, start)
char **before, **start;
{

    if ((*before = stagenext) == 0)
        stagenext = stage;

    *start = stagenext;
}

clearstage(before, start)
char *before, *start;
{

    *stagenext = 0;

    if (stagenext = before)
        return;

    if (start != NULL) {
        fflush(stderr);
        fputs(start, output);   /* was peephole(start); */
    }
}

outdec(number)
int number;
{
    int k, zs;
    char c;

    zs = 0;
    k = 10000;

    if (number < 0) {
        number = (-number);
        outbyte('-');
    }

    while (k >= 1) {
        c = number / k + '0';

        if ((c != '0') | (k == 1) | (zs)) {
            zs = 1;
            outbyte(c);
        }

        number = number % k;
        k = k / 10;
    }
}

ol(ptr)
char ptr[];
{

    ot(ptr);
    nl();
}

ot(ptr)
char ptr[];
{

    tab();
    outstr(ptr);
}

outstr(ptr)
char *ptr;
{

    while (*ptr != 0)
        outbyte(*ptr++);
}

outbyte(c)
char c;
{

    if (stagenext) {
        if (stagenext == stagelast) {
            error("staging buffer overflow");
            return (0);
        } else
            *stagenext++ = c;
    } else
        cout(c, output);

    return (c);
}

cout(c, fp)
char c;
FILE *fp;
{

    if (fputc(c, fp) == EOF)
        xout();
}

sout(string, fp)
char *string;
FILE *fp;
{

    if (fputs(string, fp) == EOF)
        xout();
}

lout(line, fp)
char *line;
FILE *fp;
{
    sout(line, fp);
    cout('\n', fp);
}

xout()
{

    fputs("output error\n", stderr);
    exit(1);
}

nl()
{

    outbyte('\n');
}

tab()
{

    outbyte('\t');
}

col()
{

    outbyte(':');
}

error(msg)
char msg[];
{

    if (errflag)
        return;

    errflag = 1;
    lout(line, stderr);
    errout(msg, stderr);

    if (listfp != NULL)
        errout(msg, listfp);
}

errout(msg, fp)
char msg[];
FILE *fp;
{
    char *k;

    k = line + 2;

    while (++k <= lptr)
        cout(' ', fp);

    lout("/\\", fp);
    sout("**** ", fp);
    lout(msg, fp);
}

streq(str1, str2)
char str1[], str2[];
{

    xi = 0;

    while (str2[xi]) {
        if ((str1[xi]) != (str2[xi]))
            return (0);

        ++xi;
    }

    return (xi);
}

astreq(str1, str2, len)
char str1[], str2[];
int len;
{
    int k;

    k = 0;

    while (k < len) {
        if ((str1[k]) != (str2[k]))
            break;

        if (str1[k] < ' ')
            break;

        if (str2[k] < ' ')
            break;

        ++k;
    }

    if (an(str1[k]))
        return (0);

    if (an(str2[k]))
        return (0);

    return (k);
}

match(lit)
char *lit;
{
    int k;

    blanks();

    if (k = streq(lptr, lit)) {
        bump(k);
        return (1);
    }

    return (0);
}

amatch(lit, len)
char *lit;
int len;
{
    int k;

    blanks();

    if (k = astreq(lptr, lit, len)) {
        bump(k);

        while (an(ch))
            inbyte();

        return (1);
    }

    return (0);
}

nextop(list)
char *list;
{
    char op[4];

    opindex = 0;
    blanks();

    for (;;) {
        opsize = 0;

        while (*list > ' ')
            op[opsize++] = *list++;

        op[opsize] = 0;

        if (opsize = streq(lptr, op))
            if ((*(lptr + opsize) != '=')
                & (*(lptr + opsize) != *(lptr + opsize - 1)))
                return (1);

        if (*list) {
            ++list;
            ++opindex;
        } else
            return (0);
    }
}

blanks()
{

    for (;;) {
        while (ch) {
            if (white())
                gch();
            else
                return;
        }

        if (line == mline)
            return;

        preprocess();

        if (eof)
            break;
    }
}
