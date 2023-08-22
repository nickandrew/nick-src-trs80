#include "doscalls.h"

// Delay 25 milliseconds times the value of 'count'.
// If count == 0, the function returns immediately
// This is a Newdos-80 specific function, as it relies on the memory
// address 0x4040 being updated by the 25msec interrupt handler.

void dos_delay25(unsigned int count) __naked __sdcccall(1)
{
	count;  // Avoid unreferenced function argument warning

	__asm
	// Parameters passed in HL
00001$:
	ld a,h              ; Return when count is zero
	or l
	ret z
	ld a,(0x4040)       ; Grab and save the current tick counter in 'b'
	ld b,a
00002$:
	ld a,(0x4040)
	cp a,b
	jr z,00002$         ; Loop until the tick counter changes each 25 msec
	dec hl
	jr 00001$

  __endasm;
}
