#include <stdio.h>

void test_read(void) {
  FILE *fp = fopen("testhw/src", "r");
  printf("fopen(testhw/src, r) returned %x\n", (int) fp);
  int i;

  for (i = 0; i < 10; ++i) {
    int rc = fgetc(fp);
    if (rc < 0) {
      printf("fgetc() returned %d - eof\n", rc);
      break;
    }
    long fpos = ftell(fp);
    printf("fgetc() returned %04x at pos %ld\n", rc, fpos);
  }
  fclose(fp);
}

void test_write(void) {
  FILE *fp = fopen("output:1", "r");
  int rc;
  rc = fputc('\n', fp);
  printf("fputc() rc %d\n", rc);
  rc = putc('\n', fp);
  printf("putc() rc %d\n", rc);
  rc = fputs("DATA\n", fp);
  printf("fputs() rc %d\n", rc);
  long fpos = ftell(fp);
  printf("ftell() rc %ld\n", fpos);
  fclose(fp);
}

int main()
{
  test_read();
  test_write();
  return 0;
}
