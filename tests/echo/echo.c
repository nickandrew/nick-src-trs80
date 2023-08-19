/* echo.c - Echo command line arguments */

#include <stdio.h>

int main(int argc, char *argv[]) {
  puts("Hello, world!\n");
  for (int i = 0; i < argc; ++i) {
    printf("Arg %02d '%s'\n", i, argv[i]);
  }
  return 55;
}
