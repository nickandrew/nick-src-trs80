#include <stdio.h>

seekto(fp, sector)
FILE *fp;
int sector;
{
    int rba;
    rba = sector << 8;
    fseek(fp, rba, 0);
}
