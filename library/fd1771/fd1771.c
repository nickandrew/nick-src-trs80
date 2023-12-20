/* Interface to Trs-80 FD1771 Floppy Disk Controller
**
*/

#include "fd1771.h"

// Execute a tight 16-bit DJNZ loop
void fd1771_delay(unsigned int delay) __naked __sdcccall(1)
{
	delay;  // Avoid unreferenced function argument warning

	__asm
	// Parameters passed in HL
	ld b,l         ; Low order delay value
00001$:
	djnz 00001$
	ld a,h
	or a
	ret z
	dec h
	jr 00001$       ; Loop around another 256x

	__endasm;
}

// Read current sector register
char fd1771_get_sector(void) __naked __sdcccall(1)
{
	__asm
	ld a,(0x37ee)   ; Read the sector register
	ret

	__endasm;
}

// Read current status register
char fd1771_get_status(void) __naked __sdcccall(1)
{
	__asm
	ld a,(0x37ec)   ; Read the status register
	ret

	__endasm;
}

// Read current track register
char fd1771_get_track(void) __naked __sdcccall(1)
{
	__asm
	ld a,(0x37ed)   ; Read the track register
	ret

	__endasm;
}

// Read one or more sectors from the diskette.
// Track and sector numbers need to be set in the corresponding registers in advance.
// Return the first unused buffer address.
char *fd1771_read(char flags, char *buf) __naked __sdcccall(1)
{
	flags;  // Avoid unreferenced function argument warning
	buf;  // Avoid unreferenced function argument warning

	__asm
	// flags: A, buf: DE
	and a,#0x1f     ; Retain only flags bits.
	or a,#0x80      ; It is now a Read command
	ld (0x37ec),a
00001$:
	ld a,(0x37ec)
	bit 0,a
	ret z           ; Controller is no longer busy; return DE
	bit 1,a
	jr z,00001$     ; Loop until a byte is ready
	ld a,(0x37ef)   ; Read data register
	ld (de),a       ; Save data in buffer
	inc de
	jr 00001$

	__endasm;
}

// Write one sector to the diskette.
// Track and sector numbers need to be set in the corresponding registers in advance.
// Return the first unwritten buffer address.
// Typical value for flags is 0x10
char *fd1771_write(char flags, const char *buf) __naked __sdcccall(1)
{
	flags;  // Avoid unreferenced function argument warning
	buf;  // Avoid unreferenced function argument warning

	__asm
	// flags: A, buf: DE
	and a,#0x1f     ; Retain only flags bits.
	or a,#0xa0      ; It is now a Write command
	ld (0x37ec),a
00001$:
	ld a,(0x37ec)
	bit 0,a
	ret z           ; Controller is no longer busy; return DE
	bit 1,a
	jr z,00001$     ; Loop until a byte is ready
	ld a,(de)       ; Read next byte from buffer
	ld (0x37ef),a   ; Write data register
	inc de
	jr 00001$

	__endasm;
}

char fd1771_read_address(struct fd1771_id_buf *buf) __naked __sdcccall(1)
{
	buf;  // Avoid unreferenced function argument warning

	__asm
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ld a,#255       ; Fake status for debugging
	ret nz          ; Return early with status in A if controller is busy
	ld a,#0xc4      ; Read Address command
	ld (0x37ec),a
	ld b,#6
00001$:
	ld a,(0x37ec)
	bit 0,a
	ret z           ; Controller is no longer busy; return status
	bit 1,a
	jr z,00001$     ; Loop until a byte is ready
	ld a,(0x37ef)   ; Read data register
	ld (hl),a
	inc hl
	djnz 00001$     ; Loop to read all 6 bytes
00002$:
	ld a,(0x37ec)
	bit 0,a
	jr nz,00002$    ; Loop until controller is no longer busy
	ret

	__endasm;
}

// Read current status byte
char fd1771_read_status(void) __naked __sdcccall(1)
{
	__asm
	ld a,(0x37ec)   ; Read the status register
	ret

	__endasm;
}

char fd1771_restore(char flags) __naked __sdcccall(1)
{
	flags;  // Avoid unreferenced function argument warning

	__asm

	and a,#0x0f     ; Retain only flags bits. It is now a restore command
	ld b,a
00001$:
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	jr nz,00001$    ; Wait until controller is not busy
	ld a,b
	ld (0x37ec),a
00002$:
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ret z
	jr 00002$       ; Loop until controller is non-busy

	__endasm;
}

void fd1771_select(char selector) __naked __sdcccall(1)
{
	selector;  // Avoid unreferenced function argument warning

	__asm
	ld (0x37e1),a
	ret
	__endasm;
}

// Set the (assumed) PERCOM doubler to double density
void fd1771_set_double_density(void) __naked {
	__asm

	ld a,#0xff      ; Switching density enables a different chip
	ld (0x37ec),a   ; so reset its state with a Force Interrupt
	ld a,#0xd0      ; Issue a Force Interrupt (no intrq)
	ld (0x37ec),a
	ret

	__endasm;
}

// Set current sector register
void fd1771_set_sector(char sector) __naked __sdcccall(1)
{
	sector;  // Avoid unreferenced function argument warning

	__asm
	ld (0x37ee),a   ; Set the sector register
	ret

	__endasm;
}

// Set the (assumed) PERCOM doubler to single density
void fd1771_set_single_density(void) __naked {
	__asm

	ld a,#0xfe        ; Switching density enables a different chip
	ld (0x37ec),a     ; so reset its state with a Force Interrupt
	ld a,#0xd0        ; Issue a Force Interrupt (no intrq)
	ld (0x37ec),a
	ret

	__endasm;
}

// Set current track register
void fd1771_set_track(char track) __naked __sdcccall(1)
{
	track;  // Avoid unreferenced function argument warning

	__asm
	ld (0x37ed),a   ; Set the track register
	ret

	__endasm;
}

// Step one track in the same direction as last step
char fd1771_step(char flags) __naked __sdcccall(1)
{
	flags;  // Avoid unreferenced function argument warning

	__asm
	and a,#0x1f     ; Retain only flags bits.
	or a,#0x20      ; It is now a Step command
	ld b,a
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ld a,#255       ; Fake status for debugging
	ret nz          ; Return early with status in A if controller is busy
	ld a,b
	ld (0x37ec),a
00001$:
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ret z
	jr 00001$       ; Loop until controller is non-busy
	__endasm;
}

char fd1771_step_in(char flags) __naked __sdcccall(1)
{
	flags;  // Avoid unreferenced function argument warning

	__asm
	and a,#0x1f     ; Retain only flags bits.
	or a,#0x40      ; It is now a Step In command
	ld b,a
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ld a,#255       ; Fake status for debugging
	ret nz          ; Return early with status in A if controller is busy
	ld a,b
	ld (0x37ec),a
00001$:
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ret z
	jr 00001$       ; Loop until controller is non-busy
	__endasm;
}

char fd1771_step_out(char flags) __naked __sdcccall(1)
{
	flags;  // Avoid unreferenced function argument warning

	__asm
	and a,#0x1f     ; Retain only flags bits.
	or a,#0x60      ; It is now a Step Out command
	ld b,a
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ld a,#255       ; Fake status for debugging
	ret nz          ; Return early with status in A if controller is busy
	ld a,b
	ld (0x37ec),a
00001$:
	ld a,(0x37ec)   ; Read the status register
	bit 0,a
	ret z
	jr 00001$       ; Loop until controller is non-busy
	__endasm;
}
