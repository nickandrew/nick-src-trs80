int  strlen(string)
char *string;
{
    int  l;
    l=0;
    while (*(string++)) ++l;
    return l;
}

