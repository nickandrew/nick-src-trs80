/*
**  mail4.c:  Commands for mail
*/

#include <stdio.h>
#include <string.h>

#define EXTERN       extern
#include "mail.h"
#include "seekto.h"

static   int      rangemsg;

static void printmail(int msg);
static void copyto(FILE *f);

void help(void)
{
    std_out("\nMail commands are as follows.\n\n");
    std_out("p [list]         Print message(s) on screen\n");
    std_out("d [list]         Delete message(s)\n");
    std_out("h [list]         Print headers for messages\n");
    std_out("m [username]     Mail to username\n");
    std_out("q or x           Exit mail\n");
    std_out("r [list]         Reply to message(s)\n");
    std_out("s [list]         Save message(s) in TEMPFILE\n");
    std_out("\n\nWhen entering a message type a dot on a line by itself\n");
    std_out("to finish entering the message.\n\n");
}

void print(char *range)
{
    if (setrange(range, '.'))
        return;

    while (rangemsg = getrange()) {
        if (rangemsg > totmail)
            continue;
        if (yourmail[rangemsg] == 0) {
            std_out("\nMessage ");
            z_itoa(rangemsg, string);
            std_out(string);
            std_out(" is deleted.\n");
            continue;
        }
        printmail(rangemsg);
        dot = rangemsg;
    }
}

static void printmail(int msg)
{
    seekto(mf, yourmail[msg]);
    readblk();
    blkpos = 10;
    length = getint(8);
    std_out("From ");
    bprint(stdout);             /* print who from */
    while (bgetc() > 0) ;       /* ignore the To field */
    std_out(",  ");
    bprint(stdout);             /* print date left */
    std_out("\nSubject: ");
    bprint(stdout);
    std_out("\n\n");
    copyto(stdout);
    std_out("\n");
}

static void copyto(FILE *f)
{
    int c;
    while (length--) {
        c = bgetc();
        if (c < 0)
            error("\n\nMessage read error!\n");
        fputc(c, f);
    }
}

void headings(char *range)
{
    int c;
    if (setrange(range, '*'))
        return;

    while (rangemsg = getrange()) {
        if (rangemsg > totmail)
            continue;
        if (yourmail[rangemsg] == 0)
            continue;
        if (rangemsg == dot)
            std_out(">");
        else
            std_out(" ");
        if (rangemsg < 10)
            std_out(" ");
        z_itoa(rangemsg, string);
        std_out(string);
        std_out("  ");
        seekto(mf, yourmail[rangemsg]);
        readblk();
        blkpos = 10;
        for (i = 0; i < 25; ++i)
            string[i] = ' ';
        string[25] = 0;
        for (i = 0; i < 25; ++i) {
            c = bgetc();
            if (c == 0)
                break;
            string[i] = c;
        }
        if (i == 25)
            while (bgetc() > 0) ;

        std_out(string);
        std_out("   ");
        while (bgetc() > 0) ;   /* ignore the To field */
        while (bgetc() > 0) ;   /* ignore the Date field */
        bprint(stdout);         /* print the subject field */
        std_out("\n");
    }
}

/* getsubj() Get or print the subject line
** Args:
**   subj: If nonzero, prompt for the user to enter the subject
**         Otherwise, print the current subject.
*/

void getsubj(int subj)
{
    std_out("Subject: ");
    if (subj)
        fgets(subject, 80, stdin);
    else {
        std_out(subject);
        std_out("\n");
    }
}

void mail(char *to_who, int subj)
{
    if (to_who != NULL) {
        while (*to_who == ' ')
            ++to_who;
        if (!*to_who) {
            std_out("To: ");
            fgets(to, 80, stdin);
        } else
            strcpy(to, to_who);
    }

    getsubj(subj);
    entermsg();
    sendmail();
}

void reply(char *range)
{
    int c;
    char *cp;
    if (setrange(range, '.'))
        return;

    while (rangemsg = getrange()) {
        if (rangemsg > totmail)
            continue;
        if (yourmail[rangemsg] == 0)
            continue;
        seekto(mf, yourmail[rangemsg]);
        readblk();
        blkpos = 10;
        cp = to;
        while ((c = bgetc()) > 0)
            *cp++ = c;
        *cp = 0;
        std_out("To: ");
        std_out(to);
        std_out("\n");
        while (bgetc() > 0) ;   /* ignore the To field */
        while (bgetc() > 0) ;   /* ignore the Date field */
        cp = subject;
        while ((c = bgetc()) > 0)
            *cp++ = c;
        *cp = 0;
        mail(0, 1);
    }
}

void save(char *range)
{
    int hdrs;
    if (setrange(range, '.'))
        return;

    tf = fopene(SAVEFILE, "a");

    std_out("Write headers as well? [y,N]: ");
    fgets(string, 80, stdin);
    hdrs = (*string == 'y' || *string == 'Y');

    while (rangemsg = getrange()) {
        if (rangemsg > totmail)
            continue;
        if (yourmail[rangemsg] == 0)
            continue;
        seekto(mf, yourmail[rangemsg]);
        readblk();
        length = getint(8);
        blkpos = 10;
        if (hdrs) {
            fputs("From: ", tf);
            bprint(tf);
            fputs("\nTo: ", tf);
            bprint(tf);
            fputs("\nDate: ", tf);
            bprint(tf);
            fputs("\nSubject: ", tf);
            bprint(tf);
            fputs("\n\n", tf);
        } else {
            for (i = 0; i < 4; ++i)
                while (bgetc() > 0) ;
        }
        copyto(tf);
    }
    fclose(tf);
}

void delete(char *range)
{
    int back, fwd, thismsg;
    if (setrange(range, '.'))
        return;

    readfree();

    while (rangemsg = getrange()) {
        if (rangemsg > totmail)
            continue;
        thismsg = yourmail[rangemsg];
        if (thismsg == 0)
            continue;
        seekto(mf, thismsg);
        readblk();
        back = getint(2);
        fwd = getint(4);

        seekto(mf, back);
        readblk();
        setint(4, fwd);
        seekto(mf, back);
        writeblk();

        seekto(mf, fwd);
        readblk();
        setint(2, back);
        seekto(mf, fwd);
        writeblk();

        while (thismsg) {
            putfree(thismsg);
            seekto(mf, thismsg);
            readblk();
            thismsg = getint(0);
        }
        std_out("Freed all blocks from one msg.\n");
    }
    writefree();
}
