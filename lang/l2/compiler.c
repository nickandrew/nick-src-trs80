/*       Languages & Processors
**
**       compiler.c - L2 Compiler
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/



#include <stdio.h>       /* Standard IO functions */
#include "lls.h"         /* Header: lls           */
#include "la.h"          /* Header: la            */
#include "compiler.h"    /* Header: compiler      */
#include "goals.h"       /* For error handling    */
#include "opcodes.h"     /* List of L2 opcode #s  */





/*
** compile() ... Do the iterative top-down compile
*/



compile() {

    errflag = FALSE;
    goal = 1;
    needtoken = TRUE;
    lareason = 1;

    do {
        if (debug) fprintf(f_debug,"GOAL is %d\n",goal);
        nextgoal();
        nexttoken();
        /* if there was no fatal error, process this goal */
        if (!errflag) procgoal();
    } while (errflag == FALSE && goal != 1);
    if (errflag) {
        error("Fatal error detected");
        printf("Fatal error goal is %d\n",goal);
        printf("Fatal error token class = %d\n",cclass);
        printf("Goal stack:\n");
        while (goalsp >= 0)
            printf("%d  ",goalstack[--goalsp]);
        printf("\n");
    }
    terminate();
}



/*
** nextgoal() ... Follow the syntax graph down the
** goal definitions until no we get to the bottom
*/



nextgoal() {

    while (def[goal] != 0) {
        push(goalstack,goal);
        goal = def[goal];
    }

}



/*
** nexttoken() ... read the next token from input
** if necessary
*/



nexttoken() {

    if (needtoken) {
        needtoken = FALSE;
        la (lareason,&cclass,&ccode,&clevel,&cerror);
        
        /* check output of LA, substitute code if error within LA */
        lacheck();
        lareason = 1 ; /* setup for next call of this function */
    }
    if (debug) fprintf(f_debug,"class=%d, code=%d, level=%d, error=%d\n",
           cclass,ccode,clevel,cerror);
}



/*
** procgoal() ... process the current goal
*/



procgoal() {

    int  e;

    /* fix things up if there will be an error and recover */
    e = expected();
    if (e==1) return;  /* restart compiler at another goal */
    if (e==2) {
        /* restart compiler at successor of current goal */
        if (debug) fprintf(f_debug,"Forcing goal %d to succeed\n",goal);
        successor();
        return;
    }


    if (goal==cclass || goal==EMPTY) {
        needtoken = (goal==cclass);
        successor();  /* process this goal then go to successor or parent */
    } else {

        /* the expected token wasn't found ... maybe an error */

        while (goal>1 && alt[goal] == 0) {
            pop(goalstack,&goal);
        }

        errflag = (goal < 1);

        if (!errflag) goal = alt[goal];
    }
}


/*
**  successor() ... move to the successor or parent of the current goal
*/

successor() {

    int  goalfound;
    goalfound = FALSE;

    while (!goalfound && goal!=1) {
        if (goal>1) {
            action(goal);
            if (suc[goal]!= 0) {
                push(goalstack,-goal);
                goal = suc[goal];
                goalfound = TRUE;
            } else {
                pop(goalstack,&goal);
            }
        } else
            pop(goalstack,&goal);
    }
}







/*
**  push() ... push a number onto either goal or opcode stack
*/


push(stack,num)
int  stack[];
int  num;
{
    int  *spp;

    if (stack == goalstack) {
        spp = &goalsp;
        if (*spp == MAXGLSTK) {
            error("Compiler goal stack overflow");
            exit(1);
        }
    } else {
        spp = &opsp;
        if (*spp == MAXOPSTK) {
            error("Compiler opcode stack overflow");
            exit(1);
        }
    }
    stack[(*spp)++] = num;
}



/*
**  pop() ... Pop a number off either stack
*/


pop(stack,gp)
int  stack[];
int  *gp;
{
    int  *spp;

    if (stack == goalstack)
        spp = &goalsp;
    else
        spp = &opsp;

    if (*spp == 0) {
        error("Compiler goal|opcode stack underflow");
        exit(1);
    }

    *gp = stack[--(*spp)];

}


/*
** togs ... get the value of the top of the goal stack
*/

int  togs() {
   return goalstack[goalsp-1];
}




/*
**  action() ... do a compiler action
*/


