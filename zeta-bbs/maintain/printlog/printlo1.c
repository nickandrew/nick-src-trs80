/* Printlog/C: Zeta Rtrs logfile printer program
 * Ver 1.0  on 16-Nov-85
 */

#include <stdio.h>

#define  LOG1     "log/zms"
#define  LOG2     "xferlog/zms"

FILE  *fpin,*fpout;
char  logx=0,logp=1;
char  *fout,*fin;
int   lpp,lines,nlines,nsaved=0,i=0,c;
char  line1[80],line2[80],linen[66][80];

main(argc,argv)
int  argc;
char *argv[];
{
   fout=":l";        /* Alcor C line printer */
   lpp=58;           /* 60 lines/page - 2    */

   while (--argc)
      {
      if (**(++argv) == '-')
         switch(argv[0][1])
            {
            case 'X' : logx=1;
                       break;

            case 'F' : fout= *(++argv); argc--; logp=0;
                       break;

            case 'P' : lpp=atoi(*(++argv))-2; argc--;
                       break;
            }
      }
   fin = (logx ? LOG2 : LOG1);
   if ((fpin=fopen(fin,"r"))==NULL)
      {
      printf("printlog: Can't open %s\n",fin);
      exit(1);
      }
   if (fgets(line1,80,fpin)==NULL)
      {
      printf("printlog: File %s empty\n",fin);
      exit(2);
      }
   if (fgets(line2,80,fpin)==NULL)
      {
      printf("printlog: File %s has only 1 line\n",fin);
      exit(2);
      }

   lines = 0;
   while ((c=getc(fpin))!=EOF)
      if (c=='\n') lines++;
   printf("printlog: %d lines in file %s\n",lines,fin);

   if (lines<lpp)
      {
      printf("printlog: No output phase - file too short\n");
      exit(0);
      }

   if ((fpout=fopen(fout,"w"))==NULL)
      {
      printf("printlog: Can't open output %s\n",fout);
      exit(2);
      }
   if (!logp) printf("printlog: Writing to %s\n",fout);
   nlines= lpp*(lines/lpp);
   fclose(fpin);
   if ((fpin=fopen(fin,"r"))==NULL)
      {
      printf("printlog: Can't re-open %s\n",fin);
      exit(1);
      }

   while(getc(fpin)!='\n'); /* bypass title 1 */
   while(getc(fpin)!='\n'); /* bypass title 2 */

   for(i=0;i<nlines;i++)
      {
      if (!(i%lpp))
         {
         fputs(line1,fpout); fputs(line2,fpout);
         }
      while (putc(getc(fpin),fpout)!='\n');
      }

   /* finished output - save rest of file in memory */
   while (fgets(linen[nsaved++],80,fpin)!=NULL);
   fclose(fpout);
   fclose(fpin);

   /* rewrite log file with titles and unprinted data */
   if ((fpin=fopen(fin,"w"))==NULL)
      {
      printf("printlog: Can't re-re-open %s\n",fin);
      exit(1);
      }
   fputs(line1,fpin);
   fputs(line2,fpin);
   for (i=0;i<nsaved;i++) fputs(linen[i],fpin);
   fclose(fpin);

   printf("printlog: finished\n");
   exit(0);
}

