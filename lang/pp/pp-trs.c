/*
 *
 *     PP.C: A Simple 'C' Preprocessor.
 *     Nick Andrew, 04-Oct-85.
 *     Currently understands the following commands:
 *            #include
 *            #define   (no macro expansions)
 *            #ifdef
 *            #ifndef
 *            #else
 *            #endif
 *
 */
#include STDIO/CSH
#define  MAXINCL  20
#define  LINELEN  255
#define  NAMELEN  80
#define  MAXDEFS  100
#define  DEFLEN   12
#define  MAXDEFLEN 1200
FILE *fout;                /* Output file pointer         */
int  nocomment;            /* Delete comments from source */
int  ignore;               /* True if inside false #if    */
int  line;                 /* Global line counter         */
int  is_unix;              /* Flag for Unix system        */
int  is_trs80;             /* Flag for TRS-80 system      */
int  *curr_line;           /* Current line pointer        */
int  *curr_file;           /* Current filename            */
char *curr_text;           /* Current line text of file   */
char defines[MAXDEFLEN];
int  trueif;               /* Count of true ifs           */
int  falseif;              /* Count of false ifs          */
int  numdef;               /* Number of active #defines   */
char auxname[NAMELEN];
main(argc,argv)
int  argc;
char *argv[];
{
   is_trs80=1;
   is_unix=0;
   nocomment=ignore=numdef=trueif=falseif=0;
   if (argc!=3)
      {
      printf("PP: Usage is pp infile outfile\n");
      exit(1);
      }
   if ((fout=fopen(argv[2],"w"))==NULL)
      {
      printf("pp: Can't open output file %s\n",argv[2]);
      exit(2);
      }
   process(argv[1]);
   fclose(fout);
   exit(0);
}
process(name)
char *name;
{
   FILE *fp;
   int  i,line;
   char c,thisline[255];
   line=1;
   curr_line= &line;
   curr_file=name;
   if ((fp=fopen(name,"r"))==NULL)
      {
      verberr(0,thisline,"Can't open file");
      return(0);
      }
   fprintf(fout,"# %d %s\n",line,curr_file);
   while (fgets(thisline,LINELEN,fp))
      {
      curr_text=thisline;
      if (is_trs80 && (*thisline==0x1a)) break;
      line++;
      i=0;
      while (whitencr(thisline[i])) i++;
      if (thisline[i]=='#') handlepp(thisline,fp,&i);
      else
         {
         i=0;
         while (c=thisline[i])
            {
            if (c=='\'') handlesq(thisline,&i);
            else
            if (c=='"')  handledq(thisline,fp,&i);
            else
            if ((c=='/') && (thisline[i+1]=='*'))
               handleco(thisline,fp,&i);
            else
               /* Simply output */
               { cputc(c);  i++; }
            }
         }
      }
   fclose(fp);
}
whitencr(c)
char c;
{
   return((c==' ') || (c=='\t') || (c=='\f'));
}
white(c)
char c;
{
   return(whitencr(c) || (c=='\n'));
}
handlesq(string,ip)
int  *ip;
char string[];
{
   char *cp;
   cp=string+*ip;
   cputc(*(cp++));
   if (*cp=='\\')
      {
      if (escchr(*(++cp)))
         {
         cputc('\\');
         cputc(*cp);
         if (isoctal(*(cp++)))
            {
            int  i;
            i=0;
            while ((i++ < 2) && isoctal(*cp))
               cputc(*(cp++));
            }
         }
      else cputc(*(cp++));
      }
   else if (*cp=='\'') verberr(0,curr_text,"Character '' ?");
        else cputc(*(cp++));
   if (*cp!='\'') 
      error("Character constant not terminated properly\n");
   cputc(*(cp++));
   *ip=cp-string;
}
escchr(c)
char c;
{
   return((c=='n') || (c=='t') || (c=='b') || (c=='r') ||
          (c=='f') || (c=='\\')|| (c=='\'')|| isoctal(c) );
}
isoctal(c)
char c;
{
   return( (c>='0') && (c<='7'));
}
handledq(string,fp,ip)
char string[];
FILE *fp;
int  *ip;
{
   char *cp;
   cp=string+*ip;
   cputc(*(cp++));
   while (*cp && (*cp!='"'))
      cputc(*(cp++));
   while (!*cp)
      {
      (*curr_line)++;
      if (!fgets(string,LINELEN,fp)) error("EOF within string\n");
      cp=curr_text=string;
      while (*cp && (*cp!='"'))
         cputc(*(cp++));
      }
   cputc(*(cp++));
   *ip=cp-string;
}
handleco(string,fp,ip)
char string[];
FILE *fp;
int  *ip;
{
   char *cp,ch1;
   cp=string+*ip;
   ch1=0;
   cputc(*(cp++));
   cputc(*(cp++));
   while (*cp && ((*cp!='/') || (ch1!='*')))
      cputc(ch1=(*(cp++)));
   while (!*cp)
      {
      (*curr_line)++;
      if (!fgets(string,LINELEN,fp)) error("EOF within comment\n");
      cp=curr_text=string;
      while (*cp && ((*cp!='/') || (ch1!='*')))
         cputc(ch1=(*(cp++)));
      }
   *ip=cp-string;
}
handlepp(string,fp,ip)
char string[];
FILE *fp;
int  *ip;
{
   char *cp,preproc[8];
   int  i;
   cp=string+*ip;
   while (whitencr(*(++cp)));
   if (!*cp || (*cp=='\n')) error("No preprocessor cmd!\n");
   i=0;
   while (*cp && !white(*cp)) preproc[i++]=(*(cp++));
   preproc[i]=0;
   if      (!strcmp(preproc,"include")) hinclude(cp);
   else if (!strcmp(preproc,"define" )) hdefine(cp);
   else if (!strcmp(preproc,"if"     )) hif(cp);
   else if (!strcmp(preproc,"ifdef"  )) hifdef(cp);
   else if (!strcmp(preproc,"ifndef" )) hifndef(cp);
   else if (!strcmp(preproc,"else"   )) helse(cp);
   else if (!strcmp(preproc,"line"   )) hline(cp);
   else if (!strcmp(preproc,"endif"  )) hendif(cp);
   else if (!ignore)  fputs(string,fout);
}
hinclude(cp)
char *cp;
{
   char delim,file[NAMELEN],stddir[NAMELEN],*fname,*last_file;
   int  i,*last_line;
   while (*cp && white(*cp)) cp++;
   delim=0;
   if (*cp=='<') delim='>';
   if (*cp=='"') delim='"';
   if (delim) cp++;
   i=0;
   while ((i<NAMELEN) && (*cp!=delim) && (!white(*cp)))
      file[i++]= (*(cp++));
   if (i=NAMELEN) error("Include filename too long\n");
   file[i]=0;
   fname=file;
   if (is_trs80 && !strcmp(file,"stdio.h")) fname="STDIO/CSH";
   if (is_unix && (delim=='>'))
      {
      /* Prepend standard unix search directory */
      strcpy(stddir,"/usr/include/");
      strcat(stddir,fname);
      fname=stddir;
      }
   last_line=curr_line;
   last_file=curr_file;
   process(fname);
   fprintf(fout,"# %d %s\n",*last_line,last_file);
}
error(str1,str2)
char *str1,*str2;
{
   printf(str1,str2);
   exit(-1);
}
verberr(flag,str1,str2)
char *str1,*str2;
int  flag;
{
   printf("\n%s",str1);
   printf("'%s', line %d, %s\n",curr_file,*curr_line,str2);
   if (flag) exit(flag);
}
cputc(c)
char c;
{
   if (!ignore) putc(c,fout);
}
hif(cp)
char *cp;
{
   verberr(1,curr_text,"#if construct not supported");
}
hdefine(cp)
char *cp;
{
   int  i;
   if (ignore) return;
   if (numdef==MAXDEFS)
      verberr(1,curr_text,"Too many #defines");
   while (*cp && white(*cp)) cp++;
   i=0;
   while (i<(DEFLEN-1) && !white(*cp) && *cp)
      defines[numdef*DEFLEN + i++]= *(cp++);
   defines[numdef*DEFLEN + i]=0;
   printf("Defined: %s\n",&defines[numdef*DEFLEN]);
   numdef++;
   fputs(curr_text,fout);
   /* Put #define in output for constant replacement */
}
hifdef(cp)
char *cp;
{
   int  i;
   char thisdef[DEFLEN];
   if (ignore)
      {
      falseif++;
      return;
      }
   while (*cp && white(*cp)) cp++;
   i=0;
   while (i<(DEFLEN-1) && !white(*cp) && *cp)
      thisdef[i++]= *(cp++);
   thisdef[i]=0;
   i=0;
   while (i<numdef)
      {
      if (strcmp(thisdef,&defines[i++ * DEFLEN])) continue;
      printf("T: %s",curr_text);
      trueif++;
      return;
      }
   printf("F: %s",curr_text);
   falseif++;
   ignore=1;
   return;
}
hifndef(cp)
char *cp;
{
   int  i;
   char thisdef[DEFLEN];
   if (ignore)
      {
      falseif++;
      return;
      }
   while (*cp && white(*cp)) cp++;
   i=0;
   while (i<(DEFLEN-1) && !white(*cp) && *cp)
      thisdef[i++]= *(cp++);
   i=0;
   while (i<numdef)
      {
      if (strcmp(thisdef,&defines[i++ * DEFLEN])) continue;
      printf("F: %s",curr_text);
      falseif++;
      ignore=1;
      return;
      }
   printf("T: %s",curr_text);
   trueif++;
   return;
}
helse(cp)
char *cp;
{
   if (trueif==0 && falseif==0)
      verberr(1,curr_text,"No matching #if");
   if (falseif)
      {
      if (falseif==1)
         {
         trueif=1;
         falseif=ignore=0;
         }
      return;
      }
   trueif--;
   falseif++;
   ignore=1;
}
hendif(cp)
char *cp;
{
   if (trueif==0 && falseif==0)
      verberr(1,curr_text,"No matching #if");
   if (falseif)
      {
      if (!(--falseif)) ignore=0;
      return;
      }
   trueif--;
}
hline(cp)
char *cp;
{
   printf("#line definition not supported\n");
}
