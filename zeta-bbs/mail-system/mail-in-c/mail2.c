/*
**  mail2.c:  Minor routines for mail
*/

#include <stdio.h>

#define EXTERN        extern
#include "mail.h"

std_out(s)
char *s;
{
    fputs(s, stdout);
}

error(s)
char *s;
{
    fputs(s, stderr);
    exit(1);
}

int getint(pos)
int pos;
{
    return (block[pos] & 0xff) + ((block[pos + 1] & 0xff) << 8);
}

setint(place, i)
int place, i;
{
    block[place] = i & 0xff;
    block[place + 1] = (i >> 8) & 0xff;
}

getfields(f1, f2, f3)
int *f1, *f2, *f3;
{
    *f1 = (block[0] + (block[1] << 8));
    *f2 = (block[2] + (block[3] << 8));
    *f3 = (block[4] + (block[5] << 8));
}

wordcat(cpp, start, count)
char **cpp;
int start, count;
{
    char *cp;
    if (count == 0)
        --count;
    while (cpp[start + 1] != NULL && count--) {
        cp = cpp[start];
        while (*cp)
            ++cp;
        *cp = ' ';
        ++start;
    }
}

bwrite(data, len)
char *data;
int len;
{
    int nextblk;

    while (len--) {
        if (blkpos == 0) {
            nextblk = getfree();
            setint(0, nextblk);
            fwrite(block, 1, 256, mf);
            seekto(mf, nextblk);
            for (i = 0; i < 256; ++i)
                block[i] = 0;
            blkpos = 2;
        }

        block[blkpos] = *(data++);
        blkpos = (blkpos + 1) & 0xff;
    }
}

bflush()
{
    if (blkpos == 0)
        blkpos = 256;
    fwrite(block, 1, 256, mf);
}

int bgetc()
{
    if ((blkpos & 0xff) == 0) {
        thisblk = getint(0);
        if (thisblk == 0)
            error("Read past end of message\n");
        seekto(mf, thisblk);
        readblk();
        blkpos = 2;
    }
    return block[blkpos++] & 0xff;
}

bprint(f)
FILE *f;
{
    int c;
    while ((c = bgetc()) > 0)
        fputc(c, f);
}

readblk()
{
    if (fread(block, 1, 256, mf) != 256)
        error("Cannot read block!\n");
}

writeblk()
{
    if (fwrite(block, 1, 256, mf) != 256)
        error("Cannot rewrite block!\n");
}

readfree()
{
    seekto(mf, 0);
    if (fread(free, 1, 256, mf) != 256)
        error("Cannot read free list\n");
}

writefree()
{
    seekto(mf, 0);
    if (fwrite(free, 1, 256, mf) != 256)
        error("Cannot write free list\n");
}

int getfree()
{
    int pos, blk, bit;
    blk = 0;
    for (pos = 0; (free[pos] == -1) && pos < 256; ++pos)
        blk += 8;

    if (pos == 256)
        error("Mailfile full, delete some mail\n");
    bit = 1;
    while (free[pos] & bit) {
        ++blk;
        bit <<= 1;
    }

    free[pos] |= bit;
    return blk;
}

putfree(blk)
int blk;
{
    int pos;
    pos = blk / 8;
    free[pos] &= ~(1 << (blk % 8));
}

FILE *fopene(name, mode)
char *name, *mode;
{
    FILE *ft;
    ft = fopen(name, mode);
    if (ft == NULL) {
        std_out("Cannot open ");
        std_out(name);
        std_out("\n");
        exit(42);
    }
}
