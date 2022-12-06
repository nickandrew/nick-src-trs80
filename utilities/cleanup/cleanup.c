#include <stdio.h>

int main(int argc, char *argv[])
{
    FILE *fin, *fout;
    char string[255], *cp1, *cp2;
    if (argc != 3) {
        printf("Cleanup: Usage cleanup infile outfile\n");
        return 1;
    }

    if ((fin = fopen(argv[1], "r")) == NULL) {
        printf("Cleanup: Can't open %s\n", argv[1]);
        return 2;
    }

    if ((fout = fopen(argv[2], "w")) == NULL) {
        printf("Cleanup: Can't open %s\n", argv[2]);
        return 3;
    }

    while (fgets(string, 255, fin)) {
        cp1 = cp2 = string;
        while (*cp2) {
            if (*cp2 == '\b') {
                cp1--;
                cp2++;
            } else
                *(cp1++) = *(cp2++);
        }

        *cp1 = 0;
        fputs(string, fout);
    }

    return 0;
}
