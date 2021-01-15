/* simple.c ... a simple c prog to test C80 / Sc.
 * Nick, '87
 */

char **charptrptr;
char  *charptr;
char   charv;

main(argc,argv)
char *argv[];
int argc;
{
   charptr=argv[-2];
   charptr=argv[-1];
   charptr=argv[0];
   charptr=argv[1];
   charptr=argv[2];
}
