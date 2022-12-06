/*
** print all assembler info before any code is generated
*/
header()  {
  beglab=getlabel();
  }

/*
** print any assembler stuff needed at the end
*/
trailer()  {  
#ifndef LINK
  if((beglab == 1)|(beglab > 9000)) {
    /* implementation dependent trailer code goes here */
    }
#else
  char *ptr;
  cptr=STARTGLB;
  while(cptr<ENDGLB) {
    if(cptr[IDENT]==FUNCTION && cptr[CLASS]==AUTOEXT)
      external(cptr+NAME);
    cptr+=SYMMAX;
    }
#ifdef UPPER
  if((ptr=findglb("MAIN")) && (ptr[OFFSET]==FUNCTION))
#else
  if((ptr=findglb("main")) && (ptr[OFFSET]==FUNCTION))
#endif
    external("Ulink");	/* link to library functions */
#endif
  ol("END");
  }

/*
** load # args before function call
*/
loadargc(val) int val; {
  if(search("NOCCARGC", macn, NAMESIZE+2, MACNEND, MACNBR, 0)==0) {
    if(val) {
      ot("MVI A,");
      outdec(val);
      nl();
      }
    else ol("XRA A");
    }
  }

/*
** declare entry point
*/
entry() {
  outstr(ssname);
  col();
#ifdef LINK
  col();
#endif
  nl();
  }

/*
** declare external reference
*/
external(name) char *name; {
#ifdef LINK
  ot("EXT ");
  ol(name);
#endif
  }

/*
** fetch object indirect to primary register
*/
indirect(lval) int lval[]; {
  if(lval[1]==CCHAR) ffcall("CCGCHAR##");
  else               ffcall("CCGINT##");
  }

/*
** fetch a static memory cell into primary register
*/
getmem(lval)  int lval[]; {
  char *sym;
  sym=lval[0];
  if((sym[IDENT]!=POINTER)&(sym[TYPE]==CCHAR)) {
    ot("LDA ");
    outstr(sym+NAME);
    nl();
    ffcall("CCSXT##");
    }
  else {
    ot("LHLD ");
    outstr(sym+NAME);
    nl();
    }
  }

/*
** fetch addr of the specified symbol into primary register
*/
getloc(sym)  char *sym; {
  const(getint(sym+OFFSET, OFFSIZE)-csp);
  ol("DAD SP");
  }

/*
** store primary register into static cell
*/
putmem(lval)  int lval[]; {
  char *sym;
  sym=lval[0];
  if((sym[IDENT]!=POINTER)&(sym[TYPE]==CCHAR)) {
    ol("MOV A,L");
    ot("STA ");
    }
  else ot("SHLD ");
  outstr(sym+NAME);
  nl();
  }

/*
** put on the stack the type object in primary register
*/
putstk(lval) int lval[]; {
  if(lval[1]==CCHAR) {
    ol("MOV A,L");
    ol("STAX D");
    }
  else ffcall("CCPINT##");
  }

/*
** move primary register to secondary
*/
move() {
  ol("MOV D,H");
  ol("MOV E,L");
  }

/*
** swap primary and secondary registers
*/
swap() {
  ol("XCHG;;");		/* peephole() uses trailing ";;" */
  }

/*
** partial instruction to get immediate value
** into the primary register
*/
immed() {
  ot("LXI H,");
  }

/*
** partial instruction to get immediate operand
** into secondary register
*/
immed2() {
  ot("LXI D,");
  }

/*
** push primary register onto stack
*/
push() {
  ol("PUSH H");
  csp=csp-BPW;
  }

/*
** unpush or pop as required
*/
smartpop(lval, start) int lval[]; char *start; {
  if(lval[5])  pop();		/* secondary was used */
  else unpush(start);
  }

/*
** replace a push with a swap
*/
unpush(dest) char *dest; {
  int i;
  char *sour;
  sour="XCHG;;";		/* peephole() uses trailing ";;" */
  while(*sour) *dest++ = *sour++;
  sour=stagenext;
  while(--sour > dest) {	/* adjust stack references */
    if(streq(sour,"DAD SP")) {
      --sour;
      i=BPW;
      while(isdigit(*(--sour))) {
        if((*sour = *sour-i) < '0') {
          *sour = *sour+10;
          i=1;
          }
        else i=0;
        }
      }
    }
  csp=csp+BPW;
  }

/*
** pop stack to the secondary register
*/
pop() {
  ol("POP D");
  csp=csp+BPW;
  }

/*
** swap primary register and stack
*/
swapstk() {
  ol("XTHL");
  }

/*
** process switch statement
*/
sw() {
  ffcall("CCSWITCH##");
  }

/*
** call specified subroutine name
*/
ffcall(sname)  char *sname; {
  ot("CALL ");
  outstr(sname);
  nl();
  }

/*
** return from subroutine
*/
ffret() {
  ol("RET");
  }

/*
** perform subroutine call to value on stack
*/
callstk() {
  ffcall("CCDCAL##");
  }

/*
** jump to internal label number
*/
jump(label)  int label; {
  ot("JMP ");
  printlabel(label);
  nl();
  }

/*
** test primary register and jump if false
*/
testjump(label)  int label; {
  ol("MOV A,H");
  ol("ORA L");
  ot("JZ ");
  printlabel(label);
  nl();
  }

/*
** test primary register against zero and jump if false
*/
zerojump(oper, label, lval) int (*oper)(), label, lval[]; {
  clearstage(lval[7], 0);	/* purge conventional code */
  (*oper)(label);
  }

/*
** define storage according to size
*/
defstorage(size) int size; {
  if(size==1) ot("DB ");
  else        ot("DW ");
  }

/*
** point to following object(s)
*/
point() {
  ol("DW $+2");
  }

/*
** modify stack pointer to value given
*/
modstk(newsp, save)  int newsp, save; {
  int k;
  k=newsp-csp;
  if(k==0)return newsp;
  if(k>=0) {
    if(k<7) {
      if(k&1) {
        ol("INX SP");
        k--;
        }
      while(k) {
        ol("POP B");
        k=k-BPW;
        }
      return newsp;
      }
    }
  if(k<0) {
    if(k>-7) {
      if(k&1) {
        ol("DCX SP");
        k++;
        }
      while(k) {
        ol("PUSH B");
        k=k+BPW;
        }
      return newsp;
      }
    }
  if(save) swap();
  const(k);
  ol("DAD SP");
  ol("SPHL");
  if(save) swap();
  return newsp;
  }

/*
** double primary register
*/
doublereg() {ol("DAD H");}

