/*  LC source code optimizer
 *  (C) 1986, Nick.
 *  (For Alcor C)
 */

#include <stdio.h>

FILE *fpin,*fpout;

char line1[64],line2[64],line3[64];
char *line[4] = { NULL, line1, line2, line3 };

int cyc[4] = { 0,0,0,0 };

main(argc,argv)
int argc;
char *argv[];
{
   if (argc!=3) {
      printf("Usage: LCOPT filein fileout\n");
      exit(1);
   }

   fpin=fopen(argv[1],"r");
   fpout=fopen(argv[2],"w");

   if (fpin==NULL || fpout==NULL) {
      printf("LCOPT: Can't open files\n");
      exit(2);
   }


   while (readline()) {
      opt1();
      opt2();
      opt3();
      cycle(3);
   }

   while (cycle(1));
}

readline() {
   int  i,c;
   char *cp;
   do {
      for (i=1;(i<4 && cyc[i]!=0) ;i++);
      if (i==4) cycle(1);
   } while (i==4);

   cp=line[i];
   cyc[i]=1;
   c=getc(fpin);
   while (c!=EOF && c!='\n') {
      *(cp++) =c;
      c=getc(fpin);
   }
   if (c!=EOF) *(cp++) =0;
   return (c!=EOF);
}

cycle(x) {
   char *cp;
   if (cyc[1]==0) return 0;
   if (cyc[x]==0) return 0;
   cp=line[1];
   while (*cp) {
      putc(*cp++,fpout);
   }

   putc('\n',fpout);

   strcpy(line[1],line[2]);
   strcpy(line[2],line[3]);
   strcpy(line[3],"");

   cyc[1]=cyc[2];
   cyc[2]=cyc[3];
   cyc[3]=0;
}

opt1() {
   /* check for:     PUSH HL
    *                LD HL,n
    *                POP DE
    * change to:
    *                EX DE,HL
    *                LD HL,n
    */

   if (cyc[3]==0) return;
   if (strcmp(line1,"\tPUSH\tHL")) return;
   if (!ststr(line2,"\tLD\tHL,")) return;
   if (strcmp(line3,"\tPOP\tDE")) return;
   strcpy(line1,"\tEX\tDE,HL");
   strcpy(line3,"");
   cyc[3]=0;
   putchar('!');
}

opt2() {
   if (cyc[3]==0) return;
   if (!ststr(line1,"\tLD\tHL,")) return;
   if (strcmp(line2,"\tPUSH\tHL")) return;
   if (strcmp(line3,line1)) return;
   strcpy(line3,"");
   putchar('!');
   cyc[3]=0;
}

opt3() {
   if (cyc[3]==0) return;
   if (strcmp(line1,"\tEX\tDE,HL")) return;
   if (strcmp(line3,"\tEX\tDE,HL")) return;
   if (!ststr(line2,"\tLD\tHL,")) return;
   strcpy(line2,line1);
   line1[4]='D';
   line1[5]='E';
   cyc[2]=cyc[3]=0;
   putchar('!');
}

ststr(l,s)
char *l,*s;
{
   char *cl,*cs;
   cl=l;
   cs=s;
   while (*cs == *cl) {
      cl++;
      cs++;
      if (*cs == 0) return 1;
   }
   return 0;
}

