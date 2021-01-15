char  *charptr;

main(argc,argv)
char *argv[];
int argc;
{
   char *fred[7];
   int  var1,var2;
   charptr=argv[-2];
   charptr=fred[-2];

   charptr=argv[-1];
   charptr=fred[-2];

   charptr=argv[0];
   charptr=fred[0];

   charptr=argv[1];
   charptr=fred[1];

   charptr=argv[2];
   charptr=fred[2];
}
