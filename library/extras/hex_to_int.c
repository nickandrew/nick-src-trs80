/* hex_to_int.c - Convert a hex number to an integer */

#include <extras.h>

/*  int hex_to_int(const char *str, unsigned int *ptr) ...
**
**  Convert the hex string in 'str' to an integer, and store it
**  in the address 'ptr'.
**
**  Any leading spaces in the hex string are skipped, as is any
**  leading '0x' or '0X'.
**
**  Up to 4 hex digits are read. Conversion stops after any non-hex
**  digit.
**
**  Returns 0 if a hex number was successfully converted, else -1.
*/

int hex_to_int(const char *str, unsigned int *ptr)
{
  unsigned int result = 0;
  int length = 0;
  char c;

  // Skip any leading spaces (not whitespace)
  while (*str && *str == ' ') {
    str++;
  }

  // Skip any leading 0x
  if (*str == '0' && (str[1] == 'x' || str[1] == 'X')) {
    str += 2;
  }

  while ((c = *str)) {
    if (c >= '0' && c <= '9') {
      result = (result << 4) + (c - '0');
    }
    else if (c >= 'A' && c <= 'F') {
      result = (result << 4) + (c - 55);
    }
    else if (c >= 'a' && c <= 'f') {
      result = (result << 4) + (c - 87);
    }
    else {
      break;
    }
    str++;
    length++;
  }

  if (length < 1 || length > 4) {
    // Invalid string, too long, possible overflow
    return -1;
  }

  *ptr = result;

  return 0;
}
