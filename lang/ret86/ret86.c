/*
 * RET86/C: Change RETZ & RETNZ instructions to 8086.
 */

#include <stdio.h>

main(argc,argv)
char *argv[];
int  argc;
{
   FILE *fpin,*fpout,*fopen();
   char  line[80];
   int   retc=1;
   if (argc!=3) exit(-1);
   printf("Ret86\n");

   if ((fpin=fopen(argv[1],"r"))==NULL ||
       (fpout=fopen(argv[2],"w"))==NULL)
      printf("Ret86: Couldn't open %s or %s\n",
             argv[1],argv[2]);

/*  process  */
   while (1) {
      fgets(line,80,fpin);
      if (*line == 0) break;
      if (strcmp(line,"\tretnz\n")) {
         fputs(line,fpout);
         continue;
      }
      fprintf(fpout,"\tjz\trnz_%d\n",retc);
      fprintf(fpout,"\tret\n");
      fprintf(fpout,"rnz_%d:\n",retc++);
   }
   printf("Ret86: Finished.\n");
}

