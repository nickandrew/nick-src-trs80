/* test script for argparse.c */

#include <stdio.h>
#include <string.h>

char **argparse(char *buf, int *p_argc);

typedef struct test {
  char *in;
  int  argc;
  char *argv[40];
} TestCase;

TestCase test1 = {.in = "abc\x0d", .argc = 1, .argv = {"abc", NULL}};

struct test tests[] = {
  { .in = "abc\x0d", .argc = 1, .argv = {"abc", NULL}},
  { .in = "abc   def  ghi\x0d", .argc = 3, .argv = {"abc", "def", "ghi", NULL}},
  { .in = "echo 'single quoted string'\x0d", .argc = 2, .argv = {"echo", "single quoted string", NULL}},
  { .in = "echo \"double quoted string\"\x0d", .argc = 2, .argv = {"echo", "double quoted string", NULL}},
  { .in = "echo words'before quoting'\x0d", .argc = 2, .argv = {"echo", "wordsbefore quoting", NULL}},
  { .in = "echo 'after quoting'words\x0d", .argc = 2, .argv = {"echo", "after quotingwords", NULL}},
  { .in = "echo the \\  end\x0d", .argc = 4, .argv = {"echo", "the", " ", "end", NULL}},
  { .in = "\x0d", .argc = 0, .argv = {NULL}},
  { .in = "hello,\\ world\x0d", .argc = 1, .argv = {"hello, world", NULL}},
  { .in = "echo \\ word\x0d", .argc = 2, .argv = {"echo", " word", NULL}},
  { .in = "echo '\"'\x0d", .argc = 2, .argv = {"echo", "\"", NULL}},
  { .in = "echo \"'\"\x0d", .argc = 2, .argv = {"echo", "'", NULL}},
  { .in = "echo \"dq \\\"inside\\\" dq string\" finally\x0d", .argc = 3, .argv = {"echo", "dq \"inside\" dq string", "finally", NULL}},
  { .in = "'unterminated sq\x0d", .argc = 1, .argv = {"unterminated sq", NULL}},
  NULL,
};

int do_test(struct test *t) {
  char buf[80];
  int argc;
  int rc = 0;

  strcpy(buf, t->in);
  char **argv = argparse(buf, &argc);

  if (argc != t->argc) {
    printf("test(%s) argc got %d, want %d\n", t->in, argc, t->argc);
    return 1;
  }

  int i;

  for (i = 0; i < argc; ++i) {
    // Compare argv values
    if (strcmp(argv[i], t->argv[i])) {
      printf("test(%s) arg %d got %s, want %s\n", t->in, i, argv[i], t->argv[i]);
      rc = 1;
    }
  }

  if (argv[argc] != NULL) {
    printf("test(%s) argv[argc] got %s, want NULL\n", t->in, argv[argc]);
    rc = 2;
  }

  // Print what we got, without testing
  for (i = 0; i < argc; ++i) {
    printf("OUT test(%s) arg %d got %s\n", t->in, i, argv[i]);
  }

  return rc;
}

int main()
{

  struct test *t;
  int rc = 0;

  for (t=tests; t != NULL && t->in; ++t) {
    fprintf(stdout, "Doing a test against %s\n", t->in);
    rc |= do_test(t);
  }

  fprintf(stdout, "Done tests.\n");
  return rc;
}
