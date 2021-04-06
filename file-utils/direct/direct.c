/*  Direct.c: Add, List and Unpack 'directory files'.       */
 /***********************************************************
 * Direct.c:    Source code for DIRECT.                     *
 * Environment: Unix System V                           OR  *
 *              Trs-80 Colour Computer running OS-9         *
 *                                                          *
 * Other files required:                                    *
 *       DIRECT.DOC       Documentation for this version    *
 *       STDIO.H          On your own system                *
 *                                                          *
 * Language:    C                                           *
 * Version:     1.3a 18-Oct-86                              *
 * Program:     (C) 1986 by Zeta Microcomputer Software     *
 *              Released to Public Domain 11-Mar-86         *
 * Updates:                                                 *
 *  1.2   02-Aug-86: Added description in 'S' command.      *
 *  1.3   09-Aug-86: Added version title on execution.      *
 *  1.3a  18-Oct-86: Closed open file to add, renamed so    *
 *                   it did not conflict with function name *
 *                                                          *
 *                                                          *
 *   If you like this program and you are an honest person  *
 * then you may consider sending a donation to the author   *
 * at P.O Box 177, Riverstone NSW 2765.                     *
 * Recommended amount: $5                                   *
 *                                                          *
 * This program is compatible with DIRECT/ASM for Trs-80.   *
 ***********************************************************/


#include <stdio.h>

int is_open;
FILE *fpdir, *fpdat;
char cmd[80], *cp, fname[80], *fcp;


#define VERSION      "1.3a"
#define VERDATE      "18-Oct-86"
#define FILELEN      16
#define DESCLEN      42

struct {
    char filename[FILELEN];
    char st_low, st_mid, st_hi;
    char le_low, le_mid, le_hi;
    char description[DESCLEN];
} directory;

char filestr[FILELEN + 1], descstr[DESCLEN + 1];

main()
{
    fprintf(stderr, "Direct version %s, %s\n", VERSION, VERDATE);
    is_open = 0;
    for (;;) {
        prompt();
        cp = cmd;
        switch (tolower(cmd[0])) {
        case 'x':
            doexit();

        case 's':
            set();
            break;

        case 'l':
            list();
            break;

        case 'e':
            extract();
            break;

        case 'a':
            addfile();
            break;

        case 'f':
            filist();
            break;

        case ':':
            syscall();
            break;

        case '!':
            syscall();
            break;

        case 0:
            continue;

        default:
            printf("Use one of the following:\n");
            printf("<S> Set open a 'direct' file\n");
            printf("<A> Add to current file\n");
            printf("<X> Exit Direct\n");
            printf("<E> Extract from current file\n");
            printf("<L> List packed files\n");
            printf("<F> Print current filename\n");
            printf("<!> Command escape\n\n");
        }
    }
}


prompt()
{
    printf("Direct %s> ", VERSION);
    if (fgets(cmd, 80, stdin) == NULL)
        doexit();
}

