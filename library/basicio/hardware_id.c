/* hardware_id.c - Bitmap of the hardware/firmware in use
**
** Details of the hardware (Model 1, Model 3, etc) is figured out
** from ROM contents and other sources. It's stored as a 16 bit
** integer bitmap of capabilities.
*/

#include "hardware_id.h"

static unsigned int hardware_id;

int get_hardware_id(void) {
  char *model4_rst = (char *) 0x000a;
  char *rom_string = (char *) 0x0125;

  int id = 0;

  if (*model4_rst != 0x40) {
    id |= HW_ID_MODEL_4;
    hardware_id = id;
    return hardware_id;
  }

  char c = *rom_string;

  if (c == 0x0d) {
    // System-80 (Model 1 + System80)
    id |= HW_ID_MODEL_1 | HW_ID_SYSTEM80 | HW_ID_PORT_CASSETTE | HW_ID_PORT_PRINTER;
  }
  else if (c == 'I') {
    // Model 3
    id |= HW_ID_MODEL_3;
  }
  else {
    // Model 1
    id |= HW_ID_MODEL_1;
  }

  hardware_id = id;
  return hardware_id;
}
