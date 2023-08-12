/* Zetasource
** Readnews program
** newsrc.c
** Routines to handle the NEWSRC file
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "readnews.h"
#include "setpos.h"

char countpos[3];               /* save position for count field */

/*
** readcount() ... Read 4 character count string
*/

void readcount(void)
{
    int i, c;
    savepos(countpos, newsrc);  /* save current position */
    count = i = 0;
    c = getc(newsrc);
    if (c == '-') {
        status = '-';
        return;
    } else if (c == 'N') {
        if (asksubs())
            status = ' ';
        else
            status = '-';
        return;
    } else if (c == '\n') {
        status = 'N';           /* we reached the end of our newsrc */
        return;
    } else {
        while (i < 4 && c >= '0' && c <= '9') {
            count = 10 * count + c - '0';
            c = getc(newsrc);
            ++i;
        }
        if (i != 4 || (c != ' ' && c != '\n'))
            fatal("Error in newsrc, bad count field\n");
    }
}

/*
** writecount() ... update count, "last article read"
*/

void writecount(void)
{
    setpos(countpos, newsrc);
    if (status == '-') {
        fputc('-', newsrc);
        fputc('-', newsrc);
        fputc('-', newsrc);
        fputc('-', newsrc);
        getc(newsrc);           /* bypass CR or ' ' */
    } else {
        fputc('0' + ((count / 1000) % 10), newsrc);
        fputc('0' + ((count / 100) % 10), newsrc);
        fputc('0' + ((count / 10) % 10), newsrc);
        fputc('0' + (count % 10), newsrc);
        getc(newsrc);           /* bypass CR or ' ' */
    }
}

/*
** readrc() ... find and/or create newsrc record for user
*/

void readrc(void)
{
    char *cp;
    char user_name[USER_NAME_LENGTH];

    getuname(user_name);

    while (fgets(line, 80, newsrc) != NULL) {
        if (atoi(line) == uid) {
            fputs("So, you've used readnews before, eh?\n", stdout);
            if (fgets(sign1, 80, newsrc) == NULL || fgets(sign2, 80, newsrc) == NULL)
                fatal("Incomplete newsrc record\n");
            fputs(sign1 + 1, stdout);
            fputs(sign2 + 1, stdout);
            return;
        }
        while ((cp = fgets(line, 80, newsrc)) != NULL)
            if (*line == '\n')
                break;
        if (cp == NULL)
            break;
    }

    fputs("\nWelcome to Readnews, O first time user\n\n", stdout);

    itoa(uid, line);
    strcat(line, " 870701123456 ");
    strcat(line, user_name);

    fputs(line, newsrc);
    fputs(sign1, newsrc);
    fputs(sign2, newsrc);

    fputs("I'm gonna ask you if you want to subscribe to various groups\n", stdout);
    fputs("When in doubt, answer 'Y', you can always unsubscribe later\n\n", stdout);

    savepos(countpos, newsrc);

    group = 0;
    while (readgrp()) {
        int c;

        if (++group != 1) {
            if ((group % 10) == 1)
                fputc('\n', newsrc);
            else
                fputc(' ', newsrc);
        }

        c = 'N';
        if (access == 'P')
            while (1) {
                fputs(grpname, stdout);
                fputs("? ", stdout);
                fgets(line, 80, stdin);
                fputs("\n", stdout);
                c = toupper(*line);
                if (c == 'Y' || c == 'N')
                    break;
            }

        if (c == 'Y')
            status = ' ';
        else
            status = '-';
        writecount();
    }
    fputc('\n', newsrc);

    fputs("\nThats it!\n\n", stdout);
    setpos(countpos, newsrc);
    fseek(active, 0, 0);
}

/*
** asksubs() ... Ask whether to subscribe to new group
*/

int asksubs(void)
{
    int c;
    while (1) {
        fputs(grpname, stdout);
        fputs(" is a new group. Subscribe to it? ", stdout);
        fgets(line, 80, stdin);
        fputs("\n", stdout);
        c = toupper(*line);
        if (c == 'Y' || c == 'N')
            break;
    }
    return (c == 'Y');
}
