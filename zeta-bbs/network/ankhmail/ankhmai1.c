/*
**  Ankhmai1.c : Last changed 26-Nov-88
**
**  Process all incoming files, including:
**
**      Arcmail, Fidonews, Nodediffs
**
*/

#include <stdio.h>

/*  Command heads and tails */

char    pktdis[]  = "pktdis -r ";
char    unarc1[]  = "unarc ";
char    unarc2[]  = " -e";
char    copy[]    = "cp ";
char    drive0[]  = ":0 ";
char    drive1[]  = ":1 ";

/*  Mask filenames to trigger processing */

char    arc1mask[] = "A0000004.???";
char    arc2mask[] = "A0000001.???";
char    fnewsmask[] = "FNEWS???.ARC";
char    fidomask[] =  "FIDO???.NWS";
char    ndiffmask[] = "NODEDIFF.???";

/*  Other usefile filenames */

char    infiles[] = "infiles";
char    packets[] = "packets";
char    nabapkt[] = "a000a000.pkt/poof:2";
char    acsfa[] = "a2c9a25b.fa/poof:2";

char    line[80],cmd[80],fn[80],findline[80],findfn[80];
char    proctype;
char    nextfn[80];

int     retcode=0, arccode,fncode,ndcode, is_pkts=0;
int     group_ok = 0;
int     filepos,findpos,oldpos;

FILE    *inf,*fp,*pac;
extern  int     chkwild(), arcnext();

main() {
    pac = 0;
    if ((inf=fopen(infiles,"r+"))==NULL) {
        fputs("Cannot open infiles\n",stderr);
        exit(1);
    }

    for (;;) {
        filepos = ftell(inf);
        if (fgets(line,80,inf)==NULL) break;

        if (*line != ' ')        /* processed */
            continue;

        proctype = procfile();   /* process the file */
        if (fp!=NULL) fclose(fp);      /* clean up */

        if (proctype != 0) {
            /* rewrite the line */
            fseek(inf,filepos,0);
            *line = proctype;
            fputs(line,inf);
        }
    }

    fclose(inf);

    procpac();    /* process file "packets" */

    exit(retcode);
}


/*  procfile : process one file of whatever type */

int     procfile() {

    getfn(line,fn);

    fputs("Requires processing: ",stderr);
    fputs(fn,stderr);
    fputs("\n",stderr);

    if (chkwild(arc1mask,fn)!=0) return procarc();
    if (chkwild(arc2mask,fn)!=0) return procarc();
    if (chkwild(fnewsmask,fn)!=0) return procfnews();
    if (chkwild(ndiffmask,fn)!=0) return procndiff();

    return '?';
}

/*  procarc : Process an arcmail file
 *
 *  Unarc onto drive 1.
 *  If error, do not set status as processed
 *  Write the name of each subfile into file "packets"
 *  Write the arcfile name into file "packets"
 *  Contents of "packets" file gets processed after ankhmail
 */

int     procarc() {

    fixfn(fn);
    if ((fp=fopen(fn,"r"))==NULL) return ' ';

    strcpy(cmd,unarc1);
    strcat(cmd,fn);
    strcat(cmd,unarc2);
    fputs(cmd,stderr);
    fputs("\n",stderr);

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Cannot unarc arcmail named ",stderr);
        fputs(fn,stderr);
        fputs("\n",stderr);
        return ' ';
    }

    for (;;) {

        arccode = arcnext(fp,nextfn);
        if (arccode == -1) return 'P';
        if (arccode == 0) break;

        fputs("Contains packet ",stderr);
        fputs(nextfn,stderr);
        fputs("\n",stderr);

        if (pac == 0) {
            pac = fopen(packets,"a");
            if (pac == NULL) {
                fputs("Cannot open 'packets'\n",stderr);
                return ' ';
            }
        }

        fputs("  ",pac);
        fixfn(nextfn);
        fputs(nextfn,pac);
        fputs("\n",pac);
    }

    /* put arcfile name AFTER packets, so we can remove once
       all packets are processed */

    fputs("A ",pac);
    fputs(fn,pac);
    fputs("\n",pac);

}

/*  process contents of "packets" file.
 *  For each unprocessed filename
 *      try to load into message base
 *      If successful, remove packet & set process flag
 *  If all packets in arcmail "group" OK,
 *      then remove the arcmail file
 */

