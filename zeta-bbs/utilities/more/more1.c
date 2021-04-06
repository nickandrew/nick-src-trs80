/* more - terminal pager        Author: Brandon S. Allbery  */

/* Pager commands:
 *  <space>  display next page
 *  <return> scroll up 1 line
 *  n    Next file
 *  '    rewind
 *  q    quit
*/

/* #define TRS80 */

#ifdef TRS80
#define LINES       15
#define COLS        64
#else
#define LINES       23          /* lines/screen - 1 */
#define COLS        80          /* columns/line */
#endif



#define TABSTOP     8           /* tabstop expansion */

#include <signal.h>

extern char *index();

#define BUFFER   1024

int lastch = 0;                 /* last character returned from input() */
int line = 0;                   /* current terminal line */
int col = 0;                    /* current terminal column */
int fd = -1;                    /* terminal file descriptor (/dev/tty) */
FILE *fp;
char ibuf[BUFFER];              /* input buffer */
char obuf[BUFFER];              /* output buffer */
int ibl = 0;                    /* chars in input buffer */
int ibc = 0;                    /* position in input buffer */
int obc = 0;                    /* position in output buffer (== chars in) */
int isrewind = 0;               /* flag: ' command -- next input() rewind */
int isdone = 0;                 /* flag: return EOF next read even if not */

main(argc, argv)
int argc;
char **argv;
{
    char ch;
    int fd, arg;

    signal(SIGINT, byebye);
    fd = 0;
    fp = stdin;
    cbreak();
    if (argc < 2) {
        fputs("usage: more filename ...\n", stdout);
        nocbreak();
        exit(1);
    } else
        for (arg = 1; argv[arg] != 0; arg++) {
            if ((fp = fopen(argv[arg], "r")) == NULL) {
                fputs("more: cannot open ", stdout);
                fputs(argv[arg], stdout);
                fputs("\n", stdout);
                nocbreak();
                exit(1);
            }

            while ((ch = input(fp)) >= 0)
                if (ch != 0)
                    output(ch);

            fclose(fp);
            if (argv[arg + 1] != 0) {
                oflush();
                if (isdone) {   /* 'n' command */
                    fputs("*** Skipping to next file ***\n", stdout);
                    isdone = 0;
                }
                fputs("--More-- (Next file: ", stdout);
                fputs(argv[arg + 1], stdout);
                fputs(")\n", stdout);
                switch (wtch()) {
                case ' ':
                case '\'':
                case 'n':
                case 'N':
                    line = 0;
                    break;
                case '\r':
                case '\n':
                    line = LINES - 1;
                    break;
                case 'q':
                case 'Q':
                    clearln();
                    byebye();
                }
                clearln();
            }
        }
    oflush();
    byebye();
}

input(fp)
char *fp;
{
    int ch;
    if (isdone) {
        ibl = 0;
        ibc = 0;
        return -1;
    }
    if (isrewind) {
        fseek(fp, 0, 0);
        ibl = 0;
        ibc = 0;
        isrewind = 0;
    }
    if (ibc == ibl) {
        ibc = 0;
        if ((ibl = fread(ibuf, 1, BUFFER, fp)) <= 0)
            return -1;
    }
    ch = ibuf[ibc++];
    if (ch == 0x0a) {
        if (lastch == 0x0d)
            return lastch = 0;
        lastch = 0;
        return 0x0d;
    }
    return lastch = ch;
}

output(c)
char c;
{
    if (obc == BUFFER) {
        lwrite(1, obuf, BUFFER);
        obc = 0;
    }
    if (!isrewind)
        obuf[obc++] = c;
}

oflush()
{
    if (!isdone)
        lwrite(1, obuf, obc);
    obc = 0;
}

lwrite(fd, buf, len)
int fd;
char *buf;
int len;
{
    int here, start;
    char cmd;

    start = 0;
    here = 0;
    while (here != len) {
        cmd = '\0';
        switch (buf[here++]) {
        case 0:
            break;
        case '\015':           /* carriage return */
        case '\012':           /* definitive linefeed */
            col = 0;
            if (++line == LINES) {
                write(fd, buf + start, here - start);
                write(1, "--More--", 8);
                cmd = wtch();
                clearln();
                line = 0;
                start = here;
            }
            break;
        case '\r':
            col = 0;
            break;
        case '\b':
            if (col != 0)
                col--;
            else {
                line--;
                col = COLS - 1;
            }
            break;
        case '\t':
            do {
                col++;
            } while (col % TABSTOP != 0);
            break;
        default:
            if (++col == COLS) {
                col = 0;
                if (++line == LINES) {
                    write(fd, buf + start, here - start);
                    write(1, "--More--", 8);
                    cmd = wtch();
                    clearln();
                    line = 0;
                    start = here;
                }
            }
        }

        /* Do whats necessary for the pressed key */
        switch (cmd) {
        case '\0':
            break;
        case ' ':
            line = 0;
            break;
        case '\r':
        case '\n':
            line = LINES - 1;
            break;
        case 'q':
        case 'Q':
            byebye();
        case '\'':
            isrewind = 1;
            fputs("*** Back ***\n", stdout);
            return;
        case 'n':
        case 'N':
            isdone = 1;
            return;
        case '?':
            help();
            return;
        default:
            break;
        }
    }
    if (here != start)
        write(fd, buf + start, here - start);
}

wtch()
{
    char ch;

    do {
        ch = getchar();
    } while (index(" \r\nqQ'nN?", ch) == 0);
    return ch;
}

cbreak()
{
    fd = 1;
    return;

}

nocbreak()
{
    fd = -1;
    return;

}

byebye()
{
    nocbreak();
    exit(0);
}

clearln()
{
#ifdef TRS80
    write(1, "\035           \035", 13);
#else
    write(1, "\012           \012", 13);        /* CR & LF reversed */
#endif
}

write(fd, buf, len)             /* cheapie version of write() */
int fd, len;
char *buf;
{
    if (fd != 1)
        return;
    while (len--)
        fputc(*(buf++), stdout);
}

help()
{
    fputs("\n  More commands:\n", stdout);
    fputs(" <cr>  Display next line\n", stdout);
    fputs(" space  Display next page\n", stdout);
    fputs("   Q   Quit\n", stdout);
    fputs("   N   Next file\n", stdout);
    fputs("   '   Rewind to start\n", stdout);
    fputs("   ?   Display this message\n", stdout);
    fputs("\n", stdout);
}
