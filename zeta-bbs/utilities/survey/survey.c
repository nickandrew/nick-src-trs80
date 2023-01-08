/* Zetasource
**  survey1.c ... Ask the non-member some survey questions
**  Ver 1.0a on 23-Jan-88
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SURVEY   "quest.zms"
#define RESULT   "answers.zms"

void std_out(char *s);
void init(void);
void signon(void);
int question(void);
int readq(void);

// Somewhere else
#include <string.h>
void getuname(char *line) { strcpy(line, "Big Dummy"); }

FILE *in, *out;
char line[80], qname[20];
char prompt[] = "\n>  ";

int main(void)
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
    fgets(line, sizeof(line), stdin);
    fputs(qname, out);
    fputs(": ", out);
    fputs(line, out);
    return 1;
}

// Read a question from 'in' and display on the screen.
// Questions are one of the forms:
//     Question Text
//     question name>Question Text
// A blank line separates questions
// Question name is copied into qname

int readq(void)
{
    char *cp;
    strcpy(qname, "Q");

    while (1) {
        if (fgets(line, 80, in) == NULL) {
            return 1;
        }
        cp = line;
        if (*line == '\n')
            return 0;
        while (*cp && *cp != '>')
            ++cp;
        if (*cp) {
            // Copy question name, if short enough
            if (cp - line < sizeof(qname)) {
              strncpy(qname, line, cp - line);
              qname[cp - line] = '\0';
            }
            else {
              strcpy(qname, "Long question name");
            }
            ++cp;
        } else {
            cp = line;
        }
        std_out(cp);
    }
}
