/*
**  Ankhmai1.c : Last changed 23-Jan-88
**
**  Process all incoming files, including:
**
**      Arcmail, Fidonews, Nodediffs, mail to/from ACSgate
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

char    arcmask[] = "A0000004.???";
char    fnewsmask[] = "FNEWS???.ARC";
char    fidomask[] =  "FIDO???.NWS";
char    ndiffmask[] = "NODEDIFF.???";
char    fromacs[] = "NABA*.PKT";
char    toacs[] = "A0000003.???";

/*  Other usefile filenames */

char    infiles[] = "infiles";
char    nabapkt[] = "a000a000.pkt/poof:2";
char    acsfa[] = "a2c9a25b.fa/poof:2";

char    line[80],cmd[80],fn[80],findline[80],findfn[80];
char    proctype;
int     retcode=0,arccode,fncode,ndcode;
char    nextfn[80];
int     filepos,findpos,oldpos;

FILE    *inf,*fp;
extern  int     chkwild(), arcnext();

main() {
    if ((inf=fopen(infiles,"r+"))==NULL) {
        fputs("Cannot open infiles\n",stderr);
        exit(1);
    }

    for (;;) {
        filepos = ftell(inf);
        if (fgets(line,80,inf)==NULL) break;

        if (*line != ' ')        /* not unprocessed ! */
            continue;

        proctype = procfile();

        if (proctype != 0) {
            /* rewrite the line */
            fseek(inf,filepos,0);
            *line = proctype;
            fputs(line,inf);
        }
    }

    fclose(inf);
    exit(retcode);
}


/*  procfile : process one file of whatever type */

int     procfile() {

    getfn(line,fn);

    fputs("Requires processing: ",stderr);
    fputs(fn,stderr);
    fputs("\n",stderr);

    if (chkwild(arcmask,fn)!=0) return procarc();
    if (chkwild(fnewsmask,fn)!=0) return procfnews();
    if (chkwild(ndiffmask,fn)!=0) return procndiff();
    if (chkwild(fromacs,fn)!=0) return procfacs();
    if (chkwild(toacs,fn)!=0) return proctacs();

    return '?';
}

/*  procarc : Process an arcmail file
 *
 *  Unarc onto drive 1.
 *  Process each subfile in turn (removing if successful)
 *  If all ok, remove the arcfile
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
        fputs("Cannot unarc arcmail\n",stderr);
        return 'P';
    }

    for (;;) {

        arccode = arcnext(fp,nextfn);
        if (arccode == -1) return 'P';
        if (arccode == 0) break;

        fputs("About to disassemble packet '",stderr);
        fputs(nextfn,stderr);
        fputs("'\n",stderr);

        fixfn(nextfn);

        strcpy(cmd,pktdis);
        strcat(cmd,nextfn);

        arccode = system(cmd);
        retcode += arccode;

        if (arccode) return 'P';

    }

    /* all processed, remove */

    unlink(fn);
    return '-';
}

/*  procfnews : Process the Fnews received weekly */

int     procfnews() {

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
    unlink(fn);

    return '-';
}

/*  Procfacs ... Process mail from acsgate to naba */

int    procfacs() {

    /* if dest file exists, cannot process */
    if ((fp=fopen(nabapkt,"r"))!=NULL) {
        fputs("Cannot process, outgoing packet already queued\n",stderr);
        fclose(fp);
        return ' ';    /* try later */
    }

    strcpy(cmd,copy);
    strcat(cmd,fn);
    strcat(cmd," ");
    strcat(cmd,nabapkt);

    fputs(cmd,stderr);
    fputs("\n",stderr);

    fncode = system(cmd);
    if (fncode) {
        retcode += fncode;
        fputs("Could not copy to outgoing packet\n",stderr);
        return 'P';
    }

    /* unlink the file */
    /* unlink(fn); */

    return '-';
}

/*  Proctacs ... Process arcmail from naba to acsgate */

int    proctacs() {

    /* open file attach list for append */
    if ((fp=fopen(acsfa,"a"))==NULL) {
        fputs("Cannot add to file attach list\n",stderr);
        return ' ';    /* try later */
    }

    fputs(fn,fp);
    fputs("\n",fp);
    fclose(fp);

    return '*';
}

/*  fixfn : Change first char of name & extension to alpha */

fixfn(cp)
char    *cp;
{

    if (*cp>='0' && *cp<='9') *cp += 0x11;

    while (*cp && *cp!='.') ++cp;

    if (*cp=='.') {
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