int     procpac() {

    if (pac != NULL) fclose(pac);
    if ((pac=fopen(packets,"r+"))==NULL) {
        fputs("Cannot reopen packets\n",stderr);
        retcode += 3;
        return;
    }

    group_ok = 1;

    for (;;) {
        filepos = ftell(pac);
        if (fgets(line,80,pac)==NULL) break;
        getfn(line,fn);
        fixfn(fn);

        if (*line == 'A') {
            if (!group_ok) {
                fputs("Cannot remove ",stderr);
                fputs(fn,stderr);
                fputs(", it is not fully processed\n",stderr);
                group_ok = 1;
                continue;
            }
            /* remove! */
            unlink(fn);
            proctype = 'R';
            /* rewrite the line */
            fseek(pac,filepos,0);
            *line = proctype;
            fputs(line,pac);
            continue;
        }
                                                                       if (*line != ' ')        /* processed */
            continue;

        proctype = do_pkt();

        if (proctype != 0) {
            /* rewrite the line */
            fseek(pac,filepos,0);
            *line = proctype;
            fputs(line,pac);
        }
    }
}

int  do_pkt() {

    if ((fp=fopen(fn,"r"))==NULL) {
        group_ok = 0;
        fputs("Cannot open ",stderr);
        fputs(fn,stderr);
        fputs("\n",stderr);
        return ' ';
    }
    fclose(fp);

    fputs("About to disassemble packet '",stderr);
    fputs(fn,stderr);
    fputs("'\n",stderr);

    strcpy(cmd,pktdis);
    strcat(cmd,fn);

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Could not pktdis it.\n",stderr);
        group_ok = 0;
        return ' ';
    }

    /* processed, remove */

    unlink(fn);
    return '-';
}

/*  procfnews : Process the Fnews received weekly */

int     procfnews() {

    fixfn(fn);
    if ((fp=fopen(fn,"r"))==NULL) return ' ';

    /* first : copy the arc file to drive 0 */
    strcpy(cmd,copy);
    strcat(cmd,fn);
    strcat(cmd,drive1);
    strcat(cmd,fn);
    strcat(cmd,drive0);

    fputs(cmd,stderr);
    fputs("\n",stderr);

    fncode = system(cmd);
    if (fncode) {
        retcode += fncode;
        fputs("Could not copy to drive 0\n",stderr);
        return 'P';
    }

    /* Second : Remove the file from drive 1 */
    strcpy(cmd,fn);
    strcat(cmd,drive1);
    unlink(cmd);

    /* Third  : Find the oldest arced fnews and delete it */
    if (find(fnewsmask,'Q')==1) {
        unlink(findfn);
        *findline = '-';
        fseek(inf,findpos,0);
        fputs(findline,inf);
        fseek(inf,oldpos,0);
    }

    /* Fourth : Unarc the fidonews (onto drive 1) */
    strcpy(cmd,unarc1);
    strcat(cmd,fn);
    strcat(cmd,unarc2);

    arccode = system(cmd);
    retcode += arccode;

    if (arccode) {
        fputs("Cannot unarc fidonews\n",stderr);
        return 'P';
    }

    /* Last : enqueue the arced fidonews */
    return 'Q';
}

/*  Procndiff ... Process nodediff by removing it */

int     procndiff() {

    fixfn(fn);
    if ((fp=fopen(fn,"r"))==NULL) return ' ';

    unlink(fn);

    return '-';
}


/*  fixfn : Change first char of name & extension to alpha */

fixfn(cp)
char    *cp;
{

    if (*cp>='0' && *cp<='9') *cp += 0x11;

    while (*cp && *cp!=SEP) ++cp;

    if (*cp==SEP) {
        ++cp;
        if (*cp>='0' && *cp<='9') *cp += 0x11;
    }
}

int     find(mask,status)
char    *mask,status;
{

    oldpos = ftell(inf);
    rewind(inf);

    for (;;) {
        findpos = ftell(inf);
        if (fgets(findline,80,inf)==NULL) break;

        if (*findline != status) continue;

        getfn(findline,findfn);
        if (chkwild(mask,findfn)==1) return 1;
    }

    fseek(inf,oldpos,0);
    return 0;
}

getfn(cp1,cp2)
char    *cp1,*cp2;
{
    cp1 += 2;
    while (*cp1 && *cp1!='\n') *cp2++ = *cp1++;
    *cp2 = 0;
}

