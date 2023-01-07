/* cwiz ... Written by Rosko, substantially modified by Nick
**
**  Usage: cwiz wisdom/txt wisdom/inx
*/

#include <stdio.h>
#include <stdlib.h>

FILE *in, *out;
#define  MAX    100
char string[MAX];

void putlong(long rba)
{
    fputc(rba & 0xff, out);
    fputc((rba >> 8) & 0xff, out);
    fputc((rba >> 16) & 0xff, out);
    fputc((rba >> 24) & 0xff, out);
}

int main(int argc, char **argv)
{
    int count;
    long rba;                    /* file position */

    if (argc < 3) {
        fprintf(stderr, "Usage: cwiz infile outfile\n");
        return 2;
    }

    if ((in = fopen(argv[1], "r")) == NULL) {
        fprintf(stderr, "Cannot open %s for read\n", argv[1]);
        return 1;
    }

    if ((out = fopen(argv[2], "w")) == NULL) {
        fprintf(stderr, "Cannot open %s for write\n", argv[2]);
        return 1;
    }

    putlong(0L);                  /* first long = count of wisdoms */

    count = 0;
    while (1) {
        do {
            string[0] = 0;
            rba = ftell(in);
            if (fgets(string, MAX, in) == NULL)
                break;
        } while (string[0] == ' ' || string[0] == '\t');
        if (string[0] == 0)
            break;
        putlong(rba);
        ++count;
    }
/*  rewind(out);
    putlong(count);
*/

    fprintf(stdout, "There are %d wisdoms.\n", count);
    fclose(out);
    return 0;
}