set()
{
    char fnm[80], fn1[80], dirdesc[DESCLEN];
    FILE *openup();
    int created, i;

    created = 0;
    if (is_open)
        dclose();
    cp++;
    while (white(*cp))
        cp++;                   /* Until 0 byte */

    /* Extract filename from cmd line */
    if (!*cp) {
        printf("Set: Set directory. Usage is 'S filename'\n");
        return;
    }

    fcp = fnm;
    while (!white(*cp) && *cp)
        *(fcp++) = *(cp++);
    *fcp = 0;
    strcpy(fn1, fnm);
    strcpy(fname, fnm);
    strcat(fn1, ".dir");
    if ((fpdir = fopen(fn1, "r+")) == NULL) {

        char answer[4], dirdesc[DESCLEN];

        printf("%s nonexistent! Create it? ", fn1);
        gets(answer);
        if (*answer == 'n' || *answer == 'N')
            return;
        if (creat(fn1, 0644) == NULL) {
            printf("Can't create file %s\n", fn1);
            return;
        }
        created = 1;
        if ((fpdir = openup(fn1, "r+")) == NULL)
            return;
    }
    strcpy(fn1, fnm);
    strcat(fn1, ".dat");
    if ((fpdat = fopen(fn1, "r+")) == NULL) {
        if (!created) {
            printf("Can't open file %s\n", fn1);
            return;
        }
        if (creat(fn1, 0644) == NULL) {
            printf("Can't create file %s\n", fn1);
            return;
        }
        if ((fpdat = openup(fn1, "r+")) == NULL)
            return;

        printf("Description of directory file? ");
        gets(dirdesc);

        fcp = "this_dir";
        for (i = 0; i < FILELEN && *fcp != 0; ++i)
            directory.filename[i] = *fcp++;
        while (i < FILELEN)
            directory.filename[i++] = ' ';

        /* xxxxxxxxxxx */
        directory.st_low = 0;
        directory.st_mid = 0;
        directory.st_hi = 0;
        directory.le_low = 0;
        directory.le_mid = 0;
        directory.le_hi = 0;

        fcp = dirdesc;
        for (i = 0; i < DESCLEN && *fcp != 0; ++i)
            directory.description[i] = *fcp++;
        while (i < DESCLEN)
            directory.description[i++] = ' ';

        /* Write entry to '.dir' file */

        if (fwrite(&directory, sizeof(directory), 1, fpdir) != 1) {
            printf("Can't write to %s.dir file\n", fname);
            return;
        }

    }

    is_open = 1;
    printf("%s Opened successfully\n", fnm);
}

dclose()
{
    if (!is_open)
        return;
    fclose(fpdir);
    fclose(fpdat);
    is_open = 0;
}

white(c)
char c;
{
    return ((c == ' ') || (c == '\t') || (c == '\n'));
}

FILE *openup(file, mode)
char *file, *mode;
{
    FILE *fp;
    if ((fp = fopen(file, mode)) == NULL) {
        printf("Can't open %s\n", file);
        return (NULL);
    }
    return (fp);
}

filist()
{
    printf("File %s\n", fname);
}

list()
{
    if (!is_open) {
        printf("You can't. No directory is open.\n");
        return;
    }
    rewind(fpdir);
    while (fread(&directory, sizeof(directory), 1, fpdir) == 1) {
        strncpy(filestr, directory.filename, FILELEN);
        strncpy(descstr, directory.description, DESCLEN);
        printf("%s :  %s\n", filestr, descstr);
    }
}

addfile()
{
    char sysfn[80], dirfn[FILELEN], buffer[BUFSIZ], desc[DESCLEN];
    char *dcp, *addfn;
    FILE *a_file;
    int i, nitems;
    long flen, fend, ftell();
    cp++;
    while (white(*cp) && *cp)
        cp++;
    /* Extract filename 1 from cmd line */
    if (!*cp) {
        printf("Add: usage is 'a system-filename [dir-filename]' \n");
        return;
    }
    fcp = sysfn;                /* get system filename */
    while (!white(*cp) && *cp)
        *(fcp++) = *(cp++);
    *fcp = 0;
    while (white(*cp) && *cp)
        cp++;
    fcp = dirfn;
    while (!white(*cp) && *cp)
        *(fcp++) = *(cp++);
    *fcp = 0;
    addfn = (*dirfn ? dirfn : sysfn);
    printf("Adding %s\n", addfn);
    if ((a_file = openup(sysfn, "r")) == NULL)
        return;
    fseek(fpdir, 0L, 2);
    fseek(fpdat, 0L, 2);
    fend = ftell(fpdat);
    fseek(a_file, 0L, 2);
    flen = ftell(a_file);
    rewind(a_file);

    /* Setup data about this entry */

    /* Firstly lengths */
    if (flen == 0L) {
        printf("File %s is empty!!\n", addfn);
        fclose(a_file);
        return;
    }

    /* Convert lengths a byte at a time */
    directory.st_low = (fend & 255);
    fend /= 256;
    directory.st_mid = (fend & 255);
    fend /= 256;
    directory.st_hi = (fend & 255);
    fend /= 256;

    if (fend != 0L) {
        printf("%s.dir file is too long!\n", fname);
        fclose(a_file);
        return;
    }

    directory.le_low = (flen & 255);
    flen /= 256;
    directory.le_mid = (flen & 255);
    flen /= 256;
    directory.le_hi = (flen & 255);
    fend /= 256;
    if (fend != 0L) {
        printf("Add file %s is too long!\n", sysfn);
        fclose(a_file);
        return;
    }

    i = 0;
    fcp = (*dirfn ? dirfn : sysfn);
    while (*fcp)
        directory.filename[i++] = *(fcp++);
    while (i < FILELEN)
        directory.filename[i++] = ' ';

    /* Get file description */
    printf("Description? ");
    if (gets(desc) == NULL)
        doexit();
    i = 0;
    fcp = desc;
    while (*fcp && i < DESCLEN)
        directory.description[i++] = *fcp++;
    while (i < DESCLEN)
        directory.description[i++] = ' ';

    /* Copy all of sysfn to end of fpdat */
    while (nitems = fread(buffer, 1, BUFSIZ, a_file)) {
        if (fwrite(buffer, 1, nitems, fpdat) != nitems) {
            printf("Can't add file to %s.dat file\n", fname);
            fclose(a_file);
            return;
        }
    }

    /* Write entry to '.dir' file */
    if (fwrite(&directory, sizeof(directory), 1, fpdir) != 1) {
        printf("Can't add entry to %s.dir file\n", fname);
        fclose(a_file);
        return;
    }
    fclose(a_file);
}

