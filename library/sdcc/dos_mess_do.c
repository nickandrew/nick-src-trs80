#include "doscalls.h"

void dos_mess_do(const char *s) __naked {
  s;    // Avoid unreferenced function argument warning

  __asm

  ld iy,#2
  add iy,sp
  ld l,0(iy)  ; s low
  ld h,1(iy)  ; s high
  push ix
  call 0x4467    ; MESS_DO
  pop ix
  ret

  __endasm;
}
