/*  putchar.c - Temporary implementation of putchar()
**
**  putchar(c) is equivalent to putc(c, stdout), however until stdout
**  exists, and it's possible to redirect it, implement putchar()
**  to display directly to the screen.
*/

#include <stdio.h>

// Addresses of the 8-bit device control blocks for display and printer
#define VDU_DCB 0x401d
#define PR_DCB  0x4025

int putchar(int c) __naked
{
  c;

  __asm

  ld   iy, #2   ; Skip over return address
  add  iy,sp
  ld   a,0(iy)  ; c low
  cp   #0x0a    ; change 0x0a to 0x0d
  jr   nz,001$
  ld   a,#0x0d
001$:
  ld   de,#0x4025 ; PR_DCB
  call 002$
  ld   hl,#0
  ret

; Avoid calling 001b directly, so it can be used as a breakpoint
002$:
  push  bc
  ld    b,#2
  jp    0x0046

  __endasm;
}
