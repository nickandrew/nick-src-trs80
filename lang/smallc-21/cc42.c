/*
** add primary and secondary registers (result in primary)
*/
ffadd() {ol("DAD D");}

/*
** subtract primary from secondary register (result in primary)
*/
ffsub() {ffcall("CCSUB##");}

/*
** multiply primary and secondary registers (result in primary)
*/
ffmult() {ffcall("CCMULT##");}

/*
** divide secondary by primary register
** (quotient in primary, remainder in secondary)
*/
ffdiv() {ffcall("CCDIV##");}

/*
** remainder of secondary/primary
** (remainder in primary, quotient in secondary)
*/
ffmod() {ffdiv();swap();}

/*
** inclusive "or" primary and secondary registers
** (result in primary)
*/
ffor() {ffcall("CCOR##");}

/*
** exclusive "or" the primary and secondary registers
** (result in primary)
*/
ffxor() {ffcall("CCXOR##");}

/*
** "and" primary and secondary registers
** (result in primary)
*/
ffand() {ffcall("CCAND##");}

/*
** logical negation of primary register
*/
lneg() {ffcall("CCLNEG##");}

/*
** arithmetic shift right secondary register
** number of bits given in primary register
** (result in primary)
*/
ffasr() {ffcall("CCASR##");}

/*
** arithmetic shift left secondary register
** number of bits given in primary register
** (result in primary)
*/
ffasl() {ffcall("CCASL##");}

/*
** two's complement primary register
*/
neg() {ffcall("CCNEG##");}

/*
** one's complement primary register
*/
com() {ffcall("CCCOM##");}

/*
** increment primary register by one object of whatever size
*/
inc(n) int n; {
  while(1) {
    ol("INX H");
    if(--n < 1) break;
    }
  }

/*
** decrement primary register by one object of whatever size
*/
dec(n) int n; {
  while(1) {
    ol("DCX H");
    if(--n < 1) break;
    }
  }
 
/*
** test for equal to
*/
ffeq()  {ffcall("CCEQ##");}

/*
** test for equal to zero
*/
eq0(label) int label; {
  ol("MOV A,H");
  ol("ORA L");
  ot("JNZ ");
  printlabel(label);
  nl();
  }

/*
** test for not equal to
*/
ffne()  {ffcall("CCNE##");}

/*
** test for not equal to zero
*/
ne0(label) int label; {
  ol("MOV A,H");
  ol("ORA L");
  ot("JZ ");
  printlabel(label);
  nl();
  }

/*
** test for less than (signed)
*/
fflt()  {ffcall("CCLT##");}

/*
** test for less than to zero
*/
lt0(label) int label; {
  ol("XRA A");
  ol("ORA H");
  ot("JP ");
  printlabel(label);
  nl();
  }

/*
** test for less than or equal to (signed)
*/
ffle()  {ffcall("CCLE##");}

/*
** test for less than or equal to zero
*/
le0(label) int label; {
  ol("MOV A,H");
  ol("ORA L");
  ol("JZ $+8");
  ol("XRA A");
  ol("ORA H");
  ot("JP ");
  printlabel(label);
  nl();
  }

/*
** test for greater than (signed)
*/
ffgt()  {ffcall("CCGT##");}

/*
** test for greater than to zero
*/
gt0(label) int label; {
  ol("XRA A");
  ol("ORA H");
  ot("JM ");
  printlabel(label);
  nl();
  ol("ORA L");
  ot("JZ ");
  printlabel(label);
  nl();
  }

/*
** test for greater than or equal to (signed)
*/
ffge()  {ffcall("CCGE##");}

/*
** test for gteater than or equal to zero
*/
ge0(label) int label; {
  ol("XRA A");
  ol("ORA H");
  ot("JM ");
  printlabel(label);
  nl();
  }

/*
** test for less than (unsigned)
*/
ult()  {ffcall("CCULT##");}

/*
** test for less than to zero (unsigned)
*/
ult0(label) int label; {
  ot("JMP ");
  printlabel(label);
  nl();
  }

/*
** test for less than or equal to (unsigned)
*/
ule()  {ffcall("CCULE##");}

/*
** test for greater than (unsigned)
*/
ugt()  {ffcall("CCUGT##");}

/*
** test for greater than or equal to (unsigned)
*/
uge()  {ffcall("CCUGE##");}

#ifdef OPTIMIZE
peephole(ptr) char *ptr; {
  while(*ptr) {
    if(streq(ptr,"LXI H,0\nDAD SP\nCALL CCGINT##")) {
      if(streq(ptr+29, "XCHG;;")) {pp2();ptr=ptr+36;}
      else                        {pp1();ptr=ptr+29;}
      }
    else if(streq(ptr,"LXI H,2\nDAD SP\nCALL CCGINT##")) {
      if(streq(ptr+29, "XCHG;;")) {pp3(pp2);ptr=ptr+36;}
      else                        {pp3(pp1);ptr=ptr+29;}
      }
    else if(optimize) {
      if(streq(ptr, "DAD SP\nCALL CCGINT##")) {
        ol("CALL CCDSGI##");
        ptr=ptr+21;
        }
      else if(streq(ptr, "DAD D\nCALL CCGINT##")) {
        ol("CALL CCDDGI##");
        ptr=ptr+20;
        }
      else if(streq(ptr, "DAD SP\nCALL CCGCHAR##")) {
        ol("CALL CCDSGC##");
        ptr=ptr+22;
          }
      else if(streq(ptr, "DAD D\nCALL CCGCHAR##")) {
        ol("CALL CCDDGC##");
        ptr=ptr+21;
        }
      else if(streq(ptr,
        "DAD SP\nMOV D,H\nMOV E,L\nCALL CCGINT##\nINX H\nCALL CCPINT##")) {
        ol("CALL CCINCI##");
        ptr=ptr+57;
        }
      else if(streq(ptr,
        "DAD SP\nMOV D,H\nMOV E,L\nCALL CCGINT##\nDCX H\nCALL CCPINT##")) {
        ol("CALL CCDECI##");
        ptr=ptr+57;
        }
      else if(streq(ptr,
        "DAD SP\nMOV D,H\nMOV E,L\nCALL CCGCHAR##\nINX H\nMOV A,L\nSTAX D")) {
        ol("CALL CCINCC##");
        ptr=ptr+59;
        }
      else if(streq(ptr,
        "DAD SP\nMOV D,H\nMOV E,L\nCALL CCGCHAR##\nDCX H\nMOV A,L\nSTAX D")) {
        ol("CALL CCDECC##");
        ptr=ptr+59;
        }
      else if(streq(ptr, "DAD D\nPOP D\nCALL CCPINT##")) {
        ol("CALL CDPDPI##");
        ptr=ptr+26;
        }
      else if(streq(ptr, "DAD D\nPOP D\nMOV A,L\nSTAX D")) {
        ol("CALL CDPDPC##");
        ptr=ptr+27;
        }
      else if(streq(ptr, "POP D\nCALL CCPINT##")) {
        ol("CALL CCPDPI##");
        ptr=ptr+20;
        }
      /* additional optimizing logic goes here */
      else cout(*ptr++, output);
      }
    else cout(*ptr++, output);
    }
  }

pp1() {
  ol("POP H");
  ol("PUSH H");
  }

pp2() {
  ol("POP D");
  ol("PUSH D");
  }

pp3(pp) int (*pp)(); {
  ol("POP B");
  (*pp)();
  ol("PUSH B");
  }
#endif
