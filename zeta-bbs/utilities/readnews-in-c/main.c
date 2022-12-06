/* Zetasource
** Readnews program
** main.c
** high level routines
*/

char version[] = "Readnews 1.0  20-Jul-87";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "readnews.h"

/*
** init() ... initialise variables
*/

void init(void)
{
    uid = 2;                    /* sysop, just temporary */
    now[0] = 87;                /* also just temporary */
    now[1] = 07;
    now[2] = 12;
    now[3] = 13;
    now[4] = 01;
    now[5] = 55;
    strcpy(sign1, ".Mail me at Fidonet [712/602]");
    strcpy(sign2, "");
}

/*
** fopene() ... Open a file with error check & exit if fail
*/

FILE *fopene(char *name, char *mode)
{
    FILE *fp;
    fp = fopen(name, mode);
    if (fp != NULL)
        return fp;
    fputs("Couldn't open ", stderr);
    fputs(name, stderr);
    fputs(" (fatal)\n", stderr);
    exit(1);
}

/*
** openfiles() ... Open all files
*/

void openfiles(void)
{
    newstxt0 = fopene("newstxt0.zms", "r+");
    newstxt1 = fopene("newstxt1.zms", "r+");
    newsidx = fopene("newsidx.zms", "r+");
    newsrc = fopene("newsrc", "r+");
    active = fopene("active", "r+");
}

/*
** closefiles() ... Close all files
*/

void closefiles(void)
{
    fclose(newstxt0);
    fclose(newstxt1);
    fclose(newsidx);
    fclose(newsrc);
    fclose(active);
}

/*
** fatal() ... Print a fatal error then exit
*/

void fatal(char *err)
{
    fputs("Fatal: ", stderr);
    fputs(err, stderr);
    exit(2);
}

/*
** prtname() ... Print group name
*/

void prtname(void)
{
    if (grptype == 'L')
        fputs("Local group ", stdout);
    else if (grptype == 'N')
        fputs("USEnet newsgroup ", stdout);
    else if (grptype == 'E')
        fputs("Echomail conference ", stdout);
    else
        fputs("Unknown grouptype ", stdout);

    fputs(grpname, stdout);
    fputs("\n\n", stdout);
}

int main()
{
    init();                     /* initialise variables */
    openfiles();                /* open NEWSRC, ACTIVE, NEWSTXT/ZMS */
    /* and NEWSIDX/ZMS                  */
    readrc();                   /* find / create newsrc record      */

    group = 0;
    while (readgrp()) {         /* while another group exists */
        ++group;
        readcount();            /* last article # or - or N   */
        if (status == '-')
            continue;           /* unsubscribed */
        if (status == 'N')
            break;              /* newsrc don't have it  */
        fseek(newsidx, 0, 0);
        prtname();

        while (count < highgrp) {
            readnews();         /* give option to read article */
            if (reply == 'N' || reply == 'Q')
                break;
        }

        writecount();           /* update last article #       */
        if (reply == 'Q')
            break;
    }

    fputs("No more articles\n", stdout);
    closefiles();
    return 0;
}
