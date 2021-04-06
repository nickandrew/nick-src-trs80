/* index.c */

char *index(list, c)
int c;
char *list;
{
    while (*list) {
        if (*list == (c & 0xff))
            return list;
        ++list;
    }
    return 0;
}
