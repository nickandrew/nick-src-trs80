/* fmerge:
 *  merge CATALOG/NEW and FILELIST/ZMS into CATALOG/UPD
 *  Unknowns filed in CATALOG/UNK
 */

#include <stdio.h>
#define MAX 250
struct f {  char name[13];
            char date[10];
            char volu[8];
            char xxxx;
         };

struct f farr[MAX];

char linein[100];
FILE *fpin,*fpf,*fpout,*fpunk;

main() {
   int  i,c;
   fpin=fopen("catalog/new","r");
   fpout=fopen("catalog/upd:1","w");
   fpf=fopen("filelist/zms","r");
   fpunk=fopen("catalog/unk","w");
   if (fpin==NULL || fpout==NULL || fpf==NULL || fpunk==NULL)
      exit(2);

   while (rf()==0);

   while (readin()==0) {
      writeout(rearr() ? fpout : fpunk);
   }
   scopy("abcdefgh/ext dd-mmm-yy ? ? ? Unknown.\n",linein,39);
   for(i=0;i<MAX;i++) writerest(i);
   for(i=0;i<MAX;i++) farr[i].name[0]=0;
   while (rf()==0);
   for(i=0;i<MAX;i++) writerest(i);

fclose(fpout);
fclose(fpin);
fclose(fpf);
fclose(fpunk);
}

rf() {
   char *cp;
   int  i=0,j=0,c;
   while (j<MAX) {
      if (*(farr[j].name)==0) break;
      j++;
   }


   printf("%d ",j);
   if (j==MAX) return 2;
   cp= &farr[j];
   c=getc(fpf);
   if (c==EOF) return 2;
   while (1) {
      *(cp++)=c;
      if (++i ==32) break;
      c=getc(fpf);
   }
   return 0;
}

readin() {
   int  i,c;
   char *cp;
   cp=linein;
   c=getc(fpin);
   if (c==EOF) return 1;
   while (1) {
      *(cp++)=c;
      if (c=='\n') break;
      c=getc(fpin);
   }

   putchar('l');
   *(cp++)=0;
   return 0;
}


writeout(f)
FILE *f;
{
   int  i,c;
   char *cp;
   cp=linein;
   while (*cp) putc(*(cp++),f);
   putchar('w');
}

rearr() {
   int  i,j=0,c;
   char *cp;

   for (i=0;i<MAX;i++) {
      if (scmp(farr[i].name,linein+0,12)==0) {
         farr[i].name[0]=0;
         scopy(farr[i].date,linein+13,9);
         rf();
         j=1;
         putchar('e');
         break;
      }
   }
   return (j);
}


scmp(cp1,cp2,len)
char *cp1,*cp2;
int  len;
{
   int  i=0;
   while (i<len) {
      if (*(cp1++) != *(cp2++)) return 1;
      i++;
   }
return 0;
}

scopy(cpi,cpo,len)
char *cpi,*cpo;
int  len;
{
   int  i=0;
   while (i<len) {
      *(cpo++)= *(cpi++);
      i++;
   }
}

writerest(i)
int i;
{
   scopy(farr[i].name,linein,12);
   scopy(farr[i].date,linein+13,9);
   if (farr[i].name[0]!=0) writeout(fpout);
}