action(goal)
int  goal;
{

    int  x1,x2,x3,x4;
    switch(act[goal]) {

        case  0 : return;

        case  1 : location = 1;
                  opcode(START);
                  currlevel = 1;
                  argcount = 0;
                  break;

        case  2 : la(9,&x1,&x2,&x3,&x4);
                  functabl[1].startloc = location;
                  functabl[1].nparam = 0;
                  functabl[1].nlocal = x1;
                  functabl[1].flevel = 1;
                  break;

        case  3 : opcode(STOP);
                  break;

        case  4 : lareason = 2;
                  break;

        case  5 : ++currlevel;
                  lareason = 3;
                  break;

        case  6 : lareason = 4;
                  break;

        case  7 : la(6,&x1,&x2,&x3,&x4);
                  functabl[x2].nparam = x1;
                  functabl[x2].flevel = currlevel;
                  break;

        case  8 : la(7,&x1,&x2,&x3,&x4);
                  functabl[x2].startloc = location;
                  functabl[x2].nlocal = x1;
                  break;

        case  9 : la(8,&x1,&x2,&x3,&x4);
                  --currlevel;
                  opcode(CRASH);
                  break;

        case 10 : lareason = 5;
                  break;

        case 11 : opcode(ccode);
                  /* output LA code (abs addr) */
                  break;

        case 12 : push(opstack,ccode);
                  break;

        case 13 : pop(opstack,&x1);
                  opcode(-x1);
                  break;

        case 14 : opcode(ccode);
                  opcode(clevel);
                  opcode(ISB);
                  break;

        case 15 : opcode(READ);
                  break;

        case 16 : opcode(WRITE);
                  break;

        case 17 : opcode(ccode);
                  opcode(WS);
                  break;

        case 18 : opcode(WN);
                  break;

        case 19 : push(opstack,location);
                  break;

        case 20 : push(opstack,location);
                  opcode(CRASH);
                  opcode(GIF);
                  break;

        case 21 : pop(opstack,&x1);
                  store(x1,location+2);
                  pop(opstack,&x1);
                  opcode(x1);
                  opcode(GO);
                  break;

        case 22 : pop(opstack,&x1);
                  store(x1,location+2);
                  push(opstack,location);
                  opcode(CRASH);
                  opcode(GO);
                  break;

        case 23 : pop(opstack,&x1);
                  store(x1,location);
                  break;

        case 24 : pop(opstack,&x1);
                  opcode(-(x1+14));
                  break;

        case 25 : opcode(ccode);
                  opcode(RS);
                  break;

        case 26 : opcode(ccode);
                  opcode(clevel);
                  opcode(ISB);
                  opcode(RS);
                  break;

        case 27 : opcode(ccode);
                  opcode(RN);
                  break;

        case 28 : opcode(ISP);
                  push(opstack,argcount);
                  argcount = 0;
                  push(opstack,ccode);
                  break;

        case 29 : ++argcount;
                  break;

        case 30 : ++argcount;
                  pop(opstack,&x1);
                  if (argcount != functabl[x1].nparam) {
                      error("Wrong number of parameters");
                  }
                  opcode(x1);
                  opcode(CALL);
                  pop(opstack,&argcount);
                  break;

        default : error("Compiler error, bad action");
    }
}



/*
**  l2init() ... Initialise the syntax graph array
*/


l2init() {

    FILE *fp;
    char string[80],s1[5],s2[5],s3[5],s4[5],s5[5];
    int  n1,n2,n3,n4,n5;
    int  i,goal;

    goalsp = opsp = 0;

    if ((fp=fopen("l2.inf","r"))==NULL) {
        fprintf(stderr,"Couldn't open l2.inf\n");
        exit(1);
    }

    /* bypass comments at start */
    fgets(string,80,fp);
    fgets(string,80,fp);
    fgets(string,80,fp);
    fgets(string,80,fp);

    /* read in syntax graph */

    for (goal=1; goal < 100 ; ++goal) {

        i=fscanf(fp,"%s %s %s %s %s",s1,s2,s3,s4,s5);

        if (!strcmp(s1,"--")) n1=0; else n1=atoi(s1);
        if (!strcmp(s2,"--")) n2=0; else n2=atoi(s2);
        if (!strcmp(s3,"--")) n3=0; else n3=atoi(s3);
        if (!strcmp(s4,"--")) n4=0; else n4=atoi(s4);
        if (!strcmp(s5,"--")) n5=0; else n5=atoi(s5);

        if (n1 != goal) {
            fprintf(stderr,"Incorrect syntax graph\n");
            exit(-1);
        }

        alt[goal] = n2;
        def[goal] = n3;
        act[goal] = n4;
        suc[goal] = n5;
    }

    fclose(fp);
}



