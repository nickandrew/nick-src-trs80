/*
 * superc/c: Find Difference of two files.
 * (C) 1986, Nick.
 */

#include <stdio.h>

FILE *fp1, *fp2;
int unique1, unique2;
char file1[40][80], file2[40][80];
int start1, start2;
int count1, count2;
char eof1, eof2;
char flag;
int i;


main(argc, argv)
int argc;
char *argv[];
{
    if (argc != 3) {
        fprintf(stderr, "Usage: SUPERC old new\n");
        exit(1);
    }

    if ((fp1 = fopen(argv[1], "r")) == NULL) {
        fprintf(stderr, "superc: cannot open %s\n", argv[1]);
        exit(1);
    }

    if ((fp2 = fopen(argv[2], "r")) == NULL) {
        fprintf(stderr, "superc: cannot open %s\n", argv[2]);
        exit(1);
    }

    unique1 = unique2 = start1 = start2 = count1 = count2 = 0;
    eof1 = eof2 = 0;

    while (read1()) ;
    while (read2()) ;

    while (!(eof1 && eof2)) {
        if (!strcmp(file1[start1], file2[start2])) {

            /* they match so flush them */
            start1 = (start1 + 1) % 40;
            start2 = (start2 + 1) % 40;
            --count1;
            --count2;
            while (read1()) ;
            while (read2()) ;

        } else {
            flag = cmpsrch();
            if (!flag) {
                empty1("Deleted", 1);
                empty2("Inserted", 1);
            } else {
                empty1("Deleted", unique1);
                empty2("Inserted", unique2);
            }
            while (read1()) ;
            while (read2()) ;
        }
    }
}

read1()
{
    int j, len;
    char *cp;
    int c;
    if (eof1 || count1 == 40)
        return 0;
    len = 0;
    j = (start1 + (count1++)) % 40;
    cp = file1[j];
    while ((c = getc(fp1)) != EOF && len < 79 && c != '\n') {
        *(cp++) = c;
        ++len;
    }

    *cp = 0;

    while (c != '\n' && c != EOF)
        c = getc(fp1);

    if (c == EOF) {
        --count1;
        eof1 = 1;
        return 0;
    }
    return 1;
}

read2()
{
    int j, len;
    char *cp;
    int c;
    if (eof2 || count2 == 40)
        return 0;
    len = 0;
    j = (start2 + (count2++)) % 40;
    cp = file2[j];
    while ((c = getc(fp2)) != EOF && len < 79 && c != '\n') {
        *(cp++) = c;
        ++len;
    }

    *cp = 0;

    while (c != '\n' && c != EOF)
        c = getc(fp2);

    if (c == EOF) {
        --count2;
        eof2 = 1;
        return 0;
    }
    return 1;
}


empty1(string, count)
char *string;
int count;
{
    int i;
    if (count == 0 || count1 == 0)
        return;

    if (*string != 0) {
        printf("\n%s\n", string);
    }

    for (i = 0; i < count; ++i) {
        if (count1 == 0)
            break;
        printf("%s\n", file1[start1]);
        start1 = (start1 + 1) % 40;
        --count1;
    }
}


empty2(string, count)
char *string;
int count;
{
    int i;
    if (count == 0 || count2 == 0)
        return;

    if (*string != 0) {
        printf("\n%s\n", string);
    }

    for (i = 0; i < count; ++i) {
        if (count2 == 0)
            break;
        printf("%s\n", file2[start2]);
        start2 = (start2 + 1) % 40;
        --count2;
    }
}


cmpsrch()
{
    int vara, varb;
    int maxa;

    maxa = max(count1, count2);

    for (vara = 0; vara < maxa; ++vara) {
        for (varb = 0; varb <= vara; ++varb) {

            if (vara < count1 && varb < count2) {
                if (!strcmp(file1[(start1 + vara) % 40], file2[(start2 + varb) % 40])) {

                    unique1 = vara;
                    unique2 = varb;
                    return 1;
                }
            }

            if (vara < count2 && varb < count1) {
                if (!strcmp(file2[(start2 + vara) % 40], file1[(start1 + varb) % 40])) {

                    unique2 = vara;
                    unique1 = varb;
                    return 1;
                }
            }

        }
    }
    return 0;
}
