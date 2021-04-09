#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char string[20];                /* the string to "anagram" */
int string_len;                 /* length of same */

void anagram(int start, int length);

int main(int argc, char *argv[])
{
    if (argc == 1) {
        printf("Usage: anagram <string>\n");
        exit(-1);
    }

    strcpy(string, argv[1]);    /* copy string */
    string_len = strlen(string);        /* find length of it */
    anagram(0, string_len);     /* find all the anagrams */
    return 0;
}

/* int start;                      index of the start we are interested in */
/* int length;                     no. of chars we are interested in */

void anagram(int start, int length)
{
    int i;

    if (length == 1) {          /* write out the anagram */
        for (i = 0; i < string_len; i++)
            putchar(string[i]);
        putchar('\n');
    } else {
        for (i = 0; i < length; i++) {
            if (i == 0)
                anagram(start + 1, length - 1);
            else {
                char tmp;       /* temp for swap */

                tmp = string[start];    /* swap */
                string[start] = string[start + i];
                string[start + i] = tmp;
                anagram(start + 1, length - 1);
                tmp = string[start];    /* swap back */
                string[start] = string[start + i];
                string[start + i] = tmp;
            }
        }
    }
}
