/*       Languages & Processors
**
**       la.c   - Lexical analyser
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/

#include <stdio.h>
#include "la.h"
#include "lls.h"

/*      Structure of descriptor table.
**      Does not contain "name length" field since
**          strings are null terminated in C.
*/

struct  desctb {
    struct  desctb     *synptr;
    int                 laclass;
    int                 lacode;
    int                 lalevel;
    char               *nameptr;
};

/*      Hash table.
**      Contains pointers to the descriptor table.
*/

struct desctb *hashtabl[MAXHASH];

/*      Descriptor table. */

struct desctb   desctabl[MAXDESC];
struct desctb  *nextdesc;

/*      Name table. */

char   nametabl[MAXNAME*SYMMAX];
char  *nextname;

/*      String table. */

char   strtabl[MAXSTR];
char  *nextstr;

/*      Number table. */

struct numbtb  {
    int   numb;
    struct numbtb *leftptr;
    struct numbtb *rightptr;
} numbtabl[MAXNUMB];

struct numbtb *nextnumb;

/*  Static tables: classtbl[] contains the class of arithmetic
**                 comparison and other tokens.
**  Starting: blank, plus, minus, star, slash, etc...
*/

int  classtbl[20] = {
   -1, 82, 82, 84, 84, 75, 75, 75, 75, 75,
   75, 43, 11, 32, 73, 31, -1, 50, 89, -1
};

/*      Other globals */
int  errcode,       /* Error code returned by LA. 0 if ok */
     currlevel,     /* Current compiler level             */
     funcode,       /* Code of last function              */
     forcode,       /* Code of last formal parameter      */
     loccode,       /* Code of last local variable        */
     loccount,      /* Count of number of local variables */
     glbcode;       /* Code of last global variable       */



/* la ... entry to the lexical analyser */

la(reason,pclass,pcode,plevel,perror)

int reason,             /* reason for calling lls */
    *pclass,            /* Ptr to returned symbol class */
    *pcode,             /* Ptr to returned code */
    *plevel,            /* Ptr to returned level */
    *perror;            /* Ptr to returned error code */

{
    errcode = 0;
    switch(reason)  {

        case 1:     reason1(pclass,pcode,plevel);
                    break;

        case 2:     reason2(pclass,pcode,plevel);
                    break;

        case 3:     reason3(pclass,pcode,plevel);
                    break;

        case 4:     reason4(pclass,pcode,plevel);
                    break;

        case 5:     reason5(pclass,pcode,plevel);
                    break;

        case 6:     reason6(pclass,pcode);
                    break;

        case 7:     reason7(pclass,pcode);
                    break;

        case 8:     reason8();
                    break;

        case 9:     reason9(pclass);
                    break;

        case 10:    reason10();
                    break;

        case 11:    reason11();
                    break;

        default:    error("LA: Incorrect reason number");
    }
    *perror = errcode;
}

/*      Newsymb() - append a new symbol to the symbol table.
*/

newsymb(nstr,class,code,level)
char  *nstr;
int   class, code, level;
{

    int  hashval;
    char *temp1,*nptr;
    struct desctb *hashptr;

    hashval=hash(nstr);

    nptr = nametabl;

    /* search for name already in name table */
    while (nptr < nextname) {
        if (strcmp(nptr,nstr)==0) break;
        while (*(nptr++)!=0);
    }

    /* append if name not found in name table */
    if (nptr == nextname) {
        temp1 = nstr;
        do {
            *(nextname++) = *temp1;
        } while (*(temp1++) != 0);
    }

    /* set LA class, LA code, LA level, Name pointer */

    nextdesc -> laclass = class;
    nextdesc -> lacode  = code;
    nextdesc -> lalevel = level;
    nextdesc -> nameptr = nptr;

    /* adjust synonym pointer and hash table */

    hashptr = hashtabl[hashval];
    nextdesc -> synptr = hashptr;
    hashtabl[hashval] = nextdesc;

    /* bump descriptor table pointer (by length of struct) */

    ++nextdesc;

}

