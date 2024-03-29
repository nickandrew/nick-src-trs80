; vim:ts=8:sw=8:noexpandtab:
;--------------------------------------------------------------------------
;  Original source:
;    crt0.s - Generic crt0.s for a Z80
;    Copyright (C) 2000, Michael Hope
;--------------------------------------------------------------------------

	.module crt0
	.globl  _argparse
	.globl  _main
	.globl  l__INITIALIZER
	.globl  s__INITIALIZED
	.globl  s__INITIALIZER
	.globl  s__FREE
	.globl  l__DATA
	.globl  s__DATA

	.area   _CODE

init:

	; Parse command line arguments (start address passed in BC)
	; Implement I/O redirection in command line

	;; Zero memory used by static and global variables
	call    clear_data
	;; Initialise global variables
	call	gsinit
	ld      hl, #0x4318   ; Model-I command buffer
	ld      de, #p_argc
	call    _argparse
	; argv(DE) = argparse(char *buf, int *p_argc)
	ld      hl, (p_argc)
	call    _main
	; unused(DE) = main(argc, argv)
	jp	_exit

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER
	.area   _GSINIT
	.area   _GSFINAL
	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _BRKADDR
	.area   _HEAP
	.area	_FREE

	.area   _CODE
; Zero the entire data area.
clear_data:
	ld      bc, #l__DATA
	ld      a, b
	or      c
	ret     z             ; Return if the data area is empty
	ld      hl, #s__DATA

	ld      (hl), #0       ; Set a zero byte at the start of the data area
	push    hl
	pop     de
	inc     de
	dec     bc
	ld      a, b
	or      c
	ret     z             ; Return if the data area is 1 byte long
	ldir              ; Replicate zero byte through the data area
	ret


_exit::
	jp      0x402d  ; DOS no-error exit

	.area   _GSINIT
gsinit::
	ld	bc, #l__INITIALIZER
	ld	a, b
	or	a, c
	jr	Z, gsinit_next
	ld	de, #s__INITIALIZED
	ld	hl, #s__INITIALIZER
	ldir
gsinit_next:

	.area   _GSFINAL
	ret

	.area _DATA
	; argc computed by _argparse()
p_argc:
	.dw   0

	.area   _BRKADDR
; First address of freespace, used by brk()
_brkaddr::
	.dw     #s__FREE
