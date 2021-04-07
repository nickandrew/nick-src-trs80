#include <stdio.h>

#include "seekto.h"

void seekto(FILE *fp, int sector)
{
    int rba;
    rba = sector << 8;
    fseek(fp, rba, 0);
}
