/*       Languages & Processors
**
**       la.c   - Lexical analyser
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/

#include <stdio.h>
#include <string.h>

#include "errors.h"
#include "la.h"
#include "lls.h"

/*      Structure of descriptor table.
**      Does not contain "name length" field since
**          strings are null terminated in C.
*/

struct desctb {
    struct desctb *synptr;
    int laclass;
    int lacode;
    int lalevel;
    char *nameptr;
};

/*      Hash table.
**      Contains pointers to the descriptor table.
*/

struct desctb *hashtabl[MAXHASH];

/*      Descriptor table. */

struct desctb desctabl[MAXDESC];
struct desctb *nextdesc;

/*      Name table. */

char nametabl[MAXNAME * SYMMAX];
char *nextname;

/*      String table. */

char strtabl[MAXSTR];
char *nextstr;

/*      Number table. */

struct numbtb numbtabl[MAXNUMB];

struct numbtb *nextnumb;

/*  Static tables: classtbl[] contains the class of arithmetic
**                 comparison and other tokens.
**  Starting: blank, plus, minus, star, slash, etc...
**  See: token codes in lls.h
*/

int classtbl[20] = {
    -1, /* INVALID/BLANK */
    82, /* PLUS */
    82, /* MINUS */
    84, /* STAR */
    84, /* SLASH */
    75, /* EQUAL */
    75, /* NOTEQUAL */
    75, /* LESS */
    75, /* LESSEQUAL */
    75, /* GREATER */
    75, /* GREATEREQUAL */
    43, /* GETS (:= ??) */
    11, /* SEMICOLON */
    32, /* LEFT */
    73, /* RIGHT */
    31, /* COMMA */
    -1, /* NAME */
    50, /* CHARSTR */
    89, /* NUMBER */
    -1  /* ENDFILE */
};

/*      Other globals */
int errcode,                    /* Error code returned by LA. 0 if ok */
 currlevel,                     /* Current compiler level             */
 funcode,                       /* Code of last function              */
 forcode,                       /* Code of last formal parameter      */
 loccode,                       /* Code of last local variable        */
 loccount,                      /* Count of number of local variables */
 glbcode;                       /* Code of last global variable       */

static void newsymb(char *nstr, int class, int code, int level);
static int hash(char *string);
static void reason10(void);
static void reason11(void);
static void reason1(int *pclass, int *pcode, int *plevel);
static void reason2(int *pclass, int *pcode, int *plevel);
static void reason3(int *pclass, int *pcode, int *plevel);
static void reason4(int *pclass, int *pcode, int *plevel);
static void reason5(int *pclass, int *pcode, int *plevel);
static void reason6(int *pclass, int *pcode);
static void reason7(int *pclass, int *pcode);
static void reason8(void);
static void reason9(int *pclass);
static void laerror(int level);
static void delsymb(struct desctb *descptr, int hashcode);
static struct desctb *findsym(char *name);
static int addstr(char *string);
static int addnumb(int number);


/* la ... entry to the lexical analyser
**
** reason: reason for calling lls
** pclass: pointer to returned symbol class
** pcode: pointer to returned code
** plevel: pointer to returned level
** perror: pointer to returned error code
*/

void la(int reason, int *pclass, int *pcode, int *plevel, int *perror)
{
    errcode = 0;
    switch (reason) {

    case 1:
        reason1(pclass, pcode, plevel);
        break;

    case 2:
        reason2(pclass, pcode, plevel);
        break;

    case 3:
        reason3(pclass, pcode, plevel);
        break;

    case 4:
        reason4(pclass, pcode, plevel);
        break;

    case 5:
        reason5(pclass, pcode, plevel);
        break;

    case 6:
        reason6(pclass, pcode);
        break;

    case 7:
        reason7(pclass, pcode);
        break;

    case 8:
        reason8();
        break;

    case 9:
        reason9(pclass);
        break;

    case 10:
        reason10();
        break;

    case 11:
        reason11();
        break;

    default:
        error("LA: Incorrect reason number");
    }
    *perror = errcode;
}

/*      Newsymb() - append a new symbol to the symbol table.
*/

