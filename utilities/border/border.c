/* border: draw a border around a lot of text.
 * Usage: border <infile >outfile
 * Nick, 18-Jan-87
 */

#include <stdio.h>

int main(void)
{
    char string[80];
    char outstr[80];
    int i;

    while ((gets(string)) != NULL) {
        outstr[0] = '|';
        outstr[1] = ' ';
        for (i = 0; string[i] != 0; ++i) {
            outstr[2 + i] = string[i];
        }
        while (i < 76)
            outstr[2 + (i++)] = ' ';
        outstr[78] = '|';
        outstr[79] = 0;
        puts(outstr);
    }

    return 0;
}
