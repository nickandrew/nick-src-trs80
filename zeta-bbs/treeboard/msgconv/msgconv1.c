/*
**  msgconv1.c : Convert message files from old to new format
*/

#include <stdio.h>

#define O_TXT    "msgtxt.zms:2"
#define O_HDR    "msghdr.zms:2"

#define N_TXT    "msgtxt.new:1"
#define N_HDR    "msghdr.new:1"

#define BUFFER   16384

FILE *o_txt, *o_hdr;
FILE *n_txt, *n_hdr;

char block[256], freemap[256], string[256];
char *buffer, *bufst, *bufend;
int i, c, isfull = 0, msgnum = 0;
int blkpos, thisblk, nextblk, newblk;
int thismsg, priormsg, nextmsg;

int x0, x1, x2;

char hdr_flag;
char hdr_lines;
char hdr_rba[3];
char hdr_date[3];
int hdr_sndr;
int hdr_rcvr;
char hdr_topic;
char hdr_time[3];

main()
{
    if ((buffer = malloc(BUFFER)) == NULL) {
        fputs("No memory\n", stderr);
        exit(1);
    }

    openem();

    setfree();
    writefree();

    while (readhdr()) {
        fixtxt();
        if (isfull) {
            fputs("New message file full\n", stderr);
            break;
        }
        writehdr();
        copytxt();
    }
    writefree();
    closem();
}

openem()
{
    o_txt = fopen(O_TXT, "r");
    o_hdr = fopen(O_HDR, "r");

    n_txt = fopen(N_TXT, "w");
    n_hdr = fopen(N_HDR, "w");

    if (o_txt == NULL || o_hdr == NULL || n_txt == NULL || n_hdr == NULL)
        exit(2);

    bufst = bufend = buffer;
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

bputc(c)
int c;
{

    if (blkpos == 0) {
        nextblk = getfree();
        if (nextblk == -1) {
            fputs("Eof within msg, new txt file\n", stderr);
            exit(1);
        }

        setint(0, nextblk);
        writeblk();
/*      seekto(nextblk);      (strictly sequential access) */
/*  implied setint(0,0);   */
        for (i = 0; i < 256; ++i)
            block[i] = 0;
        blkpos = 2;
    }
    block[blkpos] = c;
    blkpos = (blkpos + 1) & 0xff;
}

bflush()
{
    if (blkpos == 0)
        blkpos = 256;
    writeblk();
}

int getfree()
{
    int pos, blk, bit;
    blk = 0;
    for (pos = 0; (freemap[pos] == -1) && pos < 256; ++pos)
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

writeblk()
{
    if (fwrite(block, 1, 256, n_txt) != 256)
        fputs("New text file write error\n", stderr);
}

writefree()
{
    rewind(n_txt);
    if (fwrite(freemap, 1, 256, n_txt) != 256)
        fputs("New text file freemap write error\n", stderr);
}

setfree()
{
    freemap[0] = 1;             /* the free map itself is allocated */
    for (i = 1; i < 256; ++i)
        freemap[i] = 0;
}

int readhdr()
{
    ++msgnum;
    if (fread(&hdr_flag, 1, 16, o_hdr) == 16)
        return 1;
    return 0;
}

writehdr()
{
    if (fwrite(&hdr_flag, 1, 16, n_hdr) == 16)
        return 1;
    fputs("New header write error\n", stderr);
    return 0;
}

fixtxt()
{
    thisblk = getfree();
    if (thisblk == -1) {
        ++isfull;
        return;
    }

    hdr_rba[0] = 0;
    hdr_rba[1] = (thisblk & 0xff);
    hdr_rba[2] = (thisblk >> 8) & 0xff;

    hdr_flag &= ~1;             /* set not killed (unfortunately) */

}

copytxt()
{

    fputs("Msg  ", stderr);
    itoa(msgnum, string);
    fputs(string, stderr);
    fputs(".\n", stderr);

    x0 = zgetc();               /* dummy = FF  */
    x1 = zgetc();               /* dummy = 00 or 02 */
    x2 = zgetc();               /* dummy = 00  */

    if (x0 != 0xff) {
        fputs("Error in old txt, first byte != ff\n", stderr);
        exit(1);
    }

    blkpos = 2;
    setint(0, 0);

    bputc(x0);
    bputc(x1);
    bputc(x2);

    while ((c = zgetc()) > 0)
        bputc(c);
    if (c == 0)
        bputc(0);
    else {
        fputs("Read error in old txt in message\n", stderr);
        exit(1);
    }
    bflush();
}

closem()
{
    fputs("Closing\n", stderr);
    fclose(o_txt);
    fclose(o_hdr);
    fclose(n_txt);
    fclose(n_hdr);
}

int zgetc()
{
    if (bufst == bufend) {
        bufend = buffer + fread(buffer, 1, BUFFER, o_txt);
        bufst = buffer;
        if (bufend == buffer)
            return 0;
    }

    return ((*bufst++) & 0xff);
}
