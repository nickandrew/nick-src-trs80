/*
 * Useful SORT program
 * Generic 'C'
 * (C) 1986, Nick Andrew
 */

#include <stdio.h>

#define SORTBUF 5000
#define MAXREC  200

char *work1, *work2, *temp;
FILE *fpw1,  *fpw2,  *fpin;
int  i, j,   numrecs;
char *list[MAXREC];
char buf[SORTBUF];
char *cp;
int  c, ondisk, eofin,  norecs;

main(argc,argv)
int argc;
char *argv[];
{
   char c;

   if (argc!=2) {
      fprintf(stderr,"Usage: SORT infile\n");
      exit(129);
   }

   fpin=fopen(argv[1],"r");

   if (fpin==NULL) {
      fprintf(stderr,"Sort: Can't open %s\n",argv[1]);
      exit(130);
   }

   work1="sortwrk1";
   work2="sortwrk2";
   fpw1=fopen(work1,"w");
   fpw2=fopen(work2,"w");

   if (fpw1==NULL || fpw2==NULL) {
      fprintf(stderr,"Sort: Can't open work files\n");
      exit(131);
   }

   fclose(fpw1);
   fclose(fpw2);

   ondisk=eofin=0;

   readrecs();

   while (!norecs) {
      sort();

      if (!eofin) {
         merge(work1,work2,NULL);
         temp=work1;
         work1=work2;
         work2=temp;
         readrecs();
      }
         else norecs=1;

   }
    fprintf(stderr,"Final merge\n");
   merge(work1,NULL,stdout);
}

readrecs() {
   norecs=1;
   numrecs=0;
   cp=(&buf[0]);

   while (   (cp-buf+100 <SORTBUF)
          && (!eofin)
          && (numrecs<MAXREC) ) {
      list[numrecs]=cp;
      c=getc(fpin);
      while (c!=EOF && c!='\n') {
         *(cp++)=c;
         c=getc(fpin);
      }
      if (c=='\n') {
         norecs=0;
         numrecs++;
         *(cp++)=0;
      }
      if (c==EOF) {
         eofin=1;
      }
   }
fprintf(stderr,"read %d records\n",numrecs);
}

sort() {
   int swap=1;
   char *temp;
   if (numrecs==0) return;
   i=numrecs-1;
   while (swap) {
      swap=0;
      for (j=0;j<i;j++) {
         if (strcmp(list[j],list[j+1])>0) {
            swap=1;
            temp=list[j];
            list[j]=list[j+1];
            list[j+1]=temp;
         }
      }
      i--;
   }
}


merge(in,out,fp)
char *in,*out;
FILE *fp;
{
   FILE *fpin,*fpout;
   char filestr[256],fileflag,*bufptr;
   if (out!=NULL) fpout=fopen(out,"w");
      else fpout=fp;
   fpin=fopen(in,"r");
   fileflag=0;
   i=0;
   if (numrecs==0) bufptr=NULL;
      else bufptr=list[0];
   if (fgets(filestr,256,fpin)==NULL) {
      fileflag=1;
      *filestr=0;
   }
   for (j=0;filestr[j]!='\n';j++) ;
   filestr[j]=0;
   while ((!fileflag) || (bufptr!=NULL)) {
      if (fileflag || (strcmp(filestr,bufptr)>0)) {
         fputs(bufptr,fpout);
         putc('\n',fpout);
         i++;
         if (i==numrecs) bufptr=NULL;
            else bufptr=list[i];
         continue;
      }

      else {
         fputs(filestr,fpout);
         putc('\n',fpout);
         if (fgets(filestr,256,fpin)==NULL) fileflag=1;
         for (j=0;filestr[j]!='\n';j++) ;
         if (fileflag) j=3;
         if (!fileflag) filestr[j]=0;
         continue;
      }

   }
   if (fp==NULL) fclose(fpout);
   fclose(fpin);
}

