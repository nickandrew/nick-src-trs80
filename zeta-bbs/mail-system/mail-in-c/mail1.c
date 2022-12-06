/*
**  mail1.c:  Major routines for mail
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define EXTERN
#include "mail.h"
#include "seekto.h"

static void init(void);
static void findmail(void);
static void mailmsg(int totmail);
static void execute(char *cmd);
static void windup(void);

int main(int argc, char *argv[])
{
    init();

    if (argc > 1) {
        if (!strcmp(argv[1], "-C"))
            chkmail = 1;
        else {
            wordcat(argv, 1, 0);
            strcpy(to, argv[1]);
            if ((to_uid = getuid(to)) == -1)
                error("No such user\n");
            getsubj(1);
            entermsg();
            sendmail();
            windup();
        }
    }

    findmail();
    if (chkmail)
        exit(totmail);
    if (!totmail) {
        std_out("No mail for you\n");
        return 0;
    }

    execute("h");
    for (;;) {
        std_out("? ");
        fgets(command, 80, stdin);
        execute(command);
    }
}

static void init(void)
{
    uid = getuid(NULL);
    getuname(username);
    mf = fopene(MAILFILE, "r+");
    readfree();
    for (i = 0; i != MAXMSGS; ++i)
        yourmail[i] = 0;

    chkmail = totmail = 0;
    nextmsg = dot = 1;
}


static void findmail(void)
{
    while (nextmsg) {
        seekto(mf, nextmsg);
        thismsg = nextmsg;
        readblk();
        nextmsg = getint(4);
        if (uid == getint(6)) {
            yourmail[++totmail] = thismsg;
            mailmsg(totmail);
            if (chkmail)
                return;
            if (totmail == MAXMSGS)
                return;
        }
    }
}

static void mailmsg(int totmail)
{
    switch (totmail) {
    case 1:
        std_out("You have mail.\n");
        break;
    case 5:
        std_out("Hullo, here's more.\n");
        break;
    case 10:
        std_out("You sure are popular!\n");
        break;
    case 20:
        std_out("Shouldn't you be deleting some of this?\n");
        break;
    case MAXMSGS:
        std_out("\nRight, thats enough! I'm not going to handle anymore!\n");
        break;
    }
}

static void execute(char *cmd)
{
    char c;
    char *cp;

    cp = cmd;
    while (*cp) {
        if (*cp == '\n')
            *cp = 0;
        ++cp;
    }

    if ((*cmd >= '0' && *cmd <= '9') || *cmd == '.' || *cmd == '$' || *cmd == '*') {
        c = 'p';
    } else {
        c = tolower(*cmd++);
    }

    switch (c) {
    case 'p':
        print(cmd);
        break;
    case 'd':
        delete(cmd);
        break;
    case 'q':
    case 'x':
        windup();
        break;
    case 'h':
        headings(cmd);
        break;
    case 'm':
        mail(cmd, 0);
        break;
    case 'r':
        reply(cmd);
        break;
    case 's':
        save(cmd);
        break;
    case '?':
        help();
        break;
    default:
        std_out("Use '?' for help\n");
    }
}

static void windup(void)
{
    fclose(mf);
    exit(0);
}

void sendmail(void)
{
    fpin = fopene(TEMP, "r");
    fseek(fpin, 0, 2);
    length = ftell(fpin);
    if (length == 0)
        error("Empty message illegal\n");
    fseek(fpin, 0, 0);

    if ((to_uid = getuid(to)) == -1)
        error("No such user\n");

    strcpy(from, username);
    z_asctime(date);

    fputs("Finding last message\n", stderr);
    thismsg = nextmsg = 1;
    while (nextmsg != 0) {
        thismsg = nextmsg;
        /* bypass this message */
        seekto(mf, nextmsg);
        readblk();
        getfields(&nextblk, &priormsg, &nextmsg);
    }

    newblk = getfree();
    if (newblk == 0)
        error("Mail file full - message not saved\n");

    seekto(mf, newblk);

    for (i = 0; i < 256; ++i)
        block[i] = 0;

    setint(0, 0);
    setint(2, thismsg);
    setint(4, 0);
    setint(6, to_uid);
    setint(8, length);

    fputs("Writing names\n", stderr);
    blkpos = 10;
    bwrite(from, strlen(from) + 1);
    bwrite(to, strlen(to) + 1);
    bwrite(date, strlen(date) + 1);
    bwrite(subject, strlen(subject) + 1);

    fputs("Looping output\n", stderr);
    while (length) {
        if ((n = fread(text, 1, 256, fpin)) < 0)
            error("Error reading input\n");
        if (n == 0)
            error("Unexpected end of file\n");
        bwrite(text, n);
        length -= n;
    }

    bflush();

    fputs("Seeking to prior msg\n", stderr);
    seekto(mf, thismsg);
    readblk();
    setint(4, newblk);
    seekto(mf, thismsg);
    fwrite(block, 1, 256, mf);

    writefree();
    fclose(fpin);
}
