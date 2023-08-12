/* testh2i.c - Test hex_to_int() */

#include <extras.h>
#include <stdio.h>

struct testcase {
  const char *str;
  int rc;
  unsigned int result;
};

struct testcase tests[] = {
  {.str = "", .rc = -1, .result = 0},  // Empty string
  {.str = "0", .rc = 0, .result = 0},
  {.str = "1", .rc = 0, .result = 1},
  {.str = "9", .rc = 0, .result = 9},
  {.str = "a", .rc = 0, .result = 10},
  {.str = "f", .rc = 0, .result = 15},
  {.str = "1c", .rc = 0, .result = 0x1c},
  {.str = "7fed", .rc = 0, .result = 0x7fed},
  {.str = "aced", .rc = 0, .result = 0xaced},
  {.str = "0xaced", .rc = 0, .result = 0xaced},
  {.str = "0xabcde", .rc = -1, .result = 0}, // Too long
  {.str = "0xabcdef01", .rc = -1, .result = 0}, // Too long
  {.str = "aceofspades", .rc = 0, .result = 0xace}, // First 3 chars are valid hex
};

int main(void) {
  struct testcase *t;
  struct testcase *last = tests + (sizeof tests)/sizeof(struct testcase);
  int failed = 0;

  for (t = tests; t < last; ++t) {
    unsigned int uint_p;
    int rc = hex_to_int(t->str, &uint_p);

    if (rc != t->rc) {
      printf("Test failed: '%s' rc got %d want %d\n", t->str, rc, t->rc);
      failed = 1;
    }
    else if (rc == 0 && uint_p != t->result) {
      printf("Test failed: '%s' result got %u want %u\n", t->str, uint_p, t->result);
      failed = 1;
    }
    else {
      printf("Test passed: '%s'\n", t->str);
    }
  }

  return failed;
}
