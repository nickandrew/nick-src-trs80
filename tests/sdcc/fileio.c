#include <stdio.h>

int main()
{
  FILE *fp = fopen("testhw/src", "r");
  printf("fopen() returned %x\n", (int) fp);
  return 0;
}
