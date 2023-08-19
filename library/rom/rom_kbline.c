/* rom_kbline.c - ROM call 0040h (KBLINE)
*/

#include <rom.h>

/* rom_kbline ...
**  Read a line of text of maximum length 'length-1' into 'buf'.
**  Text is echoed to the screen. Backspaces erase.
**  The line is terminated by 0x0d when the ROM call returns,
**  but this is overwritten with NUL.
**  Returns -1 if BREAK was hit. Otherwise,
**  returns the number of characters in 'buf'.
*/

int rom_kbline(char *buf, int length) __naked
{
  buf;
  length;

  __asm
        ; HL contains buf; DE contains length
        ld      b,e
        ld      a,b
        cp      #2
        jr      c,00100$      ; length < 2 makes no sense
        dec     b             ; Allow 1 byte for 0x00 after text
        call    0x0040        ; ROM_KBLINE
        ; B contains the number of characters entered
        jr      c,00100$
        ld      e, b
        ld      d, #0
        add     hl,de
        ld      (hl), #0      ; Terminate the resulting string
        ; DE contains the number of characters entered
        ret
00100$:
        ; BREAK was hit or length < 2
        ld      de, #-1
        ret

  __endasm;
}
