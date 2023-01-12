/* testfget.c - Test fgets() */

#include <extras.h>
#include <stdio.h>

char line[80];

int main(void) {

  printf("sizeof(line) is %d\n", sizeof(line));

  for (int i = 0; i < 10; ++i) {
    if (fgets(line, sizeof(line), stdin) != NULL) {
      fprintf(stderr, "Read line:\n");
      memdump(line, sizeof(line), (unsigned long)&line);
    }
  }

  return 0;
}
