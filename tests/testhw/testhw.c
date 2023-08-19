/* Test hardware_id bitmap */

#include <stdio.h>
#include <string.h>

#include "doscalls.h"
#include "hardware_id.h"
#include "dos_id.h"
#include "newdos80.h"

union dos_fcb fcb;

// Don't put big buffers on the stack
char buf[256];
char sbuf[80];
char filedata[202];

/* print_array ...
**   Dump a buffer to the printer device, in hex and ascii.
**
**   buf:       Start address of buffer
**   length:    Number of bytes to dump
**   position:  (ulong) Start address or number to prefix to each line.
*/

void print_array(const char *buf, int length, unsigned long position)
{
  int i = 0;
  const char *cp = buf;
  int out_pos = 0;  // offset into sbuf to append next substring
  int offset = 0;   // offset from beginning of buffer for this line

  dos_mess_pr("-----\r");
  for (offset = 0; offset < length; offset += 16) {
    int j;

    // Append the memory address and the offset in bytes
    out_pos += sprintf(sbuf + out_pos, "%04lx %02x:", position + offset, offset);

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

int main(void) {
  int rc;
  int i;

  dos_mess_do("Hello - Test hardware ID and DOS file read\r");
  int hardware_id = get_hardware_id();
  int dos_id = dos_get_id();
  sprintf(sbuf, "Hardware ID: 0x%x DOS ID: %d\r", hardware_id, dos_id);
  dos_mess_pr(sbuf);

  print_array((char *) &fcb, (sizeof fcb), (unsigned int) &fcb);

  rc = dos_file_extract("announce/txt", &fcb);
  if (rc) {
    sprintf(sbuf, "RC from dos_file_extract was %d\r", rc);
    dos_mess_pr(sbuf);
    dos_error(rc);
  }

  print_array((char *) &fcb, (sizeof fcb), (unsigned int) &fcb);

  // dos_error(dos_file_open_ex(&fcb, buf, 0));
  rc = dos_file_open_ex(&fcb, buf, 202);
  if (rc) {
    sprintf(sbuf, "RC from dos_file_open_ex was %d\r", rc);
    dos_mess_pr(sbuf);
    dos_error(rc);
  }

  long file_size = dos_file_eof(&fcb);
  sprintf(sbuf, "File size: %04lx bytes\r", file_size);
  dos_mess_pr(sbuf);

  dos_mess_pr("This is the FCB after opening the file:\r");
  print_array((char *) &fcb, (sizeof fcb), (unsigned int) &fcb);

  // Read from the file until EOF
  i = 0;
  while (!rc) {
    long file_next = dos_file_next(&fcb);
    sprintf(sbuf, "Loop %02x: Reading 202 bytes at %04lx\r", i, file_next);
    dos_mess_pr(sbuf);

    rc = dos_file_read(&fcb, filedata);
    print_array(filedata, 202, file_next);
    i++;

    if (i == 1) {
      dos_mess_pr("This is the FCB after reading the first record:\r");
      print_array((char *) &fcb, (sizeof fcb), (unsigned int) &fcb);
    }
  }

  // Error 0x1c is "END OF FILE ENCOUNTERED"
  long file_next = dos_file_next(&fcb);
  sprintf(sbuf, "Error %02x. Final file_next is %04lx\r", rc, file_next);
  dos_mess_pr(sbuf);
  if (rc != DOSERR_END_OF_FILE_ENCOUNTERED) {
    dos_mess_do("The error is:\r");
    dos_error(rc | 0x80);
  }

  rc = dos_file_close(&fcb);
  if (rc) {
    dos_mess_do("File close error:\r");
    dos_error(rc | 0x80);
  }

  dos_mess_pr("Here is the final FCB content:\r");
  print_array((char *) &fcb, (sizeof fcb), (unsigned int) &fcb);

  dos_exit();
  return 55;
}
