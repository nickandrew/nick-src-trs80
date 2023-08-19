#include "doscalls.h"

void dos_command(const char *s) __naked __sdcccall(0)
{
  s;    // Avoid unreferenced function argument warning

  __asm

  ld iy,#2
  add iy,sp
  ld l,0(iy)  ; s low
  ld h,1(iy)  ; s high
  jp 0x4299 ; LDOS Model 3
  jp 0x4405 ; Newdos/80

  __endasm;
}
