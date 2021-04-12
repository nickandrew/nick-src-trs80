;--------------------------------------------------------------------------
;  Original source:
;    crt0.s - Generic crt0.s for a Z80
;    Copyright (C) 2000, Michael Hope
;--------------------------------------------------------------------------

	.module crt0
	.globl	_main
  .globl  l__INITIALIZER
  .globl  s__INITIALIZED
  .globl  s__INITIALIZER

  .area _CODE

init:
  ; Parse command line arguments (start address passed in BC)
  ; Implement I/O redirection in command line

	;; Initialise global variables
	call	gsinit
	call	_main
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
	.area   _HEAP

	.area   _CODE

_exit::
	jp 0x402d  ; DOS no-error exit

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