static void newsymb(char *nstr, int class, int code, int level)
{

    int hashval;
    char *temp1, *nptr;
    struct desctb *hashptr;

    hashval = hash(nstr);

    nptr = nametabl;

    /* search for name already in name table */
    while (nptr < nextname) {
        if (strcmp(nptr, nstr) == 0)
            break;
        while (*(nptr++) != 0) ;
    }

    /* append if name not found in name table */
    if (nptr == nextname) {
        temp1 = nstr;
        do {
            *(nextname++) = *temp1;
        } while (*(temp1++) != 0);
    }

    /* set LA class, LA code, LA level, Name pointer */

    nextdesc->laclass = class;
    nextdesc->lacode = code;
    nextdesc->lalevel = level;
    nextdesc->nameptr = nptr;

    /* adjust synonym pointer and hash table */

    hashptr = hashtabl[hashval];
    nextdesc->synptr = hashptr;
    hashtabl[hashval] = nextdesc;

    /* bump descriptor table pointer (by length of struct) */

    ++nextdesc;
}

static int hash(char *string)
{
    int l = 0;
    char first = 0, last = 0;

    /* hash function used: ............................ */
    /* hash = (first_char + last_char + length) mod 256 */

    first = *string;
    while (*string != 0) {
        ++l;
        ++string;
    }

    /* make it work for zero length strings !?! */

    if (l != 0)
        last = *(string - 1);
    return (l + first + last);
}





/* reason10() - initialise data structures */


static void reason10(void)
{
    int i;

    /*  Initialise all necessary global variables */

    loccount = loccode = forcode = glbcode = 0;
    funcode = 1;                /* main program has funcode == 1 */

    /* Initialise pointers to tables */

    nextdesc = desctabl;
    nextname = nametabl;
    nextstr = strtabl;
    nextnumb = numbtabl;

    /* Initialise the hash table to point to nothing */

    for (i = 0; i < MAXHASH; ++i) {
        hashtabl[i] = NULL;
    }

    /* load the symbol table with reserved words */

    newsymb("prog", 2, -1, 0);
    newsymb("endprg", 7, -1, 0);
    newsymb("funct", 12, -1, 0);
    newsymb("endfn", 23, -1, 0);
    newsymb("begin", 28, -1, 0);
    newsymb("var", 29, -1, 0);
    newsymb("return", 39, 14, 0);
    newsymb("read", 45, -1, 0);
    newsymb("write", 49, -1, 0);
    newsymb("while", 53, -1, 0);
    newsymb("do", 55, -1, 0);
    newsymb("enddo", 57, -1, 0);
    newsymb("if", 58, -1, 0);
    newsymb("then", 60, -1, 0);
    newsymb("else", 62, -1, 0);
    newsymb("endif", 64, -1, 0);
    newsymb("or", 66, 12, 0);
    newsymb("and", 69, 13, 0);
}







/*  reason11() - Dump data structures
*/

static void reason11(void)
{

    int i;
    struct desctb *descptr;
    struct numbtb *numbptr;
    char *cp;
    char *strptr;

    descptr = desctabl;
    strptr = strtabl;
    cp = nametabl;
    numbptr = numbtabl;


    printf("\n\tSymbol Table\n");
    printf("Name      Synonym   Class  Code  Level\n");
    printf("--------  --------  -----  ----  -----\n");

    while (descptr < nextdesc) {
        printf("%8s  ", descptr->nameptr);
        if (descptr->synptr != NULL)
            printf("%8s  ", descptr->synptr->nameptr);
        else
            printf("          ");

        printf("%5d  %4d  %5d\n", descptr->laclass, descptr->lacode, descptr->lalevel);

        ++descptr;
    }

    printf("\n\tHash Table\n");
    printf("Index     Name\n");
    printf("-----     --------\n");

    for (i = 0; i < MAXHASH; ++i) {
        if (hashtabl[i] == NULL)
            continue;
        printf("%5d    ", i);
        printf("%8s\n", hashtabl[i]->nameptr);
    }

    printf("\n\tName Table\n");
    printf("Position  Hash  Name\n");
    printf("--------  ----  --------\n");

    i = 0;
    while (cp < nextname) {
        printf("%8d  %4d  %s\n", i++, hash(cp), cp);
        while (*(cp++) != 0) ;
    }


    printf("\n\tString Table\n");
    printf("Offset    String\n");
    printf("------    ------\n");

    i = 0;
    while (strptr < nextstr) {
        printf("%6d    ", i++);
        while (*strptr) {
            putchar(*strptr++);
        }
        ++strptr;
        putchar('\n');
    }


    printf("\n\tNumber Table\n");
    printf("Position  Number  Leftptr  Rightptr\n");
    printf("--------  ------  -------  --------\n");

    i = 0;
    while (numbptr < nextnumb) {
        printf("%8d  %6d  ", i++, numbptr->numb);
        if (numbptr->leftptr == NULL)
            printf("   NULL  ");
        else
            printf("%7ld  ", (numbptr->leftptr) - numbtabl);

        if (numbptr->rightptr == NULL)
            printf("   NULL");
        else
            printf("%7ld", (numbptr->rightptr) - numbtabl);
        ++numbptr;
        printf("\n");
    }

    printf("\n\tEnd of data structures\n");
}






