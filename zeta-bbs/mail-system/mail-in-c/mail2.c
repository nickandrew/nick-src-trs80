/*
**  mail2.c:  Minor routines for mail
*/

#include <stdio.h>
#include <stdlib.h>

#define EXTERN        extern
#include "mail.h"
#include "seekto.h"

static char    free_block[256];

void std_out(const char *s)
{
    fputs(s, stdout);
}

void error(char *s)
{
    fputs(s, stderr);
    exit(1);
}

int getint(int pos)
{
    return (block[pos] & 0xff) + ((block[pos + 1] & 0xff) << 8);
}

void setint(int place, int i)
{
    block[place] = i & 0xff;
    block[place + 1] = (i >> 8) & 0xff;
}

void getfields(int *f1, int *f2, int *f3)
{
    *f1 = (block[0] + (block[1] << 8));
    *f2 = (block[2] + (block[3] << 8));
    *f3 = (block[4] + (block[5] << 8));
}

void wordcat(char **cpp, int start, int count)
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

void bwrite(char *data, int len)
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

void bflush(void)
{
    if (blkpos == 0)
        blkpos = 256;
    fwrite(block, 1, 256, mf);
}

int bgetc(void)
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

void bprint(FILE *f)
{
    int c;
    while ((c = bgetc()) > 0)
        fputc(c, f);
}

void readblk(void)
{
    if (fread(block, 1, 256, mf) != 256)
        error("Cannot read block!\n");
}

void writeblk(void)
{
    if (fwrite(block, 1, 256, mf) != 256)
        error("Cannot rewrite block!\n");
}

void readfree(void)
{
    seekto(mf, 0);
    if (fread(free_block, 1, 256, mf) != 256)
        error("Cannot read free list\n");
}

void writefree(void)
{
    seekto(mf, 0);
    if (fwrite(free_block, 1, 256, mf) != 256)
        error("Cannot write free list\n");
}

int getfree(void)
{
    int pos, blk, bit;
    blk = 0;

    for (pos = 0; (free_block[pos] == 0xff) && pos < 256; ++pos)
        blk += 8;

    if (pos == 256)
        error("Mailfile full, delete some mail\n");

    bit = 1;
    while (free_block[pos] & bit) {
        ++blk;
        bit <<= 1;
    }

    free_block[pos] |= bit;
    return blk;
}

void putfree(int blk)
{
    int pos;
    pos = blk / 8;
    free_block[pos] &= ~(1 << (blk % 8));
}

FILE *fopene(const char *name, const char *mode)
{
    FILE *ft;
    ft = fopen(name, mode);

    if (ft == NULL) {
        std_out("Cannot open ");
        std_out(name);
        std_out("\n");
        exit(42);
    }

    return ft;
}
