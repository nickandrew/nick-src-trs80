/* memdump.c - A function to dump memory areas to the printer device */

#include <extras.h>
#include <stdio.h>

#include "../sdcc/doscalls.h"

// Don't put big arrays on the stack
static char sbuf[80];

/* memdump ...
**   Dump a buffer to the printer device, in hex and ascii.
**
**   buf:       Start address of buffer
**   length:    Number of bytes to dump
**   position:  (ulong) Start address or number to prefix to each line.
*/

void memdump(const char *buf, int length, unsigned long position)
{
  int i = 0;
  const char *cp = buf;
  int out_pos = 0;  // offset into sbuf to append next substring
  int offset = 0;   // offset from beginning of buffer for this line

  dos_mess_pr("-----\r");
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

    out_pos += sprintf(sbuf + out_pos, "\r");
    dos_mess_pr(sbuf);
    out_pos = 0;
    cp += 16;
  }
}
