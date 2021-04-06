/* wild.c:	Wildcard checking routines */


int chkwild(wild, string)
char wild[], string[];
{
    int i, j;

    i = j = 0;

    while (wild[i] || string[j]) {
        if (!cmpwild(wild, string, &i, &j))
            return 0;
    }

    return 1;
}

int cmpwild(wild, string, i_ptr, j_ptr)
char wild[], string[];
int *i_ptr, *j_ptr;
{
    char f_srch, f_cmp;
    int i, j, endi, endj, s_len;

    f_srch = f_cmp = s_len = 0;
    i = *i_ptr;
    j = *j_ptr;

    while (wild[i] == '*') {
        i++;
        f_srch = 1;
    }

    for (endi = i; wild[endi] != 0 && wild[endi] != '*'; ++endi)
        ++s_len;

    if (!f_srch) {
        if (!windex(wild, string, i, j))
            return 0;
        *i_ptr = endi;
        *j_ptr = j + s_len;
        return 1;
    }

    while (1) {
        if (windex(wild, string, i, j)) {
            *i_ptr = endi;
            *j_ptr = j + s_len;
            return 1;
        }
        if (!string[j])
            return 0;
        ++j;
    }

    return 0;
}

int windex(wild, string, i, j)
char wild[], string[];
int i, j;
{


    while (wild[i] && string[j] && wild[i] != '*') {
        if (wild[i] != '?' && (wild[i] != string[j]))
            return 0;
        ++i;
        ++j;
    }

    if (!wild[i])
        return (string[j] == 0);

    if (wild[i] == '*')
        return 1;

    return 0;
}

/* end of wild.c */
