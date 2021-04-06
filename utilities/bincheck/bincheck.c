/* bincheck:
 * Give some checksums etc... of binary files
 * Nick, '86
 */

#include <stdio.h>

main(argc, argv)
int argc;
char *argv[];
{
    FILE *fpin;
    char buffer[256];
    char c;
    int i, l, b = 0;

    if (argc != 2) {
        printf("usage: bincheck infile\n");
        exit(1);
    }

    if ((fpin = fopen(argv[1], "r")) == NULL) {
        printf("bincheck: couldn't open %s\n", argv[1]);
        exit(2);
    }

    while (1) {
        l = read(fileno(fpin), buffer, 256);
        if (l == 256)
            printf("Block number  %3d, ", b);
        if (l == 0) {
            printf("End of file\n");
            break;
        }
        if (l != 256)
            printf("Partial block %3d, length %3d, ", b, l);
        c = 0;
        for (i = 0; i < l; ++i)
            c = c + buffer[i];
        printf("Checksum %3d, ", c & 0377);
        c = 0;
        for (i = 0; i < l; ++i)
            c = c ^ buffer[i];
        printf("Xor %3d\n", c & 0377);
        ++b;
    }
}
