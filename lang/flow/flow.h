/*
**  flow.h - Header for flow.c
*/

FILE  *asm;
char  string[256];
int   lineno, num;

char *ops[] = {

    "CALL",   "JP",     "JR",     "RET",    "IF",
    "ENDIF",  "ELSE",   "IFREF",  "IFDEF",  "IFNDEF",
    "MACRO",  "ENDM",
    0
};