/*
**  opcode() ... output the desired opcode or value
*/

opcode(num)
int  num;
{

    if (num < 0)
        fprintf(f_asm,"%d\t%s\n",location,asmtab[-num]);
    else
        fprintf(f_asm,"%d\t%d\n",location,num);

    if ((location % OUTBUF) == 0) {
        fprintf(stderr,"Output buffer overflow, writing\n");
        outflush();
    }

    outbuf[location % OUTBUF] = num;
    ++location;
}



/*
**  outflush() ... Reluctantly flush the machine code
**  output buffer, there are too many instructions in it.
**  store(addr,num) will fail to replace a location which
**  is already flushed to disk
*/

outflush() {

    int  i,top;

    /* start writing from the right place */
    if (location<=OUTBUF) i=1; else i=0;

    /* figure out where to stop writing */
    top = location % OUTBUF;
    if (top==0) top = OUTBUF;
 
    for (;i<top;++i) putw(outbuf[i],f_out);
}



/*
**  store() ... Store a value at an absolute address
*/



store(addr,num)
int  addr,num;
{

    if (addr > location) {
        error("Compiler error within store()");
        exit(1);
    }

    /* print the store place and value on the asm listing */
    fprintf(f_asm,"Store\t\tLocation %d, Value %d\n",addr,num);

    if (addr/OUTBUF != location/OUTBUF) {
        /* already written location to file - oh dear */
        error("Cannot refer back to earlier location");
    } else {
        outbuf[addr % OUTBUF] = num;
    }
}



/*
**  expected() ... Figure out what was expected here and not found
*/


int expected()
{
    char *m;
    int  parent,g;
    if (goal==cclass || goal==EMPTY) return 0;  /* no error */

    if (debug) fprintf(f_debug,"Expected goal %d, got class %d\n",goal,cclass);
    m = 0;
    switch(goal) {

        case PROG   : m = "Expected PROG";
                      break;
        case ENDPRG :  /* Dont print expected msg, its probably missing ; */
                      /* might be missing ; so go back into statements */
                      error("Missing ; near here");
                      pop(goalstack,&goal); /* pop -6 */
                      goal = 6;
                      return 1; /* loop back */

        case ENDFN  : m = "Expected ENDFN";
                      error(m);
                      /* might be missing ; so go back in */
                      error("Missing ; ?");
                      pop(goalstack,&goal); /* pop -22 */
                      goal = 22;
                      return 1; /* loop back */

        case BEGIN  : m = "Expected BEGIN";
                      break;
        case GGETS   : m = "Expected ':='";
                      /* if token is an = they have misspelt it */
                      if (cclass==RELOP && ccode==5) {
                          error("Substituted ':=' for '='");
                          cclass=GGETS;
                          return 0;  /* we changed = to := */
                      }
                      break;
        case DO     : m = "Expected DO";
                      break;
        case ENDDO  : m = "Expected ENDDO";
                      error(m);
                      /* force while...enddo goal to succeed, change goal */
                      /* from 37 to 36 because there is obviously a */
                      /* missing semicolon */
                      /* note that it can't hurt to exit the while..enddo */
                      /* pair because missing endifs etc will be picked */
                      /* up at the end of the function by the endfn */
                      successor();
                      if (goal==37) goal=36;
                      return 1; /* try stmt goal again */

        case THEN   : m = "Expected THEN";
                      break;
        case ENDIF  : m = "Expected ENDIF";
                      error(m);
                      /* force if .. endif goal to succeed, change goal */
                      /* from 37 to 36 because there is obviously a */
                      /* missing semicolon */
                      /* note we are moving OUT of the if-endif pair */
                      successor();
                      if (goal==37) goal=36;
                      return 1; /* try stmt goal again */
        case GRIGHT  : m = "Expected ')'";
                       break;
        case GLEFT  : /* check parent goal, must be 14 for error */
                      parent = togs();
                      if (parent==14 || parent==95)
                          m = "Expected '('";
                      else return 0; /* no error */
                      break;
        case RELOP  : m = "Expected relational operator";
                      /* if we used := instead of = then substitute */
                      if (cclass==GGETS) {
                          error("Substituted '=' for ':='");
                          cclass=RELOP ; ccode = 5;
                          return 0; /* because we fixed this one */
                      }
                      break;

        case SEMI   : /* The semicolon is only REQUIRED in some cases */
                      /* check parent goal */
                      parent = togs();
                      if (parent== -9 || parent==18 || parent==27)
                          m = "Expected ';'";
                      else return 0;
                      break;

        case SYNTAX :
                      return syntax();
                      /* these errors are harder to handle */

        case FNAME  : /* something was wonky within an expression */
                      /* if parent != 94 then no error so return */
                      parent = togs();
                      if (parent!=94) return 0;
                      /* pop until we pop the "expr" goal */
                      /* any of 40, 44, 51, 74, 76, 92, 96, 98 */
                      error("Invalid expression");
                      do {
                          pop(goalstack,&g);
                          goal = g;
                      } while (g!=40 && g!=44 && g!=51 && g!=74 &&
                               g!=76 && g!=92 && g!=96 && g!=98   );
                      return 2;

        case LOCAL :
                     parent = togs();
                     if (parent==41 && cclass==35) {
                         error("Assignment to formal is illegal");
                         /* fudge a local instead */
                         cclass = goal;
                         return 0;
                     }
                     return 0; /* else it is valid */
        default : return 0;
    }

    if (m!=NULL)
        error(m);
    return 2;
}
int syntax()
{

   if (cclass==ENDPRG  || cclass==ENDFN   || cclass==ENDDO   ||
       cclass==ENDIF   || cclass==ELSE) {
      pop(goalstack,&goal);
      if (goal!=36 && debug)
         fprintf(f_debug,"Syntax goal was %d\n",goal);
      pop(goalstack,&goal);
      if (goal== -37) {
         error("Unnecessary semicolon near here");
         while (goal== -37 || goal==-36) pop(goalstack,&goal);
      }
      push(goalstack,-goal);     /* assume stseq recognised */
      /* goal = 6, 22, 56, 61, 63 (program,function,while,ifthen,ifelse) */
      /* token = 7, 23, 57, 62, 64 */
      /* if they don't match up, ignore token */
      if (cclass != suc[goal] && !(cclass==64 && goal==61)) {
         /* do the previous test because ELSE has an alternate of 64 */
         /* never ignore an ENDPRG or an ENDFN */
         if (cclass!=ENDPRG && cclass!=ENDFN) {
             needtoken = TRUE;
             error("Token not relevant here, ignored");
             return 2; /* stseq goal succeeded */
         }
         return 2;
      }
      goal = cclass;          /* lust after the successor */
      return 0;
   }

   if (cclass==SEMI) {
      /* ignore a semicolon gracefully */
      error("Extra semicolon ignored");
      pop(goalstack,&goal); /* Ie: pop 36 */
      needtoken = 1;
      return 1;
   }


   error("Syntax error");
   /* when in doubt of what to do with this, ignore it */
   error("Token ignored");
   needtoken = TRUE;
   /* loop inside stseq and use the next token in the input */
   return 1;
}



