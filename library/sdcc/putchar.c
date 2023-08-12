int putchar(int c) __naked
{
  c;    // Avoid unreferenced function argument warning

  __asm

  ld a,l
  call 0x0033
  ld  hl,#0   ; Success return
  ret

  __endasm;
}
