/*  dos_id.h - Identification of running DOS version
**
**  Use the dos_id to cope with hardware and software specific
**  differences.
*/

enum dos_id {
  dos_unknown,
  dos_newdos80_v2_m1,
  dos_newdos80_v2_m3,
  dos_ldos_5_1,
  dos_ldos_5_3,
  dos_newdos80_v1,
  dos_ldos_6,      // Looks like an incompatible memory map; user code can start at 0x3000
};

extern enum dos_id dos_get_id(void);