int hash(string)
char *string;
{
    int  l=0;
    char first,last;

    /* hash function used: ............................ */
    /* hash = (first_char + last_char + length) mod 256 */

    first = *string;
    while (*string!=0)  {
        ++l;
        ++string;
    }

    /* make it work for zero length strings !?! */

    if (l!=0)  last = *(string-1);
    return (l + first + last);
}





/* reason10() - initialise data structures */


reason10() {
    int  i;

    /*  Initialise all necessary global variables */

    loccount = loccode = forcode = glbcode = 0;
    funcode = 1;     /* main program has funcode == 1 */

    /* Initialise pointers to tables */

    nextdesc = desctabl;
    nextname = nametabl;
    nextstr  = strtabl;
    nextnumb = numbtabl;

    /* Initialise the hash table to point to nothing */

    for (i=0;i<MAXHASH;++i) {
        hashtabl[i] = NULL;
    }

    /* load the symbol table with reserved words */

    newsymb("prog"  ,  2, -1, 0);
    newsymb("endprg",  7, -1, 0);
    newsymb("funct" , 12, -1, 0);
    newsymb("endfn" , 23, -1, 0);
    newsymb("begin" , 28, -1, 0);
    newsymb("var"   , 29, -1, 0);
    newsymb("return", 39, 14, 0);
    newsymb("read"  , 45, -1, 0);
    newsymb("write" , 49, -1, 0);
    newsymb("while" , 53, -1, 0);
    newsymb("do"    , 55, -1, 0);
    newsymb("enddo" , 57, -1, 0);
    newsymb("if"    , 58, -1, 0);
    newsymb("then"  , 60, -1, 0);
    newsymb("else"  , 62, -1, 0);
    newsymb("endif" , 64, -1, 0);
    newsymb("or"    , 66, 12, 0);
    newsymb("and"   , 69, 13, 0);
}







/*  reason11() - Dump data structures
*/

reason11() {

    int  i;
    struct desctb *descptr;
    struct numbtb *numbptr;
    char  *cp;
    char  *strptr;

    descptr = desctabl;
    strptr  = strtabl;
    cp      = nametabl;
    numbptr = numbtabl;


    printf("\n\tSymbol Table\n");
    printf("Name      Synonym   Class  Code  Level\n");
    printf("--------  --------  -----  ----  -----\n");

    while (descptr < nextdesc) {
        printf("%8s  ",descptr -> nameptr);
        if (descptr->synptr != NULL)
            printf("%8s  ",descptr->synptr -> nameptr);
        else
            printf("          ");

        printf("%5d  %4d  %5d\n",descptr->laclass,
            descptr->lacode,descptr->lalevel);

        ++descptr;
    }

    printf("\n\tHash Table\n");
    printf("Index     Name\n");
    printf("-----     --------\n");

    for (i=0;i<MAXHASH;++i) {
        if (hashtabl[i]==NULL) continue;
        printf("%5d    ",i);
        printf("%8s\n",hashtabl[i]->nameptr);
    }

    printf("\n\tName Table\n");
    printf("Position  Hash  Name\n");
    printf("--------  ----  --------\n");

    i=0;
    while (cp < nextname) {
        printf("%8d  %4d  %s\n",i++,hash(cp),cp);
        while (*(cp++)!=0) ;
    }


    printf("\n\tString Table\n");
    printf("Offset    String\n");
    printf("------    ------\n");

    i=0;
    while (strptr < nextstr) {
        printf("%6d    ",i++);
        while (*strptr) {
            putchar(*strptr++);                                        }
        ++strptr;
        putchar('\n');
    }


    printf("\n\tNumber Table\n");
    printf("Position  Number  Leftptr  Rightptr\n");
    printf("--------  ------  -------  --------\n");

    i=0;
    while (numbptr < nextnumb) {
        printf("%8d  %6d  ",i++,numbptr->numb);
        if (numbptr->leftptr == NULL)
            printf("   NULL  ");
        else printf("%7d  ",(numbptr->leftptr)-numbtabl);

        if (numbptr->rightptr == NULL)
            printf("   NULL");
        else printf("%7d",(numbptr->rightptr)-numbtabl);
        ++numbptr;
        printf("\n");
    }

    printf("\n\tEnd of data structures\n");
}






