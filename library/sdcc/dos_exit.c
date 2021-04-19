void dos_exit(void) __naked {

  __asm

  jp 0x402d ; DOS_EXIT

  __endasm;
}
