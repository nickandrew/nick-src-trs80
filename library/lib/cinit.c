/* cinit.c - Initialisation routine for Small-C Trs-80 */
/* Last modified: 25-Aug-87                            */

#define FILE char

extern char *stdin;
extern char *stdout;
extern char *stderr;
extern int  cmdline,noredir;


#define  MAXARGS   15
#define  NULL      0
#define  ETX       3


_initio()
{
    char    *STDIN,*STDOUT,*STDERR;
    char    *console;
    char    *mode;
    char    *argv[MAXARGS];    /*ptrs to command line args */
    char    ch;
    char    *cmdl;
    char    *cptr;
    int     argc;         /*number of command line arguments*/
    int     count;

    console = ":C";
    mode = "w";
    ch = 0;
    argv[0] = cptr = cmdl = cmdline;
    argc = count = 0;
    STDIN = STDOUT = STDERR = console;
 
    /* Count characters in command line */
    while (*cptr != '\r' && *cptr != ETX) {
       count++;
       cptr++;
    }

    while (count>0 & argc < MAXARGS) {
        while (*cmdl == ' ' && count--) {
             cmdl++;
        }
        if (count) {
            if (*cmdl == '<') {
                count--;
                if (!noredir) STDIN = ++cmdl;
            } else if (*cmdl == '>') {
                count--;
                ++cmdl;
                if (*cmdl == '>') {
                    count--;
                    cmdl++;
                    mode[0] = 'a';
                }
                if (!noredir) STDOUT = cmdl;
            } else {
                argv[argc++] = cmdl;
            }
            while (*cmdl != ' ' && count) {
                count--;
                cmdl++;
            }
            *cmdl = NULL;
            count--;
            cmdl++;
        }
    }

    /* open files, must be in order */
    fopen(STDIN,"r");
    fopen(STDOUT,mode);
    fopen(STDERR,"w");

    argv[argc] = 0;
    main(argc,argv);
    exit(0);
}

