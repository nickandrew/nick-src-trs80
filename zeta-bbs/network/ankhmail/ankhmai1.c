/*
**  @(#) ankhmai1.c 14 Aug 90 - Process Zeta's incoming files
**
**  Process all incoming files, including:
**
**      Arcmail,	(unarc & process the bundles later)
**	Bundles,	(process)
**	Fidonews,	(remove oldest and unarc)
**	News files,	(delete oldest from queue then queue)
**	Nodediffs	(remove)
**
**  1.2c 14 Aug 90
**	Add 3rd trigger for arcmail processing ... BBB10004.???
**  1.2b 17 Jun 90
**	Add password to PKT????.NET before trying to open it
**  1.2a 13 Jun 90
**	Change arcmail name from A0000004.??? to A000FFFE.???
**	Add a #define for the password
**  1.2  12 Apr 90
**	Add processing of PKT????.NET files (with a password)
**  1.1  11 Mar 90
**	If fidonews cannot unarc, let it be processed next time
**	Add FIFO processing (deletion) of received News files
**  1.0  17 Jul 89
**	Base version
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "ankhmail.h"

int procfile(void);
int procarc(void);
void procpac(void);
void packdis(void);
int do_pkt(void);
int procfnews(void);
int procndiff(void);
int procnews(void);
int procnet(void);
void fixfn(char *cp);
int find(char *mask, char status);
void getfn(char *cp1, char *cp2);
void msg3(char *s1, char *s2, char *s3);

extern int arcnext(FILE *fp, char *filename);
extern int chkwild(char *wildcard, const char *string);

int main(int argc, char *argv[])
{
    if (argc > 1) {
        if (!strcmp(argv[1], "-p"))
            p_flag = 1;
        if (!strcmp(argv[1], "-P"))
            p_flag = 1;
        if (!strcmp(argv[1], "-d"))
            d_flag = 1;
        if (!strcmp(argv[1], "-D"))
            d_flag = 1;
    }

    pac = NULL;
    if ((inf = fopen(infiles, "r+")) == NULL) {
        fputs("Cannot open infiles\n", stderr);
        exit(1);
    }

    for (;;) {
        filepos = ftell(inf);
        if (fgets(line, 80, inf) == NULL)
            break;

        /* conventions for file status:
           '.' - Processed (arcmail)
           '-' - Processed and removed
           ' ' - Unprocessed
           'Q' - In a queue
           'P' - Partially processed
           'E' - In error (human intervention required)
         */

        if (*line == '.' || *line == '-')
            continue;

        proctype = procfile();  /* process the file */
        if (fp != NULL)
            fclose(fp);         /* clean up */

        if (proctype != 0) {
            /* rewrite the line */
            fseek(inf, filepos, 0);
            *line = proctype;
            fputs(line, inf);
        }
    }

    fclose(inf);

    if (p_flag)
        procpac();              /* process file "packets" */
    if (d_flag)
        packdis();              /* process "packets" using packdis */

    return retcode;
}


/*  procfile : process one file of whatever type */

int procfile(void)
{

    getfn(line, fn);

    if (*line == ' ') {
        msg3("Requires processing: ", fn, "\n");
    }

    if (chkwild(arc1mask, fn) != 0)
        return procarc();
    if (chkwild(arc2mask, fn) != 0)
        return procarc();
    if (chkwild(arc3mask, fn) != 0)
        return procarc();
    if (chkwild(netmask, fn) != 0)
        return procnet();
    if (chkwild(newsmask, fn) != 0)
        return procnews();
    if (chkwild(fnewsmask, fn) != 0)
        return procfnews();
    if (chkwild(ndiffmask, fn) != 0)
        return procndiff();

    return '?';
}

/*  procarc : Process an arcmail file
**
**  Unarc the bundles
**  If disk full, set 'P' for partially processed
**  If error, set 'E' status
**  Write the name of each subfile into file "packets" with an ' '
**  Write the arcfile name into file "packets" with an 'A'
**  Contents of "packets" file gets processed after ankhmail
*/

int procarc(void)
{

    if (*line == 'E') {
        /* there was a previous error. Say so */
        msg3("Arcmail ", fn, " is in error.\n");
        return 0;
    }

    fixfn(fn);
    if ((fp = fopen(fn, "r")) == NULL)
        return ' ';

    strcpy(cmd, unarc1);
    strcat(cmd, fn);
    msg3("", cmd, "\n");

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        msg3("Cannot unarc Arcmail ", fn, ", code = ");
        itoa(arccode, string);  /* hope its ok */
        msg3(string, "\n", "");

        if (arccode == 4)
            return 'P';
        return 'E';
    }

    for (;;) {

        arccode = arcnext(fp, nextfn);
        if (arccode == -1)
            return 'P';
        if (arccode == 0)
            break;

        msg3("Contains bundle ", nextfn, "\n");

        if (pac == NULL) {
            pac = fopen(packets, "a");
            if (pac == NULL) {
                fputs("Cannot open 'packets'\n", stderr);
                return ' ';
            }
        }

        fixfn(nextfn);
        fputs("  ", pac);
        fputs(nextfn, pac);
        fputs("\n", pac);
    }

    /* put arcfile name AFTER bundles, so we can remove once
     ** all bundles are processed
     */

    fputs("A ", pac);
    fputs(fn, pac);
    fputs("\n", pac);

    return '.';
}

/*  process contents of "packets" file.
**  For each unprocessed filename
**      try to load into message base (packdis)
**      If successful, remove bundle & set process flag
**  If all bundles in arcmail "group" OK,
**      then remove the arcmail file
*/

