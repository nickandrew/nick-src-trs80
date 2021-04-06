/*
 *      Huffman decompressor
 *      Usage:  pcat filename ...
 *      or      unpack filename ...
 *
 * Hacked from the Unix by Nick Andrew, 15-Jun-86
 * Generic C version of 11-Oct-86
 */


#include <stdio.h>

char *argv0, *argvk;
short errorm;

#define BLKSIZE  512            /* must be 512 ! */
#define NAMELEN 80
#define SUF0    '.'
#define SUF1    'z'
#define US      037
#define RS      036


/* variables associated with i/o */
char filename[NAMELEN + 2];
FILE *infile;
FILE *outfile;
int inleft;
char *inp;
char *outp;
char inbuff[BLKSIZE];
char outbuff[BLKSIZE];

/* the dictionary */
long origsize;
int maxlev;
int intnodes[25];
char *tree[25];
char characters[256];
char *eof;

/* read in the dictionary portion and build decoding
 * structures
 * return 1 if successful, 0 otherwise
 */

getdict()
{
    register int c, i, nchildren;

    /*
     * check two-byte header
     * get size of original file,
     * get number of levels in maxlev,
     * get number of leaves on level i in intnodes[i],
     * set tree[i] to point to leaves for level i
     */
    eof = &characters[0];

    inbuff[6] = 25;
    inleft = read(fileno(infile), &inbuff[0], BLKSIZE);
    if (inleft < 0) {
        eprintf("/z: read error (file empty?)");
        return (0);
    }
    if (inbuff[0] != US) {
        eprintf("/z: Not in packed format");
        return 0;
    }

    if (inbuff[1] == US) {      /* oldstyle packing */
        expand();
        return (1);
    }

    if (inbuff[1] != RS) {
        eprintf("/z: Not in packed format");
        return 0;
    }

    inp = &inbuff[2];
    origsize = 0l;
    for (i = 0; i < 4; i++)
        origsize = origsize * 256 + ((*inp++) & 0377);
    maxlev = *inp++ & 0377;
    if (maxlev > 24) {
        eprintf(".z: not in packed format (>24 levels)");
        return (0);
    }

    /* read in intnodes array */
    for (i = 1; i <= maxlev; i++)
        intnodes[i] = *inp++ & 0377;

    for (i = 1; i <= maxlev; i++) {
        tree[i] = eof;          /* pointer to start of chars */
        for (c = intnodes[i]; c > 0; --c) {

            if (eof >= &characters[255]) {
                eprintf("/z: not in packed format (2)");
                eprintf("bad decoding tree");
                return 0;
            }

            *eof++ = *inp++;
        }
    }

    *eof++ = *inp++;
    intnodes[maxlev] += 2;
    inleft -= inp - &inbuff[0];
    if (inleft < 0) {
        /* this is a kludge ... */
        eprintf("/z: not in packed format! (buffer size)");
        return 0;
    }

    /*
     * convert intnodes[i] to be number of
     * internal nodes possessed by level i
     */

    nchildren = 0;
    for (i = maxlev; i >= 1; --i) {
        c = intnodes[i];
        intnodes[i] = nchildren /= 2;
        nchildren += c;
    }
    return (decode());
}

/* unpack the file */
/* return 1 if successful, 0 otherwise */
decode()
{
    register int bitsleft, c, i;
    int j, lev;
    char *p;

    outp = &outbuff[0];
    lev = 1;
    i = 0;
    while (1) {

        if (inleft <= 0) {
            inleft = read(fileno(infile), inp = &inbuff[0], BLKSIZE);
            if (inleft < 0) {
                eprintf(".z: read error (1)");
                return (0);
            }
        }

        if (--inleft < 0) {
            eprintf(".z: unpacking error (premature eof)");
            return (0);
        }

        c = *inp++;
        bitsleft = 8;
        while (--bitsleft >= 0) {
            i *= 2;
            if (c & 0200)
                i++;
            c <<= 1;
            if ((j = i - intnodes[lev]) >= 0) {
                p = &tree[lev][j];

                if (p == eof) {
                    /* break the loop at logical EOF */
                    c = outp - &outbuff[0];

                    if (write(fileno(outfile), &outbuff[0], c) != c) {
                        eprintf(": Write error");
                        return (0);
                    }

                    origsize -= c;
                    if (origsize != 0) {
                        eprintf(".z: unpacking error (size)");
                        return (0);
                    }
                    return (1);
                }

                *outp++ = *p;
                if (outp == &outbuff[BLKSIZE]) {
                    if (write(fileno(outfile), outp = &outbuff[0], BLKSIZE)
                        != BLKSIZE) {
                        eprintf(": write error (1)");
                        return (0);
                    }
                    origsize -= BLKSIZE;
                }
                lev = 1;
                i = 0;
            } else
                lev++;
        }
    }
}

