/* addlf/ccc: add linefeeds after CR. */
main(argc,argv)
int argc;
char **argv;
{
   int fi ;
   char c;
   if (argc!=3)
      {
      printf("Usage: ADDLF filein fileout\n");
      exit();
      }
   if ((fi=fopen(argv[1],"r"))==NULL)
      {
      printf("Can't open %s\n",argv[1]);
      exit();
      }
   else
      {
      if ((fo=fopen(argv[2],"w"))==NULL)
         {
         printf("Can't open %s\n",argv[2]);
         exit();
         }
      }
   while ((c=getc(fi))!=EOF)
      {
      if (c=='\n') add();
      putc(c,fo);
      }
   fclose(fi);
   fclose(fo);
   exit();
}

/**/
add()
{
   putc(0x0d,fo);
   c=getc(fi);
   if (c==EOF || c==0x0a)
      {
      c=0x0a;
      }
   else
      putc(0x0a,fo);
}

