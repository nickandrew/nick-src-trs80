/*
 * Asmclean/c: Cleans up /ASM files
 * (C) 1986, Nick.
 *
 */

#include <stdio.h>

char line[200],lineout[200];
FILE *fpin,*fpout;

main(argc,argv)
int  argc;
char *argv[];
{
   fpin=fopen(argv[1],"r");
   fpout=fopen(argv[2],"w");
   if (fpin==NULL || fpout==NULL) {
      printf("Couldn't open files\n");
      exit(0);
   }

   printf("Files opened OK \n");
   while (1) {
      if (getlin()!=0) break;
      putchar('.');
      clean();
      putlin();
   }
putc(0x1a,fpout);
exit(0);
}

getlin()
{
   char c,*cp;
   cp=line;
   if ((c=getc(fpin))==EOF) return 1;
   if (c==0) return 1;
   while (c != '\n') {
      *(cp++) = c;
      c=getc(fpin);
   }
*(cp++)=0;
return 0;
}

putlin()
{
   char c,*cp;
   cp=lineout;
   while (*cp) {
      putc(*(cp++),fpout);
   }
putc('\n',fpout);
}

clean()
{
    /* leave a line beginning with a comment alone */
   char c,*cp;
   int  apos,tpos;
   apos=0;
   tpos=0;
   cp=line;
   while (*cp==' ' || *cp=='\t') cp++;
   if (*cp==0) {
      /* null line... preface with ; */
      strcpy(lineout,";");
      return;
   }

   if (*cp==';') { /* line contains only a comment. Asis. */
      strcpy(lineout,line);
      return;
   }

   /* if line has a label ... */
   if (cp==line) {
      /* copy label removing colon */
      while (*cp && *cp!=':'  && *cp!=' '
                 && *cp!='\t' && *cp!=';' ) {
         tpos++;
         lineout[apos++]= *(cp++);
      }
      if (*cp==':') cp++;
   }

   while (*cp==' ' || *cp=='\t') cp++;
   if (*cp!=0) {
      lineout[apos++]='\t';
      tpos = (tpos+8)&0xF8;
   }

   /* copy opcode field if any */
   while (*cp && *cp!=' ' && *cp!='\t' && *cp!=';') {
      tpos++;
      lineout[apos++]= *(cp++);
   }

   while (*cp==' ' || *cp=='\t') cp++;
   if (*cp!=0) {
      lineout[apos++]='\t';
      tpos = (tpos+8)&0xF8;
   }

   /* copy operand field if any */
   while (*cp && *cp!=' ' && *cp!='\t' && *cp!=';') {
      if (*cp=='\'') {
         while (1) {
            tpos++;
            lineout[apos++]= *(cp++);
            if (*cp==0 || *cp=='\'') break;
         }
         if (*cp=='\'') {
            tpos++;
            lineout[apos++]= *(cp++);
         }
      }
      else {
           tpos++;
           lineout[apos++]= *(cp++);
           }
   }

   while (*cp==' ' || *cp=='\t') cp++;
   if (*cp==0) {
      lineout[apos++]=0;
      return;
   }

   if (*cp!=';') {
      lineout[apos++]=0;
      printf("Invalid line... %s\n",line);
      return;
   }

   /* else it is a semicolon */

   while (tpos<32) {
      tpos = (tpos+8)& 0xF8;
      lineout[apos++]='\t';
   }

   while (*cp) {
      tpos++;
      lineout[apos++]= *(cp++);
   }

   lineout[apos++]=0;
   /* done */
return;
}

