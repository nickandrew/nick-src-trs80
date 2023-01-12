/* Zetasource
**  survey.c ... Ask the non-member some survey questions
**  Ver 1.0a on 23-Jan-88
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __SDCC_z80
#include <rom.h>
#include <zeta.h>
#endif

void init(void);
int question(void);
int readq(void);

const char *in_file;
const char *out_file;

FILE *in_fp, *out_fp;
char line[80];    // Question text read from survey file, and response text
char qname[20];   // Question name ("qname>text" in survey file)
char prompt[] = "> ";

void std_out(char *s)
{
    fputs(s, stdout);
}

void init(void)
{
    if ((in_fp = fopen(in_file, "r")) == NULL) {
        std_out("Couldn't open survey file, sorry!\n");
        exit(1);
    }

    if ((out_fp = fopen(out_file, "a")) == NULL) {
        std_out("Couldn't open results file, sorry!\n");
        exit(1);
    }

    fputs("-----\n", out_fp);
    // Zeta function to return the current user name
    getuname(line);
    fputs(line, out_fp);
    fputs("\n", out_fp);
}

// Read a question from 'in_fp' and display on the screen.
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
        if (fgets(line, sizeof(line), in_fp) == NULL) {
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

// Return -1 if question not answered
// (BREAK or EOF seen)

int ask_question(void)
{
#ifdef __SDCC_z80
  // Read up to 78 text characters. Append \n then \0
  int rc = rom_kbline(line, sizeof(line) - 2);
  if (rc < 0) {
    return -1;
  }
  strcat(line, "\n");
  return 0;
#else
  if (fgets(line, sizeof(line), stdin) == NULL) {
    return -1;
  }
  return 0;
#endif
}

// Ask the next question, prompt for an answer; write the answer to the
// output file.

int question(void)
{
    std_out("\n");
    if (readq())
        return 0;
    std_out(prompt);
    int aq = ask_question();
    if (aq < 0) {
      return 0;
    }

    fputs(qname, out_fp);
    fputs(": ", out_fp);
    fputs(line, out_fp);
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 3) {
      in_file = argv[1];
      out_file = argv[2];
    } else {
      in_file = "survey/zms";
      out_file = "answers/zms";
    }

    init();

    // Read and print the introduction
    readq();
    std_out("\n\n");

    while (question()) ;

    fclose(in_fp);

    fputs("\n", out_fp);
    fclose(out_fp);

    std_out("\nThanks for taking the time to answer this survey.\n");
    return 0;
}
