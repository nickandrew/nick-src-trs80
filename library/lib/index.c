/* index.c */

char *index(char *list, int c)
{
    while (*list) {
        if (*list == (c & 0xff))
            return list;
        ++list;
    }
    return 0;
}
