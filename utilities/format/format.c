/* format.c : produce wraparound output from a file.
 * (C) 1986, Nick. Ver 1.0 on 20-Jul-86
 * Environment: Standard 'C'.
 */

#include <stdio.h>

int  width=31;

main(argc,argv)
int  argc;
char *argv[];
{
   FILE *fpin;
   int i;

   for(i=0;i<61;i++) printf(i%10 ? "-" : "+");
   putchar('\n');

   if (argc!=2) {
      printf("Usage: FORMAT infile\n");
      exit(1);
   }

   if ((fpin=fopen(argv[1],"r"))==NULL) {
      printf("Cannot open %s\n",argv[1]);
      exit(1);
   }

   format(fpin);
   printf("<---EOF\n");
}

format(fp)
FILE *fp;
{
   char buffer[81];
   int  i,bp,j,jj;
   int  c,lastc,newc;

   bp=buffer[0]=0;
   newc='x';

   while (1) {

      lastc=newc;
      if ((c=getc(fp))==EOF) return;
      newc=c;

      if (c=='\n') c=' ';

      if ((lastc=='\n') && ((c==' ') || (c=='>'))) {
         puts(buffer);
         buffer[0]=0;
         bp=0;
      }

      buffer[bp]=c;
      buffer[++bp]=0;
      if (bp>width) {
         jj=width;
         while ((jj>=0) && (buffer[jj]!=' ')) --jj;
         if (jj<0) {        /* write whole thing (one word) */
            puts(buffer);
            buffer[0]=0;
            bp=0;
            continue;
         }

         for (j=0;j<jj;++j) putchar(buffer[j]);
         putchar('\n');

         strcpy(buffer,&buffer[jj+1]);
         for (j=0;buffer[j]!=0;++j);
         bp=j;
      }
   }
}

