/* Zetasource
**  survey1.c ... Ask the non-member some survey questions
**  Ver 1.0  on 11-Oct-87
*/

#include <stdio.h>
#define SURVEY   "quest.zms"
#define RESULT   "answers.zms"

FILE *in, *out;
char *line[80],*qname[20];
char prompt[] = "\n>  ";

main() {
    init();
    signon();
    while (question());
    std_out("\n\nThanks for taking the time to answer this survey.\n");
    exit(0);
}

std_out(s)
char    *s;
{
    fputs(s,stdout);
}

init() {
    if ((in=fopen(SURVEY,"r"))==NULL) {
        std_out("Couldn't open survey file, sorry!\n");
        exit(1);
    }

    if ((out=fopen(RESULT,"a"))==NULL) {
        std_out("Couldn't open results file, sorry!\n");
        exit(1);
    }

    fputs("\n-----\n",out);
}

signon() {
    readq();
    std_out("\n\n");
}

question() {
    std_out("\n");
    if (readq()) return 0;
    std_out(prompt);
    reada(line);
    fputs(qname,out);
    fputs(": ",out);
    fputs(line,out);
    fputs("\n",out);
    return 1;
}

readq() {
    int  i;
    char *cp,*cp2,*cp3;
    *qname = 0;
    while (1) {
        if (fgets(line,80,in)==NULL) return 1;
        cp = cp3 = line;
        if (*line=='\n') return 0;;
        while (*cp && *cp!='>') ++cp;
        if (*cp) {
            cp2 = qname;
            while (cp3 != cp) *(cp2++) = *(cp3++);
            *cp2 = 0;
            ++cp;
        } else cp = line;
        std_out(cp);
    }
}