main(argc, argv)
char *argv[];
{
    register i, k;
    int sep, pcat = 0;
    register char *p1, *cp;
    int fcount = 0;             /* failure count */

    p1 = *argv;
    while (*p1++) ;             /* Point p1 to end of argv[0] string */
    /* find tail of pathname */
    while (--p1 >= *argv)
        if (*p1 == '/')
            break;
    *argv = p1 + 1;
    argv0 = argv[0];
    if (**argv == 'p')
        pcat++;                 /* User entered pcat */
    for (k = 1; k < argc; k++) {
        errorm = 0;
        sep = -1;
        cp = filename;
        argvk = argv[k];
        for (i = 0; i < (NAMELEN - 3) && (*cp = argvk[i]); i++)
            if (*cp++ == '?')
                sep = i;
        if (cp[-1] == SUF1 && cp[-2] == SUF0) {
            argvk[i - 2] = '\0';        /* Remove suffix, try again */
            k--;
            continue;
        }

        fcount++;               /* expect the worst */
        if (i >= (NAMELEN - 3) || (i - sep) > 13) {
            eprintf(": file name too long");
            goto done;
        }

        *cp++ = SUF0;
        *cp++ = SUF1;
        *cp = '\0';
        if ((infile = fopen(filename, "r")) == NULL) {
            eprintf("/z: cannot open");
            goto done;
        }

        if (pcat)
            outfile = stdout;
        else {
            if ((outfile = fopen(argvk, "w")) == NULL) {
                eprintf("Cannot open output file");
                goto done;
            }
        }

        if (getdict()) {        /* unpack */
            fcount--;           /* success after all */
            if (!pcat) {
                eprintf(": unpacked");

            }
        } else
      done:if (errorm)
            fprintf(stderr, "\n");
        fclose(infile);
        if (!pcat)
            fclose(outfile);
    }
    return (fcount);
}

eprintf(s)
char *s;
{
    if (!errorm) {
        errorm = 1;
        fprintf(stderr, "%s: %s", argv0, argvk);
    }
    fprintf(stderr, s);
}

/*
 * This code is for unpacking files that
 * were packed using the previous algorithm.
 */

int Tree[1024];

expand()
{
    register tp, bit;
    short word;
    int keysize, i, *t;

    outp = outbuff;
    inp = &inbuff[2];
    inleft -= 2;
    origsize = ((long) (unsigned) getwd()) * 256 * 256;
    origsize += (unsigned) getwd();
    t = Tree;
    for (keysize = getwd(); keysize--;) {
        if ((i = getch()) == 0377)
            *t++ = getwd();
        else
            *t++ = i & 0377;
    }

    bit = tp = 0;
    for (;;) {
        if (bit <= 0) {
            word = getwd();
            bit = 16;
        }
        tp += Tree[tp + (word < 0)];
        word <<= 1;
        bit--;
        if (Tree[tp] == 0) {
            putch(Tree[tp + 1]);
            tp = 0;
            if ((origsize -= 1) == 0) {
                write(fileno(outfile), outbuff, outp - outbuff);
                return;
            }
        }
    }
}



getch()
{
    if (inleft <= 0) {
        inleft = read(fileno(infile), inp = inbuff, BLKSIZE);
        if (inleft < 0) {
            eprintf(".z: read error");
            exit(1);
        }
    }
    inleft--;
    return (*inp++ & 0377);
}



getwd()
{
    register char c;
    register d;
    c = getch();
    d = getch();
    d <<= 8;
    d |= c & 0377;
    return (d);
}

putch(c)
char c;
{
    register n;

    *outp++ = c;
    if (outp == &outbuff[BLKSIZE]) {
        n = write(fileno(outfile), outp = outbuff, BLKSIZE);
        if (n < BLKSIZE) {
            eprintf(": write error (2)");
            exit(1);
        }
    }
}
