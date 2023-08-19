#include "doscalls.h"

void dos_mess_pr(const char *s) __naked __sdcccall(0)
{
  s;    // Avoid unreferenced function argument warning

  __asm

  ld iy,#2
  add iy,sp
  ld l,0(iy)  ; s low
  ld h,1(iy)  ; s high
  push ix
  call 0x446a    ; MESS_PR
  pop ix
  ret

  __endasm;
}
