/*  uechoarc : A filter for echoarc messages
 *  Converted by Nick Andrew
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// defined in this file:
void ioer(void);

int main()
{
    int i, ch = 0, ct = 0, k;
    char ln[80];

    do {
        if (0 == fgets(ln, 80, stdin))
            ioer();
    } while (strcmp(ln, "echoarc("));

    for (;;) {
        if (0 == fgets(ln, 80, stdin))
            ioer();
        if (!strcmp(ln, "}echoarc"))
            break;

        for (i = 0; i < strlen(ln); ++i) {
            k = ln[i];
            if (k < 0x21 || k > 0x61)
                continue;
            ch |= (k - 0x21) << ct;
            ct += 6;
            while (ct >= 8) {
                putchar(ch & 0xff);
                ch >>= 8;
                ct -= 8;
            }
        }
    }

    return 0;
}

void ioer(void)
{
    fputs("uechoarc: File I/O error - aborting\n", stderr);
    exit(100);
}
