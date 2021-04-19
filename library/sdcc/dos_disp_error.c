void dos_disp_error(void) __naked {

  __asm

  jp 0x4030 ; DOS_DISP_ERROR

  __endasm;
}
