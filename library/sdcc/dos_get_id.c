#include "dos_id.h"

enum dos_id dos_get_id(void) {
  char *const ldos_osver = (char *) 0x441f;
  char *const newdos80_v1_system_id = (char *) 0x403e;
  char *const newdos80_v2_system_id = (char *) 0x4427;
  char *const newdos80_v2_model_id = (char *) 0x442b;

  char c = *ldos_osver;
  char ci;

  if (c == 0x53) {
    return dos_ldos_5_3;
  }
  else if (c == 0x51) {
    return dos_ldos_5_1;
  }

  // Maybe a NEWDOS/80
  c = *newdos80_v2_system_id;
  ci = *newdos80_v2_model_id;
  if (c == 0x82) {
    if (ci == 1) {
      return dos_newdos80_v2_m1;
    }
    if (ci == 3) {
      return dos_newdos80_v2_m3;
    }
  }

  c = *newdos80_v1_system_id;
  if (c == 0x50 || c == 0x80) {
    return dos_newdos80_v1;
  }

  return dos_unknown;
}
