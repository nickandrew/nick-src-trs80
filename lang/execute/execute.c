/*
 *  execute.c: Simple structured language interpreter
 *  (C) 1986, Nick Andrew
 */

#include <stdio.h>
#include <stdlib.h>

#define NONE   0
#define RUN    1
#define WHILET 2
#define WHILEF 3
#define IFTRUE 4
#define IFFALS 5
#define ALFALS 6

char prog[1000];

int pc /*  ,endpc    */ ;
int var[26], num;

void execute(int outer);
int word1(char *str, char *cmd);
int args(char *str);

int main(int argc, char *argv[])
{
    FILE *fp;
    int i;
    int c;
    if (argc != 2)
        return 1;
    fp = fopen(argv[1], "r");
    if (fp == NULL)
        return 2;
    i = 0;
    while ((c = getc(fp)) != EOF)
        prog[i++] = c;
    pc = 0;
    execute(RUN);
    return 0;
}

void execute(int outer)
{
    int i, j, savedpc;
    char c;
    char line[64];

    while (1) {
        i = pc;
        j = 0;
        if (prog[i] == 0)       /* eof */
            return;
        while (prog[i] != '\n')
            line[j++] = prog[i++];
        line[j] = 0;
        pc = i + 1;
        if (j == 0)
            continue;
        printf(":%d> %s\n", pc, line);

        if (word1(line, "while")) {     /* while */
            if (outer == WHILEF || outer == IFFALS || outer == ALFALS)
                execute(WHILEF);
            else {
                i = args(line);
                c = line[i];
                if (c >= 'A' && c <= 'Z') {
                    savedpc = pc;
                    if (var[c - 'A'] != 0) {
                        while (var[c - 'A'] != 0) {
                            pc = savedpc;
                            execute(WHILET);
                        }
                    } else
                        execute(WHILEF);
                    /*            pc=endpc;    */
                }
            }
        }

        if (word1(line, "if")) {        /* if    */
            if (outer == WHILEF || outer == IFFALS || outer == ALFALS)
                execute(ALFALS);
            else {
                i = args(line);
                c = line[i];
                if (c >= 'A' && c <= 'Z')
                    if (var[c - 'A'] != 0) {
                        execute(IFTRUE);
                    } else {
                        execute(IFFALS);
                    }
            }
        }

        if (word1(line, "else")) {      /* else  */
            if (outer == IFTRUE)
                execute(IFFALS);
            if (outer == IFFALS)
                execute(IFTRUE);
            return;
        }

        if (word1(line, "end")) {       /* end   */
            /*       endpc=pc;    */
            return;
            /* ha ha ha ha ha! (in evil sounding voice) */
        }

        if (word1(line, "set")) {       /* set   */
            if (outer != RUN && outer != WHILET && outer != IFTRUE)
                continue;
            i = args(line);
            c = line[i];
            if (c >= 'A' && c <= 'Z')
                if (sscanf(&line[i + 1], "%d", &num) == 1)
                    var[c - 'A'] = num;
        }

        if (word1(line, "unset")) {     /* unset */
            if (outer != RUN && outer != WHILET && outer != IFTRUE)
                continue;
            i = args(line);
            c = line[i];
            if (c >= 'A' && c <= 'Z')
                var[c - 'A'] = 0;
        }

        if (word1(line, "print")) {     /* print */
            if (outer != RUN && outer != WHILET && outer != IFTRUE)
                continue;
            i = args(line);
            printf("%s\n", &line[i]);
        }
    }
}

int word1(char *str, char *cmd)
{
    int i = 0, j = 0;
    while (str[j] == ' ')
        j++;
    while (str[j] != 0 && str[j] != ' ' && str[j] == cmd[i])
        i++, j++;
    if (cmd[i] == 0)
        return 1;
    return 0;
}

int args(char *str)
{
    int i;
    i = 0;
    while (str[i] == ' ')
        i++;
    while (str[i] != 0 && str[i] != ' ')
        i++;
    if (str[i] == ' ')
        i++;
    return i;
}
