/* toupper.c - change a program to upper case
 * ignore stuff within quotes
 * ignore cobol comments
 */
#include <stdio.h>

int outside,dbl,sngl;
char c,line[256];

main()
{
   outside=1;
   dbl=sngl=0;
   while (gets(line))
      process(line);
}

process(line)
char line[];
{
   char *cp,c;
   int i,comm;
   cp=line;
   /* Cobol test. */
   comm=1;
   for (i=0;i<6;i++) if (line[i]!=' ') comm=0;
   if (line[6]!='*') comm=0;
   if (comm)
      {
      puts(line);
      return;
      }
   while (*cp)
      {
      c= *(cp++);
      if (outside)
         {
         if (c>='a' && c<='z') c=toupper(c);
         putchar(c);
         if (c=='"')
            { outside=0; dbl=1; }
         if (c=='\'')
            { outside=0; sngl=1; }
         continue;
         }
      putchar(c);
      if (dbl && (c=='"'))
         { dbl=0; outside=1; }
      if (sngl && (c=='\''))
         { sngl=0; outside=1; }
      }
   putchar('\n');
}
