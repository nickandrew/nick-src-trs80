/*
 *     Huffman encoding program
 *     Usage:  pack [[ - ] filename ... ] filename ...
 *             - option: enable/disable listing of statistics
 * hacked from Unix by Nick Andrew, 15-Jun-86
 * Generic C version, 13-Oct-86
 */


#include  <stdio.h>

#define END     256
#define BLKSIZE 512
#define NAMELEN 32    /* filename length */
#define PACKED 017436 /* <US><RS> - Unlikely value */
#define SUF0    '.'   /* CP/M   */
#define SUF1    'z'

/* character counters */
long    count[END+1];
long    insize;
long    outsize;
long    dictsize;
int     diffbytes;

/* i/o stuff */
char    vflag = 0;       /* verbose output */
int     force = 0;
       /* allow forced packing for consistency in directory */
char    filename [NAMELEN];
char    namein   [NAMELEN];
FILE   *infile;         /* unpacked file */
FILE   *outfile;        /* packed file */
char    inbuff [BLKSIZE];
char    outbuff [BLKSIZE+4];

/* variables associated with the tree */
int     maxlev;
int     levcount [25];
int     lastnode;
int     parent [2*END+1];

/* variables associated with the encoding process */
char    length [END+1];
long    bits [END+1];
long    mask,masklong;
char    longch[4];
long    inc;

/* the heap */
int     n;
struct  heaptype {
        long int count;
        int node;
} heap [END+2];

/* gather character frequency statistics */
/* return 1 if successful, 0 otherwise */
input()
{
    register int i;
    long inlen=0;
    for (i=0; i<END; i++)
        count[i] = 0;
    while ((i = read(fileno(infile), inbuff, BLKSIZE)) > 0)
        while (i > 0) {
            inlen += i;
            count[inbuff[--i]&0377] += 2;
        }

    if (vflag) printf(" (input length = %ld) ",inlen);

        if (i == 0)
                return (1);

        printf (": read error");
        return (0);

}

/* encode the current file */
/* return 1 if successful, 0 otherwise */

output()
{
    int c, i, inleft;
    char *inp;
    register char *outp;
    register int bitsleft,q;
    long temp;

    /* output ``PACKED'' header */
    outbuff[0] = 037;       /* ascii US */
    outbuff[1] = 036;       /* ascii RS */
    /* output the length and the dictionary */
    temp = insize;
    for (i=5; i>=2; i--) {
        outbuff[i] =  (char) (temp & 0377);
        temp >>= 8;
    }
    outp = &outbuff[6];
    *outp++ = maxlev;
    for (i=1; i<maxlev; i++)
        *outp++ = levcount[i];
    *outp++ = levcount[maxlev]-2;
    for (i=1; i<=maxlev; i++)
        for (c=0; c<END; c++)
            if (length[c] == i)
                *outp++ = c;
    dictsize = outp-&outbuff[0];

    /* output the text */
    if (vflag) printf(" (5) ");
    fclose(infile);
    infile=fopen(namein,"r");
    if (infile==NULL) {
        printf("Input file reopen error");
        return 0;
    }
    outsize = 0;
    bitsleft = 8;
    inleft = 0;
    do {
        if (inleft <= 0) {
            inleft = read(fileno(infile), inp = &inbuff[0],
                          BLKSIZE);
            if (inleft < 0) {
                printf (": READ ERROR");
                return (0);
            }
        }
        c = (--inleft < 0) ? END : (*inp++ & 0377);
        mask = bits[c]<<bitsleft;
	masklong=mask;  /* save in scratchpad */
	longch[3]=(masklong & 0377);
	masklong >>= 8;
	longch[2]=(masklong & 0377);
	masklong >>= 8;
	longch[1]=(masklong & 0377);
	masklong >>= 8;
	longch[0]=(masklong & 0377);

        q =0;
        if (bitsleft == 8)
            *outp = longch[q++];
        else
            *outp |= longch[q++];

        bitsleft -= length[c];

        while (bitsleft < 0) {
            *++outp = longch[q++];
            bitsleft += 8;
        }
        if (vflag) printf(" %d ",*outp);
        if (outp >= &outbuff[BLKSIZE]) {
            if (write(fileno(outfile), outbuff, BLKSIZE)
                != BLKSIZE) {
                printf (".z: write error");
                return (0);
            }

        outbuff[0]=outbuff[BLKSIZE];
        outbuff[1]=outbuff[BLKSIZE+1];
        outbuff[2]=outbuff[BLKSIZE+2];
        outbuff[3]=outbuff[BLKSIZE+3];
        outp -= BLKSIZE;
        outsize += BLKSIZE;
        }
    } while (c != END);

    if (bitsleft < 8)
        outp++;
    c = outp-outbuff;
    if (write(fileno(outfile), outbuff, c) != c) {
        printf(".z: Write Error");
        return (0);
    }
    outsize += c;
    return (1);
}

/* heapify(i) makes a heap out of heap[i],...,heap[n] */

