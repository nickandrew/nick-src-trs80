/* cpack: Pack a C source program given advance knowledge
 *        about the word usage (ie. reserved words).
 * (C) Nick '85
 */

#include <stdio.h>

#define  SUFFIX1     "/C"    /* C source */
#define  SUFFIX2     "/T"    /* cpack'ed non-C source ?? */
#define  SUFFIX3     "/CT"   /* cpack'ed C source */
#define  REPEATS     '\032'
#define  REPEATT     '\033'

FILE *fpin,*fpout;
char string[80];
char *resvd[] =
   {  "int",      "char",     "float",   "double",   "struct",
      "union",    "long",     "short",   "unsigned", "auto",
      "extern",   "register", "typedef", "static",   "goto",
      "return",   "sizeof",   "break",   "continue", "if",
      "else",     "for",      "do",      "while",    "switch",
      "case",     "default",  "entry",   "#define",  "#undef",
      "#include", "#if",      "#ifdef",  "#ifndef",  "#else",
      "#endif",   "#line",    "EOF",     "NULL",     "FILE",
      "getc",     "getchar",  "putc",    "putchar",  "fopen",
      "fclose",   "exit",
      "printf",   "fprintf",  "read",    "write",    NULL

   };


main(argc,argv)
int  argc;
char *argv[];
{
   int  bad_packs = 0;
   if (argc == 1)
      {
      fprintf(stderr,"usage: cpack [sourcefile.c] ...\n");
      exit(-1);
      }

   while (--argc)
      bad_packs += pack(*(++argv));

   exit(bad_packs);
}

pack(file)
char *file;
{
   int  len,c;
   char newfile[80];

   if ((fpin=fopen(file,"r"))==NULL)
      {
      fprintf(stderr,"cpack: can't open %s\n",file);
      exit(1);
      }
   *newfile=0;
   strcat(newfile,file);
   len=strlen(newfile);
   if (!strcmp(&newfile[len-2],SUFFIX1))
         strcpy(&newfile[len-2],SUFFIX3);
   else  strcat(newfile,SUFFIX2);
   if ((fpout=fopen(newfile,"w"))==NULL)
      {
      fprintf(stderr,"cpack: Can't open %s\n",file);
      exit(1);
      }
   printf("New filename is %s\n",newfile);

   while ((c=putchar(getc(fpin)))!=EOF)
      {
      switch(c)
          {
          case ' ' :    spaces();
                        break;
          case '\t':    tabs();
                        break;
          case '"' :    dquote();
                        break;
          case '\'':    squote();
                        break;
          case '/' :    acomment();
                        break;
          default  :    anychar(c);
          }
      }
   fclose(fpin);
   fclose(fpout);
}

spaces()
{
   int  i,j,c;
   i=1;
   while ((c=getc(fpin))==' ') i++;
   ungetc(c,fpin);
   while ( i > 2)
      {
      j=(i>255 ? 255 : i);
      i-=j;
      putc(REPEATS,fpout);
      putc(j,fpout);
      }
   while (i--) putc(' ',fpout);
}

tabs()
{
   int  i,j,c;
   i=1;
   while ((c=getc(fpin))==' ') i++;
   ungetc(c,fpin);
   while ( i > 2)
      {
      j=(i>255 ? 255 : i);
      i-=j;
      putc(REPEATT,fpout);
      putc(j,fpout);
      }
   while (i--) putc('\t',fpout);
}

dquote()
{
   int  c;
   putc('"',fpout);
   while ( (c=getc(fpin)) !='"' && c!=EOF)
      {
      putc(c,fpout);
      if (c=='\\') backslsh();
      }
   putc('"',fpout);
}

squote()
{
   int  c;
   while ((c=getc(fpin))!='\'' && c!=EOF)
      {
      putc(c,fpout);
      if (c=='\\') backslsh();
      }
   putc('\'',fpout);
}

anychar(c)
int  c;
{
   int  i=0,j=0;
   while (c=='#' || (c>='a' && c<='z') || (c>='A' && c<='Z'))
      {
      /* build a string */
      string[i++]=c;
      c=getc(fpin);
      }
   string[i]=0;
   if (i!=0)
      {
      ungetc(c,fpin);
      j= -1;
      do
         {
         if (!strcmp(string,resvd[++j]))
            {
            putc(j+128,fpout);
            break;
            }
         }
      while (strcmp(string,resvd[j]) && resvd[j]!=NULL);
      if (resvd[j]==NULL) fputs(string,fpout);
      }
   else
      putc(c,fpout);
}

backslsh()
{
   int  c;
   putc('\\',fpout);
   if ((c=getc(fpin))==EOF) return;
   putc(c,fpout);
   if (c>='0' && c<='9')
      {
      putc(getc(fpin),fpout);
      putc(getc(fpin),fpout);
      }
}

acomment()
{
   int c,c_l;
   putc('/',fpout);
   if ((c=getc(fpin))!='*')
      {
      ungetc(c,fpin);
      return;
      }
   do
      {
      putc(c,fpout);
      c_l=c;
      c=getc(fpin);
      }
   while (c!=EOF && !(c=='/' && c_l=='*'));
   if (c!=EOF) putc(c,fpout);
}

