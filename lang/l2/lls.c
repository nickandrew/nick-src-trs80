/*     Languages & Processors
**
**     lls.c  - Low level scan
**
**     Nick Andrew, 8425464   (zeta@amdahl)
**
*/


#include <stdio.h>

#include "lls.h"
#include "errors.h"

char ch,                        /* this character */
 eof,                           /* end of file, source */
 nextch;                        /* the next character */

int line,                       /* source line number */
 number,                        /* the integer number */
 code;                          /* code of the next token */

char thisline[LINESIZE],        /* line buffer */
 string[LINESIZE],              /* literal string array */
*strptr,                        /* pointer to string */
 namestr[LINESIZE],             /* name array */
*nameptr,                       /* pointer to namestr */
*lineptr;                       /* pointer to next char in line buffer */

int linepos;                    /* current position in input line */

extern  FILE *f_in;
extern  FILE *f_out;
extern  FILE *f_list;

static void blankcomm(void);
static void isnumber(void);
static void isname(void);
static int lower(char ch);
static void isstring(void);
static void isoperator(void);
void getnext(void);
void init(void);
void outtoken(void);

void lls(void)
{

    do {
        blankcomm();

        if (eof) {
            code = ENDFILE;
            return;
        }

        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z'))
            isname();
        else if (ch >= '0' && ch <= '9')
            isnumber();
        else if (ch == '"')
            isstring();
        else
            isoperator();
        if (code == INVALID) {
            error("Invalid character in source file");
            getnext();
        }
    } while (code == INVALID);  /* ignore invalid characters */


}

static void blankcomm(void)
{
    char flag = 1;
    if (eof)
        return;
    while (flag--) {
        while (ch == ' ' || ch == '\n')
            getnext();          /* ignore leading blanks */

        if (ch == '(' && nextch == '*') {       /* process a comment */
            flag++;
            getnext();          /* bypass star */
            getnext();
            while (ch != '\n' && !(ch == '*' && nextch == ')'))
                getnext();
            if (ch == '\n')
                getnext();      /* bypass linefeed */
            else {
                getnext();      /* bypass '*' */
                getnext();      /* bypass ')' */
            }
        }
    }
}

static void isnumber(void)
{
    int i, len;
    i = len = 0;

    while (ch >= '0' && ch <= '9' && ++len <= MAXDIGITS) {
        i = i * 10 + (ch - '0');
        getnext();
    }

    while (ch >= '0' && ch <= '9')
        getnext();
    if (len > MAXDIGITS)
        error("Number too long, digits ignored");

    code = NUMBER;
    number = i;
}

static void isname(void)
{
    nameptr = namestr;
    *nameptr = 0;

    ch = lower(ch);
    while ((ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9')) {
        *nameptr++ = ch;
        getnext();
        ch = lower(ch);
    }

    *nameptr = 0;

    code = NAME;
}

static int lower(char ch)
{
    if (ch >= 'A' && ch <= 'Z')
        ch |= 0x20;             /* Ascii */
    return ch;
}

static void isstring(void)
{
    strptr = string;
    *strptr = 0;

    getnext();

    while (ch != '\n' && ch != '"') {
        *strptr++ = ch;
        getnext();
    }

    *strptr = 0;
    if (ch == '"')
        getnext();
    else
        error("String terminated by end of line");

    code = CHARSTR;
}

static void isoperator(void)
{
    switch (ch) {

    case '+':
        code = PLUS;
        break;
    case '-':
        code = MINUS;
        break;
    case '*':
        code = STAR;
        break;
    case '/':
        code = SLASH;
        break;
    case '=':
        code = EQUAL;
        break;
    case ';':
        code = SEMICOLON;
        break;
    case ',':
        code = COMMA;
        break;
    case '(':
        code = LEFT;
        break;
    case ')':
        code = RIGHT;
        break;
    case '<':{
            if (nextch == '>')
                code = NOTEQUAL;
            else if (nextch == '=')
                code = LESSEQUAL;
            else
                code = LESS;
        }
        break;
    case '>':{
            if (nextch == '=')
                code = GREATEREQUAL;
            else
                code = GREATER;
        }
        break;
    case ':':
        if (nextch == '=') {
            code = GETS;
            break;
        }
    default:
        code = INVALID;
    }

    if (code != INVALID)
        getnext();
    if (code == NOTEQUAL || code == LESSEQUAL || code == GREATEREQUAL || code == GETS)
        getnext();
}

void getnext(void)
{
    static int nexttime = 0;
    if (eof) {
        ch = nextch;
        nextch = 0;
        return;
    }

    if (nexttime == 1) {        /* delay list file print if error at end of line */
        nexttime = 0;
        /* output the source line preceded by a pipe and line No */
        fprintf(f_list, "%3d", ++line);
        fputs("|", f_list);
        fputs(thisline, f_list);
    }

    if (*lineptr == 0) {
        lineptr = thisline;
        if (fgets(thisline, STRLENGTH, f_in) == NULL) {
            ch = nextch = 0;
            eof = 1;
        } else {
            nexttime = 1;
        }
    }

    /* update the position within the line of the "current" character */
    ch = nextch;
    nextch = *lineptr++;

    if (ch == '\n' || ch == 0)
        linepos = 0;
    else
        ++linepos;
}

void init(void)
{
    /* do initialisations */
    eof = 0;

    lineptr = thisline;
    *thisline = 0;
    linepos = 0;

    strptr = string;
    *string = 0;
}

void outtoken(void)
{
    if (code == NAME) {
        fputs("name:   ", f_out);
        fputs(namestr, f_out);
    } else if (code == CHARSTR) {
        fputs("string: ", f_out);
        fputs(string, f_out);
    } else if (code == NUMBER) {
        fputs("number: ", f_out);
        fprintf(f_out, "%d", number);
    } else if (code == ENDFILE)
        fputs("Eof!\n", f_out);
    else {
        fputs("token:  ", f_out);
        fprintf(f_out, "%d", code);
    }

    fputs("\n", f_out);
}
