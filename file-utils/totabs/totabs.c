/* totabs.c: Convert multiple spaces in a file to tabs
 * (C) Nick, 19-Jan-87
 * Usage: totabs <infile >outfile
 */

#include <stdio.h>

void convert(char *icp, char *ocp);

void main()
{
    char instr[256];
    char outstr[256];

    while ((gets(instr)) != NULL) {
        convert(instr, outstr);
        puts(outstr);
    }
}

void convert(char *icp, char *ocp)
{

    /* bugs...  this code doesn't realise the significance of tabs
     *          in text - it assumes a tab is one character position.
     *          Pretty dumb eh for a program which is supposed to
     *          substitute tabs in for not to be able to handle tabs
     *          in its input!
     */

    int pos = 0;
    int spaces;

    while (*icp != 0) {
        spaces = 0;
        while (*icp != ' ' && *icp != 0) {
            *(ocp++) = *(icp++);
            ++pos;
        }
        while (*icp == ' ') {
            ++icp;
            ++spaces;
        }
        while (spaces > 7) {
            *(ocp++) = '\t';
            spaces -= (8 - (pos % 8));
            pos += (8 - (pos % 8));
        }
        while (spaces > 0) {
            *(ocp++) = ' ';
            ++pos;
            --spaces;
        }
    }
    *ocp = 0;
}