/*  reason1() - Return class, code, and level
**  for the next token
*/

reason1(pclass,pcode,plevel)
int  *pclass,*pcode,*plevel;
{
    struct desctb *descptr, *findsym();

    do {   
        lls();
    } while (code==BLANK);

    /* plus symbol through to comma symbol */

    if (code >= PLUS && code <= COMMA) {
        *pclass = classtbl[code];
        *pcode  = code;
        return;
    }

    /* if a name */

    if (code == NAME) {
        /* look if its in symbol table */
        descptr = findsym(namestr);

        if (descptr == NULL) {
            laerror(1); /* name not in symbol table */
            return;
        }

        *pclass = descptr -> laclass;
        *pcode  = descptr -> lacode;
        *plevel = descptr -> lalevel;
        return;
    }

    /* if a string */
 
   if (code == CHARSTR) {
        *pclass = classtbl[CHARSTR];
        *pcode  = addstr(string);
        return;
    }

    /* if it is a number */

    if (code == NUMBER) {
        *pclass = classtbl[NUMBER];
        *pcode  = addnumb(number);
        return;
    }

    if (code==ENDFILE) {
        laerror(2); /* unexpected eof */
        return;
    }
    error("LA error ... bad code returned from lls");
}






/*  reason2() - Expect a global variable name
*/

reason2(pclass,pcode,plevel)
int  *pclass,*pcode,*plevel;
{

    struct desctb *findsym();

    lls();

    if (code != NAME) {
        laerror(4); /* expecting global */
        return;
    }

    if (findsym(namestr)!=NULL) {
        laerror(5); /* name already in sym tab */
        return;
    }

    newsymb(namestr,33,++glbcode,1);
    *pclass = 33;
    *pcode = glbcode;
    *plevel = 1;
}






/*  reason3() - Expect a function name
*/

reason3(pclass,pcode,plevel)
int  *pclass,*pcode,*plevel;
{

    struct desctb *findsym();

    lls();

    if (code != NAME) {
        laerror(6); /* expecting func name */
        return;
    }

    if (findsym(namestr)!=NULL) {
        laerror(5); /* name already in sym tab */
        return;
    }

    newsymb(namestr,34,++funcode,currlevel);
    *pclass = 34;
    *pcode = funcode;
    *plevel = currlevel;
    forcode = 0;
    loccode = loccount = 0;     /* ... last bug fixed, see sample3 ... */
}






/*  reason4() - Expect a formal parameter name
*/

reason4(pclass,pcode,plevel)
int  *pclass,*pcode,*plevel;
{

    struct desctb *descptr, *findsym();

    lls();

    if (code != NAME) {
        laerror(7); /* expecting formal */
        return;
    }

    if ((descptr = findsym(namestr))!=NULL) {

        /* test if name is already a formal parameter */
        if (descptr -> laclass == 35 &&
            descptr -> lalevel == currlevel) {
            laerror(8); /* already a formal */
            return;
        }

        /* test if name is the current function name */
        if (descptr -> laclass == 34 &&
            descptr -> lalevel == currlevel) {
            laerror(9); /* same as current func name */
            return;
        }
    }

    newsymb(namestr,35,++forcode,currlevel);
    *pclass = 35;
    *pcode = forcode;
    *plevel = currlevel;

    /* initialise count & codes of local variables */

    loccode = forcode;
    loccount = 0;
}






/*  reason5() - Expect local variable name
*/

reason5(pclass,pcode,plevel)
int  *pclass,*pcode,*plevel;
{

    struct desctb *descptr, *findsym();

    lls();

    if (code != NAME) {
        laerror(10); /* expecting local */
        return;
    }

    if ((descptr = findsym(namestr))!=NULL) {

        /* test if name is already a local variable */
        if (descptr -> laclass == 30 &&
            descptr -> lalevel == currlevel) {
            laerror(11); /* is already a local */
            return;
        }

        /* test if name is already a formal parameter */
        if (descptr -> laclass == 35 &&
            descptr -> lalevel == currlevel) {
            laerror(8); /* already a formal */
            return;
        }

        /* test if name is the current function name */
        if (descptr -> laclass == 34 &&
            descptr -> lalevel == currlevel) {
            laerror(9); /* same as current func name */
            return;
        }
    }

    newsymb(namestr,30,++loccode,currlevel);
    *pclass = 30;
    *pcode = forcode;
    *plevel = currlevel;
    ++loccount;
}










