/*
**  msgconv1.c : Convert message files from old to new format
*/

#include <stdio.h>
#include <stdlib.h>

#define O_TXT    "msgtxt.zms:2"
#define O_HDR    "msghdr.zms:2"

#define N_TXT    "msgtxt.new:1"
#define N_HDR    "msghdr.new:1"

#define BUFFER   16384

void openem(void);
int getint(int pos);
void setint(int place, int i);
void bputc(int c);
void bflush(void);
int getfree(void);
void writeblk(void);
void writefree(void);
void setfree(void);
int readhdr(void);
int writehdr(void);
void fixtxt(void);
void copytxt(void);
void closem(void);
int zgetc(void);

FILE *o_txt, *o_hdr;
FILE *n_txt, *n_hdr;

unsigned char block[256], freemap[256], string[256];
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

int main()
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
    return 0;
}

void openem(void)
{
    o_txt = fopen(O_TXT, "r");
    o_hdr = fopen(O_HDR, "r");

    n_txt = fopen(N_TXT, "w");
    n_hdr = fopen(N_HDR, "w");

    if (o_txt == NULL || o_hdr == NULL || n_txt == NULL || n_hdr == NULL)
        exit(2);

    bufst = bufend = buffer;
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

void bputc(int c)
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

void bflush(void)
{
    if (blkpos == 0)
        blkpos = 256;
    writeblk();
}

int getfree(void)
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

void writeblk(void)
{
    if (fwrite(block, 1, 256, n_txt) != 256)
        fputs("New text file write error\n", stderr);
}

void writefree(void)
{
    rewind(n_txt);
    if (fwrite(freemap, 1, 256, n_txt) != 256)
        fputs("New text file freemap write error\n", stderr);
}

void setfree(void)
{
    freemap[0] = 1;             /* the free map itself is allocated */
    for (i = 1; i < 256; ++i)
        freemap[i] = 0;
}

int readhdr(void)
{
    ++msgnum;
    if (fread(&hdr_flag, 1, 16, o_hdr) == 16)
        return 1;
    return 0;
}

int writehdr(void)
{
    if (fwrite(&hdr_flag, 1, 16, n_hdr) == 16)
        return 1;
    fputs("New header write error\n", stderr);
    return 0;
}

void fixtxt(void)
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

void copytxt(void)
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

void closem(void)
{
    fputs("Closing\n", stderr);
    fclose(o_txt);
    fclose(o_hdr);
    fclose(n_txt);
    fclose(n_hdr);
}

int zgetc(void)
{
    if (bufst == bufend) {
        bufend = buffer + fread(buffer, 1, BUFFER, o_txt);
        bufst = buffer;
        if (bufend == buffer)
            return 0;
    }

    return ((*bufst++) & 0xff);
}
