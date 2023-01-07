/* testtime.c - Test time() */

#include <stdio.h>
#include <time.h>

int main(void) {
  time_t t = time(0);
  printf("The current time is %ld\n", t);

  return 0;
}