/*  reason1() - Return class, code, and level
**  for the next token
*/

static void reason1(int *pclass, int *pcode, int *plevel)
{
    struct desctb *descptr;

    do {
        lls();
    } while (code == BLANK);

    /* plus symbol through to comma symbol */

    if (code >= PLUS && code <= COMMA) {
        *pclass = classtbl[code];
        *pcode = code;
        return;
    }

    /* if a name */

    if (code == NAME) {
        /* look if its in symbol table */
        descptr = findsym(namestr);

        if (descptr == NULL) {
            laerror(1);         /* name not in symbol table */
            return;
        }

        *pclass = descptr->laclass;
        *pcode = descptr->lacode;
        *plevel = descptr->lalevel;
        return;
    }

    /* if a string */

    if (code == CHARSTR) {
        *pclass = classtbl[CHARSTR];
        *pcode = addstr(string);
        return;
    }

    /* if it is a number */

    if (code == NUMBER) {
        *pclass = classtbl[NUMBER];
        *pcode = addnumb(number);
        return;
    }

    if (code == ENDFILE) {
        laerror(2);             /* unexpected eof */
        return;
    }
    error("LA error ... bad code returned from lls");
}






/*  reason2() - Expect a global variable name
*/

static void reason2(int *pclass, int *pcode, int *plevel)
{
    lls();

    if (code != NAME) {
        laerror(4);             /* expecting global */
        return;
    }

    if (findsym(namestr) != NULL) {
        laerror(5);             /* name already in sym tab */
        return;
    }

    newsymb(namestr, 33, ++glbcode, 1);
    *pclass = 33;
    *pcode = glbcode;
    *plevel = 1;
}






/*  reason3() - Expect a function name
*/

static void reason3(int *pclass, int *pcode, int *plevel)
{
    lls();

    if (code != NAME) {
        laerror(6);             /* expecting func name */
        return;
    }

    if (findsym(namestr) != NULL) {
        laerror(5);             /* name already in sym tab */
        return;
    }

    newsymb(namestr, 34, ++funcode, currlevel);
    *pclass = 34;
    *pcode = funcode;
    *plevel = currlevel;
    forcode = 0;
    loccode = loccount = 0;     /* ... last bug fixed, see sample3 ... */
}






/*  reason4() - Expect a formal parameter name
*/

static void reason4(int *pclass, int *pcode, int *plevel)
{
    struct desctb *descptr;

    lls();

    if (code != NAME) {
        laerror(7);             /* expecting formal */
        return;
    }

    if ((descptr = findsym(namestr)) != NULL) {

        /* test if name is already a formal parameter */
        if (descptr->laclass == 35 && descptr->lalevel == currlevel) {
            laerror(8);         /* already a formal */
            return;
        }

        /* test if name is the current function name */
        if (descptr->laclass == 34 && descptr->lalevel == currlevel) {
            laerror(9);         /* same as current func name */
            return;
        }
    }

    newsymb(namestr, 35, ++forcode, currlevel);
    *pclass = 35;
    *pcode = forcode;
    *plevel = currlevel;

    /* initialise count & codes of local variables */

    loccode = forcode;
    loccount = 0;
}






/*  reason5() - Expect local variable name
*/

static void reason5(int *pclass, int *pcode, int *plevel)
{

    struct desctb *descptr;

    lls();

    if (code != NAME) {
        laerror(10);            /* expecting local */
        return;
    }

    if ((descptr = findsym(namestr)) != NULL) {

        /* test if name is already a local variable */
        if (descptr->laclass == 30 && descptr->lalevel == currlevel) {
            laerror(11);        /* is already a local */
            return;
        }

        /* test if name is already a formal parameter */
        if (descptr->laclass == 35 && descptr->lalevel == currlevel) {
            laerror(8);         /* already a formal */
            return;
        }

        /* test if name is the current function name */
        if (descptr->laclass == 34 && descptr->lalevel == currlevel) {
            laerror(9);         /* same as current func name */
            return;
        }
    }

    newsymb(namestr, 30, ++loccode, currlevel);
    *pclass = 30;
    *pcode = forcode;
    *plevel = currlevel;
    ++loccount;
}










