/* Test getchar() */

#include <stdio.h>

int main(void)
{
  int i, c;

  for (i = 0; i < 20; ++i) {
    c = getchar();
    if (c == EOF) {
      puts("EOF");
      break;
    }
    printf("Char %2d was 0x%02x\n", i, c);
  }

  return 0;
}