/*
**  terminate() ... report on count of errors found
*/


terminate() {

   if (errorfound==0)
       fprintf(f_list,"\nNo errors detected ... lucky you\n");
   else
       fprintf(f_list,"\n%d errors were detected\n",errorfound);
}



/*
**  lacheck() ... Check the output and error status of LA
*/


lacheck() {
    char *m = NULL ;
    if (cerror == 0) return;

    /* print appropriate message */
    switch (cerror) {

        case 1 : /* error is name not in sym tab */
                 /* if we are expecting local,global,formal or function
                    then print undeclared, else let other routine handle */
                 if (goal==30 || goal==33 || goal==34 || goal==35) {
                     m = "Undeclared";
                 } else {
                     cclass = 33; /* make believe it is a global */
                     error("Undeclared");
                     return;
                 }
                 break;
        case 2 : m = "Unexpected end of source file";
                  error(m);
                  errflag = TRUE;
                   return;
        case 4 : m = "Expected global";
                 error(m);
                 /* assume there was one there & process goal 9 */
                 successor();
                 return;
        case 5 : m = "Name already in symbol table";
                 break;
        case 6 : m = "Expected function name";
                 break;
        case 7 : m = "Expected formal parameter";
                 break;
        case 8 : m = "Is already a formal parameter";
                 break;
        case 9 : m = "Same as current function name";
                 break;
        case 10: m = "Expected local";
                 error(m);
                 /* assume there was one there & process goal 25 */
                 successor();
                 return;
        case 11: m = "Is already a local variable";
                 break;
    }

    if (m!=NULL) error(m);

    /* ignore the error by assuming whatever is required (ie: goal) */
    /* has just been read in */

    cclass = goal;


}
