/* getchar.c
**
**  int getchar(void)
**
**  This implementation reads from the TRS-80 keyboard and blocks
**  until a key is hit.
**  The TRS-80 keyboard had these special keys:
**    arrows: up, down, left, right
**    break
**    clear
**  It lacked:
**    control key (^c on xtrs is returned as 'c')
**    esc key (xtrs returns 0x01 - this is treated as EOF)
*/

int getchar(void) __naked
{
  __asm

  call 0x0049
  ld de,#-1
  cp a,#0x01
  ret z
  ld e,a
  ld d,#0
  ret

  __endasm;
}
