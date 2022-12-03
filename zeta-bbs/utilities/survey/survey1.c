/* Zetasource
**  survey1.c ... Ask the non-member some survey questions
**  Ver 1.0a on 23-Jan-88
*/

#include <stdio.h>
#include <stdlib.h>

#define SURVEY   "quest.zms"
#define RESULT   "answers.zms"

void std_out(char *s);
void init(void);
void signon(void);
int question(void);
int readq(void);

// Somewhere else
extern void reada(char *line);
extern void getuname(char *line);

FILE *in, *out;
char line[80], qname[20];
char prompt[] = "\n>  ";

int main()
{
    init();
    signon();
    while (question()) ;
    fputs("\n", out);
    fclose(out);
    std_out("\n\nThanks for taking the time to answer this survey.\n");
    return 0;
}

void std_out(char *s)
{
    fputs(s, stdout);
}

void init(void)
{
    if ((in = fopen(SURVEY, "r")) == NULL) {
        std_out("Couldn't open survey file, sorry!\n");
        exit(1);
    }

    if ((out = fopen(RESULT, "a")) == NULL) {
        std_out("Couldn't open results file, sorry!\n");
        exit(1);
    }

    fputs("-----\n", out);
    getuname(line);
    fputs(line, out);
    fputs("\n", out);
}

void signon(void)
{
    readq();
    std_out("\n\n");
}

int question(void)
{
    std_out("\n");
    if (readq())
        return 0;
    std_out(prompt);
    reada(line);
    fputs(qname, out);
    fputs(": ", out);
    fputs(line, out);
    fputs("\n", out);
    return 1;
}

int readq(void)
{
    char *cp, *cp2, *cp3;
    *qname = 0;
    while (1) {
        if (fgets(line, 80, in) == NULL)
            return 1;
        cp = cp3 = line;
        if (*line == '\n')
            return 0;;
        while (*cp && *cp != '>')
            ++cp;
        if (*cp) {
            cp2 = qname;
            while (cp3 != cp)
                *(cp2++) = *(cp3++);
            *cp2 = 0;
            ++cp;
        } else
            cp = line;
        std_out(cp);
    }
}
