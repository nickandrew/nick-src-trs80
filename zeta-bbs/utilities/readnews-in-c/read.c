/* Zetasource
** Readnews program
** read.c
** Routines to read a news item
*/

#include <stdio.h>
#include "readnews.h"

/*
** readnews() ... Give option to read one article
*/

readnews()
{
    reply = ' ';

    if (!readidx()) {           /* read one news item index */
        fputs("No more articles in this newsgroup\n", stdout);
        count = highgrp;
        return;
    }

    if (i_group != group)
        return;
    if (i_article <= count)
        return;

    if (i_article - count > 1) {
        fputs("\nYou missed out on ", stdout);
        itoa(line, i_article - count - 1);
        fputs(line, stdout);
        fputs(" articles in this group\n", stdout);
    }

    count = i_article;

    puthdr();
    askdisp();
    if (reply == ' ')
        readtxt();
}

puthdr()
{
    fputs("Article ", stdout);
    itoa(line, i_article);
    fputs(line, stdout);
    fputs(" dated ", stdout);
    fputs(h_date, stdout);
    fputs("\n", stdout);

    fputs("From: ", stdout);
    fputs(h_from, stdout);
    fputs("\n", stdout);

    fputs("Subject: ", stdout);
    fputs(h_subj, stdout);
    fputs("\n", stdout);
}