/*  reason6() - Count formal parameters  */

reason6(pclass,pcode)
int  *pclass, *pcode;
{

    struct desctb *descptr;
    int    formal=0;

    descptr = nextdesc - 1;

    /* loop until we attain the current function name */
    while (!((descptr->lalevel==currlevel)&&(descptr->laclass==34))) {

        /* test if a formal parameter of current function */
        if ((descptr->lalevel==currlevel)&&(descptr->laclass==35))
            ++formal;

        --descptr;
    }

    /* get current function code from current place in symbol table */
    *pcode = descptr -> lacode;

    *pclass = formal;
}






/*  reason7() - Count local variables  */

reason7(pclass,pcode)
int  *pclass, *pcode;
{

    struct desctb *descptr;
    int    loc=0;

    descptr = nextdesc - 1;

    /* loop until we attain the current function name */
    while (!((descptr->lalevel==currlevel)&&(descptr->laclass==34))) {

        /* test if a local variable of current function */
        if ((descptr->lalevel==currlevel)&&(descptr->laclass==30))
            ++loc;

        --descptr;
    }

    /* get current function code from current place in symbol table */
    *pcode = descptr -> lacode;

    *pclass = loc;
}






/*  reason8() - Delete from symbol table:
**      Local Variables
**      Formal Parameters
**      Local function names & variables & parameters
*/

reason8() {

    struct desctb *descptr;
    int  hashval;

    descptr = nextdesc - 1;   /* last structure in desctbl */

    /* loop forever, break when at/past current function */

    for (;;) {
        hashval = hash(descptr -> nameptr);

        /* test if finished or somehow gone too far */

        if ( (descptr->lalevel  < currlevel) ||
           ( (descptr->lalevel == currlevel) &&
                (descptr->laclass == 34)))
                    break;

        /* remove it from the symbol table, adjust hash */

        delsymb(descptr,hashval);
        --descptr;
    }
}






/*  reason9() - Count global variables
**
*/

reason9(pclass)
int  *pclass;
{
    *pclass = glbcode;
}

/*  laerror() ... Return an error code to the compiler
*/


laerror(level)
int  level;
{

    errcode = level;
}

/*
**  Delsymb: Delete the last descriptor from the descriptor
**  table and adjust hash pointers. Leave the name table
**  alone.
*/


delsymb(descptr,hashcode)
struct desctb *descptr;
int    hashcode;
{

    /*  Point backwards or NULL if nowhere to point to */
    hashtabl[hashcode] =  descptr -> synptr;

    /*  Subtract length of desctb from nextdesc to set
    **  new "end of table"
    */

    nextdesc = descptr;     /* table ends just before deleted entry */
}

/*
**  findsym() - Search the symbol table for a name
**  return pointer to the structure
**  return null if name not in symbol table
*/

struct desctb *findsym(name)
char *name;
{
    int  hashval;
    struct desctb *descptr;

    hashval=hash(name);

    descptr=hashtabl[hashval];

    /* look until found or no more synonyms */

    while (descptr != NULL) {
        if (strcmp(descptr->nameptr,name)==0)
            return descptr;
        descptr = descptr -> synptr;
    }

    return NULL;
}


/*
**  addstr() - add a new string to the string table
**  return character offset from 0 of first char in string
*/

int addstr(string)
char *string;
{
    char *p;

    p = nextstr;

    /* copy the string to the end of the string table */

    while (*string!=0)
        *nextstr++ = *string++;

    *nextstr++ = 0;

    return (p-strtabl);
}

/*
**  addnumb() - add a new number to the number table
**  if it is not already there
**  return position within number table from 0
*/

int addnumb(number)
int  number;
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

    numbptr -> numb     = number;
    numbptr -> leftptr  = NULL;
    numbptr -> rightptr = NULL;

    ++nextnumb;
    return (numbptr - numbtabl);
}

