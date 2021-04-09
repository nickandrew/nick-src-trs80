/* gettok.c: Get the BASIC tokens out of ROM.
 */

#include <stdio.h>
#include <unistd.h>

int main()
{
    int toknum, labelnum, i;
    FILE *fp;
    char *locn, name[10];

    if ((fp = fopen("tokens.asm", "w")) == NULL) {
        return 1;
    }

    /* Address in ROM of the start of the BASIC token table. Model 1 only? */
    locn = (char *) 0x1650;

    for (labelnum = 1, toknum = 128; toknum < 251; toknum++, labelnum++) {
        i = 1;
        *name = (*(locn++) & 0x7f);

        while (*locn < 0x80)
            name[i++] = *(locn++);

        name[i] = 0;

        fprintf(fp, "TOK_%d\tDEFM\t'%s',0\n", labelnum, name);
        printf("%5d %s\n", labelnum, name);
    }

    fclose(fp);
    return 0;
}
