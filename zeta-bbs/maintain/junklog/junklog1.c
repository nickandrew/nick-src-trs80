/*
** Junklog: Delete unwanted lines from log/zms
** Ver 1.0  on 08-Jun-87
**/

#include <stdio.h>

#define  LOGIN    "log.zms"
#define  LOGOUT   "log.out"

FILE  *fpin,*fpout;
char  line[80];

main() {

    fpin=fopen(LOGIN,"r");
    fpout=fopen(LOGOUT,"w");

    if (fpin==NULL || fpout==NULL) exit(2);

    while (fgets(line,80,fpin)!=NULL) {
        if (strcmp(line+43,"No carrier found\n") &&
            strcmp(line+43,"Didn't log on\n")) {
            fputs(line,fpout);
        }
    }

    fclose(fpin);
    fclose(fpout);
}

