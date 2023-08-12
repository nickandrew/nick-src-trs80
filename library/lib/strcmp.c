/*
**  strcmp.c : Some string routines hacked from Alcor
*/

#include <string.h>

char *strcpy(char *to_ptr, char *from_ptr)
{
    char *dest = to_ptr;
    while (*to_ptr++ = *from_ptr++) ;
    return dest;
}

int strcmp(char *first, char *second)
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

char *strcat(char *first, char *second)
{
    char *dest = first;
    while (*first != '\0')
        first++;
    while ((*first++ = *second++) != '\0') ;
    return dest;
}


/************************************************************/
/*   strsave ... I don't want to compile this yet !         */
/************************************************************/

/* char *strsave(char *s)
** {
**     char    *ptr;
**     char    *calloc();
**     if ((ptr = calloc(1,strlen(s)+1)) != NULL)
**        strcpy(ptr,s);
**     return(ptr);
** }
*/