syscall()
{
    cp++;
    system(cp);
    putchar('\n');
}

doexit()
{
    printf("\nFini.\n");
    dclose();
    exit(0);
}

extract()
{
    char dirfn[FILELEN], filestr[FILELEN], deststr[DESCLEN], dest[DESCLEN];
    char buffer[BUFSIZ];
    int i, nitems, nit;
    long datposn, datlen;
    FILE *fpdest;
    cp++;
    while (white(*cp) && *cp)
        cp++;

    /* Extract filename 1 from cmd line */
    if (!*cp) {
        printf("Extract: usage is 'e dir-filename'\n");
        return;
    }

    fcp = dirfn;
    i = 0;
    while (!white(*cp) && *cp && i++ < FILELEN)
        *(fcp++) = *(cp++);
    while (i < FILELEN)
        dirfn[i++] = ' ';

    dirfn[i] = 0;
    rewind(fpdir);
    while (fread(&directory, sizeof(directory), 1, fpdir) == 1) {
        if (!strncmp(directory.filename, dirfn, FILELEN)) {
            strncpy(filestr, directory.filename, FILELEN);
            strncpy(descstr, directory.description, DESCLEN);
            printf("'%s' %s\n", filestr, descstr);
            printf("Write to which file? ");
            if (gets(dest) == NULL)
                doexit();
            if ((fpdest = openup(dest, "w")) == NULL)
                return;

            /* Position .dat file to the right place */
            datposn = 0L;
            datposn += directory.st_hi & 255;
            datposn *= 256;
            datposn += directory.st_mid & 255;
            datposn *= 256;
            datposn += directory.st_low & 255;

            datlen = 0L;
            datlen += directory.le_hi & 255;
            datlen *= 256;
            datlen += directory.le_mid & 255;
            datlen *= 256;
            datlen += directory.le_low & 255;

            fseek(fpdat, datposn, 0);
            while (datlen != 0L) {
                nitems = (datlen > BUFSIZ ? BUFSIZ : datlen);

                if (fread(buffer, 1, nitems, fpdat) != nitems) {
                    printf("Bad read from .dat file!\n");
                    return;
                }

                if (fwrite(buffer, 1, nitems, fpdest) != nitems) {
                    printf("Can't add file to dest file\n");
                    return;
                }
                datlen -= nitems;
            }
            fclose(fpdest);
            return;
        }
    }
    printf("No matching file in %s\n", fname);
}

char tolower(c)
char c;
{
    if (c >= 'A' && c <= 'Z')
        c += 'a' - 'A';
    return c;
}
