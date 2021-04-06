/*
**  strcmp.c : Some string routines hacked from Alcor
*/

strcpy(to_ptr, from_ptr)
char *to_ptr;
char *from_ptr;
{
    while (*to_ptr++ = *from_ptr++) ;
}

strcmp(first, second)
char *first;
char *second;
{
    while (*first == *second) {
        if (*first == '\0')
            return 0;
        else {
            first++;
            second++;
        }
    }
    return *first - *second;
}

strcat(first, second)
char *first;
char *second;
{
    while (*first != '\0')
        first++;
    while ((*first++ = *second++) != '\0') ;
}


/************************************************************/
/*   strsave ... I don't want to compile this yet !         */
/************************************************************/

/* char *strsave(s)
** char    *s;
** {
**     char    *ptr;
**     char    *calloc();
**     if ((ptr = calloc(1,strlen(s)+1)) != NULL)
**        strcpy(ptr,s);
**     return(ptr);
** }
*/
