/*
**  flow.c - Show the way an assembler program flows
**           by printing all labels, jumps and calls.
*/

#include <stdio.h>
#include "flow.h"

main(argc,argv)
int  argc;
char *argv[];
{
    if (argc!=2) {
        printf("flow:  Show how an assembly program flows\n");
        printf("Usage: %s filename\n",*argv);
        exit(1);
    }

    asm=fopen(argv[1],"r");
    if (asm==NULL) {
        printf("Couldn't open %s\n",asm);
        exit(2);
    }

    lineno=0;

    while (fgets(string,256,asm)!=NULL) {
        ++lineno;
        num = 0;
        if (*string==0x1a) break;     /* end of asm file */
        if (*string=='\n') continue;  /* bypass blank line */
        if (*string=='*')  continue;  /* bypass directive  */
        if (*string==';')  continue;  /* bypass comment    */

        if (*string!=' ' && *string!='\t') {
            printf("%05d\t",lineno);
            num = 1;
            label();
        }
        opcode();
        if (num) putchar('\n');
    }
}

/*
**  opcode() ... If the opcode part is known then print it
*/

opcode() {
    int  i=0,j;
    char *cp,*cp2,*str,oldchar;

    cp = string;

    if (num) {
        /* bypass the label field */
        while (*cp!='\n' && *cp!=' ' && *cp!='\t')
            ++cp;
    }

    /* find start of word */
    while (*cp==' ' || *cp=='\t') ++cp;

    /* find end of word */
    str = cp;  /* start of word */
    while (*cp!='\n' && *cp!=' ' && *cp!='\t') ++cp;
    oldchar = ((*cp=='\n') ? 0 : *cp);
    cp2 = cp;

    /* remove trailing \n */
    while (*cp && *cp!='\n') ++cp;
    *cp = 0;

    /* null end of word for strcmp */
    *cp2 = 0;

    for (i=0;ops[i]!=NULL;++i) {
        if (!strcmp(str,ops[i])) {
            *cp2 = oldchar;
            if (!num) printf("%05d\t",lineno);
            printf("\t%s",str);
            num=1;
            break;
        }
    }
}

/*
**  label() ... Print the label portion of a line
*/

label() {

    int  i=0;
    char *cp;

    cp=string;
    while (*cp!='\n' && *cp!=' ' && *cp!='\t')
        putchar(*(cp++));
}