/*  reason6() - Count formal parameters  */

static void reason6(int *pclass, int *pcode)
{

    struct desctb *descptr;
    int formal = 0;

    descptr = nextdesc - 1;

    /* loop until we attain the current function name */
    while (!((descptr->lalevel == currlevel) && (descptr->laclass == 34))) {

        /* test if a formal parameter of current function */
        if ((descptr->lalevel == currlevel) && (descptr->laclass == 35))
            ++formal;

        --descptr;
    }

    /* get current function code from current place in symbol table */
    *pcode = descptr->lacode;

    *pclass = formal;
}






/*  reason7() - Count local variables  */

static void reason7(int *pclass, int *pcode)
{

    struct desctb *descptr;
    int loc = 0;

    descptr = nextdesc - 1;

    /* loop until we attain the current function name */
    while (!((descptr->lalevel == currlevel) && (descptr->laclass == 34))) {

        /* test if a local variable of current function */
        if ((descptr->lalevel == currlevel) && (descptr->laclass == 30))
            ++loc;

        --descptr;
    }

    /* get current function code from current place in symbol table */
    *pcode = descptr->lacode;

    *pclass = loc;
}






/*  reason8() - Delete from symbol table:
**      Local Variables
**      Formal Parameters
**      Local function names & variables & parameters
*/

static void reason8(void)
{

    struct desctb *descptr;
    int hashval;

    descptr = nextdesc - 1;     /* last structure in desctbl */

    /* loop forever, break when at/past current function */

    for (;;) {
        hashval = hash(descptr->nameptr);

        /* test if finished or somehow gone too far */

        if ((descptr->lalevel < currlevel) ||
            ((descptr->lalevel == currlevel) && (descptr->laclass == 34)))
            break;

        /* remove it from the symbol table, adjust hash */

        delsymb(descptr, hashval);
        --descptr;
    }
}






/*  reason9() - Count global variables
**
*/

static void reason9(int *pclass)
{
    *pclass = glbcode;
}

/*  laerror() ... Return an error code to the compiler
*/


static void laerror(int level)
{
    errcode = level;
}

/*
**  Delsymb: Delete the last descriptor from the descriptor
**  table and adjust hash pointers. Leave the name table
**  alone.
*/


static void delsymb(struct desctb *descptr, int hashcode)
{

    /*  Point backwards or NULL if nowhere to point to */
    hashtabl[hashcode] = descptr->synptr;

    /*  Subtract length of desctb from nextdesc to set
     **  new "end of table"
     */

    nextdesc = descptr;         /* table ends just before deleted entry */
}

/*
**  findsym() - Search the symbol table for a name
**  return pointer to the structure
**  return null if name not in symbol table
*/

static struct desctb *findsym(char *name)
{
    int hashval;
    struct desctb *descptr;

    hashval = hash(name);

    descptr = hashtabl[hashval];

    /* look until found or no more synonyms */

    while (descptr != NULL) {
        if (strcmp(descptr->nameptr, name) == 0)
            return descptr;
        descptr = descptr->synptr;
    }

    return NULL;
}


/*
**  addstr() - add a new string to the string table
**  return character offset from 0 of first char in string
*/

static int addstr(char *string)
{
    char *p;

    p = nextstr;

    /* copy the string to the end of the string table */

    while (*string != 0)
        *nextstr++ = *string++;

    *nextstr++ = 0;

    return (p - strtabl);
}

/*
**  addnumb() - add a new number to the number table
**  if it is not already there
**  return position within number table from 0
*/

static int addnumb(int number)
{
    struct numbtb *numbptr;

    numbptr = numbtabl;

    /* search for number, if found, return position */

    while (numbptr < nextnumb) {
        if (numbptr->numb == number)
            return (numbptr - numbtabl);
        ++numbptr;
    }

    /* initialise structure. */

    numbptr->numb = number;
    numbptr->leftptr = NULL;
    numbptr->rightptr = NULL;

    ++nextnumb;
    return (numbptr - numbtabl);
}
