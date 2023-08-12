#include <string.h>

size_t strlen(const char *string)
{
    int l;
    l = 0;
    while (*(string++))
        ++l;
    return l;
}
