/*
**  newsfmt ... Reformat news files to suit Zeta
**  usage: newsfmt infile outfile
*/

#include <stdio.h>
FILE *fi, *fo;
char line[81];

main(argc, argv)
int argc;
char *argv[];
{
    if (argc != 4) {
        fprintf(stderr, "usage: %s infile outfile shortname\n", *argv);
        exit(1);
    }

    if (((fi = fopen(argv[1], "r")) == NULL) ||
        ((fo = fopen(argv[2], "w")) == NULL) || ((fs = fopen("subjects", "a")) == NULL)) {
        fprintf(stderr, "%s: couldn't open file(s)\n", *argv);
        exit(2);
    }

    keycopy();
    textcopy();

    fclose(fi);
    fclose(fo);
    fclose(fs);
}

keycopy()
{
    char *fg;

    for (;;) {
        if (fgets(line, 80, fi) == NULL)
            break;
        if (*line != '\n') {
            if (keysrch())
                putline();
        } else
            break;
    }

    strcpy(line, "Gated-By: all@zeta  (Fidonet [712/602])\n\n");
}

char *keys[8] = {
    "From: ", "Newsgroups: ", "Subject: ", "Message-ID: ",
    "Date: ", "Lines: ", "Keywords: ", "Reply-To: "
};

keysrch()
{
    int i = 0;
    while (i < 8)
        if (prefix(keys[i++]))
            return 1;
    return 0;
}

prefix(cp)
char *cp;
{
    char *lp;
    lp = line;
    while (*cp)
        if (*cp++ != *line++)
            return 0;
    return 1;
}

putline()
{
    register char *cp;
    cp = line;

    while (*cp) {
        if (*cp == '\n')
            putc(0x13, fo);
        else
            putc(*cp, fo);
        ++cp;
    }

    while (*(cp - 1) != '\n') { /* partial long line */
        if (fgets(line, 80, fi) == NULL)
            break;
        cp = line;
        while (*cp) {
            if (*cp == '\n')
                putc(0x13, fo);
            else
                putc(*cp, fo);
            ++cp;
        }
    }
}


textcopy()
{
    while (fgets(line, 80, fi) != NULL)
        putline();
}
