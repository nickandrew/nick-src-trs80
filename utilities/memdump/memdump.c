/* memdump.c - Dump some RAM to printer */

#include <extras.h>
#include <stdio.h>

int main(int argc, char **argv)
{
  char *start;
  unsigned int len;

  if (argc < 3) {
    printf("Usage: memdump start-address length\n");
    return 1;
  }

  if (hex_to_int(argv[1], &start)) {
    printf("Unable to parse start-address\n");
    return 2;
  }

  if (hex_to_int(argv[2], &len)) {
    printf("Unable to parse length\n");
    return 2;
  }

  memdump(start, len, (unsigned long) start);
  return 0;
}
