/* rearrange current CATALOG/ZMS format so names at start */

#include <stdio.h>

char linein[100],lineout[100];
FILE *fpin,*fpout;

main()
{
   int  c;
   fpin=fopen("catalog/zms:2","r");
   fpout=fopen("catalog/new:1","w");

   if (fpin==NULL || fpout==NULL) exit(2);

   while (readin()) {
      rearr();
      writeout();
   }

   fclose(fpin);
   fclose(fpout);
}

readin() {
   int  i,c;
   char *cp;
   i=0;
   cp=linein;
   c=getc(fpin);
   while (c!=EOF && i<99 && c!='\n') {
      i++;
      *(cp++)=c;
      if (c=='\n') break;
      c=getc(fpin);
   }

   if (c=='\n') *(cp++)=0;
   if (i>99) printf("Line too long ... truncated\n");

   return (c!=EOF);
}

writeout() {
   char *cp;
   cp=lineout;
   while (*cp) putc(*(cp++),fpout);
}

rearr() {
   int  i,c;
   char *cpi,*cpo;
   for(i=0;i<100;i++) lineout[i]=' ';
   scopy(linein+16,lineout,12);
   scopy(linein+6,lineout+13,9);
   scopy(linein,lineout+23,5);
   cpi=linein+29;
   cpo=lineout+29;
   while (*cpi) *(cpo++)= (*(cpi++));
   *(cpo++)='\n';
   *(cpo++)=0;
}

scopy(cpi,cpo,len)
char *cpi,*cpo;
int  len;
{
   int  i;
   for(i=0;i<len;i++) *(cpo++) =(*(cpi++));
}

