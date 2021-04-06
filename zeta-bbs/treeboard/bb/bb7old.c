/*
**  bb7.c:  Message file handling routines for BB
*/

/* External functions. Not sure if I wrote these. */
extern int seekto(int blk);
extern int writeblk();
extern int readblk();

int getfree();
void putfree(int blk);

int blkpos, thisblk, nextblk, newblk;
int thismsg, priormsg, nextmsg;

char block[256], freemap[256];

int getint(int pos)
{
    return (block[pos] & 0xff) + ((block[pos + 1] & 0xff) << 8);
}

void setint(int place, int i)
{
    block[place] = i & 0xff;
    block[place + 1] = (i >> 8) & 0xff;
}

int bputs(char *string)
{
    int nextblk, i;

    while (*string) {
        if (blkpos == 0) {
            if ((nextblk = getfree()) == -1)
                return -1;
            setint(0, nextblk);
            if (writeblk())
                return -1;
            seekto(nextblk);
            for (i = 0; i < 256; ++i)
                block[i] = 0;
            blkpos = 2;
        }
        block[blkpos] = *(string++);
        blkpos = (blkpos + 1) & 0xff;
    }
    return 0;
}

int bputc(int c)
{
    int nextblk, i;

    if (blkpos == 0) {
        if ((nextblk = getfree()) == -1)
            return -1;
        setint(0, nextblk);
        if (writeblk())
            return -1;
        seekto(nextblk);
        for (i = 0; i < 256; ++i)
            block[i] = 0;
        blkpos = 2;
    }
    block[blkpos] = c;
    blkpos = (blkpos + 1) & 0xff;
    return 0;
}

int bflush()
{
    if (blkpos == 0)
        blkpos = 256;
    return writeblk();
}

int bgetc()
{
    if ((blkpos & 0xff) == 0) {
        thisblk = getint(0);
        if (thisblk == 0)
            return -1;
        seekto(thisblk);
        if (readblk())
            return -1;
        blkpos = 2;
    }
    return block[blkpos++] & 0xff;
}

/* Allocate a free block from the freemap and return its number (0-2047).
**
** Return -1 if all blocks are in use.
**
** A free block is a '0' bit in the freemap.
*/

int getfree()
{
    int pos, blk, bit;
    blk = 0;
    for (pos = 0; (freemap[pos] == 0xff) && pos < 256; ++pos)
        blk += 8;

    if (pos == 256)
        return -1;
    bit = 1;
    while (freemap[pos] & bit) {
        ++blk;
        bit <<= 1;
    }

    freemap[pos] |= bit;
    return blk;
}

/* putfree(): Free a block (0-2047) in the freemap.
*/

void putfree(int blk)
{
    int pos;
    pos = blk / 8;
    freemap[pos] &= ~(1 << (blk % 8));
}
