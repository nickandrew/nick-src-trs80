/*       Languages & Processors
**
**	  main.c  - Main function (top level)
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/

#include <stdio.h>
#include "main.h"

main(argc,argv)
int  argc;
char *argv[];
{
    init();              /* Initialise LLS       */
    files(argc,argv);    /* Open files           */
    l2init();            /* Load L2 syntax table */
    getnext();
    getnext();           /* establish 2 chars of read-ahead */
    la(10,&cclass,&ccode,&clevel,&cerror);

    compile();

    /* flush m/l output if necessary (ie: almost always) */
    if ((location % OUTBUF)!=0)
        outflush();


    /* load in the relevant stuff */

    loadmem();

    /* start executing */

    pc = 1;

    fprintf(stderr,"Execution commences....\n");

    if (debug) la(11,&cclass,&ccode,&clevel,&cerror);
    while (!execute());

    fclose(f_list);
    fclose(f_in);
    fclose(f_out);
    exit(0);
}



files(argc,argv)
int  argc;
char *argv[];
{
    if (argc<5) {
        printf("usage: %s source output listfile asmfile [debugfile]\n",argv[0]);
        exit(0);
    }

    if ((f_in=fopen(argv[1],"r"))==NULL) {
        printf("Can't open source %s\n",argv[1]);
        exit(1);
    }

    if ((f_out=fopen(argv[2],"w+"))==NULL) {
        printf("Can't open object %s\n",argv[2]);
        exit(1);
    }

    if ((f_list=fopen(argv[3],"w"))==NULL) {
        printf("Can't open list %s\n",argv[3]);
        exit(1);
    }
    if ((f_asm=fopen(argv[4],"w"))==NULL) {
        printf("Can't open asm %s\n",argv[4]);
        exit(1);
    }

    if (argc==6)
        if ((f_debug=fopen(argv[5],"w"))==NULL) {
            printf("Can't open debug %s\n",argv[5]);
            exit(1);
        } else debug = 1;

}


