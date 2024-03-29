/* Zetasource
** cpnews program
** Copies an ACSnet file into NEWSTXT
*/

#define  GROUPS  25

char version[] = "Cpnews 1.0  20-Jul-87";

#include <stdio.h>
#include <stdlib.h>

int
 highgrp[GROUPS],               /* highest message in this newsgroup     */
 group,                         /* group number                          */
 groups,                        /* highest group number                  */
 sector,                        /* sector # in newstxt                   */
 expiry[GROUPS];                /* expiry time in days this newsgroup    */

char
 posbuf[3 * GROUPS],            /* fcb position buffer                */
 line[80],                      /* buffer for anything                */
 h_from[80],                    /* "from" field     */
 h_to[80],                      /* "to" */
 h_date[80],                    /* */
 h_subj[80],                    /* */
 access[GROUPS],                /* access Public,Sysop,Restricted     */
 grptype[GROUPS],               /* group is from Local, News, Echo    */
 grpname[80 * GROUPS];          /* text of group name                 */

FILE * newstxt0,                /* where the text is kept (drive 0, 128k)   */
    *newstxt1,                  /* where the text is kept (drive 2, 512k)   */
    *newsidx,                   /* index to all articles                    */
    *fp,                        /* input file pointer                       */
    *active;                    /* list of active groups                    */

void openfiles(void);
FILE *fopene(char *name, char *mode);
void closefiles(void);
void fatal(char *err);
void prtname(void);
int readgrp(void);
char *blanks(char *x);
void cpnews(void);
void readhdr(void);
int hdrcmp(char *string);
char *skiphdr(void);
void hdrcp(char *ptr);
void findgrp(void);
int grpcmp(char *grp, char **cpp);

extern int  allocs(void);
extern void puthead(void);
extern void putidx(void);
extern void putmsg(void);
extern void readfree(void);
extern void savepos(char *buf, FILE *fp);
extern void setpos(char *buf, FILE *fp);
extern void writegrp(int);  // I don't know where this is implemented
extern void writfree(void);

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fputs("Usage: cpnews file ...\n", stderr);
        exit(1);
    }

    openfiles();

    groups = 0;

    /* save all the group information */
    savepos(3 * groups + posbuf, active);
    while (readgrp()) {         /* while another group exists */
        if (++groups == GROUPS)
            fatal("Too many groups defined in ACTIVE\n");
        savepos(3 * groups + posbuf, active);
    }

    /* read free block table */
    readfree();

    /* copy all articles */
    while (--argc) {
        fp = fopene(*(++argv), "r");
        cpnews();
        fclose(fp);
    }

    /* update high article numbers in ACTIVE */
    group = 1;
    while (group <= groups) {
        setpos(group * 3 + posbuf, active);
        writegrp(highgrp[group]);
        ++group;
    }

    /* rewrite free block table */
    writfree();

    fputs("All articles copied\n", stdout);
    closefiles();
    return 0;
}

/*
** openfiles() ... Open all files
*/

void openfiles(void)
{
    newstxt0 = fopene("newstxt0.zms", "r+");
    newstxt1 = fopene("newstxt1.zms", "r+");
    newsidx = fopene("newsidx.zms", "r+");
    active = fopene("active", "r+");
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
    fputs("cpnews: Couldn't open ", stderr);
    fputs(name, stderr);
    fputs(" (fatal)\n", stderr);
    exit(1);
}

/*
** closefiles() ... Close all files
*/

void closefiles(void)
{
    fclose(fp);
    fclose(newstxt0);
    fclose(newstxt1);
    fclose(newsidx);
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
    if (grptype[group] == 'L')
        fputs("Local group ", stdout);
    else if (grptype[group] == 'N')
        fputs("USEnet newsgroup ", stdout);
    else if (grptype[group] == 'E')
        fputs("Echomail conference ", stdout);
    else
        fputs("Unknown grouptype ", stdout);

    fputs(grpname, stdout);
    fputs("\n\n", stdout);
}

/*
** readgrp() ... Read active line, return 0 if eof
*/

int readgrp(void)
{
    char *cp, *cp2;
    if (fgets(line, 80, active) == NULL)
        return 0;
    highgrp[group] = atoi(line);
    cp = blanks(line + 4);
    access[group] = *cp++;
    cp = blanks(cp);
    expiry[group] = atoi(cp);
    while (*cp != ' ')
        ++cp;
    cp = blanks(cp);
    grptype[group] = *cp;
    while (*cp != ' ')
        ++cp;
    cp = blanks(cp);
    cp2 = &grpname[group * 80];
    while (*cp != '\n')
        *cp2++ = *cp++;
    *cp2 = '\0';
    return 1;
}

char *blanks(char *x)
{
    while (*x == ' ')
        ++x;
    return x;
}

/*
** cpnews() ... Copy one file into NEWSTXT0/1
*/

void cpnews(void)
{
    sector = allocs();

    if (sector == 0) {
        fputs("Cannot allocate sector, disk full\n", stderr);
        writfree();
        closefiles();
        exit(1);
    }

    readhdr();                  /* extract relevant fields */

    puthead();                  /* write to newstxt[01]    */

    rewind(fp);
    putmsg();                   /* copy entirety of message */
    putidx();                   /* output index file record */
}

void readhdr(void)
{
    while (1) {
        fgets(line, 80, fp);
        if (*line == '\n')
            return;
        if (!hdrcmp("From: "))
            hdrcp(h_from);
        else if (!hdrcmp("To: "))
            hdrcp(h_to);
        else if (!hdrcmp("Subject: "))
            hdrcp(h_subj);
        else if (!hdrcmp("Date: "))
            hdrcp(h_date);
        else if (!hdrcmp("Newsgroups: "))
            findgrp();
    }
}

int hdrcmp(char *string)
{
    char *cp;

    cp = line;
    while (*string) {
        if (*string != *cp)
            return 1;
        ++string;
        ++cp;
    }
    return 0;
}

char *skiphdr(void)
{
    char *cp;
    cp = line;
    while (*cp != ' ')
        ++cp;
    while (*cp == ' ')
        ++cp;
    return cp;
}

void hdrcp(char *ptr)
{
    char *cp;

    cp = skiphdr();

    while (*cp && *cp != '\n')
        *(ptr++) = *(cp++);

    *ptr = '\0';
}

void findgrp(void)
{
    char *cp;

    group = 1;
    while (group <= groups) {
        cp = skiphdr();
        if (!grpcmp(&grpname[80 * group], &cp))
            return;
        ++group;
    }

    fputs("Not in a group we carry\n", stderr);
    writfree();
    closefiles();
    exit(3);
}

int grpcmp(char *grp, char **cpp)
{
    char *cp, *g;

    cp = *cpp;
    while (*cp && *cp != '\n') {
        g = grp;
        while (1) {
            if (!*g) {
                if (*cp == ',' || *cp == '\n' || *cp == '\0') {
                    // if (*cp == ',')   -- Looks unused
                    //     ++cp;
                    return 0;
                }
            }
            if (*(g++) != *(cp++))
                break;
        }
        while (*cp != ',' && *cp && *cp != '\n')
            ++cp;
    }

    return 1;
}
