/*
**      Small C Compiler Version 2.2 - 84/03/05 16:30:09 - c0.c
**
**      Copyright 1982 J. E. Hendrix
**
*/

#include        "cc.h"

int     sargc;
char    **sargv;

main(argc, argv)
int     argc, *argv;
        {

        sargc = argc;
        sargv = argv;

        swend = (swnext = swq) + SWTABSZ - SWSIZ;
        stagelast = stage + STAGELIMIT;

        swactive =              /* not in switch */
        stagenext =             /* direct output mode */
        iflevel =               /* #if... nesting level = 0 */
        skiplevel =             /* #if... not encountered */
        macptr =                /* clear the macro pool */
        csp =                   /* stack ptr (relative) */
        errflag =               /* not skipping errors till ";" */
        eof =                   /* not eof yet */
        ncmp =                  /* not in compound statement */
        files =
        filearg =
        quote[1] = 0;

        ccode = 1;              /* enable preprocessing */

        wqptr = wq;             /* clear while queue */
        quote[0] = '"';         /* fake a quote literal */
        input = input2 = EOF;

        ask(argc, argv);
        openin();
        preprocess();
        cptr = STARTGLB - 1;
        while (++cptr < ENDGLB)
                *cptr = 0;

        glbptr = STARTGLB;
        glbflag = 1;
        ctext = 0;

        header();
        setops();
        parse();
        outside();
        trailer();
        fclose(output);
}

/*
**      process all input text
**
**      At this level, only static declarations,
**      defines, includes and function definitions
**      are legal...
*/

parse()
        {

        while (eof == 0)        {
                if (amatch("extern", 6))
                        dodeclare(EXTERNAL);
                else if (dodeclare(STATIC))
                        ;
                else if (match("#asm"))
                        doasm();
                else if (match("#include"))
                        doinclude();
                else if (match("#define"))
                        addmac();
                else
                        newfunc();

                blanks();
        }
}

/*
**      dump the literal pool
*/

dumplits(size)
int     size;
        {
        int     j, k;

        k = 0;

        while (k < litptr)      {
                defstorage(size);
                j = 10;

                while (j--)     {
                        outdec(getint(litq + k, size));
                        k = k + size;

                        if ((j == 0) | (k >= litptr))   {
                                nl();
                                break;
                        }

                        outbyte(',');
                }
        }
}

/*
**      dump zeros for default initial values
*/

dumpzero(size, count)
int     size, count;
        {
        int     j;

        if (count <= 0)
                return;

        ot(".blkb ");
        outdec(count * size);
        nl();
}

/*
**      verify compile ends ouside any function
*/

outside()
        {

        if (ncmp)
                error("no closing bracket");
}

/*
**      get run options
*/

ask(argc, argv)
int     argc;
char    **argv;
        {

        listfp = nxtlab = 0;
        output = stdout;
        optimize = monitor = NO;
        line = mline;

        while (--argc)  {
                argv++;

                if (argv[0][0] != '-')
                        continue;

                switch (argv[0][1])     {

                case 'l':
                case 'L':
                        listfp = stdout;
                        continue;

                case 'm':
                case 'M':
                        monitor = YES;
                        continue;

                case 'o':
                case 'O':
                        optimize = YES;
                        continue;

                default:
                        sout("usage: cc [file] ... [-m] [-l] [-o]\n", stderr);
                        exit(1);
                }
        }
}

/*
**      get next input file
*/

openin()
        {

        input = EOF;

        while (++filearg != sargc)      {
                strcpy(pline, sargv[filearg]);

                if (pline[0] == '-')
                        continue;

                if ((input = fopen(pline, "r")) == NULL)        {
                        sout(pline, stderr);
                        lout(": open error", stderr);
                        exit(1);
                }

                sout(pline, stderr);
                lout(":", stderr);

                files = YES;
                kill();
                return;
        }

        if (files++)
                eof = YES;
        else
                input = stdin;

        kill();
}

setops()
        {

        op2[00] =       op[00] = or;    /* heir5 */
        op2[01] =       op[01] = xor;   /* heir6 */
        op2[02] =       op[02] = and;   /* heir7 */
        op2[03] =       op[03] = eq;    /* heir8 */
        op2[04] =       op[04] = ne;
        op2[05] = ule;  op[05] = le;    /* heir9 */
        op2[06] = uge;  op[06] = ge;
        op2[07] = ult;  op[07] = lt;
        op2[08] = ugt;  op[08] = gt;
        op2[09] =       op[09] = asr;   /* heir10 */
        op2[10] =       op[10] = asl;
        op2[11] =       op[11] = add;   /* heir11 */
        op2[12] =       op[12] = sub;
        op2[13] =       op[13] = mult;  /* heir12 */
        op2[14] =       op[14] = div;
        op2[15] =       op[15] = mod;
}

char    *
fgets(lp, max, fp)
char    *lp;
int     max, fp;
        {
        int     c;

        if (feof(fp))
                return (NULL);

        while (max--)   {
                *lp = c = getc(fp);

                if (c == EOF || c == '\n')      {
                        *lp = 0;
                        return (lp);
                }

                lp++;
        }

        *lp = 0;
        return (lp);
}
