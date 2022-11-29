/* repc.c
 * do repeat character encoding or decoding on a file
 */

#include <stdio.h>
#include <stdlib.h>

#define DLE 0x10
#define MAGIC1 0x1b
#define MAGIC2 0x1d

void encode(char *string);
void decode(char *string);

int main(int argc, char *argv[])
{
    char flag, *cp;
    int i;
    if (argc < 3) {
        fprintf(stderr, "usage: repc [e|d] files ...\n");
        return 1;
    }

    flag = 'e';

    cp = argv[1];
    if (*cp == 'd')
        flag = 'd';
    else if (*cp != 'e') {
        fprintf(stderr, "use 'e' to encode & 'd' to decode\n");
        return 1;
    }

    i = 1;
    fprintf(stderr, "message 1\n");
    while (argv[++i]) {
        if (flag == 'e')
            encode(argv[i]);
        else
            decode(argv[i]);
        fprintf(stderr, "Finished %s\n", argv[i]);
    }

    return 0;
}

void decode(char *string)
{
    int c, count;
    char ok;
    FILE *input;
    if ((input = fopen(string, "r")) == NULL) {
        fprintf(stderr, "couldn't decode %s\n", string);
    }

    ok = 0;
    if (getc(input) == MAGIC1)
        if (getc(input) == MAGIC2)
            ok = 1;
    if (!ok) {
        fprintf(stderr, "repc - not repeat encoded\n");
        return;
    }
    while ((c = getc(input)) != EOF) {
        if (c != DLE)
            putchar(c);
        else {
            count = getc(input);
            if (count < 4) {
                fprintf(stderr, "repc - error in %s\n", string);
                return;
            }
            c = getc(input);
            while (count--)
                putchar(c);
        }
    }
}

void encode(char *string)
{
    int c, d, count;
    FILE *input;
    if ((input = fopen(string, "r")) == NULL) {
        fprintf(stderr, "couldn't encode %s\n", string);
        return;
    }

    /* output the magic numbers to be sure */
    putchar(MAGIC1);
    putchar(MAGIC2);


    c = getc(input);
    while (c != EOF) {
        d = getc(input);
        if (d == c || c == DLE) {
            count = 1;
            if (d == c) {
                while (d == c && count < 255) {
                    d = getc(input);
                    ++count;
                }
            }
            if (c == DLE || count > 3) {
                putchar(DLE);
                putchar(count);
                putchar(c);
            } else {
                while (count--)
                    putchar(c);
            }
            c = d;
        } else {
            putchar(c);
            c = d;
        }
    }
}
