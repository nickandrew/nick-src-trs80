void dos_disp_error(void) __naked __sdcccall(0)
{

  __asm

  jp 0x4030 ; DOS_DISP_ERROR

  __endasm;
}
