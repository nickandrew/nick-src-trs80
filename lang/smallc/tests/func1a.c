main()
{
    int    e,f;
    char   ( *(func()) ) [6];
    char   (*x)[6];

    x = func(1,3);
    (*x)[2] = 't';
}

char *abc;

char (*(func(e,f)))[6]
int  e,f;
{
   puts("This is func\n");
   return &abc;
}
