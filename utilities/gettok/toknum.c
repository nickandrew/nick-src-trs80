#include <stdio.h>

main()
{
    int number;
    FILE *fp;

    if ((fp = fopen("trstbl/asm:1", "w")) == NULL)
        exit(0);

    for (number = 1; number < 128; number++) {
        fprintf(fp, "\tDEFW\tTOK_%d\n", number);
    }
    fclose(fp);
}
