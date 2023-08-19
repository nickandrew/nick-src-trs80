/* hardware_id.h - Bitmap of the hardware/firmware in use
**
** Details of the hardware (Model 1, Model 3, etc) is figured out
** from ROM contents and other sources. It's stored as a 16 bit
** integer bitmap of capabilities.
*/

#ifndef _HARDWARE_ID_H_
#define _HARDWARE_ID_H_

#define HW_ID_MODEL_1         1
#define HW_ID_MODEL_3         2
#define HW_ID_MODEL_4         4
#define HW_ID_MODEL_4P        8  // Not sure if 4P is a variant or a different model (later)
// Next few bits are hardware variants
#define HW_ID_SYSTEM80       16  // System-80 Black label
#define HW_ID_SYSTEM80_BLUE  32  // System-80 Blue label (later)
#define HW_ID_DISK_WD1771    64  // WD1771 controller connected (later)
#define HW_ID_DISK_WD1791   128  // WD1791 double-density controller connected (later)
#define HW_ID_RS232         256  // TRS-80 RS-232 interface (later)
#define HW_ID_PORT_CASSETTE 512  // Port-mapped cassette I/O
#define HW_ID_PORT_PRINTER 1024  // Port-mapped printer I/O

extern int get_hardware_id(void);

#endif
