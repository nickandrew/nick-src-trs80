/*      Languages & Processors
**
**      llstest.c  - Low level scan test harness
**
**      Nick Andrew, 8425464    (zeta@amdahl)
**
*/

#include <stdio.h>
#include "lls.h"
#include "lls.c"

main(argc,argv)
int  argc;
char *argv[];
{
    init();
    files(argc,argv);
    getnext();
    getnext();           /* establish 2 chars of read-ahead */
    do {
        lls();
        outtoken();
    } while (code != ENDFILE);

    fclose(f_list);
    fclose(f_in);
    fclose(f_out);
    exit(0);
}
files(argc,argv)
int  argc;
char *argv[];
{
    if (argc!=4) {
        printf("usage: %s source outfile listfile\n",argv[0]);
        exit(0);
    }

    if ((f_in=fopen(argv[1],"r"))==NULL) {
        printf("Can't open %s\n",argv[1]);
        exit(1);
    }

    if ((f_out=fopen(argv[2],"w"))==NULL) {
        printf("Can't open %s\n",argv[2]);
        exit(1);
    }

    if ((f_list=fopen(argv[3],"w"))==NULL) {
        printf("Can't open %s\n",argv[3]);
        exit(1);
    }
}
