/* Gettok.c: Get the BASIC tokens out of ROM.
 */

#include <stdio.h>

main()
{
   int  toknum,labelnum,i;
   FILE *fp;
   char *locn,name[10];

   if ((fp=fopen("tokens/asm","w"))==NULL) exit(0);
   locn = (char *) 0x1650;
   for (labelnum=1,toknum=128;toknum<251;toknum++,labelnum++)
      {
      i=1;
      *name = (*(locn++) & 0x7f);
      while (*locn < 0x80)
        name[i++] = *(locn++);
      name[i]=0;

      fprintf(fp,"TOK_%d\tDEFM\t'%s',0\n",labelnum,name);
      printf("%5d %s\n",labelnum,name);
      }
   fclose(fp);
}