heapify (i)
int  i;
{
        register int k;
        int lastparent;
        struct heaptype heapsubi;
        hmove (&heap[i], &heapsubi);
        lastparent = n/2;
        while (i <= lastparent) {
                k = 2*i;
                if (heap[k].count > heap[k+1].count && k < n)
                        k++;
                if (heapsubi.count < heap[k].count)
                        break;
                hmove (&heap[k], &heap[i]);
                i = k;
        }
        hmove (&heapsubi, &heap[i]);
}

/* return 1 after successful packing, 0 otherwise */
int packfile ()
{
        register int c, i, p;
        long bitsout;

        /* gather frequency statistics */
        if (input() == 0) return (0);
        if (vflag) printf(" (1) ");

        /* put occurring chars in heap with their counts */
        diffbytes = -1;
        count[END] = 1;
        insize = n = 0;
        for (i=END; i>=0; i--) {
                parent[i] = 0;
                if (count[i] > 0) {
                        diffbytes++;
                        insize += count[i];
                        heap[++n].count = count[i];
                        heap[n].node = i;
                }
        }
        if (diffbytes == 1) {
                printf (": trivial file");
                return (0);
        }
        insize >>= 1;
        for (i=n/2; i>=1; i--)
                heapify(i);

        /* build Huffman tree */
        lastnode = END;
        while (n > 1) {
                parent[heap[1].node] = ++lastnode;
                inc = heap[1].count;
                hmove (&heap[n], &heap[1]);
                n--;
                heapify(1);
                parent[heap[1].node] = lastnode;
                heap[1].node = lastnode;
                heap[1].count += inc;
                heapify(1);
        }
        parent[lastnode] = 0;

        /* assign lengths to encoding for each character */
        if (vflag) printf(" (2) ");
        bitsout = maxlev = 0;
        for (i=1; i<=24; i++)
                levcount[i] = 0;
        for (i=0; i<=END; i++) {
                c = 0;
                for (p=parent[i]; p!=0; p=parent[p])
                        c++;
                levcount[c]++;
                length[i] = c;
                if (c > maxlev)
                        maxlev = c;
                bitsout += c*(count[i]>>1);
        }
        if (maxlev > 24) {
        /* can't occur unless insize >= 2**24 */
                printf (": Huffman tree has too many levels");
                return(0);
        }

        /* don't bother if no compression results */
        outsize = ((bitsout+7)>>3)+6+maxlev+diffbytes;
        if ((insize+BLKSIZE-1)/BLKSIZE <=
          (outsize+BLKSIZE-1)/BLKSIZE && !force) {
                printf (": no saving");
                return(0);
        }

        /* compute bit patterns for each character */
        if (vflag) printf(" (3) ");
        inc = 1L << 24;
        inc >>= maxlev;
        mask = 0;
        for (i=maxlev; i>0; i--) {
                for (c=0; c<=END; c++)
                        if (length[c] == i) {
                                bits[c] = mask;
                                mask += inc;
   if (vflag) printf("bits[%d] = %ld ",c,bits[c]);
                        }
                mask &= ~inc;
                inc <<= 1;
        }

        if (vflag) printf(" (4) ");
        return (output());
}

main(argc, argv)
int argc; char *argv[];
{
    register int i;
    register char *cp;
    int k, sep;
    int fcount =0; /* count failures */

    for (k=1; k<argc; k++) {
        if (argv[k][0] == '-' && argv[k][1] == '\0') {
            vflag = 1 - vflag;
            continue;
        }
        if (argv[k][0] == '-' && argv[k][1] == 'f') {
            force++;
            continue;
        }
        fcount++;
        /* inc failure count - expect the worst */
        printf ("%s: %s", argv[0], argv[k]);
        sep = -1;  cp = filename;
        for (i=0;
             i < (NAMELEN-3) && (*cp = argv[k][i]);
             i++)
            if (*cp++ == '/') sep = i;
        if (cp[-1]==SUF1 && cp[-2]==SUF0) {
            printf (": already packed\n");
            continue;
        }
        if (i >= (NAMELEN-3) || (i-sep) > 13) {
            printf (": file name too long\n");
            continue;
        }
        if ((infile =fopen(filename,"r"))== 0) {
            printf (": cannot open\n");
            continue;
        }
        strcpy(namein,filename);
        *cp++ = SUF0;  *cp++ = SUF1;  *cp = '\0';

        if ((outfile =fopen(filename, "w"))== 0) {
            printf (".z: cannot create\n");
            goto closein;
        }

        if (packfile()) {
            fcount--;  /* success after all */
            printf (": %.1f%% Compression\n",
                ((double)(-outsize+(insize))
                /(double)insize)*100);
        }
        else
            {       printf (" - file unchanged\n");
            }

    closein: fclose (outfile);
             fclose (infile);
    }
    return (fcount);
}

hmove(a,b)
struct heaptype *a,*b;
{
   (*b).count = (*a).count;
   (*b).node =  (*a).node;
}
