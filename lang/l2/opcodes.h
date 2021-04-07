/*       Languages & Processors
**
**       opcodes.h - L2 opcodes
**
**       Nick Andrew, 8425464       (zeta@amdahl)
**
*/

#define STOP              -17
#define CRASH             -18
#define READ              -19
#define WRITE             -20 /* Write newline to stdout */
#define WS                -21 /* Write String from strtabl + (pop) to stdout */
#define WN                -22 /* Write integer from (pop) to stdout */
#define GIF               -23 /* Jump to (pop) if (pop) is non-zero */
#define GO                -24 /* Jump to (pop) unconditionally */
#define ISP               -25 /* Increment stack pointer */
#define CALL              -26
#define ISB               -27
#define RS                -28
#define RN                -29
#define START             -30
