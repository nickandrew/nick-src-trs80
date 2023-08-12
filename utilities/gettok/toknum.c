#include <stdio.h>

int main(void)
{
    int number;
    FILE *fp;

    if ((fp = fopen("trstbl/asm:1", "w")) == NULL) {
        return 1;
    }

    for (number = 1; number < 128; number++) {
        fprintf(fp, "\tDEFW\tTOK_%d\n", number);
    }
    fclose(fp);

    return 0;
}
