/* dumpcmd.c - Dump the contents of a .CMD file */

#include <stdio.h>

void memdump(const char *buf, int length, unsigned long position)
{
  const char *cp = buf;
  int out_pos = 0;  // offset into sbuf to append next substring
  int offset = 0;   // offset from beginning of buffer for this line
  char sbuf[80];

  for (offset = 0; offset < length; offset += 16) {
    int j;

    // Append the memory address and the offset in bytes
    out_pos += sprintf(sbuf + out_pos, "%04lx %03x:", position + offset, offset);

    // Append 16 hex bytes: "<space>XX"
    for (j = 0; j < 16; ++j) {
      if (offset + j < length) {
        out_pos += sprintf(sbuf + out_pos, " %02x", cp[j]);
      } else {
        // Append only dashes beyond the end of the buffer
        out_pos += sprintf(sbuf + out_pos, " --");
      }
    }

    out_pos += sprintf(sbuf + out_pos, "  ");

    // Append 16 characters (dots if unreadable)
    char c;
    for (j = 0; j < 16; ++j) {
      if (offset + j < length) {
        c = cp[j];
        if (c >= 0x20 && c < 0x7f) {
          out_pos += sprintf(sbuf + out_pos, "%c", c);
        } else {
          out_pos += sprintf(sbuf + out_pos, ".");
        }
      }
    }

    out_pos += sprintf(sbuf + out_pos, "\n");
    fputs(sbuf, stdout);
    out_pos = 0;
    cp += 16;
  }
}

int readbuf(char *buf, int length, FILE *fp) {
  int ch;
  for (int i = 0; i < length; ++i) {
    ch = fgetc(fp);
    if (ch == EOF) return EOF;
    *buf++ = ch;
  }

  return 0;
}

void dumpcmd(char *filename)
{
  FILE *ifp = fopen(filename, "r");
  if (ifp == NULL) {
    fprintf(stderr, "Unable to open %s for read\n", filename);
    return;
  }

  char buf[256];

  while (1) {
    int c = fgetc(ifp);
    int length;
    char address[2];

    if (c == EOF) {
      break;
    }

    if (c == 0x05) {
      // Program-name
      length = fgetc(ifp);
      if (length == EOF) {
        break;
      }
      if (readbuf(buf, length, ifp) == EOF) {
        break;
      }
      buf[length] = '\0';
      printf("Program name: '%s'\n", buf);
    }
    else if (c == 0x01) {
      // Load length - 2 bytes at some address
      length = fgetc(ifp);
      if (length == EOF) {
        break;
      }
      length = (length - 2) & 0xff;
      if (length == 0) {
        length = 0x100;
      }
      if (readbuf(address, 2, ifp) == EOF) {
        break;
      }
      if (length > 0) {
        if (readbuf(buf, length, ifp) == EOF) {
          break;
        }
      }
      int start = (address[0] & 0xff) | ((address[1] & 0xff) << 8);
      printf("Load block from %04x to %04x\n", start, start + length);
    }
    else if (c == 0x02) {
      // Chunk length
      length = fgetc(ifp);
      if (length == EOF) {
        break;
      }
      if (readbuf(buf, length, ifp) == EOF) {
        break;
      }
      printf("Start address %04x\n", buf[0] + (buf[1] << 8));
    }
    else {
      printf("Type byte: %02x\n", c);
      break;
    }
      
  }

  fclose(ifp);
}

int main(int argc, char *argv[]) 
{
  if (argc < 2) {
    fprintf(stderr, "Usage: dumpcmd file.cmd\n");
    return 2;
  }

  dumpcmd(argv[1]);
  return 0;
}