void procpac(void)
{

    if (pac != NULL)
        fclose(pac);

    if ((pac = fopen(packets, "r+")) == NULL) {
        fputs("Cannot reopen 'packets'\n", stderr);
        retcode += 3;
        return;
    }

    group_ok = 1;

    for (;;) {
        filepos = ftell(pac);
        if (fgets(line, 80, pac) == NULL)
            break;
        getfn(line, fn);
        fixfn(fn);

        if (*line == 'A') {
            if (!group_ok) {
                msg3("Cannot remove ", fn, ", it is not fully processed\n");
                group_ok = 1;
                continue;
            }
            /* remove! */
            unlink(fn);
            proctype = 'R';
            /* rewrite the line */
            fseek(pac, filepos, 0);
            *line = proctype;
            fputs(line, pac);
            continue;
        }

        if (*line != ' ')       /* processed */
            continue;

        proctype = do_pkt();

        if (proctype != 0) {
            /* rewrite the line */
            fseek(pac, filepos, 0);
            *line = proctype;
            fputs(line, pac);
        }
    }
}

/* packdis ...
**	Call packdis to process contents of the "packets" file
**	In just the same way that routine procpac above does it
*/

void packdis(void)
{
    if (pac != NULL)
        fclose(pac);
    strcpy(cmd, "packdis -pr");

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Packdis could not complete.\n", stderr);
        fputs("Packdis return code = ", stderr);
        itoa(arccode, string);
        msg3(string, "\n", "");
    }
}

/* do_pkt:
**	Call packdis to process one bundle
*/

int do_pkt(void)
{

    if ((fp = fopen(fn, "r")) == NULL) {
        group_ok = 0;
        msg3("Cannot open ", fn, "\n");
        return ' ';
    }

    fclose(fp);

    msg3("Processing bundle '", fn, "'\n");

    strcpy(cmd, packone);
    strcat(cmd, fn);

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Could not process the bundle.\n", stderr);
        fputs("Packdis return code = ", stderr);
        itoa(arccode, string);
        msg3(string, "\n", "");

        group_ok = 0;
        return ' ';
    }

    /* processed, remove */

    unlink(fn);
    return '-';
}

/*  procfnews : Process the Fnews received weekly */

int procfnews(void)
{

    if (*line != ' ')
        return 0;
    fixfn(fn);
    if ((fp = fopen(fn, "r")) == NULL)
        return ' ';

    /* Unarc the fidonews (onto drive 1) */
    strcpy(cmd, unarc1);
    strcat(cmd, fn);

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Cannot unarc fidonews\n", stderr);
        if (arccode == 4)
            fputs("Disk is full, try again\n", stderr);
        return ' ';
    }

    /* Find the oldest arced fnews and delete it */
    if (find(fnewsmask, 'Q') == 1) {
        unlink(findfn);
        *findline = '-';
        fseek(inf, findpos, 0);
        fputs(findline, inf);
        fseek(inf, oldpos, 0);
    }

    /* Last : enqueue the arced fidonews */
    return 'Q';
}

/*  Procndiff ... Process nodediff by removing it */

int procndiff(void)
{

    if (*line != ' ')
        return 0;
    fixfn(fn);
    if ((fp = fopen(fn, "r")) == NULL)
        return ' ';
    fclose(fp);

    msg3("Unlinking nodediff file ", fn, "\n");
    unlink(fn);

    return '-';
}

/*  Procnews ... Process a NEWSxxxx.NWS file received
**	How?  Delete the oldest one in the queue; add this one to the queue
*/

int procnews(void)
{

    if (*line != ' ')
        return 0;

    if (find(newsmask, 'Q') == 1) {
        unlink(findfn);
        *findline = '-';
        fseek(inf, findpos, 0);
        fputs(findline, inf);
        fseek(inf, oldpos, 0);
    }

    /* Last : enqueue the news file */
    return 'Q';
}

/*  Procnet ... Process a PKT????.NET file
**	Add password, and run packdis on it
*/

int procnet(void)
{
    if (*line != ' ')
        return 0;

    /* add secret password */
    strcat(fn, PASSWORD);

    if ((fp = fopen(fn, "r")) == NULL)
        return ' ';
    fclose(fp);

    msg3("Processing bundle '", fn, "'\n");

    strcpy(cmd, packone);
    strcat(cmd, fn);

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Could not process the bundle.\n", stderr);
        return ' ';
    }

    /* processed, remove */

    unlink(fn);
    return '-';

}

/*  fixfn : Change first char of name & extension to alpha */

void fixfn(char *cp)
{

    if (*cp >= '0' && *cp <= '9')
        *cp += 0x11;

    while (*cp && *cp != SEP)
        ++cp;

    if (*cp == SEP) {
        ++cp;
        if (*cp >= '0' && *cp <= '9')
            *cp += 0x11;
    }
}

/* find the first filename & status match in INFILES */

int find(char *mask, char status)
{

    oldpos = ftell(inf);
    rewind(inf);

    for (;;) {
        findpos = ftell(inf);
        if (fgets(findline, 80, inf) == NULL)
            break;

        if (*findline != status)
            continue;

        getfn(findline, findfn);
        if (chkwild(mask, findfn) == 1)
            return 1;
    }

    fseek(inf, oldpos, 0);
    return 0;
}

/* get the filename part from a \n-terminated string */

void getfn(char *cp1, char *cp2)
{
    cp1 += 2;
    while (*cp1 && *cp1 != '\n')
        *cp2++ = *cp1++;
    *cp2 = 0;
}

/* print 3 strings on stderr */

void msg3(char *s1, char *s2, char *s3)
{
    fputs(s1, stderr);
    fputs(s2, stderr);
    fputs(s3, stderr);
}

/* end of ankhmai1.c */
